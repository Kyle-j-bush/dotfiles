#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '\n[profile:base] %s\n' "$*"
}

log "Installing base developer extras"

sudo apt-get update
sudo apt-get install -y \
  direnv \
  shellcheck \
  shfmt \
  httpie \
  tldr \
  tree \
  htop \
  sqlite3 \
  graphviz

python3 -m pipx ensurepath

if ! command -v uv >/dev/null 2>&1; then
  pipx install uv
else
  pipx upgrade uv || true
fi

if ! command -v ruff >/dev/null 2>&1; then
  pipx install ruff
else
  pipx upgrade ruff || true
fi

if ! command -v poetry >/dev/null 2>&1; then
  pipx install poetry
else
  pipx upgrade poetry || true
fi

log "Base profile complete"
