---
name: check-lts
description: Check LTS support status for Go, Node.js, and Java by fetching official release pages. Use when asked about LTS versions, support lifecycle, or EOL dates for these languages.
compatibility: Requires internet access to fetch official release pages
allowed-tools: WebFetch
---

# Check LTS Support Status

Go、Node.js、JavaのLTSサポート状況を公式サイトから取得して表示します。

## 手順

以下の3つの公式URLをそれぞれWebFetchで取得し、サポート状況をまとめてください。
3つのフェッチは並列で実行してください。

### 1. Go

- URL: https://go.dev/doc/devel/release
- Goのサポートポリシー: **最新の2つのメジャーバージョン**のみサポート対象
- 取得情報: 各 Go 1.x バージョンのリリース日

### 2. Node.js

- URL: https://nodejs.org/en/about/previous-releases
- 取得情報: LTSバージョンのコードネーム・リリース日・Active LTS開始日・Maintenance開始日・EOL日・現在のステータス

### 3. Java

- URL: https://www.oracle.com/jp/java/technologies/java-se-support-roadmap.html
- 取得情報: LTSバージョンのGA日・Premier Support終了日・Extended Support終了日

## 出力フォーマット

取得結果を以下の形式でまとめてください。今日の日付を基準にステータスを判定してください。

---

### Go LTS サポート状況

> **サポートポリシー**: 最新2バージョンのみサポート

| バージョン | リリース日 | ステータス |
|-----------|-----------|---------|
| Go 1.x    | YYYY-MM-DD | ✅ Active / ❌ EOL |

---

### Node.js LTS サポート状況

| バージョン | コードネーム | リリース日 | Active LTS開始 | Maintenance開始 | EOL | ステータス |
|-----------|------------|-----------|--------------|----------------|-----|---------|
| v24       | Krypton    | ...       | ...          | ...            | ... | ✅ Active LTS |

ステータスの凡例:
- `✅ Active LTS` — 現在 Active LTS 期間中
- `🔧 Maintenance` — メンテナンスモード（セキュリティ修正のみ）
- `❌ EOL` — サポート終了

---

### Java LTS サポート状況

| バージョン | GA日 | Premier Support終了 | Extended Support終了 | ステータス |
|-----------|------|--------------------|--------------------|---------|
| Java 21   | ...  | ...                | ...                | ✅ Premier Support |

ステータスの凡例:
- `✅ Premier Support` — Premier Support 期間中
- `🔧 Extended Support` — Extended Support 期間中（有償）
- `❌ EOL` — すべてのサポート終了

---