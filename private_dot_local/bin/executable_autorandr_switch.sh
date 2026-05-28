#!/bin/bash
# Triggered by udev on display change events
# Runs as root, switches to user for autorandr

LOG="/tmp/autorandr_udev.log"
echo "[$(date)] udev triggered" >> "$LOG"

USER="master"
DISPLAY=":1"
XAUTHORITY="/run/user/1000/gdm/Xauthority"

# Fallback Xauthority paths
if [ ! -f "$XAUTHORITY" ]; then
  for f in /home/master/.Xauthority /tmp/.Xauthority; do
    [ -f "$f" ] && { XAUTHORITY="$f"; break; }
  done
fi

export DISPLAY XAUTHORITY
echo "[$(date)] DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY" >> "$LOG"

sleep 2

# Run autorandr as the user
su -c "autorandr --change" "$USER" >> "$LOG" 2>&1

# Restart i3 to apply layout
su -c "i3-msg restart" "$USER" >> "$LOG" 2>&1

echo "[$(date)] done" >> "$LOG"
