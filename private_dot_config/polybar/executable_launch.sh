#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.3; done

# Wait for xrandr to see monitors (can be slow after boot)
for i in $(seq 1 10); do
  count=$(xrandr --query 2>/dev/null | grep -c ' connected')
  [ "$count" -gt 0 ] && break
  sleep 0.5
done

# Prefer explicitly primary, then +0+0 monitor, then first connected
primary=$(xrandr --query | awk '/ primary/{print $1; exit}')
: "${primary:=$(xrandr --query | awk '/ connected.*\+0\+0/{print $1; exit}')}"
: "${primary:=$(xrandr --query | awk '/ connected/{print $1; exit}')}"

MONITOR="$primary" polybar main >> /tmp/polybar.log 2>&1 &
disown
