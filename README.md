# fm-tour

macOS の `fm` コマンド（Apple Foundation Models CLI）を、**Enter を押しながら1ステップずつ試せる**案内スクリプトです。
画像の読み取り（OCR）、決まった形での出力（構造化出力）、OpenAI 互換のローカル API サーバー（`fm serve`）、そして `fm` の限界まで、実際に動かして確かめられます。

> 📺 解説動画：**（動画の公開後に、ここへ URL を追記します）**
> YouTube「Tech千一夜」で、このツアーの見どころを紹介します。

## 必要なもの

- **macOS 27 以降**（`fm` コマンドが入っている環境）。`fm available` が `System model available` と答えること
- `zsh`・`curl`・`python3`（macOS に標準で入っています）
- ネットワーク接続は不要です（モデルは Mac の中で動きます）

## 使い方

```sh
git clone https://github.com/hdkworks/fm-tour.git
cd fm-tour
zsh try_fm.sh
```

各ステップで `Enter` を押すと、表示されたコマンドが実際に実行されます。`Ctrl-C` でいつでも止められます。

### ツアーの内容

| STEP | 内容 | 使うコマンド |
|---|---|---|
| 1 | モデルが使えるか確認 | `fm available` |
| 2 | 日本語で1回質問する | `fm respond` |
| 3 | 答えをストリーム表示する | `fm respond --stream` |
| 4 | 画像の文字を読み取る（OCR） | `fm respond --tool ocr --image` |
| 5 | 欲しい出力の形（スキーマ）を作る | `fm schema object` |
| 6 | スキーマを指定して、画像から JSON を抜き出す | `fm respond --schema --image` |
| 7 | トークン数を数える | `fm count-tokens` |
| 8 | 限界の確認：`fm` 自身のことを聞くと…（モデルの答えは間違っていることがある） | `fm respond` |
| 8b | 本物の説明（`fm serve --help`）と見比べる | `fm serve --help` |
| 9 | OpenAI 互換のローカル API サーバーを起動して、curl で呼ぶ | `fm serve` |

サンプルは `samples/` にあります（`receipt.png` は、このツアーのために作った架空の領収書です）。

## 試して分かったこと（2026-10 時点・macOS 27.0.1 での実測）

- コンテキストの大きさは**約8,000トークン**（日本語でおよそ1.6万字）が目安です。11,000トークンの入力では、エラーになりました。
- モデルは `fm` コマンド自身の使い方を**知りません**。聞くと、もっともらしい間違いを答えることがあります（STEP 8。いわゆる「幻覚」）。コマンド自体は実在しますが、モデルの説明は当てになりません。STEP 8b で本物の説明（`--help`）と見比べられます。
- 日本語を含む内容で、安全フィルターが誤って反応することがあります。`--guardrails permissive-content-transformations` を付けると通る場合があります。
- 生成の速さは、日本語でおよそ毎秒50文字でした。
- これらは**この環境での観察**です。OS のバージョンや設定で変わります。

## 設定

| 環境変数 | 既定値 | 意味 |
|---|---|---|
| `NO_COLOR` | （未設定） | 設定すると、STEP 8〜8b の赤い見出しを色なしで表示します |
| `FM_TOUR_PORT` | `1976` | 9 の `fm serve` が使うポート。使用中のときは別の番号を指定します（例：`FM_TOUR_PORT=1977 zsh try_fm.sh`） |

## 安全について

- スクリプトは、9 の `fm serve` を **`127.0.0.1`（自分の Mac の中だけ）** で待ち受けます。外のネットワークには公開しません。
- 詳しくは [SECURITY.md](SECURITY.md) を見てください。

## English summary

**fm-tour** is a step-by-step, press-Enter guided tour of the `fm` command (Apple Foundation Models CLI) on macOS 27+: plain responses, streaming, OCR, structured output with a schema, token counting, the model's limits, and `fm serve` (an OpenAI-compatible local API server bound to `127.0.0.1`).
Run `zsh try_fm.sh`. The prompts in the tour are in Japanese. No network access is needed; everything runs on-device.

## ライセンス

[MIT License](LICENSE) © 2026 Hideki Tanaka

## 貢献

[CONTRIBUTING.md](CONTRIBUTING.md) を見てください。変更履歴は [CHANGELOG.md](CHANGELOG.md) にあります。
