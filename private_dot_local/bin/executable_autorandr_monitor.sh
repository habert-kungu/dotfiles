#!/bin/bash
# Monitor display connections and auto-switch autorandr profiles
# Uses polling (more reliable than udevadm monitor pipelines)

export DISPLAY=":0"
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

LOCKFILE="/tmp/autorandr_monitor.lock"
CURRENT_PROFILE=""

detect_profile() {
  xrandr --current 2>/dev/null | grep -q "^DP-1-3 connected" && echo "docked" || echo "mobile"
}

switch_if_needed() {
  exec 9>"$LOCKFILE"
  flock -n 9 || return

  target=$(detect_profile)
  if [ "$target" != "$CURRENT_PROFILE" ]; then
    autorandr --load "$target"
    CURRENT_PROFILE="$target"
    i3-msg restart 2>/dev/null || true
  fi
}

# Initial load
switch_if_needed

# Poll every 3 seconds
while true; do
  sleep 3
  switch_if_needed
done
