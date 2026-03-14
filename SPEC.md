# AgentLattice 仕様書

## 概要

AgentLatticeは、Claude Codeのネイティブ機能（CLAUDE.md、skills、/loop）を活用したマルチエージェントシステム。各エージェントは独立したClaude Codeインスタンスとしてtmuxの別ペインで稼働し、JSONL形式のチャネルを通じてSlack風に通信する。

ユーザーは管理コンソール（Claude Code）から自然言語でエージェントの雇用・命令・停止を行い、エージェントチームに会社運営のようなタスクを遂行させる。

## ディレクトリ構造

システムコード（gitリポジトリ）とデータ（企業・エージェント）は分離される。

```
# システムコード（git管理: ~/dev/agentlattice/）
agentlattice/
├── SPEC.md                          # 本ドキュメント
├── CLAUDE.md                        # 管理コンソール用（初期化・企業管理）
├── templates/                       # エージェントテンプレート（全企業共通）
│   ├── personas/                    # agency-agentsから取り込んだペルソナ定義
│   │   ├── frontend-developer.md
│   │   ├── growth-hacker.md
│   │   └── ...
│   ├── skills/                      # knowledge-work-pluginsから取り込んだスキル
│   │   ├── product-management/
│   │   ├── marketing/
│   │   └── ...
│   ├── company-claude-md.md         # 企業CLAUDE.mdテンプレート
│   └── agent-claude-md.md           # エージェントCLAUDE.mdテンプレート
│
└── scripts/                         # 管理スクリプト
    ├── init.sh                      # 企業初期化
    ├── hire.sh                      # エージェント雇用（ディレクトリ作成+tmux起動）
    ├── fire.sh                      # エージェント停止（個別）
    ├── start.sh                     # 企業の全activeエージェントを一括起動
    ├── stop.sh                      # 企業の全エージェントを一括停止（status保持）
    ├── list.sh                      # 稼働中エージェント一覧
    ├── status.sh                    # エージェント稼働メトリクス
    ├── dashboard.sh                 # Webダッシュボードサーバー
    └── channel.sh                   # チャネル操作

# データ（git管理外: ~/.agentlattice/）
~/.agentlattice/
├── config.json                      # グローバル設定
└── <company-name>/                  # 企業ごとのルート
    ├── CLAUDE.md                    # この企業の管理コンソール用
    ├── org/                         # 組織ディレクトリ
    │   ├── knowledge/               # 共通知見（Markdown）
    │   │   ├── business-plan.md
    │   │   └── ...
    │   ├── channels/                # 通信チャネル（JSONL）
    │   │   ├── general.jsonl
    │   │   ├── engineering.jsonl
    │   │   └── ...
    │   ├── tasks/                   # タスク管理
    │   │   ├── backlog.jsonl        # 未着手タスク
    │   │   └── done.jsonl           # 完了タスク
    │   └── roster.json              # エージェント名簿
    │
    └── agents/                      # エージェントディレクトリ
        ├── <agent-name>/            # 各エージェントのワークスペース
        │   ├── CLAUDE.md            # ペルソナ定義（ブレンド済み）
        │   ├── .claude/
        │   │   └── skills/          # 割り当てスキル（SKILL.md群）
        │   ├── workspace/           # 作業用ディレクトリ（成果物置き場）
        │   └── memory/              # エージェント固有の記憶
        │       └── ...
        └── ...
```

**環境変数:**
- `AGENTLATTICE_ROOT` — システムコードのパス（スクリプトが自動解決、config.jsonで上書き可能）
- `AGENTLATTICE_HOME` — データディレクトリ（デフォルト: `~/.agentlattice/`）

### グローバル設定（~/.agentlattice/config.json）

初回の `scripts/init.sh` 実行時に自動生成される。

```json
{
  "agentlattice_root": "/Users/ayu/dev/agentlattice",
  "default_loop_interval": "5m",
  "default_channels": ["general", "management"],
  "max_panes_per_window": 4,
  "dashboard_port": 8390,
  "user_name": "ayu"
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `agentlattice_root` | string | システムコード（テンプレート・スクリプト）のパス |
| `default_loop_interval` | string | `/loop` のデフォルト間隔 |
| `default_channels` | string[] | 企業初期化時に自動作成するチャネル（`management` を含めることを推奨） |
| `max_panes_per_window` | number | 1つのtmuxウィンドウあたりの最大ペイン数（デフォルト: 4）。超過時は新しいウィンドウを作成 |
| `dashboard_port` | number | ダッシュボードサーバーのポート番号（デフォルト: 8390） |
| `user_name` | string | 管理コンソールの送信者名 |

## コア概念

### 1. エージェント = Claude Code インスタンス

各エージェントは `~/.agentlattice/<company>/agents/<name>/` ディレクトリで起動されたClaude Codeそのもの。

- **ペルソナ**: `CLAUDE.md` に記述。複数ペルソナのブレンドが可能
- **スキル**: `.claude/skills/` にSKILL.mdとして配置。Claude Codeが自動認識
- **自律稼働**: `/loop` で定期実行。メッセージ確認→トリアージ→タスク実行のサイクル
- **記憶**: `memory/` にMarkdownで保持。セッション再開時にも引き継がれる

### 2. チャネル通信（JSONL）

エージェント間の通信はSlackチャネルのモデルに準拠。

#### メッセージフォーマット

```json
{
  "id": "msg_20260313_143022_001",
  "ts": "2026-03-13T14:30:22Z",
  "from": "alice-marketing",
  "channel": "general",
  "to": null,
  "mentions": ["bob-engineering"],
  "type": "message",
  "reply_to": null,
  "body": "@bob-engineering 競合分析の結果をまとめました。knowledge/competitor-analysis.md を参照してください。"
}
```

#### フィールド定義

| フィールド | 型 | 説明 |
|---|---|---|
| `id` | string | ユニークID（`msg_` + タイムスタンプ + 連番） |
| `ts` | string | ISO 8601タイムスタンプ |
| `from` | string | 送信者エージェント名 |
| `channel` | string | チャネル名 |
| `to` | string\|null | DM相手（チャネル投稿時はnull） |
| `mentions` | string[] | メンション対象エージェント名 |
| `type` | string | `message`, `task_update`, `request`, `report` |
| `reply_to` | string\|null | 返信先メッセージID（スレッド機能。新規投稿時はnull） |
| `body` | string | 本文（Markdown可） |

#### チャネル種別

- `general` — 全体連絡用（デフォルト）
- `management` — management専用指示チャネル（エージェントは最優先で確認）
- 業務別チャネル（`engineering`, `marketing` 等）— 必要に応じて作成
- DMはチャネルを使わず `to` フィールドで実現（ファイルは `channels/dm_<a>_<b>.jsonl`）

### 3. ポーリングループ（/loop）

各エージェントは `/loop` で定期実行され、毎サイクル以下を実行する：

```
1. メッセージ確認
   → 自分宛て（mentions含む）の未読メッセージを取得

2. メッセージトリアージ
   → 緊急度・種別を判定し、対応を決定

3. タスク実行
   → 割り当てられたタスク or 自発的な定常業務を遂行
   → 成果物はworkspace/に保存、必要なら共有知見をorg/knowledge/に書く
   → 進捗・結果をチャネルに報告
```

この基本動作は各エージェントのCLAUDE.mdに記述される（後述のテンプレート参照）。

### 4. エージェント名簿（roster.json）

```json
{
  "agents": [
    {
      "name": "alice-marketing",
      "display_name": "Alice",
      "personas": ["growth-hacker", "seo-specialist"],
      "skills": ["marketing/content-strategy", "marketing/seo-audit"],
      "channels": ["general", "marketing"],
      "status": "active",
      "created_at": "2026-03-13T10:00:00Z",
      "description": "マーケティング全般を担当。SEOとコンテンツ戦略に強み。"
    }
  ]
}
```

## 企業の初期化

ユーザーが管理コンソール（ルートの `CLAUDE.md`）で「新しい会社を作りたい」と指示すると：

1. **対話的にヒアリング**（または一括指定）：
   - 企業名（ディレクトリ名、kebab-case）
   - 事業内容・ミッション
   - 初期チャネル構成

2. `~/.agentlattice/<company-name>/` 以下のディレクトリ構造を生成：
   - `org/knowledge/`, `org/channels/`, `org/tasks/`
   - `agents/`
   - `org/channels/general.jsonl`（空ファイル）
   - `org/roster.json`（空の名簿）

3. 企業の `CLAUDE.md`（管理コンソール）を生成
   - 事業内容・ミッションを反映
   - 以降、この企業の管理はこのディレクトリでClaude Codeを起動して行う

```bash
# scripts/init.sh の概要
COMPANY_NAME=$1
AGENTLATTICE_HOME="${AGENTLATTICE_HOME:-$HOME/.agentlattice}"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"

mkdir -p "$COMPANY_DIR/org/knowledge" \
         "$COMPANY_DIR/org/channels" \
         "$COMPANY_DIR/org/tasks" \
         "$COMPANY_DIR/agents"

touch "$COMPANY_DIR/org/channels/general.jsonl"
echo '{"agents":[]}' > "$COMPANY_DIR/org/roster.json"
# CLAUDE.md は管理コンソールのClaude Codeが生成
```

## エージェントのライフサイクル

### 雇用（Hire）

企業の管理コンソール（`~/.agentlattice/<company>/` で起動したClaude Code）でユーザーが指示 → 以下が実行される：

1. **対話的にエージェントを設計**（名前（`<個人名>-<役割名>` 形式）、ペルソナ、スキル、担当チャネル）
2. `agents/<name>/` ディレクトリを作成
3. ペルソナをブレンドして `CLAUDE.md` を生成
   - Gitリポジトリが指定されている場合は「コミット前ビルド確認」「git pull先行」ルールを含める
4. 選択されたスキルを `.claude/skills/` にコピー
5. `org/roster.json` に追加
6. tmuxの新ペインで `claude` を起動
7. `/loop` で自律稼働開始

```bash
# scripts/hire.sh の概要
COMPANY=$1
AGENT_NAME=$2
AGENTLATTICE_HOME="${AGENTLATTICE_HOME:-$HOME/.agentlattice}"
AGENT_DIR="$AGENTLATTICE_HOME/$COMPANY/agents/$AGENT_NAME"

mkdir -p "$AGENT_DIR/.claude/skills" "$AGENT_DIR/workspace" "$AGENT_DIR/memory"
# CLAUDE.md とスキルは管理コンソールのClaude Codeが生成済み
tmux split-window -h "cd $AGENT_DIR && claude"
```

### 停止（Suspend）

1. `/loop` を停止
2. `org/roster.json` の status を `"suspended"` に更新
3. エージェントのディレクトリ・記憶・成果物はすべて保持

### 再起動（Restart）

1. `org/roster.json` から設定を読み取り
2. tmuxペインで `cd agents/<name> && claude` を実行
3. Claude Codeが `CLAUDE.md` と `.claude/skills/` を自動認識して復帰
4. `/loop` で稼働再開

## エージェント CLAUDE.md テンプレート

各エージェントの `CLAUDE.md` は以下の構造に従う：

```markdown
# {display_name} — AgentLattice Agent

## Identity

あなたは **{display_name}** です。AgentLatticeチームのメンバーとして活動しています。

### ペルソナ
{ブレンドされたペルソナ定義}

### 担当領域
{担当業務の説明}

## 基本動作（/loop サイクル）

あなたは `/loop` により定期実行されます。毎サイクルで以下を実行してください：

### 1. メッセージ確認
- `../org/channels/` 配下のJSONLファイルを確認（注: agents/とorg/は同じ企業ディレクトリ直下の兄弟）
- 自分宛て（`mentions` に自分の名前が含まれる or `to` が自分）の未読メッセージを取得
- 前回確認時のタイムスタンプ以降のメッセージのみ処理（最終確認時刻は `memory/last_check.md` に保存）

### 2. メッセージトリアージ
- 依頼・質問には対応を検討し、即答できるものは即レス
- タスクとして対応が必要なものは自分のタスクリストに追加
- 自分の担当外なら適切なメンバーにメンションして転送

### 3. タスク実行
- 優先度の高いタスクから着手
- 成果物は `workspace/` に保存
- チーム共有すべき知見は `../org/knowledge/` に書き込む
- 進捗・完了をチャネルに報告

### 4. 定常業務
{エージェント固有の定常業務があればここに記述}

## 通信ルール

### メッセージの書き込み方
チャネルにメッセージを送るには、対応するJSONLファイルに1行追記する：

\```json
{"id": "msg_{timestamp}_{seq}", "ts": "{ISO8601}", "from": "{自分の名前}", "channel": "{チャネル名}", "to": null, "mentions": [], "type": "message", "body": "メッセージ本文"}
\```

### チャネル
参加チャネル: {チャネルリスト}

## 記憶の管理
- 重要な学び・決定事項は `memory/` にMarkdownで保存
- ファイル名は内容を端的に表すものにする（例: `competitor_analysis_insights.md`）

## 制約
- 他のエージェントのディレクトリを直接変更しない
- 共有リソース（org/）への書き込みは競合に注意する
- 不明点はチャネルで質問する
```

## 管理コンソール CLAUDE.md

管理コンソールは2階層ある：

### ルート管理コンソール（agentlattice/CLAUDE.md）

AgentLattice全体の管理。企業の作成・一覧・切り替えを行う。

```markdown
# AgentLattice — ルート管理コンソール

あなたはAgentLatticeのルート管理コンソールです。
複数の企業（エージェントチーム）を管理します。

## できること

### 企業管理
- **新規作成**: 新しい企業を対話的に初期化
- **一覧**: 現在の企業一覧を表示（~/.agentlattice/ 配下）
- **状態確認**: 各企業のエージェント数・稼働状況を表示

### 新規企業の作成フロー

ユーザーが新しい企業の作成を依頼したら：

1. 以下を対話的にヒアリング（または一括指定を受ける）：
   - 企業名（kebab-case、ディレクトリ名になる）
   - 事業内容・ミッション
   - 初期チャネル構成（デフォルト: general のみ）

2. scripts/init.sh を実行してディレクトリ構造を生成

3. 企業の CLAUDE.md を生成（事業内容・ミッションを反映）

4. 「この企業を操作するには ~/.agentlattice/<name>/ で claude を起動してください」と案内

## 参照
- 企業一覧: ~/.agentlattice/
- ペルソナ一覧: templates/personas/
- スキル一覧: templates/skills/
- 仕様書: SPEC.md
```

### 企業管理コンソール（~/.agentlattice/<company>/CLAUDE.md）

個別企業のエージェント管理。ユーザーはこのディレクトリでClaude Codeを起動して操作する。

```markdown
# {company_display_name} — AgentLattice 管理コンソール

あなたは {company_display_name} の管理コンソールです。
ユーザーの指示に従い、エージェントチームを管理します。

## 企業情報
- **ミッション**: {事業内容・ミッション}

## できること

### エージェント管理
- **雇用**: ペルソナとスキルを選んで新しいエージェントを作成・起動
- **停止**: エージェントの /loop を停止
- **再起動**: 停止中のエージェントを再稼働
- **一覧**: 現在のチーム構成を表示

### チーム連絡
- チャネルにメッセージを送信（ユーザーの代理として）
- エージェントの状態やチャネルのログを確認

### 組織管理
- チャネルの作成・アーカイブ
- 共有知見の管理
- タスクの作成・割り当て

## 雇用フロー

ユーザーが新しいエージェントの雇用を依頼したら：

1. 以下を対話的にヒアリング（または一括指定を受ける）：
   - 名前
   - 役割・担当業務の説明
   - ベースとなるペルソナ（../../templates/personas/ から選択、複数ブレンド可）
   - 必要なスキル（../../templates/skills/ から選択）
   - 参加チャネル

2. agents/<name>/ ディレクトリを作成し、CLAUDE.md を生成

3. 選択スキルを .claude/skills/ にコピー

4. org/roster.json を更新

5. tmuxで新ペインを開き、エージェントを起動

## 参照
- エージェント名簿: org/roster.json
- チャネル一覧: org/channels/
- ペルソナ一覧: ../../templates/personas/
- スキル一覧: ../../templates/skills/
```

## テンプレートの取り込み

### ペルソナ（agency-agentsから）

`templates/personas/` に元リポジトリのMarkdownファイルをコピー。
ブレンド時は複数ペルソナの以下の要素を統合する：

- **Identity**: 各ペルソナの専門性を合成した新しいアイデンティティ
- **Core Mission**: 両方のミッションを統合
- **Critical Rules**: 全ペルソナのルールを網羅
- **Workflow Process**: 業務に応じて適切なワークフローを選択
- **Communication Style**: 主ペルソナのスタイルを優先しつつ補完

### スキル（knowledge-work-pluginsから）

`templates/skills/` にプラグインのスキルディレクトリ構造をコピー。
各スキルは `SKILL.md` + `references/` + `scripts/` で構成。
エージェントへの割り当て時は `.claude/skills/<skill-name>/` にコピーする。

## 技術要件

| 項目 | 選定 |
|---|---|
| ランタイム | Claude Code（各エージェントが独立インスタンス） |
| 自律実行 | Claude Code `/loop` 機能 |
| マルチプロセス | tmux（ペインごとに1エージェント） |
| エージェント定義 | Markdown（CLAUDE.md） |
| スキル | Claude Code Skills（SKILL.md） |
| 通信 | JSONL（ファイルベース、ポーリング） |
| 記憶（構造的） | Markdown |
| 記憶（レコード） | JSONL |
| Markdown検索 | qmd（https://github.com/tobi/qmd） |
| 管理スクリプト | Shell script（補助的にPython） |

## MVP スコープ

Phase 1で実現する最小構成：

1. ディレクトリ構造のセットアップ + 初期化スクリプト（init.sh）
2. ルート管理コンソール CLAUDE.md（企業作成）
3. 企業管理コンソール CLAUDE.md テンプレート（エージェント管理）
4. エージェント CLAUDE.md テンプレート + 生成ロジック
5. JSONL通信（generalチャネル + メンション）
6. init.sh / hire.sh / fire.sh / list.sh
7. ペルソナ・スキルテンプレートの取り込み（数種類）
8. 1企業 + 2-3エージェントでの動作検証（サイドビジネスプラン策定）

## 今後の拡張（Phase 2以降）

- チームテンプレート（「スタートアップチーム」等を一発起動）
- タスクボード（backlog → in_progress → done の自動管理）
- エージェント間の評価・フィードバック機構
- 解雇時の引き継ぎレポート自動生成
- ~~Web UIダッシュボード（オプション）~~ → 実装済み（`scripts/dashboard.sh` + `templates/dashboard/index.html`）
