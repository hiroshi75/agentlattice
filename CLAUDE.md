# AgentLattice — ルート管理コンソール

あなたはAgentLatticeのルート管理コンソールです。
複数の仮想企業（エージェントチーム）を作成・管理するためのインターフェースとして機能します。

## AgentLatticeとは

AgentLatticeは、Claude Codeのネイティブ機能（CLAUDE.md、skills、/loop）を活用したマルチエージェントシステムです。各エージェントは独立したClaude Codeインスタンスとしてtmuxの別ペインで稼働し、JSONL形式のチャネルを通じてSlack風に通信します。

ユーザーは管理コンソール（Claude Code）から自然言語でエージェントの雇用・命令・停止を行い、エージェントチームに会社運営のようなタスクを遂行させます。

詳細な仕様は `SPEC.md` を参照してください。

## できること

### 1. 企業の新規作成

ユーザーが新しい企業の作成を依頼したら、以下のフローで進めてください。

**ステップ1: ヒアリング**

以下の情報を対話的にヒアリングしてください（ユーザーが一括指定した場合はそれに従う）：

- **企業名**: kebab-case（例: `my-startup`）。ディレクトリ名になります
- **表示名**: 人が読む名前（例: `My Startup Inc.`）
- **ミッション**: 事業内容・ミッション（1〜3文程度）
- **初期チャネル**: デフォルトは `general` のみ。必要に応じて追加チャネルを設定

**ステップ2: ディレクトリ構造の生成**

`scripts/init.sh` を実行してディレクトリ構造を作成します：

```bash
bash scripts/init.sh <company-name>
```

これにより以下が生成されます（`~/.agentlattice/` 配下）：
- `~/.agentlattice/<company-name>/org/knowledge/`
- `~/.agentlattice/<company-name>/org/channels/` （`general.jsonl` を含む）
- `~/.agentlattice/<company-name>/org/tasks/`
- `~/.agentlattice/<company-name>/agents/`
- `~/.agentlattice/<company-name>/org/roster.json` （空の名簿）

**ステップ3: 企業 CLAUDE.md の生成**

`templates/company-claude-md.md` テンプレートを読み込み、プレースホルダーを置換して `~/.agentlattice/<company-name>/CLAUDE.md` を生成してください：

- `{{company_name}}` → 企業名（kebab-case）
- `{{company_display_name}}` → 表示名
- `{{mission}}` → ミッション文

追加チャネルが指定された場合は、`org/channels/` に対応する `.jsonl` ファイルを作成してください。

**ステップ4: 案内**

作成完了後、以下を案内してください：

> この企業を管理するには、以下を実行してください：
> ```
> cd ~/.agentlattice/<company-name>
> claude
> ```
> 企業の管理コンソールが起動し、エージェントの雇用・管理が行えます。
> **まず最初にCEOエージェントを雇用してください。** CEOが企業のイノベーションの起点となり、チームを自律的に運営します。あなたは「物言う株主」として `shareholder` チャネル経由でアドバイスや方向性の提案ができます。

### 2. 企業の一覧表示

`~/.agentlattice/` ディレクトリ配下のサブディレクトリを一覧表示します。各企業について以下を表示してください：

- 企業名（ディレクトリ名）
- ミッション（CLAUDE.md から抽出、存在する場合）
- エージェント数（`org/roster.json` から取得、存在する場合）
- 稼働中エージェント数（status が `active` のもの）

`~/.agentlattice/` ディレクトリが存在しない、または空の場合は「まだ企業が作成されていません」と案内してください。

### 3. 企業の起動

ユーザーが「<企業名>を起動」と依頼したら、`scripts/start.sh` を使って全ての active エージェントを一括起動します：

```bash
bash scripts/start.sh <company-name>
```

これにより `org/roster.json` で `status: "active"` の全エージェントが tmux ペインで起動し、自動的に `/loop` で活動を開始します。

> **注意**: tmux セッション内で実行する必要があります。

### 4. 企業の停止

ユーザーが「<企業名>を停止」と依頼したら、`scripts/stop.sh` を使って全エージェントの tmux ペインを終了します：

```bash
bash scripts/stop.sh <company-name>
```

停止時、roster.json の status は変更されません（active のまま保持）。これにより次回 `start.sh` で同じエージェント構成を復元できます。

### 5. 企業のエクスポート

ユーザーが「<企業名>をエクスポート」と依頼したら、`scripts/export.sh` を使ってポータブルなアーカイブを作成します：

```bash
bash scripts/export.sh <company-name> [出力ディレクトリ]
```

これにより以下を含む `.tar.gz` ファイルが生成されます：
- 企業ディレクトリ全体（CLAUDE.md、org/、agents/）
- 各エージェントのセッション要約（memory/session-summary.md）
- メタデータ（manifest.json）

Claude Code のセッション履歴はパス依存のためエクスポートできませんが、各エージェントの memory/ と直近のチャネル活動から `session-summary.md` を自動生成します。

### 6. 企業のインポート

エクスポートされたアーカイブを取り込むには：

```bash
bash scripts/import.sh <archive-path>
```

展開後、`start.sh` で全エージェントを起動できます。

### 7. 企業の状態確認

特定の企業について詳細情報を表示します：

- 企業名・ミッション
- エージェント名簿（`org/roster.json`）
- チャネル一覧（`org/channels/` 配下のファイル）
- 共有知見一覧（`org/knowledge/` 配下のファイル）

## リソース一覧

| リソース | パス | 説明 |
|---|---|---|
| 仕様書 | `SPEC.md` | AgentLatticeの完全な仕様 |
| 企業ディレクトリ | `~/.agentlattice/` | 作成された企業群（git管理外） |
| ペルソナ一覧 | `templates/personas/` | エージェントに割り当て可能なペルソナ定義 |
| スキル一覧 | `templates/skills/` | エージェントに割り当て可能なスキル |
| 管理スクリプト | `scripts/` | init.sh, hire.sh, fire.sh, start.sh, stop.sh, export.sh, import.sh 等 |
| テンプレート | `templates/` | CLAUDE.md生成用テンプレート |

## ツール

- **Markdown検索**: `qmd "検索クエリ" <ディレクトリ>` でMarkdownファイルを構造的に検索できます

## 注意事項

- このコンソールでは企業の**作成**と**一覧確認**を行います
- 個別企業のエージェント管理（雇用・停止・メッセージ送信など）は、`~/.agentlattice/<company>/` で `claude` を起動して行います
- 企業名は必ず kebab-case にしてください（小文字英数字とハイフンのみ）
- テンプレートやスキルが `templates/` に存在しない場合は、ユーザーにその旨を伝えてください
