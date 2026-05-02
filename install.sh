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
    libxcb-shape0

# Install Neovim (latest stable)
echo "=== Installing Neovid"
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

# Install programming tools
echo "=== Installing programming tools ==="
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    golang-go

# Install Oh My Zsh
echo "=== Installing Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
echo "=== Installing Zsh plugins ==="
# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
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

echo ""
echo "=== Installation Complete! ==="
echo "Please restart your terminal or log out and back in."
echo "On first launch of Neovim, run ':LazySync' to install plugins."