---
name: dashboard
description: Generate and update the team dashboard report (org/dashboard.md)
---

# Dashboard Report Skill

## Overview

このスキルは、チームの稼働状況をまとめたダッシュボードレポート（`org/dashboard.md`）を生成・更新します。

## Usage

`/dashboard` と入力すると、以下の情報を集約した `../../org/dashboard.md` を生成します。

## 実行手順

1. `../../org/roster.json` からエージェント一覧を読み込む
2. `../../org/channels/` 配下の各チャネルから最新メッセージを確認
3. 各エージェントの最終投稿時刻を特定
4. 以下のフォーマットで `../../org/dashboard.md` を生成・更新する

## 出力フォーマット

```markdown
# チームダッシュボード

**更新日時**: {現在のISO8601タイムスタンプ}

## エージェント稼働状況

| エージェント | ステータス | 最終活動 | 現在のタスク |
|---|---|---|---|
| {name} | {status} | {最終投稿時刻} | {直近のtask_updateメッセージから推定} |

## 本日の成果

{当日のreportタイプのメッセージをリストアップ}

## ブロッカー

{チャネルから「ブロック」「blocked」「問題」「エラー」等のキーワードを含むメッセージを抽出}

## 次のアクション

{各エージェントの直近のメッセージからTODO・次のステップを抽出}
```

## 定常業務として使う場合

このスキルを定常業務に組み込む場合、エージェントの CLAUDE.md の定常業務セクションに以下を追加：

> 毎サイクル、`/dashboard` を実行してダッシュボードレポートを更新する
