# Dotfiles

Personal configuration for Debian-based Linux systems with i3, polybar, Neovim, and Zsh.

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
- **i3** - Tiling window manager
- **polybar** - Status bar
- **picom** - Compositor (transparency/blur)
- **rofi** - App launcher
- **Kitty/Alacritty/Wezterm** - Terminal emulators
- **autorandr** - Automatic display switching

---

## Display Switching

Uses **autorandr** for automatic monitor detection.

### Profiles
- `docked` - External monitor connected (DP-1-3 at 1920x1080)
- `mobile` - Laptop only (eDP-1 at 1366x768)

### How it works
- Automatically detects display changes via udev rules
- Runs `autorandr --change` on i3 startup
- Works when plugging/unplugging cables

### Manual switch
```bash
Super+Shift+D  # Manual display switch keybinding
```

### Creating new profiles
```bash
# Set up your displays manually, then save:
autorandr --save profile-name

# Or save with current resolution:
autorandr --save my-setup --force
```

### List profiles
```bash
autorandr --list
```

---

## Commands

### Fuzzy File Search (Main Feature)

| Command | Description |
|---------|-------------|
| `ff` | Fuzzy search files (filtered) → opens in Neovim |
| `fp` | Fuzzy search files → just show (no open) |
| `ffr` | Fuzzy search → open in Neovim |

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
| `fcpp` | Fuzzy find .cpp file → compile → run |

### Other Aliases

| Command | Description |
|---------|-------------|
| `fd` | fdfind (fast file search) |
| `lzd` | lazydocker |
| `ff` | Fuzzy file search → nvim |

---

## Keybindings

### In Terminal (fzf default)
- `Ctrl+T` - Fuzzy find files
- `Ctrl+R` - Fuzzy search command history
- `Alt+C` - Fuzzy change directory

### In Neovim (Space as leader)
- `Space + ff` - Telescope file picker
- `Ctrl+P` - Quick open files (nvim-cmp)
- `Ctrl+Shift+P` - Command palette

---

## File Structure

```
dotfiles/
├── install.sh              # One-command install script
├── README.md               # This file
├── dot_zshrc               # Zsh configuration
├── dot_bashrc              # Bash configuration
├── dot_tmux.conf           # Tmux configuration
├── dot_gitconfig           # Git configuration
├── dot_condarc             # Conda configuration
├── dot_vscode-extensions    # VS Code extensions list
└── private_dot_config/      # User configs (nvim, i3, polybar, etc.)
    ├── nvim/               # Neovim config
    ├── i3/                 # i3 window manager
    ├── polybar/            # Polybar config
    ├── rofi/               # Rofi config
    ├── kitty/              # Kitty terminal
    ├── wezterm/            # Wezterm terminal
    └── picom/              # Picom compositor
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
- i3-wm, i3status, i3lock, polybar, picom
- rofi, libnotify-bin, xdotool, x11-utils
- autorandr (display switching)

### Terminals
- kitty, alacritty

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
# Install fzf if missing
sudo apt install fzf

# Or manually
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Neovim plugins not loading
```bash
# Open nvim and run
:LazySync
# or
:Lazy! sync
```

### Conda not initializing
```bash
# For anaconda3
source ~/anaconda3/etc/profile.d/conda.sh
conda init zsh

# For miniconda3
source ~/miniconda3/etc/profile.d/conda.sh
conda init zsh
```

---

## Customization

Edit these files to customize:
- `dot_zshrc` - Shell aliases and functions
- `private_dot_config/nvim/lua/` - Neovim config
- `private_dot_config/i3/` - i3 config
- `private_dot_config/polybar/` - Polybar config

After editing, commit and push to sync across machines.

---

For more info, see [chezmoi docs](https://www.chezmoi.io/user-guide/).