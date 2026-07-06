# Dotfiles

Personal configuration for Debian-based Linux systems with Regolith (i3 + GNOME), polybar, Neovim, and Zsh.

## Quick Install (One Command)

```bash
bash <(curl -sL https://raw.githubusercontent.com/habert-kungu/dotfiles/main/install.sh)
```

Or manually:

```bash
git clone https://github.com/habert-kungu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

---

## What's Included

### Terminal & Shell
- **Zsh** with Oh My Zsh
- **fzf** - Fuzzy finder for files/commands
- **fd** (fdfind) - Fast file finder
- **bat** - Cat clone with syntax highlighting
- **ripgrep** - Fast grep alternative

### Editor & Development
- **Neovim** (NvChad-based configuration)
- **tmux** - Terminal multiplexer
- **Python** (via Miniconda/Anaconda)
- **Node.js** with npm/pnpm/bun

### Desktop Environment
- **Regolith** - i3 + GNOME session (displays, sound, bluetooth, network handled by GNOME)
- **polybar** - Status bar
- **picom** - Compositor (transparency/blur)
- **rofi** - App launcher
- **Kitty/Alacritty/Wezterm** - Terminal emulators

---

## Hardware Management

Regolith handles all hardware via GNOME services — no per-machine config needed:

- **Displays** — `gnome-control-center display` or hotplug detection
- **Sound** — PulseAudio/PipeWire, managed by GNOME
- **Bluetooth** — `gnome-control-center bluetooth`
- **Wi-Fi** — `gnome-control-center wifi` or `nm-connection-editor`

---

## Commands

### Fuzzy File Search (Main Feature)

| Command | Description |
|---------|-------------|
| `ff` | Fuzzy search files (filtered) -> opens in Neovim |
| `fp` | Fuzzy search files -> just show (no open) |
| `ffr` | Fuzzy search -> open in Neovim |

**Filters applied** (ignored in search):
- `.git`, `node_modules`, `__pycache__`
- `venv`, `.venv`, `dist`, `build`
- `target`, `.cache`, `Downloads`
- `anaconda3`, `miniconda3`, `.cargo`
- `vendor`, `.next`, `.nuxt`, `*.log`

### Compilation

| Command | Description |
|---------|-------------|
| `makec <file>` | Compile C file with gcc |
| `makecpp <file>` | Compile C++ file with g++ |
| `make <file>` | Auto-detect and compile |
| `fcpp` | Fuzzy find .cpp file -> compile -> run |

### Other Aliases

| Command | Description |
|---------|-------------|
| `fd` | fdfind (fast file search) |
| `lzd` | lazydocker |
| `ff` | Fuzzy file search -> nvim |

---

## Keybindings

### In Terminal (fzf default)
- `Ctrl+T` - Fuzzy find files
- `Ctrl+R` - Fuzzy search command history
- `Alt+C` - Fuzzy change directory

### i3 / Regolith
See `~/.config/i3/config` for all keybindings (Mod4 = Super key).

| Key | Action |
|-----|--------|
| `$mod+Return` | Terminal (WezTerm) |
| `$mod+b` | Firefox |
| `$mod+d` | Rofi app launcher |
| `$mod+q` | Close window |
| `$mod+j/k/l/;` | Focus left/down/up/right |
| `$mod+Shift+j/k/l/;` | Move window |
| `$mod+1-0` | Switch to workspace |
| `$mod+Shift+1-0` | Move window to workspace |
| `$mod+r` | Resize mode |
| `$mod+f` | Fullscreen toggle |
| `$mod+Shift+c` | Reload i3 config |
| `$mod+Shift+r` | Restart i3 |

### Audio
- `F1` / `XF86AudioMute` — Mute toggle
- `F2` / `XF86AudioLowerVolume` — Volume down
- `F3` / `XF86AudioRaiseVolume` — Volume up

### In Neovim (Space as leader)
- `Space + ff` - Telescope file picker
- `Ctrl+P` - Quick open files (nvim-cmp)
- `Ctrl+Shift+P` - Command palette

---

## File Structure

```
dotfiles/
├── install.sh                  # One-command install script
├── README.md                   # This file
├── dot_zshrc                   # Zsh configuration
├── dot_bashrc                  # Bash configuration
├── dot_tmux.conf               # Tmux configuration
├── dot_gitconfig               # Git configuration
├── dot_condarc                 # Conda configuration
├── dot_vscode-extensions        # VS Code extensions list
└── private_dot_config/          # User configs (nvim, i3, polybar, etc.)
    ├── nvim/                   # Neovim config
    ├── i3/                     # i3 config (keybindings, workspaces)
    ├── polybar/                # Polybar config
    ├── rofi/                   # Rofi config
    ├── kitty/                  # Kitty terminal
    ├── wezterm/                # WezTerm terminal
    └── picom/                  # Picom compositor (blur/opacity)
```

---

## Dependencies Installed by `install.sh`

### Core
- zsh, curl, git, wget, stow
- fzf, fd-find (fd), ripgrep, bat, tmux

### Build Tools
- build-essential, cmake, pkg-config
- libssl-dev, libwebkit2gtk-4.1-dev

### Desktop
- Regolith desktop (i3 + GNOME session, compositor, rofi, notifications)
- polybar

### Terminals
- kitty, alacritty, wezterm

### Programming
- python3, python3-pip, python3-venv, python3-dev
- nodejs, npm
- golang-go
- Miniconda3 (optional)

### Plugins
- Oh My Zsh
- zsh-autosuggestions
- zsh-syntax-highlighting

---

## Usage Tips

### First Time Setup
```bash
# Run the install script
bash install.sh

# Reboot and select Regolith from your display manager
# Restart terminal or source
source ~/.zshrc

# In Neovim, sync plugins
:LazySync
```

### Updating Dotfiles
```bash
# Make changes, then
cd dotfiles
git add .
git commit -m "description"
git push
```

### Applying Changes to Other Machines
```bash
chezmoi init https://github.com/habert-kungu/dotfiles.git
chezmoi apply
```

---

## Troubleshooting

### fzf not working
```bash
sudo apt install fzf
# Or manually
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Neovim plugins not loading
```bash
# Open nvim and run
:LazySync
```

### Conda not initializing
```bash
source ~/anaconda3/etc/profile.d/conda.sh
conda init zsh
# Or for miniconda3
source ~/miniconda3/etc/profile.d/conda.sh
conda init zsh
```

### Regolith not showing up after install
```bash
# Reboot and select Regolith from your display manager (GDM/LightDM)
# The session uses Regolith's i3 with GNOME services underneath
```

---

## Customization

Edit these files to customize:
- `dot_zshrc` - Shell aliases and functions
- `private_dot_config/nvim/lua/` - Neovim config
- `private_dot_config/i3/config` - i3 keybindings and workspaces
- `private_dot_config/polybar/config.ini` - Status bar
- `private_dot_config/picom/picom.conf` - Compositor (blur/opacity)
- `private_dot_config/wezterm/wezterm.lua` - WezTerm theme

After editing, commit and push to sync across machines.

---

For more info, see [chezmoi docs](https://www.chezmoi.io/user-guide/) and [Regolith docs](https://regolith-desktop.com/).
