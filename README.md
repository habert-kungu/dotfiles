# dotfiles

just my configs

## Getting Started on a New Machine

This repository contains my personal dotfiles and configuration for tools like Zsh, Neovim (NvChad), Kitty, i3, tmux, and more. It uses [chezmoi](https://www.chezmoi.io/) for dotfile management.

### 1. Install chezmoi

```sh
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. Initialize chezmoi with this repo

```sh
chezmoi init https://github.com/habert-kungu/dotfiles.git
chezmoi apply
```

### 3. Install dependencies

- **Zsh**: `sudo apt install zsh`
- **Oh My Zsh**: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- **Neovim**: Follow instructions at https://github.com/neovim/neovim/wiki/Installing-Neovim
- **Kitty**: `sudo apt install kitty`
- **i3**: `sudo apt install i3`
- **tmux**: `sudo apt install tmux`
- **fd, ripgrep, bat, fzf**:
  ```sh
  sudo apt install fd-find ripgrep bat fzf
  ```

### 4. Additional steps

- Restart your shell or source your `.zshrc`:
  ```sh
  source ~/.zshrc
  ```
- For Neovim, plugins will install automatically on first launch.
- Review and update secrets or machine-specific configs in `.local` or `private_dot_*` files as needed.

### 5. Customization

- Edit configs in `~/.config/` or via chezmoi and re-apply:
  ```sh
  chezmoi edit <file>
  chezmoi apply
  ```

---

For more details, see [chezmoi documentation](https://www.chezmoi.io/user-guide/).
