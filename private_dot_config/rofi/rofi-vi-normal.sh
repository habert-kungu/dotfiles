#!/usr/bin/env bash

# Normal mode script for rofi

echo -e "Press j/k to navigate, i to switch to insert mode"

# Read key input
read -rsn1 key

case "$key" in
    j)
        rofi -show normal -kb-row-down "j"
        ;;
    k)
        rofi -show normal -kb-row-up "k"
        ;;
    i)
        rofi -show insert
        ;;
    *)
        rofi -show normal
        ;;
esac
