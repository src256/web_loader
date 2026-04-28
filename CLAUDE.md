# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## コマンド

```bash
# 依存関係のインストール
bundle install

# テスト実行（全テスト）
bundle exec rake test

# 単一テストファイルの実行
bundle exec ruby -Ilib -Itest test/test_utils.rb

# CLIツールの実行
bundle exec exe/wl [オプション] <URL>

# gemのビルド
bundle exec rake build

# gemのリリース（バージョン更新後）
bundle exec rake release
```

### CLIオプション

```
-d DRIVER, --driver=DRIVER   ドライバ指定: pureruby(デフォルト) | selenium
--disable-cache              キャッシュ無効化
--user-agent=USERAGENT       User-Agentヘッダの設定
-b, --binary                 バイナリファイルのダウンロード
-v, --verbose                詳細ログ出力
```

## アーキテクチャ

### 処理フロー

```
exe/wl → Downloader.run(argv) → Command#load(url) → Driver#fetch(url) → Response
                                         ↕
                                    Cache (./cache/)
```

### 主要クラス

- **`Downloader`** (`lib/web_loader/downloader.rb`): CLIエントリポイント。optparseでオプション解析し、ドライバとCommandを組み立てる。継承してカスタム`wait_proc`を定義できる。
- **`Command`** (`lib/web_loader/command.rb`): ロードのコアロジック。キャッシュ管理、リダイレクト追跡（最大10回）、リトライ（タイムアウト・429対応）を担当。
- **`Cache`** (`lib/web_loader/cache.rb`): URLのMD5ハッシュをファイル名に使い `./cache/` 配下に `.html` + `.yml` ペアで保存。デフォルト有効期限は1時間。
- **`Response`** (`lib/web_loader/response.rb`): ステータスコードのラッパー。`ok?`(2xx)、`redirect?`(3xx)、`rate_limited?`(429)を提供。

### ドライバ

`BaseDriver` を継承して `fetch(url)` を実装する設計。

- **`HttpDriver`**: `Net::HTTP` を使用。文字コード変換（`Utils.toutf8`）を行う。SSL証明書検証は無効(`VERIFY_NONE`)。
- **`SeleniumDriver`**: ヘッドレスChromeを使用。JavaScriptレンダリングが必要なページ向け。`wait_proc` でカスタム待機条件を定義可能（未指定時は`wait_seconds`秒スリープ）。

### 文字コード処理

`Utils#toutf8` はレスポンスのCharset指定 → metaタグ検出 → Kconvフォールバックの順で変換。Shift_JISはWindows-31Jとして扱う。

### キャッシュ

デフォルトのキャッシュディレクトリは実行カレントディレクトリ直下の `./cache/`。`Command#cache_dir` で変更可能。
