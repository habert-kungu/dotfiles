
#!/usr/bin/env bash

MODE="normal"

rofi \
    -modi "normal:~/.config/rofi/rofi-vi-normal.sh,insert:~/.config/rofi/rofi-vi-insert.sh" \
    -show normal \
    -kb-cancel "Escape,Control+c" \
    -kb-accept-entry "!Shift+Return,Return" \
    -kb-mode-next "Shift+Right,Control+Tab" \
    -kb-mode-previous "Shift+Left,Control+Shift+Tab" \
    -kb-custom-1 "Insert" \
    -kb-custom-2 "Control+["
