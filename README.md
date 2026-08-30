# convenient-agent-skills
便利なAgent Skills

## Skills
<!-- SKILLS:LIST:START -->
### boiled-me
文書全体を意味を落とさずに要約・凝縮する。論証構造を持つ箇所は内部的に論証図（従属前提・独立前提・中間結論）を構築して支持関係を壊さない圧縮かどうかを検証し、手順・時系列・箇条書きなど論証構造を持たない箇所は重複排除を手がかりに原文の順序を保ったまま圧縮する。圧縮方針をユーザーと確認しながら短文の連なりに仕上げ、元の文章に反映する。「文章を要約して」「文章を短くして」「長い文章を凝縮して」「手順書を簡潔にして」といった依頼で使用する。

### check-lts
Check LTS support status for Go, Node.js, Java, Python, and PHP by fetching official release pages. Use when asked about LTS versions, support lifecycle, or EOL dates for these languages.

### grounded-report
ユーザーが指定した目的を満たす、根拠資料に基づいたHTMLレポートを生成する。対象読者の前提知識に応じた用語の先出し定義、目的達成度、論理構成の妥当性、引用の有無、引用元との整合性の5点を、実装文脈を持たない独立した検証者が自動検証し、実行→検証→修正のループで基準を満たすまで自律的に改善する。「レポートを作って」「根拠付きのレポートが欲しい」「調べてレポートにまとめて」といった依頼で使用する。

### masked-software-modeling
指定したソフトウェアの一部のロジックを削除（マスク）し、ユーザー自身に再実装させることでソフトウェアへの理解を深める。Masked Language Modelingのソフトウェア版。「ソフトウェアのコードをマスクして問題を作って」「ヒントが欲しい」「答え・解説を見せて」といった依頼で使用する。

### setup-loop
Interview the user to build an autonomous execute-verify loop for a task — gathering execution steps, verification method (always via subagent), and termination conditions — then pre-approve required commands/tools and run the loop until the termination condition is met. Use when the user wants to set up an autonomous iteration loop (execute, verify, fix, repeat) for a task.

### slack-canvas-comment-threads
SlackのCanvas URLを渡すと、そのCanvasに付けられたコメント（Canvasネイティブの注釈コメント。通常のチャンネルスレッドとは別物だが、実体はfile conversation上のメッセージ/スレッドとして保持されている）を網羅的に洗い出し、網羅性を検証した上でリンクと内容の要約をユーザーに提示する。「CanvasのコメントをまとめてSlack Canvasのコメントスレッドを取得して」「このCanvasについたコメントを全部見せて」といった依頼で使用する。
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
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill boiled-me
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill check-lts
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill grounded-report
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill masked-software-modeling
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill setup-loop
npx skills add https://github.com/kitakou0313/convenient-agent-skills --skill slack-canvas-comment-threads
```
<!-- SKILLS:CODE:END -->

### Claude Desktop
Claude CodeとClaude Desktopはスキルの保存場所が別のため、使いたいスキルを手動でアップロードする。ZIPのルート直下にスキルのフォルダ、その1階層下に`SKILL.md`が来る構成にする必要がある（例: `boiled-me.zip` の中に `boiled-me/SKILL.md`）。

Claude Desktopへのアップロードを行うAPI/CLIは提供されていないため、Desktopへの追加は最終的に手動操作になる。以下の手順1（ZIP化）は自動化されており、コミット時に `dist/desktop-skills/` へ最新のZIPが生成される（gitでは管理しない）。手順2以降はDesktopアプリ上での手動操作が必要。

1. リポジトリのルートで、インストールしたいスキルをZIP圧縮する（`dist/desktop-skills/` に生成済みのZIPを使ってもよい）

    <!-- SKILLS:DESKTOP:START -->
    ```
    cd skills
    zip -r boiled-me.zip boiled-me
    zip -r check-lts.zip check-lts
    zip -r grounded-report.zip grounded-report
    zip -r masked-software-modeling.zip masked-software-modeling
    zip -r setup-loop.zip setup-loop
    zip -r slack-canvas-comment-threads.zip slack-canvas-comment-threads
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
- テストの品質検証
    - どんなテストを行っているか
    - 網羅性を満たしているか
    - どんなことが演繹的に言えるか
- ソフトウェアの構造、依存関係などを一眼で理解できるskillsの作成
    - CIで実行したいので全文の読み込みなどは行わないようにする