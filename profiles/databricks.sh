#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '\n[profile:databricks] %s\n' "$*"
}

log "Installing Databricks/data-engineering tooling"

sudo apt-get update
sudo apt-get install -y \
  openjdk-17-jdk \
  sqlite3 \
  graphviz \
  unixodbc \
  unixodbc-dev

if ! command -v databricks >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh
else
  databricks -v || true
fi

python3 -m pipx ensurepath

if ! command -v uv >/dev/null 2>&1; then
  pipx install uv
fi

# Useful local data/dev tools.
uv tool install sqlfluff --force
uv tool install ruff --force
uv tool install black --force
uv tool install ipython --force

# dbt Databricks is useful, but workspace/project requirements vary.
# Keeping it installed as a tool is usually safe for side projects.
uv tool install dbt-databricks --force

log "Databricks profile complete"
log "Next: run 'databricks auth login' or configure ~/.databrickscfg manually. Do not commit credentials."
