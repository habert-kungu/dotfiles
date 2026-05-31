#!/bin/bash
# Monitor display connections and auto-switch autorandr profiles
# Uses polling (more reliable than udevadm monitor pipelines)

export DISPLAY=":0"
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

LOG="/tmp/autorandr_monitor.log"
LOCKFILE="/tmp/autorandr_monitor.lock"
CURRENT_PROFILE=""

detect_profile() {
  xrandr --current 2>/dev/null | grep -q "^DP-1-3 connected" && {
    echo "docked"
    return
  }
  echo "mobile"
}

switch_if_needed() {
  exec 9>"$LOCKFILE"
  flock -n 9 || return

  target=$(detect_profile)
  echo "[$(date)] detected=$target current=$CURRENT_PROFILE" >> "$LOG"
  if [ "$target" != "$CURRENT_PROFILE" ]; then
    echo "[$(date)] switching to $target" >> "$LOG"
    autorandr --load "$target" >> "$LOG" 2>&1
    CURRENT_PROFILE="$target"
    echo "[$(date)] restarting i3" >> "$LOG"
    i3-msg restart >> "$LOG" 2>&1
  fi
}

# Initial load
switch_if_needed

# Poll every 3 seconds
while true; do
  sleep 3
  switch_if_needed
done
