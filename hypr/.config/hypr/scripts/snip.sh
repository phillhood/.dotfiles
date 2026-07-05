#!/usr/bin/env bash
# Region snip, Windows Snipping Tool style (bound to Super+Shift+S).
#   1. slurp region selection
#   2. grim captures it, copied to clipboard immediately
#   3. opens in swappy for editing; Ctrl+C re-copies edits, Ctrl+S saves
#
# Gaming-aware: a true-fullscreen window (e.g. WoW) renders on top of floating
# windows, so swappy would be hidden behind the game. When something is
# fullscreen we relocate swappy to a monitor that isn't hosting it (the side
# monitor), leaving the game untouched.

tmp="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp"' EXIT

# Region selection; cancel (Esc) -> empty output -> exit quietly.
geom="$(slurp)" || exit 0
[ -n "$geom" ] || exit 0

# grim writes the PNG directly to the file (piping it via hyprshot --raw got
# TRUNCATED under a busy fullscreen game). Bail if grim fails or the result is
# truncated: a partial PNG (no trailing IEND chunk) on the clipboard renders cut
# off and freezes whatever you paste into.
grim -g "$geom" "$tmp" || exit 0
if [ ! -s "$tmp" ] || ! tail -c 8 "$tmp" | grep -qa IEND; then
    exit 0
fi

# Initial clip straight to the clipboard (wl-copy buffers it in memory).
wl-copy --type image/png < "$tmp"

# If anything is fullscreen, pick a monitor that isn't hosting it for the editor.
target_mon=""
fs_mon="$(hyprctl clients -j 2>/dev/null | jq -r 'first(.[] | select(.fullscreen != 0)) | .monitor')"
if [ -n "$fs_mon" ] && [ "$fs_mon" != "null" ]; then
    target_mon="$(hyprctl monitors -j 2>/dev/null | jq -r --argjson m "$fs_mon" \
        'first(.[] | select(.id != $m)) | .name')"
fi

# Open the editor (swappy reliably grabs focus on launch).
swappy -f "$tmp" &
sw=$!

# Once swappy has focus, move it onto the non-fullscreen monitor. Guarding on
# focus == swappy ensures we never accidentally move the game itself.
if [ -n "$target_mon" ] && [ "$target_mon" != "null" ]; then
    for _ in $(seq 1 20); do
        if [ "$(hyprctl activewindow -j 2>/dev/null | jq -r '.class')" = "swappy" ]; then
            hyprctl dispatch "hl.dsp.window.move({ monitor = \"$target_mon\" })" >/dev/null 2>&1
            break
        fi
        sleep 0.1
    done
fi

wait "$sw"
