# 変更履歴

このファイルは [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) の形式に沿っています。

## [Unreleased]

## [0.1.1] - 2026-10-14

### Added
- 幻覚の実験（8〜8b）の前後に、赤い帯の見出し「【幻覚の実験を開始します】／【幻覚の実験を終わります】」を表示（白の太字・黒い背景でも読める。`NO_COLOR` を設定すると色なし）

### Changed
- ステップ番号を「STEP n」表記に変更（Terminal のフォントで丸数字（1〜9）が崩れて読めないため）
- 8 に「コマンドは本物だが、モデルの説明は間違うことがある」という案内を追加し、8b で本物の説明（`fm serve --help`）と見比べられるようにした

### Added
- `tools/record_tour.py`：Terminal.app でツアーを動かし、Enter を自動で送りながらウィンドウを画面収録する補助スクリプト（動画撮影用。画面収録とアクセシビリティの許可が必要）

## [0.1.0] - 2026-10-14

### Added
- `try_fm.sh`：`fm` コマンドを Enter で1ステップずつ試せる案内スクリプト（9ステップ）
- `samples/`：架空の領収書の画像（`receipt.png`）と、構造化出力用のスキーマ（`receipt.schema.json`）
- `README.md`・`LICENSE`（MIT）・`SECURITY.md`・`CONTRIBUTING.md`

### Security
- `fm serve` を `127.0.0.1` に固定して起動し、終了時に必ず停止する
- ポートが使用中のときは、起動せずにエラーで止める（`FM_TOUR_PORT` で変更可）
- ログの一時ファイルは `mktemp` で作り、終了時に削除する
