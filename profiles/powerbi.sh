#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '\n[profile:powerbi] %s\n' "$*"
}

log "Installing Power BI custom visual tooling"

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  python3 \
  make \
  g++ \
  jq

NVM_VERSION="v0.40.4"

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default 'lts/*'
nvm use default

npm install -g npm@latest
npm install -g \
  powerbi-visuals-tools@latest \
  typescript \
  ts-node \
  eslint \
  prettier \
  pnpm

log "Power BI profile complete"
log "Verify with: node -v && npm -v && pbiviz"
