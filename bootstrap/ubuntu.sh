#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.opencode/bin:$PATH"

log() {
  printf '\n[bootstrap] %s\n' "$*"
}

warn() {
  printf '\n[bootstrap:warn] %s\n' "$*" >&2
}

die() {
  printf '\n[bootstrap:error] %s\n' "$*" >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
APT_FILE="$DOTFILES_DIR/packages/apt.txt"

install_apt_packages() {
  log "Installing apt packages"

  [[ -f "$APT_FILE" ]] || die "Missing $APT_FILE"

  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

  mapfile -t packages < <(grep -Ev '^\s*(#|$)' "$APT_FILE")

  if [[ "${#packages[@]}" -gt 0 ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
  fi
}

setup_local_bin() {
  log "Ensuring ~/.local/bin exists"

  mkdir -p "$HOME/.local/bin"

  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  python3 -m pipx ensurepath >/dev/null 2>&1 || true
}

install_oh_my_zsh() {
  log "Installing Oh My Zsh if missing"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "Oh My Zsh already installed"
    return
  fi

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_powerlevel10k() {
  log "Installing Powerlevel10k if missing"

  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    log "Powerlevel10k already installed"
    return
  fi

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
}

install_zsh_plugins() {
  log "Installing Zsh plugins if missing"

  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom_dir/plugins"

  if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$custom_dir/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$custom_dir/plugins/zsh-syntax-highlighting"
  fi
}

install_neovim() {
  log "Installing current Neovim release if user-local nvim is missing"

  mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"

  local nvim_bin="$HOME/.local/bin/nvim"

  if [[ -x "$nvim_bin" && "${FORCE_NVIM_UPDATE:-0}" != "1" ]]; then
    "$nvim_bin" --version | head -n 1 || true
    return
  fi

  local arch
  arch="$(uname -m)"

  local asset
  case "$arch" in
    x86_64|amd64)
      asset="nvim-linux-x86_64.appimage"
      ;;
    aarch64|arm64)
      asset="nvim-linux-arm64.appimage"
      ;;
    *)
      die "Unsupported architecture for automatic Neovim AppImage install: $arch"
      ;;
  esac

  local tmp_appimage
  tmp_appimage="$(mktemp)"

  curl -fL --retry 3 \
    "https://github.com/neovim/neovim/releases/latest/download/${asset}" \
    -o "$tmp_appimage"

  chmod +x "$tmp_appimage"

  if "$tmp_appimage" --version >/dev/null 2>&1; then
    mv "$tmp_appimage" "$nvim_bin"
    chmod +x "$nvim_bin"
    "$nvim_bin" --version | head -n 1
    return
  fi

  warn "Direct AppImage execution failed. Extracting AppImage instead."

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  cp "$tmp_appimage" "$tmp_dir/nvim.appimage"
  chmod +x "$tmp_dir/nvim.appimage"

  (
    cd "$tmp_dir"
    ./nvim.appimage --appimage-extract >/dev/null
  )

  rm -rf "$HOME/.local/opt/nvim-appimage"
  mv "$tmp_dir/squashfs-root" "$HOME/.local/opt/nvim-appimage"
  ln -sf "$HOME/.local/opt/nvim-appimage/AppRun" "$nvim_bin"

  rm -rf "$tmp_dir" "$tmp_appimage"

  "$nvim_bin" --version | head -n 1
}

install_lazyvim_starter() {
  log "Installing LazyVim starter into dotfiles if missing"

  local nvim_config="$DOTFILES_DIR/home/.config/nvim"

  if [[ -f "$nvim_config/init.lua" ]]; then
    log "Neovim config already exists in dotfiles"
    return
  fi

  rm -rf "$nvim_config"
  git clone https://github.com/LazyVim/starter "$nvim_config"
  rm -rf "$nvim_config/.git"
}

install_opencode() {
  log "Installing OpenCode if missing"

  if command -v opencode >/dev/null 2>&1; then
    opencode --version || true
    return
  fi

  curl -fsSL https://opencode.ai/install | bash

  hash -r || true

  if command -v opencode >/dev/null 2>&1; then
    opencode --version || true
  elif [[ -x "$HOME/.opencode/bin/opencode" ]]; then
    "$HOME/.opencode/bin/opencode" --version || true
  else
    warn "OpenCode install finished, but opencode was not found on PATH. Restart your shell or check ~/.opencode/bin."
  fi
}

run_stow() {
  log "Running GNU Stow"

  mkdir -p "$HOME/.config"

  cd "$DOTFILES_DIR"

  if ! stow --dir="$DOTFILES_DIR" --target="$HOME" --restow home; then
    cat >&2 <<MSG

Stow hit a conflict.

Common fix:

  mkdir -p ~/dotfiles-backup
  mv ~/.zshrc ~/dotfiles-backup/.zshrc.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
  mv ~/.gitconfig ~/dotfiles-backup/.gitconfig.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow home

Alternative adoption flow:

  cd "$DOTFILES_DIR"
  stow --dir="$DOTFILES_DIR" --target="$HOME" --adopt home
  git restore home
  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow home

MSG
    exit 1
  fi
}

set_default_shell() {
  log "Setting Zsh as default shell if needed"

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    log "Zsh is already the default shell"
    return
  fi

  if ! grep -qxF "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$zsh_path" "$USER" || warn "chsh failed. You can run manually: chsh -s $zsh_path"
}

main() {
  log "Dotfiles dir: $DOTFILES_DIR"

  install_apt_packages
  setup_local_bin
  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  install_neovim
  install_lazyvim_starter
  install_opencode
  run_stow
  set_default_shell

  log "Done. Restart the terminal or run: exec zsh"
  log "Then run: p10k configure"
}

main "$@"
