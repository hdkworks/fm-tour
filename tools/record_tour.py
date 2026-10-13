#!/usr/bin/env python3
"""Terminal.app で try_fm.sh を実際に動かし、Enter を自動で送りながらウィンドウの領域を画面収録する。

必要な許可（システム設定 → プライバシーとセキュリティ）:
  - 画面収録（screencapture / この Python を起動したアプリ）
  - アクセシビリティ（System Events でキーを送る）
使い方:  python3 tools/record_tour.py 出力.mov
"""
import subprocess, sys, time, signal, os, re

OUT = sys.argv[1] if len(sys.argv) > 1 else "fm_tour.mov"
FONT = 16
BOUNDS = (100, 30, 1500, 760)  # 画面（1600x900pt）の中のウィンドウ位置
PROMPT = "（Enter で実行）"
READ_PAUSE = 2.6   # 各ステップで、見る人が読むための間（秒）
MAX_WAIT = 90      # 1ステップの最大待ち（秒）


def osa(*lines):
    args = ["osascript"]
    for l in lines:
        args += ["-e", l]
    return subprocess.run(args, capture_output=True, text=True).stdout.strip()


def history():
    return osa('tell application "Terminal" to get history of selected tab of front window')


def count(h, s):
    return h.count(s)


def main():
    # 以前のツアーを止めて、窓を閉じる
    subprocess.run(["pkill", "-f", "try_fm.sh"])
    osa('tell application "Terminal"', 'repeat while (count of windows) > 0', 'try', 'close front window saving no',
        'on error', 'exit repeat', 'end try', 'end repeat', 'end tell')
    time.sleep(1)
    osa('tell application "Terminal"', 'activate', 'do script "cd ~/Projects/fm-tour && clear && zsh try_fm.sh"',
        'delay 1', f'set font size of current settings of front window to {FONT}',
        'set bounds of front window to {%d, %d, %d, %d}' % BOUNDS, 'end tell')
    time.sleep(2)
    x, y, x2, y2 = BOUNDS
    rec = subprocess.Popen(["screencapture", "-v", "-R", f"{x},{y},{x2-x},{y2-y}", OUT])
    time.sleep(2.5)
    try:
        prompts = count(history(), PROMPT)
        while True:
            time.sleep(READ_PAUSE)
            osa('tell application "Terminal" to activate', 'delay 0.3', 'tell application "System Events" to key code 36')
            t0 = time.time()
            while time.time() - t0 < MAX_WAIT:
                time.sleep(0.5)
                h = history()
                if "おしまい" in h:
                    time.sleep(3)
                    return
                if count(h, PROMPT) > prompts:
                    prompts = count(h, PROMPT)
                    break
            else:
                print("タイムアウト", file=sys.stderr)
                return
    finally:
        rec.send_signal(signal.SIGINT)
        rec.wait(timeout=30)


if __name__ == "__main__":
    main()
