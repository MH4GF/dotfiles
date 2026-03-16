---
description: デイリーノートの編集ノート更新と整理
mode: noninteractive
---
1. `.claude/scripts/daily-edited-notes.sh` を実行して昨日の編集ノートセクションを更新
   - `bash` や絶対パスで実行しない。カレントディレクトリで直接 `.claude/scripts/daily-edited-notes.sh` を実行すれば良い
2. 昨日のデイリーノートを読み込み、全体の記述からEvergreen notesとして切り出せる内容を探す
   - 対象: メモ、タスクの学び、日記の記述など（編集ノートセクションは抽出済みなので除く）
   - 1ノート=1アイデアの原則に従い、独立した概念・知見を発見したらユーザーに提案
   - ユーザーが承認したら notes/ に新規ノート作成 + デイリーノートにwikilink追加
   - 候補がなければ完了を報告して終了
