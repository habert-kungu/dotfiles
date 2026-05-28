#!/bin/bash
# Monitor DRM udev events and auto-switch autorandr profiles

export DISPLAY=":1"
export XAUTHORITY="$HOME/.Xauthority"

udevadm monitor --subsystem-match=drm --property --udev 2>/dev/null | while read -r line; do
  if echo "$line" | grep -q "ACTION=change"; then
    sleep 1.5
    autorandr --change
    i3-msg restart 2>/dev/null || true
  fi
done
