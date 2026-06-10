#!/bin/sh
# Pick a random image from the wallpapers directory and set it with feh.
# feh writes ~/.fehbg, which i3 runs at startup to restore the last wallpaper.
# (Replaces nitrogen, which intermittently hangs on an X round-trip here.)

DIR="$HOME/Pictures/wallpapers"

pick=$(find "$DIR" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n1)

[ -n "$pick" ] && exec feh --bg-fill "$pick"
