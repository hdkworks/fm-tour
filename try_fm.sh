#!/bin/zsh
# fm-tour: macOS の `fm` コマンド（Apple Foundation Models CLI）を、Enter で1ステップずつ試す案内スクリプト。
# Ctrl-C でいつでも止められます。ネットワークへは出ません（⑨ の fm serve も自分の Mac の中だけで待ち受けます）。
set -u
cd "$(dirname "$0")" || exit 1

PORT="${FM_TOUR_PORT:-1976}"
SAMPLES="samples"

if ! command -v fm >/dev/null 2>&1; then
  echo "fm コマンドが見つかりません。macOS 27 以降（Apple Foundation Models CLI が入った環境）で実行してください。" >&2
  exit 1
fi

strip() { sed 's/\x1b\[[0-9;]*m//g'; }

# 目立つ見出し（白の太字＋赤い帯。黒い背景でも読める）。NO_COLOR を設定すると色を付けない。
banner() {   # banner "文字（全角のみ）" 幅（半角換算）
  local text="$1" width="$2" blank
  blank="$(printf '%*s' "$width" '')"
  echo ""
  if [ -n "${NO_COLOR:-}" ]; then
    echo "$text"
  else
    printf '\033[1;97;48;5;196m%s\033[0m\n\033[1;97;48;5;196m  %s  \033[0m\n\033[1;97;48;5;196m%s\033[0m\n' "$blank" "$text" "$blank"
  fi
}

step() {   # step "説明" コマンド...
  local msg="$1"; shift
  echo ""
  echo "──────────────────────────────────────────────"
  echo "▶ $msg"
  echo "  \$ ${SHOW:-$*}"
  echo -n "  （Enter で実行）"; read -r _
  "$@" 2>&1 | strip
}

echo "fm コマンド お試しツアー（macOS 27 / Apple Foundation Models）"
echo "各ステップで Enter を押すと、実際に fm を実行します。Ctrl-C で中止できます。"

step "① モデルが使えるか確認" fm available

step "② 1回の質問に答えさせる（日本語）" fm respond --no-stream "パスキーを、初心者向けに2文で説明して"

step "③ 文章をストリームで表示する（1文字ずつ出てくる）" fm respond --stream "日本の四季を100字くらいで説明して"

step "④ 画像を読ませる（領収書の画像を OCR で読み取る）" fm respond --no-stream --tool ocr --image "$SAMPLES/receipt.png" --text "この画像の文字を読み取って"

echo ""; echo "── 構造化出力：先に『欲しい形』を定義します ──"
step "⑤ スキーマ（欲しい項目：shop / date / total）を作る" fm schema object --name Receipt --string shop --string date --int total

step "⑥ スキーマを指定して、画像から JSON を抜き出す" fm respond --no-stream --schema "$SAMPLES/receipt.schema.json" --image "$SAMPLES/receipt.png" --text "領収書の内容を抽出して"

step "⑦ トークン数を数える（コンテキストは約8,000トークンが目安）" fm count-tokens "パスキーの仕組みを教えて"

banner "【幻覚の実験を開始します】" 30
echo ""
echo "※ ⑧ は『モデルが間違えることがある』例です。fm serve というコマンドは本物ですが、"
echo "   モデルは fm 自身のことを学習していないので、その説明を作り込んでしまうことがあります（幻覚）。"
echo "   答えは実行のたびに変わります。次の ⑧b で、本物の説明と見比べます。"
step "⑧ 限界の確認：fm 自身のことを聞くと…（モデルの答えに注目）" fm respond --no-stream "macOSのfmコマンドのserveサブコマンドの使い方を教えて"

real_help() { fm serve --help 2>&1 | strip | grep -v '^[[:space:][:cntrl:]⠀-⣿]*$'; }
SHOW="fm serve --help" step "⑧b 本物の説明と見比べる（fm serve --help）" real_help
banner "【幻覚の実験を終わります】" 30

echo ""
echo "──────────────────────────────────────────────"
echo "▶ ⑨ fm serve（OpenAI 互換のローカル API サーバー）を起動して、curl で呼ぶ"
echo "  \$ fm serve --host 127.0.0.1 --port $PORT   （バックグラウンドで起動。自分の Mac の中だけで待ち受けます）"
echo "  \$ curl http://127.0.0.1:$PORT/v1/models"
echo -n "  （Enter で実行）"; read -r _

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "ポート $PORT はすでに使われています。FM_TOUR_PORT=1977 zsh try_fm.sh のように、別のポートを指定してください。" >&2
  exit 1
fi

LOG="$(mktemp -t fm-tour-serve)"
fm serve --host 127.0.0.1 --port "$PORT" > "$LOG" 2>&1 &
SERVE_PID=$!
trap 'kill "$SERVE_PID" 2>/dev/null; rm -f "$LOG"' EXIT INT TERM
sleep 3
curl -s "http://127.0.0.1:$PORT/health"; echo
curl -s "http://127.0.0.1:$PORT/v1/models"; echo

echo ""
echo "  \$ curl http://127.0.0.1:$PORT/v1/chat/completions ...   （質問して、答えを受け取る）"
echo -n "  （Enter で実行）"; read -r _
curl -s "http://127.0.0.1:$PORT/v1/chat/completions" -H 'Content-Type: application/json' \
  -d '{"model":"system","stream":false,"messages":[{"role":"user","content":"Hello を日本語で言って"}]}' \
  | python3 -m json.tool --no-ensure-ascii 2>/dev/null | head -30

echo ""
echo "サーバーを止めます。おしまい。"
