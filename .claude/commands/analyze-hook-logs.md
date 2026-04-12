---
description: Claude Code hook logs を分析し settings/CLAUDE.md/scripts 全体の改善候補を対話適用
---

## Task

`~/.claude/logs/*.jsonl` の集計 JSON を読み、改善候補を **settings.json だけでなく**
CLAUDE.md / `.claude/scripts/` / hooks / lint-test config まで広く分類・提示・適用する。

集計スクリプトは grouping と事実収集のみ。**分類と判断はこのコマンド内で Claude が行う。**

`$ARGUMENTS` は `--since N` の日数 (未指定時 14)。

## Step 1: データ取得

```bash
bash ~/.claude/bin/aggregate-hook-logs.sh --since ${ARGUMENTS:-14} --format json
```

出力の主要フィールド:
- `stats` — セッション・イベント・`by_ask_flow` 内訳
- `current_settings.{allow,ask,deny}_bash_prefixes`
- `groups[]` — `(tool_name, cmd_prefix)` でまとめた invocation 集約:
  - `count`, `ask_flow_breakdown`, `permission_modes`, `cwds`, `example_commands`, `error_count`
  - `in_current_allow/ask/deny` — 現行 settings との照合

`ask_flow` の 4 状態:
- `auto_allowed` — 自動許可で実行された (既存 allow がヒット or bypassPermissions)
- `user_allowed` — ask ダイアログを経てユーザが許可して実行された
- `user_denied` — ask ダイアログでユーザが拒否した
- `auto_denied` — deny ルール or auto-mode classifier が自動拒否した

## Step 2: スキップ判定

以下は改善不要。件数のみカウントして先頭で報告する:
- `in_current_ask == true` で `user_allowed / user_denied` のみ → **意図的 ask** (e.g. `gh pr merge`)
- `permission_modes == ["plan"]` のみ → **plan mode 仕様**
- `in_current_deny == true` で `auto_denied` のみ → **正しく deny 動作中**
- `count < 3` の低頻度グループ → ノイズ。ただし危険パターンや error は例外で低頻度でも拾う

## Step 3: 改善カテゴリの分類

各グループを読み、以下のカテゴリに分類する。複数該当可。

### Where に書くか: グローバル vs プロジェクト判定

`cwds` の分布で判断する:
- **グローバル** (`~/.claude/settings.json`, `~/.claude/CLAUDE.md`): cwds が 3+ リポジトリに分散 or /tmp /home 等の非リポジトリ
- **プロジェクト** (`<repo>/.claude/settings.local.json`, `<repo>/CLAUDE.md`): cwds の 80%+ が 1 リポジトリに集中

プロジェクト対応が必要なら **Claude 自身は cd しない** — 実行コマンドをユーザに提示 or `/collect-permissions` を案内。

### What を書くか:

#### (1) settings.json 調整

- **allow 追加**: `user_allowed` が多い + `in_current_allow == false` → `Bash(<prefix>:*)` 追加
- **deny 追加**: `example_commands` に破壊的操作が含まれ `auto_allowed` or `user_allowed` で実行完了している
- **unused allow 削除**: `current_settings.allow_bash_prefixes` のうち、期間内どのグループにも `in_current_allow == true` で出ていないもの → 肥大化抑制
- **pattern 修正**: head_token で近い prefix が現 allow にあるが full match しない → 既存 pattern を広げる提案

#### (2) CLAUDE.md ルール追加

**シグナル**: 同一 cmd_prefix で `auto_denied >= 3` → Claude が繰り返し同じ禁止コマンドを試みている = CLAUDE.md にルールが無い or 守れていない。

例:
- `git add -A` が denied ×5 → CLAUDE.md: 「ファイルを個別に add すること」(settings deny と二重防御)
- `cat` が頻繁に使われている → CLAUDE.md: 「Read ツールを使え」
- `git -C <path>` → CLAUDE.md: 「cd してから git 実行」

CLAUDE.md はグローバル (`~/.claude/CLAUDE.md`) かプロジェクト (`<repo>/CLAUDE.md`) かを cwds で判定。

#### (3) Script 抽出 (`.claude/scripts/<name>.sh`)

**シグナル**: `example_commands` に 200 char+ の one-liner や複合シェル構文 (`&&`, `|`, `;`, `for`, `while`, `$(...)`, heredoc) が含まれる。

→ 共通部分をスクリプトに抽出し、`Bash(bash ~/.claude/scripts/<name>.sh*)` として allow する。

**禁則**: `Bash(bash -c:*)` のような過剰に広い allow は作らない。

#### (4) Lint/test hotspot (情報提示のみ)

**シグナル**: `error_count >= 3`。
- Write/Edit で error 多発 → biome / linter 設定問題
- `pnpm test` / `go test` で error 多発 → テスト脆弱性
- build (tsc, cargo) error → 型定義/依存問題

**Claude は修正しない** — 「この hotspot を調査してください」と提示するだけ。

#### (5) Hook validator regex 調整

現行 PreToolUse hooks (force push, git add -A, --no-verify, git -C, --help, cd&&tq) について:
- 該当パターンが `user_allowed` で多い → regex が広すぎて safe な変種を誤検知している可能性 → 狭める提案
- 危険パターンが通っている → regex が漏れている → 追加提案

## Step 4: 提示順序

1. **サマリ**: 期間・統計・ask_flow 内訳・スキップ件数
2. **グローバル settings 候補**: allow/deny 追加、unused 削除、pattern 修正
3. **プロジェクト settings 案内**: どのリポジトリで何するかのリスト
4. **Script 抽出候補**: 候補ごとにスクリプト名案 + allow 提案
5. **CLAUDE.md 更新候補**: グローバル/プロジェクト別
6. **Lint/test hotspot**: 情報提示のみ
7. **Hook tuning 候補**

## Step 5: 対話適用

カテゴリ毎に `AskUserQuestion` を使って対話する。

- **Claude が直接編集するもの**: グローバル `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/scripts/*`
  → 承認を得たら Edit / Write で適用
- **ユーザに委ねるもの**: プロジェクト内ファイル (`<repo>/CLAUDE.md`, `<repo>/.claude/settings.local.json`)
  → 実行コマンドとして提示 (e.g. 「`cd <repo>` で `/collect-permissions` を実行」)
- **情報提示のみ**: Lint/test hotspot → 何も編集しない

## Step 6: 検証 & commit

settings.json を Edit した場合:

```bash
jq empty ~/.claude/settings.json
```

で妥当性検証。失敗時はユーザに通知して停止 (自動巻き戻しはしない)。

変更 1 件以上で `/commit` skill を呼ぶ。

## 禁則事項

- 意図的 ask (`in_current_ask == true`) を allow に昇格させない
- `Bash(bash -c:*)` のような過剰に広い allow を作らない
- 他リポジトリに cd して編集しない — 案内のみ
- 壊れた settings.json を自動巻き戻さない
- Lint/test config を自動修正しない (提示のみ)
- CLAUDE.md 追記は必ずユーザ承認を得る (behavior 変更は重大)
