#!/usr/bin/env bash
# Explicit, repeatable installation. Existing files are backed up, never removed.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "$0")" && pwd -P)
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$HOME/.local/bin:$HOME/.local/share/devtools/node/node_modules/.bin:$PNPM_HOME/bin:$PNPM_HOME:/opt/homebrew/bin:/usr/local/bin:$PATH"
BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/$(date +%Y%m%d-%H%M%S)-$$"

usage() {
  cat <<'EOF'
Usage: ./install.sh --packages | --activate | --plugins | --all
  --packages  Install Brewfile, isolated Python LSP, locked Node CLI toolchain.
  --activate  Back up conflicts and link configs/scripts; no package installs.
  --plugins   Install TPM plugins, Lazy plugins, and Treesitter parsers.
  --all       Run all three phases, in order.
Linux: install system dependencies manually, then --activate and --plugins.
EOF
}

link() {
  local src=$1 dest=$2 existing
  mkdir -p -- "$(dirname -- "$dest")"
  if [[ -L "$dest" ]]; then
    existing=$(readlink "$dest")
    [[ "$existing" == "$src" ]] && return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p -- "$BACKUP/$(dirname -- "${dest#"$HOME/"}")"
    mv -- "$dest" "$BACKUP/${dest#"$HOME/"}"
    printf 'Backed up %s → %s\n' "$dest" "$BACKUP/${dest#"$HOME/"}"
  fi
  ln -s -- "$src" "$dest"
}

packages() {
  [[ $(uname -s) == Darwin ]] || {
    printf 'Use your Linux package manager; see docs/INSTALL.md.\n' >&2
    return 1
  }
  command -v brew >/dev/null || {
    printf 'Install Homebrew first: https://brew.sh\n' >&2
    return 1
  }
  brew bundle --file="$ROOT/Brewfile"
  mkdir -p "$PNPM_HOME"
  uv tool install basedpyright
  # One locked toolchain: pnpm 12 global packages are isolated from each other.
  pnpm --dir "$ROOT/tooling/node" install --frozen-lockfile
  printf '\nInstalled tools. Docker daemon remains OFF: start colima when needed.\n'
}

activate() {
  link "$ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
  link "$ROOT/tmux/project-roots" "$HOME/.config/tmux/project-roots"
  link "$ROOT/nvim" "$HOME/.config/nvim"
  link "$ROOT/ghostty/config" "$HOME/.config/ghostty/config"
  link "$ROOT/zsh/zshrc" "$HOME/.zshrc"
  link "$ROOT/zsh/zprofile" "$HOME/.zprofile"
  link "$ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
  link "$ROOT/git/gitconfig" "$HOME/.gitconfig"
  link "$ROOT/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
  link "$ROOT/tooling/node" "$HOME/.local/share/devtools/node"
  mkdir -p "$HOME/code" "$HOME/work" "$HOME/labs"
  printf '\nActivated configs. Open a new login shell; reload Ghostty from its menu.\n'
  printf 'Existing tmux servers: prefix r or tmux source-file ~/.tmux.conf\n'
}

clone_once() {
  [[ -d "$2/.git" ]] || git clone --depth 1 "$1" "$2"
}

plugins() {
  [[ -L "$HOME/.config/nvim" ]] || {
    printf 'Activate configs before installing plugins.\n' >&2
    return 1
  }
  mkdir -p "$HOME/.tmux/plugins"
  clone_once https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
  clone_once https://github.com/tmux-plugins/tmux-resurrect.git "$HOME/.tmux/plugins/tmux-resurrect"
  clone_once https://github.com/tmux-plugins/tmux-continuum.git "$HOME/.tmux/plugins/tmux-continuum"
  # TPM handles updates later (prefix U). Cloning avoids starting/restoring tmux now.
  nvim --headless -u NONE -i NONE -l "$ROOT/scripts/bootstrap-nvim.lua"
}

case ${1:-} in
--packages) packages ;;
--activate) activate ;;
--plugins) plugins ;;
--all)
  packages
  activate
  plugins
  ;;
-h | --help | '') usage ;;
*)
  usage >&2
  exit 1
  ;;
esac
