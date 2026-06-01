#!/bin/bash
# Triggered by udev on display change events
# Runs as root, switches to user for autorandr

LOCKFILE="/tmp/autorandr_switch.lock"
COOLDOWN_FILE="/tmp/autorandr_switch.cooldown"
COOLDOWN_SECS=10

exec 9>"$LOCKFILE"
flock -n 9 || exit 1

# Cooldown: skip if we just ran recently (breaks udev event storms)
if [ -f "$COOLDOWN_FILE" ]; then
  last_run=$(cat "$COOLDOWN_FILE")
  now=$(date +%s)
  if [ $((now - last_run)) -lt "$COOLDOWN_SECS" ]; then
    exit 0
  fi
fi

LOG="/tmp/autorandr_udev.log"
echo "[$(date)] udev triggered" >> "$LOG"

USER="master"
DISPLAY=":0"
XAUTHORITY="/run/user/1000/gdm/Xauthority"

if [ ! -f "$XAUTHORITY" ]; then
  for f in /home/master/.Xauthority /tmp/.Xauthority; do
    [ -f "$f" ] && { XAUTHORITY="$f"; break; }
  done
fi

# Wait for udev events to settle before probing
sleep 3

date +%s > "$COOLDOWN_FILE"

# Detect which outputs are connected via xrandr (more reliable than autorandr matching)
detect_profile() {
  su -c "xrandr --current" "$USER" 2>/dev/null | grep -q "^DP-1-3 connected" && echo "docked" || echo "mobile"
}

current_profile=$(detect_profile)
echo "[$(date)] detected profile: $current_profile" >> "$LOG"

su -c "autorandr --load $current_profile" "$USER" >> "$LOG" 2>&1

echo "[$(date)] done" >> "$LOG"
