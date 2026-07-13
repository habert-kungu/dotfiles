#!/bin/bash
# Load OpenRGB profile at startup. If profile fails (device path changed),
# falls back to direct color mode so the keyboard always lights up.

PROFILE="habert"
FALLBACK_COLOR="FF5500"

if ! command -v openrgb &>/dev/null; then
  echo "openrgb not found. Install it first." >&2
  exit 1
fi

openrgb --server --profile "$PROFILE" &>/dev/null &
sleep 2

# If profile load failed (or keyboar not lit), apply fallback color
if ! openrgb --mode direct --color "$FALLBACK_COLOR" &>/dev/null; then
  echo "openrgb: keyboard not detected or profile failed" >&2
fi

disown
