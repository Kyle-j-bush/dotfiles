#!/usr/bin/env bash
set -euo pipefail

sudo apt update

sudo apt install -y \
  git curl wget zsh stow tmux ripgrep fd-find fzf jq unzip zip \
  ca-certificates gnupg lsb-release software-properties-common \
  build-essential python3 python3-pip python3-venv pipx tree htop \
  zoxide

mkdir -p "$HOME/.local/bin"

if command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

echo "CLI tools installed."
