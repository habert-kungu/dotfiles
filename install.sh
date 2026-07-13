#!/bin/bash
# Dotfiles Installation Script for Regolith + Debian
# Run: bash install.sh
#
# Step-by-step, fail-resilient. A failing step is logged and the script
# continues. A summary is printed at the end. Re-running is safe (idempotent).

set -u
set -o pipefail

FAILED_STEPS=()
SUCCEEDED_STEPS=()
SKIPPED_STEPS=()

log()    { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn()   { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err()    { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
ok()     { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
info()   { printf '\033[1;36m[info]\033[0m %s\n' "$*"; }
fail()   { printf '\033[1;31m[fail]\033[0m %s\n' "$*" >&2; }

run_step() {
    local name="$1"; shift
    log "Step: $name"
    if "$@"; then
        ok "$name"
        SUCCEEDED_STEPS+=("$name")
        return 0
    else
        local rc=$?
        err "$name failed (exit $rc) — continuing"
        FAILED_STEPS+=("$name")
        return $rc
    fi
}

skip_step() {
    local name="$1"; shift
    local reason="$*"
    warn "$name skipped: $reason"
    SKIPPED_STEPS+=("$name ($reason)")
}

# ---------- OS detection ----------
detect_os() {
    local codename=""
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="${ID:-unknown}"
        codename="${VERSION_CODENAME:-}"
        echo "Detected OS: $OS $codename"
        return 0
    fi
    err "Cannot detect OS from /etc/os-release"
    OS="unknown"
    return 1
}

# ---------- Sudo helper ----------
prime_sudo() {
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
        sudo -v || warn "sudo authentication failed; some steps may fail"
    else
        warn "sudo not available and not running as root — privileged steps will fail"
        SUDO=""
    fi
}

# ---------- Steps ----------
apt_update() {
    $SUDO apt-get update -y
}

apt_install() {
    $SUDO apt-get install -y --no-install-recommends "$@"
}

# Install packages one at a time so a single unavailable/broken package does
# not abort the whole batch — the rest still get installed.
apt_install_each() {
    local pkg rc=0
    for pkg in "$@"; do
        apt_install "$pkg" || { warn "package '$pkg' failed — continuing"; rc=1; }
    done
    return $rc
}

install_core_deps() {
    apt_install \
        zsh curl git wget stow fzf fd-find ripgrep bat tmux unzip fontconfig \
        build-essential cmake pkg-config libssl-dev \
        libxcb1 libxcb-xkb1 libxkbcommon-x11-0 libx11-xcb1 \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
        libxcb-render-util0 libxcb-shape0 \
        libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev \
        libxcb-ewmh-dev libxcb-composite0 libxcb-xfixes0 \
        feh xclip
}

install_regolith() {
    if dpkg -l regolith-desktop >/dev/null 2>&1; then
        ok "regolith already installed"
        return 0
    fi

    local codename=""
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        codename="${VERSION_CODENAME:-}"
    fi
    if [[ -z "$codename" ]]; then
        codename="trixie"
        warn "could not detect Debian codename, defaulting to $codename"
    fi

    wget -qO - https://archive.regolith-desktop.com/regolith.key \
        | gpg --yes --dearmor \
        | $SUDO tee /usr/share/keyrings/regolith-archive-keyring.gpg > /dev/null \
        || return 1

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] https://archive.regolith-desktop.com/debian/stable $codename v3.4" \
        | $SUDO tee /etc/apt/sources.list.d/regolith.list > /dev/null \
        || return 1

    $SUDO apt-get update -y || return 1

    apt_install regolith-desktop \
        regolith-session-flashback \
        regolith-look-lascaille \
        xdg-desktop-portal-regolith \
        polybar

    ok "Regolith installed — reboot and select Regolith from the display manager"
}

# Apps the Polybar bar + i3 config depend on at runtime.
# Bar modules/clicks: pavucontrol, gnome-calendar, gnome-system-monitor,
#   gnome-control-center (regolith-control-center wraps it).
# Audio: pipewire stack provides wpctl (WirePlumber) + the pulse shim the
#   polybar volume module reads. Screenshots: flameshot. Launcher: rofi.
# i3 autostart helpers: unclutter, blueman (bluetooth), playerctl (media keys).
install_desktop_apps() {
    # per-package so one failure doesn't block the others. regolith-rofication
    # provides rofication-daemon (the i3 notification daemon).
    apt_install_each \
        polybar flameshot rofi regolith-rofication \
        pavucontrol pipewire pipewire-pulse wireplumber \
        gnome-calendar gnome-system-monitor gnome-control-center \
        blueman unclutter playerctl
}

# i3-swap-focus (alt-tab-style focus toggle) — not in apt; it's a PyPI tool.
# Prefer pipx (isolated, respects Debian's PEP 668); fall back to user pip.
install_i3_swap_focus() {
    if command -v i3-swap-focus >/dev/null 2>&1; then
        ok "i3-swap-focus already installed"
        return 0
    fi
    if command -v pipx >/dev/null 2>&1 || apt_install pipx; then
        if pipx install i3-swap-focus; then
            pipx ensurepath >/dev/null 2>&1 || true
            return 0
        fi
    fi
    warn "pipx path failed; falling back to user pip install"
    pip install --user --break-system-packages i3-swap-focus \
        || python3 -m pip install --user --break-system-packages i3-swap-focus
}

# JetBrainsMono Nerd Font + Symbols Nerd Font — REQUIRED for the bar's icons and
# the workspace square glyph; without them the bar renders empty boxes.
install_fonts() {
    local fdir="$HOME/.local/share/fonts"
    mkdir -p "$fdir"
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font" \
       && fc-list 2>/dev/null | grep -qi "Symbols Nerd Font"; then
        ok "Nerd Fonts already installed"
        return 0
    fi
    local base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
    local pkg tmp rc=0
    for pkg in JetBrainsMono NerdFontsSymbolsOnly; do
        tmp="/tmp/${pkg}.zip"
        if curl -fsSL -o "$tmp" "$base/${pkg}.zip"; then
            unzip -oq "$tmp" -d "$fdir/${pkg}" || { warn "unzip $pkg failed"; rc=1; }
            rm -f "$tmp"
        else
            warn "download of $pkg Nerd Font failed"; rc=1
        fi
    done
    fc-cache -f >/dev/null 2>&1 || true
    return $rc
}

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        ok "nvim already installed: $(nvim --version | head -n1)"
        return 0
    fi

    if [[ "${OS:-}" == "ubuntu" ]]; then
        if apt_install software-properties-common \
            && $SUDO add-apt-repository ppa:neovim-ppa/unstable -y \
            && $SUDO apt-get update -y \
            && apt_install neovim; then
            return 0
        fi
        warn "Ubuntu PPA path failed; falling back to GitHub tarball"
    fi

    local tarball=/tmp/nvim-linux-x86_64.tar.gz
    curl -fsSL -o "$tarball" \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || return 1
    $SUDO rm -rf /opt/nvim-linux-x86_64
    $SUDO tar -C /opt -xzf "$tarball" || return 1
    $SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -f "$tarball"
}

install_terminals() {
    apt_install kitty alacritty
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        ok "ghostty already installed: $(ghostty --version 2>/dev/null | head -n1)"
        return 0
    fi

    local keyring=/etc/apt/keyrings/debian.griffo.io.gpg
    local listfile=/etc/apt/sources.list.d/debian.griffo.io.list
    local codename
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    : "${codename:=trixie}"

    $SUDO install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
        | $SUDO gpg --dearmor --yes -o "$keyring" || return 1

    echo "deb [signed-by=$keyring] https://debian.griffo.io/apt $codename main" \
        | $SUDO tee "$listfile" > /dev/null || return 1

    $SUDO apt-get update -y || return 1
    apt_install_each ghostty viu zig lazygit yazi eza zoxide starship atuin uv bun
}

install_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        ok "wezterm already installed: $(wezterm --version 2>/dev/null | head -n1)"
        return 0
    fi

    local keyring=/usr/share/keyrings/wezterm-fury.gpg
    local listfile=/etc/apt/sources.list.d/wezterm.list

    curl -fsSL https://apt.fury.io/wez/gpg.key \
        | $SUDO gpg --yes --dearmor -o "$keyring" || return 1
    $SUDO chmod 644 "$keyring"

    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
        | $SUDO tee "$listfile" >/dev/null
    $SUDO chmod 644 "$listfile"

    $SUDO apt-get update -y || return 1
    apt_install wezterm
}

install_programming_tools() {
    apt_install \
        python3 python3-pip python3-venv python3-dev python3-setuptools \
        nodejs npm golang-go
}

install_miniconda() {
    if [ -d "$HOME/miniconda3" ] || [ -d "$HOME/anaconda3" ]; then
        ok "conda already installed"
        return 0
    fi
    local installer=/tmp/miniconda.sh
    wget -O "$installer" \
        https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || return 1
    bash "$installer" -b -p "$HOME/miniconda3" || return 1
    rm -f "$installer"
    "$HOME/miniconda3/bin/conda" init zsh || true
}

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "oh-my-zsh already installed"
        return 0
    fi
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_zsh_plugins() {
    local custom="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom"
    if [ ! -d "$custom/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom/zsh-autosuggestions" || return 1
    fi
    if [ ! -d "$custom/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom/zsh-syntax-highlighting" || return 1
    fi
}

install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        ok "chezmoi already installed"
        return 0
    fi
    sh -c "$(curl -fsLS get.chezmoi.io)"
}

apply_dotfiles() {
    if ! command -v chezmoi >/dev/null 2>&1; then
        export PATH="$HOME/bin:$PATH"
    fi
    command -v chezmoi >/dev/null 2>&1 || return 1

    chezmoi init https://github.com/habert-kungu/dotfiles.git || true

    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    while IFS= read -r f; do
        if [ -f "$HOME/$f" ]; then
            mkdir -p "$(dirname "$backup_dir/$f")"
            cp -a "$HOME/$f" "$backup_dir/$f"
        fi
    done < <(chezmoi managed --include=files 2>/dev/null)
    info "Old configs backed up to $backup_dir"

    chezmoi apply --verbose --keep-going --force
}

set_default_shell() {
    local zsh_path target_user current_shell
    zsh_path="$(command -v zsh)" || return 1

    target_user="${SUDO_USER:-$USER}"

    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
    fi

    current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
    if [ "$current_shell" = "$zsh_path" ]; then
        ok "zsh already default shell for $target_user"
        return 0
    fi

    if [ "$(id -u)" = "0" ]; then
        chsh -s "$zsh_path" "$target_user" \
            || usermod -s "$zsh_path" "$target_user" \
            || return 1
    else
        chsh -s "$zsh_path" || return 1
    fi
    ok "Default shell for $target_user set to $zsh_path (effective on next login)"
}

setup_wallpapers() {
    mkdir -p "$HOME/Pictures/wallpapers"

    local src
    for src in "$HOME/.local/share/chezmoi/wallpapers" "$HOME/dotfiles/wallpapers"; do
        if [ -d "$src" ]; then
            local count=0
            for f in "$src"/*; do
                if [ -f "$f" ]; then
                    cp "$f" "$HOME/Pictures/wallpapers/"
                    count=$((count + 1))
                fi
            done
            info "Copied $count wallpapers from $src"
        fi
    done
}

install_openrgb() {
    if command -v openrgb >/dev/null 2>&1; then
        ok "openrgb already installed: $(openrgb --version 2>/dev/null | head -n1)"
        return 0
    fi

    local ver="1.0rc2"
    local commit="0fca93e"
    local codename
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    local deb="openrgb_${ver}_amd64_${codename}_${commit}.deb"
    local url="https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_${ver}/${deb}"

    info "Downloading OpenRGB ${ver} (${codename}) ..."
    curl -sSL -o "/tmp/${deb}" "$url" || {
        fail "Failed to download OpenRGB from $url"
        return 1
    }

    info "Installing ${deb} ..."
    sudo dpkg -i "/tmp/${deb}" || {
        info "Installing missing dependencies ..."
        sudo apt-get install -fyq
        sudo dpkg -i "/tmp/${deb}"
    }
    rm -f "/tmp/${deb}"
}

install_claude() {
    if command -v claude >/dev/null 2>&1; then
        ok "claude already installed: $(claude --version 2>/dev/null | head -n1)"
        return 0
    fi
    curl -sSL https://cli.anthropic.com/install.sh | sh
}

install_opencode() {
    if [ -f "$HOME/.opencode/bin/opencode" ]; then
        ok "opencode already installed"
        return 0
    fi
    curl -fsSL https://opencode.ai/install.sh | sh
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
}

install_deno() {
    if command -v deno >/dev/null 2>&1; then
        ok "deno already installed: $(deno --version 2>/dev/null | head -n1)"
        return 0
    fi
    curl -fsSL https://deno.land/install.sh | sh
}

# ---------- Summary ----------
print_summary() {
    echo ""
    log "Installation Summary"
    if [ ${#SUCCEEDED_STEPS[@]} -gt 0 ]; then
        printf '\033[1;32mSucceeded (%d):\033[0m\n' "${#SUCCEEDED_STEPS[@]}"
        printf '  - %s\n' "${SUCCEEDED_STEPS[@]}"
    fi
    if [ ${#SKIPPED_STEPS[@]} -gt 0 ]; then
        printf '\033[1;33mSkipped (%d):\033[0m\n' "${#SKIPPED_STEPS[@]}"
        printf '  - %s\n' "${SKIPPED_STEPS[@]}"
    fi
    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        printf '\033[1;31mFailed (%d):\033[0m\n' "${#FAILED_STEPS[@]}"
        printf '  - %s\n' "${FAILED_STEPS[@]}"
        echo ""
        echo "Re-run the script to retry failed steps (it is idempotent)."
        return 1
    fi
    echo ""
    echo "All steps completed. Reboot and select Regolith from your display manager."
    echo "On first launch of Neovim, run ':Lazy sync' to install plugins."
    return 0
}

# ---------- Main ----------
echo "=== Dotfiles Installation Script (Regolith) ==="

detect_os
prime_sudo

run_step "apt update"               apt_update                || true
run_step "core dependencies"        install_core_deps         || true
run_step "Regolith desktop"         install_regolith          || true
run_step "desktop apps (bar/screenshot/audio)" install_desktop_apps || true
run_step "Nerd Fonts"               install_fonts             || true
run_step "Neovim"                   install_neovim            || true
run_step "terminals (kitty, alacritty)" install_terminals     || true
run_step "Ghostty"                   install_ghostty           || true
run_step "Wezterm"                   install_wezterm           || true
run_step "programming tools"        install_programming_tools || true
run_step "i3-swap-focus"            install_i3_swap_focus     || true
run_step "Miniconda"                install_miniconda         || true
run_step "Oh My Zsh"                install_oh_my_zsh         || true
run_step "Zsh plugins"              install_zsh_plugins       || true
run_step "chezmoi"                  install_chezmoi           || true
run_step "apply dotfiles"           apply_dotfiles            || true
run_step "set zsh as default shell" set_default_shell         || true
run_step "wallpapers"               setup_wallpapers          || true
run_step "OpenRGB"                  install_openrgb           || true
run_step "Claude CLI"               install_claude            || true
run_step "OpenCode"                 install_opencode          || true
run_step "Deno"                     install_deno              || true

print_summary
