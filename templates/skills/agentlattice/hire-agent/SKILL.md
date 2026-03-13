---
name: hire-agent
description: 新しいエージェントを雇用（作成・起動）するスキル。ディレクトリ作成、CLAUDE.md生成、スキルコピー、roster更新、tmux起動まで一貫して行う。
---

# エージェント雇用スキル

あなたはこのスキルにより、新しいエージェントを雇用する権限を持っています。
チームに必要な人材がいないと判断した場合、自らの判断でエージェントを雇用できます。

## パス解決

```bash
AGENTLATTICE_ROOT=$(python3 -c "import json; print(json.load(open('$HOME/.agentlattice/config.json'))['agentlattice_root'])")
```

- ペルソナ一覧: `$AGENTLATTICE_ROOT/templates/personas/`（INDEX.md に概要あり）
- スキル一覧: `$AGENTLATTICE_ROOT/templates/skills/`（INDEX.md に概要あり）
- エージェントテンプレート: `$AGENTLATTICE_ROOT/templates/agent-claude-md.md`
- 雇用スクリプト: `$AGENTLATTICE_ROOT/scripts/hire.sh`
- 企業ディレクトリ: `../../`（自分の作業ディレクトリから2階層上）
- roster.json: `../../org/roster.json`

## 雇用フロー

### 1. 雇用の判断

以下のいずれかに該当する場合、雇用を検討してください：
- 自分の専門外のタスクが発生し、チームに適任者がいない
- 作業量が多く、分担が必要
- managementまたは他のエージェントから雇用を依頼された

雇用前に `../../org/roster.json` を確認し、既存メンバーで対応できないか検討すること。

### 2. エージェントの設計

以下を決定してください：
- **名前** (`name`): kebab-case。ディレクトリ名・通信上の識別子
- **表示名** (`display_name`): 人が読む名前
- **役割・担当業務の説明**: 期待する業務内容
- **ペルソナ**: `$AGENTLATTICE_ROOT/templates/personas/INDEX.md` を参照して選択（複数ブレンド可）
- **スキル**: `$AGENTLATTICE_ROOT/templates/skills/INDEX.md` を参照して選択
- **参加チャネル**: `../../org/channels/` 内の既存チャネルから選択

### 3. ディレクトリ作成

```bash
mkdir -p ../../agents/<agent-name>/.claude/skills ../../agents/<agent-name>/workspace ../../agents/<agent-name>/memory
```

### 4. CLAUDE.md の生成

`$AGENTLATTICE_ROOT/templates/agent-claude-md.md` を読み込み、プレースホルダーを置換して `../../agents/<agent-name>/CLAUDE.md` を生成：

- `{{agent_name}}` → エージェント名
- `{{display_name}}` → 表示名
- `{{company_name}}` → 自分の所属企業名
- `{{persona_blend}}` → ブレンドされたペルソナ定義
- `{{role_description}}` → 役割・担当業務の説明
- `{{channels}}` → 参加チャネルのカンマ区切りリスト
- `{{routine_tasks}}` → 定常業務（なければ「特になし。メッセージ対応とタスク実行に集中してください。」）

**ペルソナブレンドの手順:**
1. 選択された各ペルソナファイルを読み込む
2. 以下の要素を統合：
   - **Identity**: 各ペルソナの専門性を合成した新しいアイデンティティ
   - **Core Mission**: 全ペルソナのミッションを統合
   - **Critical Rules**: 全ペルソナのルールを網羅
   - **Workflow Process**: 業務に応じて適切なワークフローを選択・統合
   - **Communication Style**: 主ペルソナのスタイルを基本に補完

### 5. スキルのコピー

```bash
cp -r $AGENTLATTICE_ROOT/templates/skills/<category>/<skill-name>/ ../../agents/<agent-name>/.claude/skills/<skill-name>/
```

### 6. roster.json の更新

`../../org/roster.json` にエージェント情報を追加：

```json
{
  "name": "<agent-name>",
  "display_name": "<表示名>",
  "personas": ["<persona-1>", "<persona-2>"],
  "skills": ["<category>/<skill-name>"],
  "channels": ["general", "<other-channels>"],
  "status": "active",
  "created_at": "<ISO8601>",
  "description": "<役割・担当業務の説明>"
}
```

### 7. エージェントの起動

```bash
bash $AGENTLATTICE_ROOT/scripts/hire.sh <company-name> <agent-name>
```

hire.sh がtmuxペインを開き、`/loop` を自動実行します。

### 8. チャネルで報告

雇用完了後、generalチャネルに報告してください：

```
@<agent-name> を雇用しました。役割: <役割説明>。参加チャネル: <チャネル一覧>
```

## 制約

- 雇用はチームに明確な必要性がある場合のみ行うこと
- 同じ名前のエージェントが既にいないか、roster.json で事前確認すること
- 雇用後は必ずチャネルでチームに報告すること
