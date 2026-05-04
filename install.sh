#!/bin/bash
# Dotfiles Installation Script
# Run: bash install.sh

set -e

echo "=== Dotfiles Installation Script ==="
echo ""

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Update package list
echo "=== Updating package list ==="
sudo apt update

# Install core dependencies
echo "=== Installing core dependencies ==="
sudo apt install -y \
    zsh \
    curl \
    git \
    wget \
    stow \
    fzf \
    fd-find \
    ripgrep \
    bat \
    tmux \
    build-essential \
    libxcb1 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libx11-xcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    cmake \
    pkg-config \
    libssl-dev \
    libwebkit2gtk-4.1-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libxcb-ewmh-dev \
    libxcb-composite0 \
    libxcb-xfixes0 \
    autorandr

# Install Neovim (latest stable)
echo "=== Installing Neovim ==="
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y neovim

# Install i3 and related
echo "=== Installing i3 and desktop tools ==="
sudo apt install -y \
    i3-wm \
    i3status \
    i3lock \
    polybar \
    picom \
    rofi \
    libnotify-bin \
    xdotool \
    x11-utils

# Install terminals
echo "=== Installing terminals ==="
sudo apt install -y \
    kitty \
    alacritty

# Install Wezterm
echo "=== Installing Wezterm ==="
if ! command -v wezterm &> /dev/null; then
    wget -O /tmp/wezterm.deb https://github.com/wez/wezterm/releases/download/20240203-114724-70cd1be3/wezterm-20240203-114724-70cd1be3-Ubuntu22.04.deb
    sudo dpkg -i /tmp/wezterm.deb
    sudo apt install -f -y
    rm /tmp/wezterm.deb
fi

# Install programming tools
echo "=== Installing programming tools ==="
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    nodejs \
    npm \
    golang-go

# Install Miniconda (Python data science)
echo "=== Installing Miniconda ==="
if [ ! -d "$HOME/miniconda3" ] && [ ! -d "$HOME/anaconda3" ]; then
    wget -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
    # Initialize conda for zsh
    "$HOME/miniconda3/bin/conda" init zsh
fi

# Install Oh My Zsh
echo "=== Installing Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
echo "=== Installing Zsh plugins ==="
# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zash-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Install chezmoi
echo "=== Installing chezmoi ==="
if ! command -v chezmoi &> /dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# Clone and apply dotfiles
echo "=== Applying dotfiles ==="
chezmoi init https://github.com/habert-kungu/dotfiles.git
chezmoi apply

# Set Zsh as default shell
echo "=== Setting Zsh as default shell ==="
chsh -s $(which zsh)

# Setup wallpapers
echo "=== Setting up wallpapers ==="
mkdir -p "$HOME/Pictures"
if [ -d "$HOME/.local/share/chezmoi/wallpapers" ]; then
    cp -n "$HOME/.local/share/chezmoi/wallpapers/"* "$HOME/Pictures/" 2>/dev/null || true
fi
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    cp -n "$HOME/dotfiles/wallpapers/"* "$HOME/Pictures/" 2>/dev/null || true
fi

# Setup autorandr display profiles
echo "=== Setting up display profiles ==="
mkdir -p "$HOME/.config/autorandr"
if [ -d "$HOME/dotfiles/autorandr" ]; then
    cp -r "$HOME/dotfiles/autorandr/"* "$HOME/.config/autorandr/" 2>/dev/null || true
fi

echo ""
echo "=== Installation Complete! ==="
echo "Please restart your terminal or log out and back in."
echo "On first launch of Neovim, run ':LazySync' to install plugins."