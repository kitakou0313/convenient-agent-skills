---
name: check-lts
description: Check LTS support status for Go, Node.js, Java, Python, and PHP by fetching official release pages. Use when asked about LTS versions, support lifecycle, or EOL dates for these languages.
compatibility: Requires internet access to fetch official release pages
allowed-tools: WebFetch
---

# Check LTS Support Status

Go、Node.js、Java、Python、PHPのLTSサポート状況を公式サイトから取得して表示します。

## 手順

以下の5つの公式URLをそれぞれWebFetchで取得し、サポート状況をまとめてください。
5つのフェッチは並列で実行してください。

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

### 4. Python

- URL: https://devguide.python.org/versions/
- 取得情報: 各バージョンのリリース日・EOL日・現在のステータス（feature / bugfix / security / end-of-life）
- EOLになっていないバージョンのみ表示する

### 5. PHP

- URL: https://www.php.net/supported-versions.php
- 取得情報: 各バージョンのリリース日・Active Support終了日・Security Support終了日・現在のステータス

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

### Python サポート状況

| バージョン | リリース日 | EOL日 | ステータス |
|-----------|-----------|------|---------|
| 3.14      | 2025-10-07 | 2030-10 | ✅ Bugfix |
| 3.13      | 2024-10-07 | 2029-10 | ✅ Bugfix |
| 3.12      | 2023-10-02 | 2028-10 | 🔧 Security |

ステータスの凡例:
- `🚧 Prerelease` — 開発中（次期バージョン、feature フェーズ）
- `✅ Bugfix` — バグ修正・セキュリティ修正を受ける通常サポート期間中
- `🔧 Security` — セキュリティ修正のみ・バイナリ配布なし
- `❌ EOL` — サポート終了

---

### PHP サポート状況

| バージョン | リリース日 | Active Support終了 | Security Support終了 | ステータス |
|-----------|-----------|------------------|---------------------|---------|
| 8.5       | 2025-11-20 | 2027-12-31 | 2029-12-31 | ✅ Active Support |
| 8.4       | 2024-11-21 | 2026-12-31 | 2028-12-31 | ✅ Active Support |
| 8.3       | 2023-11-23 | 2025-12-31 | 2027-12-31 | 🔧 Security |
| 8.2       | 2022-12-08 | 2024-12-31 | 2026-12-31 | 🔧 Security |

ステータスの凡例:
- `✅ Active Support` — バグ修正・セキュリティ修正を受ける通常サポート期間中
- `🔧 Security` — セキュリティ修正のみ受ける期間中
- `❌ EOL` — サポート終了

---