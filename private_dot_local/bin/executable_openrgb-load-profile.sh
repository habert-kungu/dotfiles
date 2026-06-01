#!/bin/bash
# Load OpenRGB profile at startup — no GUI needed.
# Requires: openrgb (apt package).
# Profile must be saved via OpenRGB GUI first.

PROFILE="habert"

if ! command -v openrgb &>/dev/null; then
  echo "openrgb not found. Install it first." >&2
  exit 1
fi

openrgb --server --profile "$PROFILE" &>/dev/null &
disown
