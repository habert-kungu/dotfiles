#!/bin/bash
# Outputs short bluetooth state for polybar; icon comes from polybar's format-prefix.
device=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
if [ -n "$device" ]; then
  echo "$device"
else
  powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')
  if [ "$powered" = "yes" ]; then
    echo "on"
  else
    echo "off"
  fi
fi
