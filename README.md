# convenient-agent-skills
便利なAgent Skills

## Skills
<!-- SKILLS:LIST:START -->
### architecture-map
対象コードベースの構造を、依存関係の簡易マップと、機能（エントリーポイント）ごとのデータフロー図（クラス/構造体間でやりとりされるデータの型と責務）としてインタラクティブなHTMLで可視化する。Java/Go/Node.jsは標準ツールで補強し、他言語はAIの読解でフォールバックする。「このコードベースのアーキテクチャを教えて」「アーキテクチャを可視化して」「このリポジトリの構造を理解したい」「このソフトウェアの構造を把握したい」といった依頼で使用する。

### audit-requirements-based-on-ieee830
IEEE Std 830が定義するSRS(Software Requirements Specification)の品質特性（Correct/Unambiguous/Complete/Consistent/Ranked for importance and stability/Verifiable/Modifiable/Traceable）に基づき、渡された要件を評価し改善点をフィードバックする。要件が2件以上渡された場合は要件セット全体で判定する特性（Complete/Consistent/Ranked）も評価し、単一要件のみの場合はそれらを「判定不可」として明示する。要件テキストの範囲内でのみ判定し、外部文脈（上位仕様・ビジネス優先度・トレーサビリティ情報等）が必要な項目は判定不可とその根拠・必要情報を明記する。問題のある要件には指摘点を統合した書き直し案を提示するが、確定的な置き換えとしては提示しない。評価と改善案の提示のみを行い、以降どう反映するかはユーザーに委ねる。「この要件をIEEE830の観点で評価して」「要件の品質をチェックして」「この要件は曖昧じゃないか確認して」「要件を検証して」「要件の改善点を教えて」といった依頼で使用する。

### boiled-me
文書全体を意味を落とさずに要約・凝縮する。論証構造を持つ箇所は内部的に論証図（従属前提・独立前提・中間結論）を構築して支持関係を壊さない圧縮かどうかを検証し、手順・時系列・箇条書きなど論証構造を持たない箇所は重複排除を手がかりに原文の順序を保ったまま圧縮する。圧縮方針をユーザーと確認しながら短文の連なりに仕上げ、元の文章に反映する。「文章を要約して」「文章を短くして」「長い文章を凝縮して」「手順書を簡潔にして」といった依頼で使用する。

### check-lts
Check LTS support status for Go, Node.js, Java, Python, and PHP by fetching official release pages. Use when asked about LTS versions, support lifecycle, or EOL dates for these languages.

### grounded-report
ユーザーが指定した目的を満たす、根拠資料に基づいたHTMLレポートを生成する。対象読者の前提知識に応じた用語の先出し定義、目的達成度、論理構成の妥当性、引用の有無、引用元との整合性の5点を、実装文脈を持たない独立した検証者が自動検証し、実行→検証→修正のループで基準を満たすまで自律的に改善する。「レポートを作って」「根拠付きのレポートが欲しい」「調べてレポートにまとめて」といった依頼で使用する。

### invest-task-splitter
渡された要件を、INVESTの原則（独立している・交渉可能・価値がある・見積もれる・小さい・テスト可能）を満たす形で複数のサブタスクに分割する。分割案をユーザーに提示する前に、実装文脈を持たない独立した検証者がINVESTの充足と全体の網羅性を自動検証し、不合格の場合は該当タスクのみ修正して再検証するループを回す。さらに各タスクを「他者への依頼/他タスクのブロック」「見積もり困難・後続の方針に影響する調査等」「内容が明確で高精度に見積もれる」の3段階に分類し、着手優先度として提示する。「要件をタスクに分割して」「INVESTを満たす形でタスクに分けて」「サブタスクに落として」といった依頼で使用する。

### masked-software-modeling
指定したソフトウェアの一部のロジックを削除（マスク）し、ユーザー自身に再実装させることでソフトウェアへの理解を深める。Masked Language Modelingのソフトウェア版。「ソフトウェアのコードをマスクして問題を作って」「ヒントが欲しい」「答え・解説を見せて」といった依頼で使用する。

### setup-loop
Interview the user to build an autonomous execute-verify loop for a task — gathering execution steps, verification method (always via subagent), and termination conditions — then pre-approve required commands/tools and run the loop until the termination condition is met. Use when the user wants to set up an autonomous iteration loop (execute, verify, fix, repeat) for a task.

### slack-canvas-comment-threads
SlackのCanvas URLを渡すと、そのCanvasに付けられたコメント（Canvasネイティブの注釈コメント。通常のチャンネルスレッドとは別物だが、実体はfile conversation上のメッセージ/スレッドとして保持されている）を網羅的に洗い出し、網羅性を検証した上でリンクと内容の要約をユーザーに提示する。「CanvasのコメントをまとめてSlack Canvasのコメントスレッドを取得して」「このCanvasについたコメントを全部見せて」といった依頼で使用する。

### test-logic-audit
対象のテストコードを論理学的アプローチで監査し、(1)各テストが何を検証しているか、(2)仕様条件に対する網羅性、(3)テスト（前提）からコードの性質について演繹的に何が言えるか、を明らかにする。テストの前提を論証地図（独立前提・従属前提・中間結論）として構造化し、弱いアサーションやトートロジー的なテストも検出する。不足しているテストケースの提案まで行うが、テストコードの自動生成は行わない。「このテストの品質を検証して」「テストの網羅性を確認して」「このテストから何が演繹的に言えるか教えて」「テストをレビューして」「このテストは十分か」といった依頼で使用する。
<!-- SKILLS:LIST:END -->

## How to install

### Claude Code
https://github.com/vercel-labs/skills を利用。

```
# 一覧
npx skills add https://github.com/kitakou0313/convenient-agent-skills --list
```

各スキルを個別にインストールする場合:

<!-- SKILLS:CODE:START -->
```
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill architecture-map
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill audit-requirements-based-on-ieee830
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill boiled-me
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill check-lts
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill grounded-report
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill invest-task-splitter
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill masked-software-modeling
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill setup-loop
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill slack-canvas-comment-threads
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill test-logic-audit
```
<!-- SKILLS:CODE:END -->

### Claude Desktop
Claude CodeとClaude Desktopはスキルの保存場所が別のため、使いたいスキルを手動でアップロードする。ZIPのルート直下にスキルのフォルダ、その1階層下に`SKILL.md`が来る構成にする必要がある（例: `boiled-me.zip` の中に `boiled-me/SKILL.md`）。

Claude Desktopへのアップロードを行うAPI/CLIは提供されていないため、Desktopへの追加は最終的に手動操作になる。以下の手順1（ZIP化）は自動化されており、コミット時に `dist/desktop-skills/` へ最新のZIPが生成される（gitでは管理しない）。手順2以降はDesktopアプリ上での手動操作が必要。

1. リポジトリのルートで、インストールしたいスキルをZIP圧縮する（`dist/desktop-skills/` に生成済みのZIPを使ってもよい）

    <!-- SKILLS:DESKTOP:START -->
    ```
    cd skills
    zip -r architecture-map.zip architecture-map
    zip -r audit-requirements-based-on-ieee830.zip audit-requirements-based-on-ieee830
    zip -r boiled-me.zip boiled-me
    zip -r check-lts.zip check-lts
    zip -r grounded-report.zip grounded-report
    zip -r invest-task-splitter.zip invest-task-splitter
    zip -r masked-software-modeling.zip masked-software-modeling
    zip -r setup-loop.zip setup-loop
    zip -r slack-canvas-comment-threads.zip slack-canvas-comment-threads
    zip -r test-logic-audit.zip test-logic-audit
    ```
    <!-- SKILLS:DESKTOP:END -->

2. Claude Desktopの`設定 → Capabilities`で「Code execution」を有効化する
3. `Customize → Skills`の`+`ボタン → `Upload a skill`から作成したZIPを選択してアップロード
4. 一覧でトグルをONにする
5. 有効化前に開いていた会話には反映されないため、新しい会話で動作確認する

## Development
`## Skills`節、および上記インストールコマンドの `<!-- SKILLS:...:START/END -->` マーカーで囲まれた部分は `scripts/sync_skills.py` による自動生成のため、直接編集しない。

初回セットアップとして以下を一度だけ実行し、pre-commitフックを有効化する。

```
bash scripts/install-hooks.sh
```

以後、コミットのたびに `scripts/sync_skills.py` が自動実行され、README.mdの更新（変更があれば）と `dist/desktop-skills/`（git管理外）へのZIP再生成が行われる。

## ToDo
- AIで生成された文章を煎じ詰めて短くするskills
    - 論理構造の分析に引っ張られすぎて手順書などの要約に適用できない
- skillsのテストを行うskills
- ソフトウェアの構造、依存関係などを一眼で理解できるskillsの作成
    - CIで実行したいので全文の読み込みなどは行わないようにする
- skills作成時の方針をCLAUDE.mdにまとめる
    - Claude Codeに依存しない
        - 組み込みのskillsに依存しない