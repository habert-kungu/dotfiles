#!/bin/bash
# Monitor display connections and auto-switch autorandr profiles.
# Polls periodically and lets `autorandr --change` pick the matching profile
# by EDID fingerprint -- no hardcoded output names (DP-1-3 etc.), so it is
# immune to port renumbering (DP-1-2 vs DP-1-3) across docks.

export DISPLAY=":0"
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

LOG="/tmp/autorandr_monitor.log"
LOCKFILE="/tmp/autorandr_monitor.lock"

# Name of the profile autorandr currently considers active ("(current)").
active_profile() {
  autorandr 2>/dev/null | grep -F '(current)' | awk '{print $1}' | tr '\n' ','
}

# Remember what is applied now so we only restart i3 on a real change below.
LAST=$(active_profile)

switch_if_needed() {
  exec 9>"$LOCKFILE"
  flock -n 9 || return

  # autorandr loads the saved profile whose EDID fingerprint matches the
  # connected outputs; --default falls back to mobile when nothing matches.
  autorandr --change --default mobile >> "$LOG" 2>&1

  # Restart i3 only when the active profile actually changed, so polybar and
  # the wallpaper re-initialise for the new layout.
  local now
  now=$(active_profile)
  if [ -n "$now" ] && [ "$now" != "$LAST" ]; then
    echo "[$(date)] profile changed: '$LAST' -> '$now', restarting i3" >> "$LOG"
    LAST="$now"
    i3-msg restart >> "$LOG" 2>&1
  fi
}

# Initial sync (only restarts i3 if --change actually alters the profile)
switch_if_needed

# Poll every 3 seconds
while true; do
  sleep 3
  switch_if_needed
done
