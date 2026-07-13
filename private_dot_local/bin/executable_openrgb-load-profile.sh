#!/bin/bash
# Set keyboard RGB color at startup. No server, no profile — just works.
# Customize the color below (hex RRGGBB).

COLOR="FF5500"

if ! command -v openrgb &>/dev/null; then
  echo "openrgb not found. Install it first." >&2
  exit 1
fi

openrgb --mode direct --color "$COLOR" &>/dev/null &
disown
