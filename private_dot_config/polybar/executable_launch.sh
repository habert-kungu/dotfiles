#!/usr/bin/env bash
# Launch the Omarchy-style polybar on the primary monitor (falls back to first
# connected output). Kills any running instance first so it is reload-safe.

polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.3; done

primary=$(xrandr --query | awk '/ primary/{print $1; exit}')
: "${primary:=$(xrandr --query | awk '/ connected/{print $1; exit}')}"

MONITOR="$primary" polybar main >>/tmp/polybar.log 2>&1 &
disown
