# Regolith Dotfiles — Handoff Notes

## Summary
Migrated habert-kungu's dotfiles from bare i3 + polybar to **Regolith Linux** (i3 + GNOME session on Debian Trixie). Regolith handles displays/sound/bluetooth/network via GNOME, eliminating per-machine hardware configs. Custom i3 keybindings, bar, compositor, and terminal configs are preserved via chezmoi-managed dotfiles.

## Dotfiles Repo
`github.com/habert-kungu/dotfiles` — managed with **chezmoi**.

## What's Working

### i3 Keybindings (`~/.config/regolith3/i3/config`)
Full replacement config (Regolith loads this instead of `/etc/regolith/i3/config` if present):
- **Nav**: j=left, k=down, l=up, ;=right
- **Mod4+d**: rofi app launcher
- **Mod4+Return**: wezterm
- **Mod4+b**: firefox, Mod4+c: code, Mod4+t: thunar
- **Mod4+q**: kill window
- **Mod4+h split h** (instead of Regolith's `g`), Mod4+v split v, Mod4+f fullscreen
- **Mod4+e**: layout toggle split, Mod4+n: layout default
- **Mod4+Shift+space**: floating toggle, Mod4+space: focus mode toggle
- **Mod4+Shift+d**: gnome-control-center display (GNOME handles displays)
- **Mod4+Shift+w**: random wallpaper cycle
- **F1/F2/F3**: audio mute/vol down/vol up via wpctl
- **Mod4+Shift+e**: i3-nagbar exit dialog, **Mod4+Shift+x**: logout, **Mod4+Shift+p**: power off
- **Mod4+Escape**: GNOME screen lock
- Workspaces: Mod4+1-0 switch, Mod4+Shift+1-0 move

### Bar — NOW POLYBAR (`~/.config/polybar/config.ini`), 2026-07-06
The i3bar/i3xrocks bar was retired and replaced with a **minimal Omarchy-style
Polybar** (i3bar can't do rounded/floating bars or per-module styling; Waybar was
ruled out because it is Wayland-only and this is an X11/i3 session).
- **Style**: floating rounded bar (`radius 10`, `offset 10/6`, `width 100%:-20`),
  dark near-black bg `#11111b`, flat modules (colored Nerd Font icon + value, `·`
  separators), Catppuccin accent colours, focused workspace = blue underline.
- **Modules**: left `i3` (workspaces) · center `xwindow` (title) · right
  `volume memory cpu wlan battery date` — all polybar **internal** modules
  (no external i3xrocks scripts).
- **Clickable / GNOME integration**: each right module has a `click-left` that
  opens the matching GNOME panel — volume→`gnome-control-center sound`
  (right-click→pavucontrol), wlan→`… wifi`, battery→`… power`, date→`… datetime`,
  mem/cpu→`gnome-system-monitor`.
- **Launch**: `~/.config/polybar/launch.sh` (picks primary monitor), autostarted
  from i3 via `exec_always`. No `bar {}` block in the i3 config = no i3bar, no tray.
- **Window gap**: i3 `smart_gaps off` + `gaps top 5` so tiled windows clear the
  floating bar (smart_gaps had been collapsing the gap for lone windows).
- Old i3xrocks conf.d (`~/.config/regolith3/i3xrocks/`) is now unused (harmless).

<details><summary>Previous i3xrocks bar (retired)</summary>

Replaced polybar with Regolith i3bar + i3xrocks, styled to match old polybar:
- **Position**: top, height 30px
- **Colors**: bg #1c1c1c, text #cdd6f4, accent #89b4fa, muted #585b70
- **Font**: JetBrainsMono Nerd Font 12
- **Modules** (left to right): workspaces, window name | volume, memory, cpu, wifi, battery, time
- Depends on apt packages: `i3xrocks-volume i3xrocks-memory i3xrocks-wifi i3xrocks-battery i3xrocks-focused-window-name i3xrocks-cpu-usage i3xrocks-net-traffic i3xrocks-time`
</details>

### Compositor (`~/.config/picom/picom.conf`)
- GLX backend, dual_kawase blur (strength 8), no shadows
- Active opacity 0.89, inactive 0.69, dim 0.08
- Exclusions for polybar, browsers, RustDesk, Comet

### Other preserved configs
- **WezTerm** (`~/.config/wezterm/wezterm.lua`): Custom Gruvbox theme
- **Neovim** (`~/.config/nvim/`): NvChad-based
- **Zsh** (`~/.zshrc`): Oh My Zsh with autosuggestions + syntax highlighting
- **Rofi** (`~/.config/rofi/config.rasi`): Gruvbox theme
- **tmux** (`~/.tmux.conf`)

## What Was Removed
- autorandr profiles/scripts/systemd (GNOME handles displays)
- bluetooth/wifi custom scripts (GNOME panels handle both)
- nm-applet from i3 autostart (GNOME/gnome-flashback already launches it)
- `dex --autostart` from i3 config (gnome-session already runs every XDG autostart entry; dex re-ran them → duplicate tray icons)
- Duplicate `gnome-flashback-media-keys` exec from i3 config (gnome-flashback launches it)
- polybar config and autostart (replaced with Regolith bar)
- Hardcoded eth module (`enp0s20f0u6u4`) from polybar
- Old `~/.config/i3/config` (moved to `config.old-regolith-migration`)

## Bar Redundancy — FIXED (2026-07-06)
The top bar showed duplicate indicators. Root cause: three mechanisms each
launched the same tray applets — gnome-flashback's own autostart, `dex --autostart`,
and explicit `exec` lines in the i3 config — so nm-applet/media-keys ran 2–3×.
The i3xrocks `wifi` block then added a third network readout on top.

Resolution (design choice: **text bar / polybar style** — i3xrocks blocks are the
single readout, tray kept only for bluetooth):
- Removed the duplicate `exec nm-applet`, `exec gnome-flashback-media-keys`, and
  `exec dex --autostart` lines from `~/.config/regolith3/i3/config`.
- Added `~/.config/autostart/nm-applet.desktop` with `Hidden=true` to suppress the
  network tray icon entirely (wifi name is shown by the i3xrocks `wifi` block; click
  the block to open the network panel). Blueman tray icon retained (no bar module for BT).
- Trade-off: with nm-applet disabled, NetworkManager's secret-agent prompt for *new*
  secured Wi-Fi comes from GNOME Control Center instead — open it to join a new network.
  To revert, delete the `nm-applet.desktop` override.

**Second pass — tray removed entirely + corner padding (2026-07-06):**
- Set `tray_output none` in the bar block. This removes ALL tray icons at once:
  bluetooth (blueman-tray), the remote-desktop/app icon (rustdesk --tray), and
  gnome-flashback's sound status icon (which was the phantom "duplicate speaker" — the
  i3xrocks volume block only ever emits one glyph). blueman/rustdesk keep running
  headless; their tray windows go IsUnMapped (no stray corner icon).
- Added `padding 5px` to the bar block (valid in i3 4.24) for a 5px inset so content
  doesn't hug the screen corners.
- To restore any tray icon, set `tray_output primary` again.
- **Flameshot**: with the tray gone, its icon is gone too — but it never needed it.
  Added `exec --no-startup-id flameshot` (it previously only ran because `dex` launched
  it, so it would NOT have autostarted after `dex` was removed). Screenshots are now
  keybound: `Print` = `flameshot gui` (interactive), `Mod+Print` = full screen to
  `~/Pictures`, `Mod+Shift+Print` = `maim -s` fallback.

## What Still May Need Work
- **i3xrocks duplicate lines**: wifi and cpu scripts output both full_text + short_text (normal i3blocks behavior — only one shows at a time; verified no visual duplicate)
- **Battery icon accuracy**: script uses Xresources labels for battery levels (`i3xrocks.label.battery80` etc.), icons may not render without proper Nerd Font
- **Pluely app**: user data removed, still need to run `sudo apt remove -y pluely`
- **Border fix temp file**: `~/.config/regolith3/i3/config.d/00-border-fix` is a temporary partial — remove after confirming borders are fine with the full replacement config

## Key File Map
```
~/.config/
├── regolith3/
│   ├── i3/config                          # i3 config (Regolith auto-loads if exists)
│   ├── i3xrocks/conf.d/                   # i3xrocks bar block configs
│   │   ├── 01_setup                       # Global: colors, font, separator width
│   │   ├── 10_volume                      # Volume block
│   │   ├── 20_memory                      # Memory block
│   │   ├── 30_cpu                         # CPU block
│   │   ├── 40_wifi                        # Wi-Fi block
│   │   ├── 50_battery                     # Battery block
│   │   └── 90_time                        # Date/time block
│   └── Xresources                         # Regolith Xresources (i3xrocks colors/fonts)
├── picom/picom.conf                       # Compositor config
├── rofi/config.rasi                       # Rofi launcher theme
├── wezterm/wezterm.lua                    # WezTerm theme
└── nvim/                                  # Neovim config
```

## Dotfiles Structure (chezmoi source)
```
dotfiles/
├── install.sh                             # One-command install (Regolith PPA + packages)
├── private_dot_config/
│   ├── regolith3/i3/config                # -> ~/.config/regolith3/i3/config
│   ├── regolith3/i3xrocks/conf.d/         # -> ~/.config/regolith3/i3xrocks/conf.d/
│   ├── regolith3/Xresources               # -> ~/.config/regolith3/Xresources
│   ├── picom/picom.conf                   # -> ~/.config/picom/picom.conf
│   ├── rofi/config.rasi                   # -> ~/.config/rofi/config.rasi
│   ├── wezterm/wezterm.lua                # -> ~/.config/wezterm/wezterm.lua
│   └── nvim/                              # -> ~/.config/nvim/
├── dot_zshrc, dot_bashrc, dot_tmux.conf, dot_gitconfig  # shell & tool configs
└── dot_condarc, dot_vscode-extensions
```

## Fresh Machine Setup
```bash
git clone https://github.com/habert-kungu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
# Reboot, select Regolith from login screen
```
Install script handles: Regolith PPA, desktop packages, **bar/desktop apps**
(polybar, flameshot, rofi, pavucontrol, pipewire+wireplumber, gnome-calendar,
gnome-system-monitor, gnome-control-center, blueman, unclutter, playerctl),
**Nerd Fonts** (JetBrainsMono + Symbols — required for the bar glyphs), Neovim,
WezTerm, terminals, programming tools, miniconda, oh-my-zsh, chezmoi, wallpapers,
OpenRGB, Claude CLI, OpenCode, Deno.
