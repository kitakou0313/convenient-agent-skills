---
name: setup-loop
description: Interview the user to build an autonomous execute-verify loop for a task — gathering execution steps, verification method (always via subagent), and termination conditions — then pre-approve required commands/tools and run the loop until the termination condition is met. Use when the user wants to set up an autonomous iteration loop (execute, verify, fix, repeat) for a task.
---

# Setup Loop — 実行・検証ループの構築と自律実行

Agentがあるタスクを「実行 → 検証 → 修正」のループで自律的に進めるために必要な要件を聞き取り、ループを構築して実行するスキル。

## 全体の流れ

1. **ループの構築**（Plan mode で実施）— 実行・検証・終了条件を聞き取り、実行計画を作る
2. **ループ実行前準備** — 実行計画を元に、必要なコマンド・toolのapproveを事前に取得する
3. **ループの実行** — Plan modeの解除を依頼し、解除されたら終了条件を満たすまでループを実行する

## Phase 1: ループの構築（Plan mode）

まず `EnterPlanMode` でPlan modeに切り替える（すでにPlan modeであれば不要）。
以下の3点を `AskUserQuestion` で聞き取る。ユーザーの依頼内容から自明な項目は確認のみに留め、不明な点を重点的に聞くこと。

### 1-1. 実行についての聞き取り

- 実現したいタスクは何か（対象・ゴール）
- 実行に使うコマンド・手順・対象ファイル

### 1-2. 検証についての聞き取り

- 実行結果をどう検証するか（テスト・ビルド・lint・実際の動作確認など、具体的なコマンドや手順）
- 検証方法については複数あることを想定して確認すること
  - 検証したい軸が複数あることが考えられるため

**検証は必ずsubagent（Agent tool）で実施すること。** メインagentが実行、subagentが検証と役割を分離し、検証の客観性を保つ。subagentには検証手順と合格基準のみを渡し、実装時の文脈（どう直したか・どう直したつもりか）は渡さない。

### 1-3. 終了条件についての聞き取り

- 成功条件: 検証がどういう結果になればループを終了するか
- 検証の合格基準（何をもって「成功」とするか）
- 最大イテレーション数（検証の合格基準に達せずループを繰り返す場合の最大ループ数。未指定ならデフォルト10回を提案する）
- 上限到達時の扱い: ループを中断し、現状と残課題をユーザーに報告する

### 実行計画の作成

聞き取りが完了したら、以下を含む実行計画をまとめる:

- 実行手順（1イテレーションの内容）
- 検証手順（subagentに渡すプロンプトの要点と合格基準）
- 終了条件（成功条件・最大イテレーション数）
- **ループ中に必要になるコマンド・toolの一覧**（Phase 2のapprove取得対象）

## Phase 2: ループ実行前準備

`ExitPlanMode` で実行計画を提示し、Plan modeの解除を依頼する。

解除されたら、ループを承認待ちで中断させないため、実行計画に挙げたコマンド・toolを **ループ開始前に1回ずつ実行（または安全な形で試行）** し、permission promptをまとめて前倒しで処理する。

- 例: テストコマンド・ビルドコマンドを一度実行して承認を得る
- 破壊的なコマンドはこの段階では実行せず、ユーザーに事前承認（permission設定への追加など）を依頼する

## Phase 3: ループの実行

終了条件を満たすまで以下を繰り返す:

1. **実行**: Phase 1で定義した実行手順を1イテレーション分実施する
2. **検証**: subagentを起動し、検証手順と合格基準のみを渡して検証させる
3. **判定**:
   - 合格 → ループを終了し、結果をユーザーに報告する
   - 不合格 → subagentの指摘を元に修正し、次のイテレーションへ進む
   - 最大イテレーション数に到達 → ループを中断し、現状・試したこと・残課題をユーザーに報告する

各イテレーションの終わりに「イテレーション番号 / 実行した内容 / 検証結果」を1〜2行でユーザーに報告する。
