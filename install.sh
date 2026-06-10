#!/bin/bash
# Dotfiles Installation Script
# Run: bash install.sh
#
# Step-by-step, fail-resilient. A failing step is logged and the script
# continues. A summary is printed at the end. Re-running is safe (idempotent).

# Note: intentionally NOT using `set -e` — we want every step to attempt,
# and report failures collectively at the end.
set -u
set -o pipefail

FAILED_STEPS=()
SUCCEEDED_STEPS=()
SKIPPED_STEPS=()

log()    { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn()   { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err()    { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
ok()     { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

# run_step <name> <command...>
# Runs the command, captures pass/fail, records into the summary.
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
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS="${ID:-unknown}"
        echo "Detected OS: $OS"
        return 0
    fi
    err "Cannot detect OS from /etc/os-release"
    OS="unknown"
    return 1
}

# ---------- Sudo helper ----------
# Non-interactive sudo when possible; otherwise prompt once up-front.
prime_sudo() {
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
        # Trigger one prompt now so later steps don't stall mid-run.
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
    # Args: package list
    $SUDO apt-get install -y --no-install-recommends "$@"
}

install_core_deps() {
    apt_install \
        zsh curl git wget stow fzf fd-find ripgrep bat tmux \
        build-essential cmake pkg-config libssl-dev \
        libxcb1 libxcb-xkb1 libxkbcommon-x11-0 libx11-xcb1 \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
        libxcb-render-util0 libxcb-shape0 \
        libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev \
        libxcb-ewmh-dev libxcb-composite0 libxcb-xfixes0 \
        autorandr
}

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        ok "nvim already installed: $(nvim --version | head -n1)"
        return 0
    fi

    # On Ubuntu, try the PPA first; fall back to tarball on any failure.
    if [[ "$OS" == "ubuntu" ]]; then
        if apt_install software-properties-common \
            && $SUDO add-apt-repository ppa:neovim-ppa/unstable -y \
            && $SUDO apt-get update -y \
            && apt_install neovim; then
            return 0
        fi
        warn "Ubuntu PPA path failed; falling back to GitHub tarball"
    fi

    # Generic fallback: official GitHub release tarball.
    local tarball=/tmp/nvim-linux-x86_64.tar.gz
    curl -fsSL -o "$tarball" \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || return 1
    $SUDO rm -rf /opt/nvim-linux-x86_64
    $SUDO tar -C /opt -xzf "$tarball" || return 1
    $SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -f "$tarball"
}

install_i3_stack() {
    apt_install \
        i3-wm i3status i3lock polybar picom rofi feh \
        libnotify-bin xdotool x11-utils
}

install_audio_stack() {
    # pipewire is already default on Debian 13. wireplumber provides wpctl,
    # which the i3 audio keybindings (F1/F2/F3) use to mute and adjust
    # volume. pulseaudio-utils stays for legacy `pactl` consumers.
    apt_install \
        pipewire pipewire-pulse wireplumber \
        pulseaudio-utils
}

install_network_tools() {
    # NetworkManager core + the GTK editor (nm-connection-editor) that
    # polybar's wifi icon opens on click.
    apt_install network-manager network-manager-gnome
}

install_bluetooth_stack() {
    # bluez (bluetoothctl backend) + blueman (blueman-manager GUI launched
    # by polybar's bluetooth icon on click).
    apt_install bluez blueman
}

install_terminals() {
    apt_install kitty alacritty
}

install_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        ok "wezterm already installed: $(wezterm --version 2>/dev/null | head -n1)"
        return 0
    fi

    # Official wezterm apt repo (Debian + Ubuntu).
    # https://wezfurlong.org/wezterm/install/linux.html
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
        # chezmoi installs to $HOME/bin by default — make sure it's reachable.
        export PATH="$HOME/bin:$PATH"
    fi
    command -v chezmoi >/dev/null 2>&1 || return 1

    # `chezmoi init` is idempotent if the source dir already exists.
    chezmoi init https://github.com/habert-kungu/dotfiles.git || true

    # Back up any existing configs before overwriting
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    while IFS= read -r f; do
        if [ -f "$HOME/$f" ]; then
            mkdir -p "$(dirname "$backup_dir/$f")"
            cp -a "$HOME/$f" "$backup_dir/$f"
        fi
    done < <(chezmoi managed --include=files 2>/dev/null)
    info "Old configs backed up to $backup_dir"

    # Verbose so failing files are visible in the install log.
    # `--keep-going` keeps applying remaining entries when one fails, so
    # a single broken file doesn't black-hole the whole apply.
    # `--force` skips the interactive TTY prompt so the script is non-blocking.
    chezmoi apply --verbose --keep-going --force
}

set_default_shell() {
    local zsh_path target_user current_shell
    zsh_path="$(command -v zsh)" || return 1

    # If invoked via `sudo`, target the invoking user, not root.
    target_user="${SUDO_USER:-$USER}"

    # zsh must be listed in /etc/shells for chsh to accept it.
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
    fi

    current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
    if [ "$current_shell" = "$zsh_path" ]; then
        ok "zsh already default shell for $target_user"
        return 0
    fi

    # As root: chsh/usermod do not need a password and can target a user
    # explicitly. As an unprivileged user: chsh prompts for the user's
    # password and only changes the invoking user's shell.
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
    # feh (and the i3 $mod+Shift+w cycle keybind) read from
    # ~/Pictures/wallpapers/, so copy the repo's wallpapers there.
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

setup_autorandr() {
    # autorandr profiles are managed by chezmoi under
    # private_dot_config/autorandr/ -> ~/.config/autorandr/, so nothing to
    # copy here. Just make sure the target dir exists for autorandr's
    # systemd unit.
    mkdir -p "$HOME/.config/autorandr"
}

install_openrgb() {
    # OpenRGB controls RGB lighting.
    # The profile-loading script (~/.local/bin/openrgb-load-profile.sh) is
    # managed by chezmoi under private_dot_local/bin/.
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
    # Ensure it's in PATH for future sessions
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
    echo "All steps completed. Restart your terminal or log out and back in."
    echo "On first launch of Neovim, run ':Lazy sync' to install plugins."
    return 0
}

# ---------- Main ----------
echo "=== Dotfiles Installation Script ==="

detect_os
prime_sudo

run_step "apt update"               apt_update                || true
run_step "core dependencies"        install_core_deps         || true
run_step "Neovim"                   install_neovim            || true
run_step "i3 + desktop tools"       install_i3_stack          || true
run_step "audio stack (pipewire + wpctl)" install_audio_stack || true
run_step "NetworkManager + nm-connection-editor" install_network_tools || true
run_step "Bluetooth stack (bluez + blueman)" install_bluetooth_stack || true
run_step "terminals (kitty, alacritty)" install_terminals     || true
run_step "Wezterm"                  install_wezterm           || true
run_step "programming tools"        install_programming_tools || true
run_step "Miniconda"                install_miniconda         || true
run_step "Oh My Zsh"                install_oh_my_zsh         || true
run_step "Zsh plugins"              install_zsh_plugins       || true
run_step "chezmoi"                  install_chezmoi           || true
run_step "apply dotfiles"           apply_dotfiles            || true
run_step "set zsh as default shell" set_default_shell         || true
run_step "wallpapers"               setup_wallpapers          || true
run_step "autorandr profiles"       setup_autorandr           || true
run_step "OpenRGB"                  install_openrgb           || true
run_step "Claude CLI"               install_claude            || true
run_step "OpenCode"                 install_opencode          || true
run_step "Deno"                     install_deno              || true

print_summary
