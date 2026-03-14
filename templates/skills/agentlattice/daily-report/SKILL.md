---
name: daily-report
description: Generate a daily summary report of all team activities
---

# Daily Report Skill

## Overview

チーム全体の日次活動レポートを自動生成するスキルです。全チャネルの活動を集約し、management向けのサマリーを作成します。

## Usage

`/daily-report` と入力すると、`../../org/knowledge/daily-report-YYYY-MM-DD.md` にレポートを生成します。

## 実行手順

1. 本日の日付を取得する（ISO 8601形式）
2. `../../org/channels/` 配下の全チャネルJSONLファイルを読み込む
3. 本日のタイムスタンプ（`ts` フィールド）を持つメッセージのみ抽出する
4. `../../org/roster.json` からエージェント一覧を取得する
5. 以下のフォーマットでレポートを生成する

## 出力フォーマット

```markdown
# 日次レポート — {YYYY-MM-DD}

## サマリー

- **活動エージェント数**: {本日メッセージを投稿したエージェント数} / {全エージェント数}
- **総メッセージ数**: {本日の全チャネル合計メッセージ数}
- **アクティブチャネル**: {本日メッセージがあったチャネル名のリスト}

## エージェント別活動

### {agent_display_name} ({agent_name})

- **投稿数**: {本日のメッセージ数}
- **主な活動**:
  - {report/task_updateタイプのメッセージを箇条書きで要約}

## 今日の成果物

{本日のreportタイプメッセージからファイルパスを含むものをリスト}

## ブロッカー・課題

{「ブロック」「blocked」「問題」「エラー」「error」等のキーワードを含むメッセージを抽出}

## 明日に向けて

{各エージェントの直近メッセージから「次は」「TODO」「明日」等のキーワードを含むものを抽出}
```

## 保存先

- レポートファイル: `../../org/knowledge/daily-report-{YYYY-MM-DD}.md`
- 過去のレポートは上書きせず、日付ごとに別ファイルとして保持
