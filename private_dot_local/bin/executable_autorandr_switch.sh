#!/bin/bash
# Triggered by udev on display change events.
# Runs as root; switches to the desktop user and lets autorandr pick the
# matching profile by EDID (robust to port renumbering, e.g. DP-1-2 vs DP-1-3).

LOCKFILE="/tmp/autorandr_switch.lock"
COOLDOWN_FILE="/tmp/autorandr_switch.cooldown"
COOLDOWN_SECS=10
LOG="/tmp/autorandr_udev.log"

USER="master"
UID_NUM=1000
DISPLAY=":0"

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

echo "[$(date)] udev triggered" >> "$LOG"

# Locate the user's X authority file.
XAUTHORITY="/run/user/${UID_NUM}/gdm/Xauthority"
if [ ! -f "$XAUTHORITY" ]; then
  for f in "/home/${USER}/.Xauthority" "/tmp/.Xauthority"; do
    [ -f "$f" ] && { XAUTHORITY="$f"; break; }
  done
fi

# Wait for udev events to settle before probing.
sleep 3
date +%s > "$COOLDOWN_FILE"

# Let autorandr choose the matching profile by EDID; fall back to mobile.
# Env must be set *inside* the su shell -- su does not inherit the caller's
# unexported variables, which is why the previous version logged "Can't open
# display" and never actually applied a profile.
su "$USER" -c "DISPLAY='$DISPLAY' XAUTHORITY='$XAUTHORITY' autorandr --change --default mobile" >> "$LOG" 2>&1
echo "[$(date)] change applied (exit $?)" >> "$LOG"

echo "[$(date)] done" >> "$LOG"
