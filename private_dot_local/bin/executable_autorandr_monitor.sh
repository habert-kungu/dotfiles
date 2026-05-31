#!/bin/bash
# Monitor DRM udev events and auto-switch autorandr profiles

export DISPLAY=":0"
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

LOCKFILE="/tmp/autorandr_monitor.lock"
CURRENT_PROFILE=""

detect_profile() {
  xrandr --current 2>/dev/null | grep -q "^DP-1-3 connected" && echo "docked" || echo "mobile"
}

udevadm monitor --subsystem-match=drm --udev 2>/dev/null | stdbuf -oL grep --line-buffered "ACTION=change" | while read -r _; do
  sleep 2

  exec 9>"$LOCKFILE"
  flock -n 9 || continue

  target=$(detect_profile)
  if [ "$target" != "$CURRENT_PROFILE" ]; then
    autorandr --load "$target"
    CURRENT_PROFILE="$target"
    i3-msg restart 2>/dev/null || true
  fi
done
