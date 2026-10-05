# Installation, activation, verification

## macOS Apple Silicon

1. Install Xcode Command Line Tools if absent: `xcode-select --install`.
2. Install Homebrew using the official instructions at <https://brew.sh>.
   Inspect its installation script before running it. Apple Silicon prefix:
   `/opt/homebrew`; do not install an x86/Rosetta toolchain accidentally.
3. Clone this repo, then run the phases below (or `./install.sh --all`).

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
cd ~/.dotfiles
./install.sh --packages
./install.sh --activate
./install.sh --plugins
exec zsh -l
```

The package phase performs these complete installations:

```sh
brew tap hashicorp/tap
brew tap terraform-linters/tap
# Newer Homebrew may require this explicit, formula-scoped trust decision:
brew trust --formula hashicorp/tap/terraform
brew install git gh tmux neovim fzf ripgrep fd zoxide lazygit starship node pnpm \
  uv ruff shellcheck shfmt stylua lua-language-server marksman tree-sitter-cli \
  hashicorp/tap/terraform terraform-ls hadolint jq yq \
  docker docker-compose colima kubernetes-cli kubectx helm k9s
brew install --cask ghostty font-jetbrains-mono
brew install --cask terraform-linters/tap/tflint

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$HOME/.local/bin:$HOME/.local/share/devtools/node/node_modules/.bin:$PNPM_HOME/bin:$PNPM_HOME:$PATH"
mkdir -p "$PNPM_HOME"
uv tool install basedpyright
pnpm --dir ~/.dotfiles/tooling/node install --frozen-lockfile
```

`brew bundle --file=Brewfile` is the authoritative equivalent used by the installer.
Homebrew already-installed packages are reused. `tooling/node/package.json` lists
every required Node CLI at an exact version; its lockfile pins transitive dependencies.
They share one installation because pnpm 12 global packages are isolated (a
globally installed TypeScript LS cannot reliably see a separately global TypeScript).
The activated toolchain is on PATH; user global pnpm bins remain available too.
TypeScript 6 is deliberate:
the current `ts_ls` JavaScript server requires TypeScript <7. Each project can pin
its own compatible TypeScript/LSP versions. This is not a Node-version manager;
if a project requires a particular Node release, use an explicit runtime strategy
such as a container or mise later, rather than silently changing Node here.

Installation downloads software but **does not** start Colima, Docker, Kubernetes,
launch agents, log-in tmux, or a project process. For containers when needed:

```sh
colima start
docker context show
docker run --rm hello-world
```

If Docker Compose's CLI plugin is not discovered, follow `brew info docker-compose`:
merge `"cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]` into your
existing `~/.docker/config.json`. Do not replace an existing config containing
registry credentials. `docker-compose` is also directly available. Docker Desktop
is a valid alternative to Colima; **choose one daemon**, not both by default.

## Credentials and Git identity

No SSH key generation, credential copy, global identity inference, or repository
signing changes are done by the installer.

```sh
gh auth login
mkdir -p ~/.config/git
git config --file ~/.config/git/local.gitconfig user.name 'Your Name'
git config --file ~/.config/git/local.gitconfig user.email 'YOUR_GITHUB_NOREPLY_ADDRESS'
git config --show-origin --get user.email
```

The public Git config includes that untracked per-host file. GitHub HTTPS uses
`gh auth git-credential`; SSH remotes still use your normal SSH agent/key setup.
Use GitHub's account-specific noreply address if you want email privacy. For
work repositories, configure an appropriate per-repository identity or `includeIf`
in the private file. Check identity before committing. GitHub CLI auth on Linux
may store a token in a file if no keyring exists; never add that file to dotfiles.

## Active paths and backups

| Repository path | Active symlink |
|---|---|
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `tmux/project-roots` | `~/.config/tmux/project-roots` |
| `nvim/` | `~/.config/nvim` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `zsh/zshrc`, `zsh/zprofile` | `~/.zshrc`, `~/.zprofile` |
| `git/gitconfig` | `~/.gitconfig` |
| `scripts/tmux-sessionizer` | `~/.local/bin/tmux-sessionizer` |
| `tooling/node/` | `~/.local/share/devtools/node` |

Conflicts are moved intact to `~/.local/state/dotfiles-backups/<timestamp>-<pid>`.
Running `--activate` twice is a no-op for correct links. The installer assumes
standard config locations; custom `$XDG_CONFIG_HOME`/`ZDOTDIR` require adapting
the link destinations. It does not overwrite your current process environment;
open a fresh login shell, and reload/restart Ghostty as appropriate.

To undo activation, inspect the links with `ls -l`, unlink **only** links pointing
into this repo, then move the corresponding backup files back. Do not delete a
whole config directory blindly. There is no global destructive uninstall command.

## Linux reproduction

Use your distribution's packages or upstream release binaries. Requirements:
Neovim **>=0.12**, tmux **>=3.3**, fzf supporting `--zsh`, fd, rg, Git, a C compiler,
curl/tar, and tree-sitter-cli **>=0.26.1** (not the npm package).
Old distribution Neovim packages may be too old for this configuration.

Example Ubuntu/Debian base (availability/versions vary):

```sh
sudo apt update
sudo apt install git tmux zsh fzf ripgrep fd-find curl tar build-essential \
  jq shellcheck wl-clipboard ncurses-bin
mkdir -p ~/.local/bin
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

Install current Neovim, GitHub CLI, lazygit, Starship, zoxide, uv, Node/pnpm, shfmt, StyLua,
Lua LS, Marksman, Terraform/terraform-ls, tflint, hadolint and tree-sitter-cli via
trusted upstream releases, your distro, or Homebrew on Linux. Install Python/JS
tools with the **same `uv tool`/`pnpm install --frozen-lockfile` commands above**; Ruff can be
installed with `uv tool install ruff` if it is not a system package. Linux desktops
can use wl-clipboard (Wayland) or xclip (X11); SSH uses OSC 52 instead. Ghostty and
the font only need to be installed on your local desktop, not the remote server.
Remote Linux Docker uses the host daemon: Colima is a macOS choice, not a remote
dependency. Only install kubectl/helm/etc. on hosts where they are needed.

```sh
git clone https://github.com/Kyle-j-bush/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --activate
./install.sh --plugins
exec zsh -l
```

`--plugins` preserves the normal tmux server; it clones TPM/resurrect/continuum
directly rather than starting a throwaway default server that could trigger
automatic restoration. It bootstraps LazyVim's locked plugins and installs the
configured Treesitter parsers. Mason is disabled; install editor tools with the
Homebrew/uv/pnpm instructions above (or their Linux equivalents).

## Verify the setup

```sh
shellcheck install.sh scripts/tmux-sessionizer
zsh -n zsh/zshrc zsh/zprofile
stylua --check nvim
starship explain
nvim --headless '+checkhealth' '+qa'
tmux-sessionizer --list
```

Inside Neovim: `:checkhealth`, `:ConformInfo`, `:Lazy profile`,
`:lua =vim.lsp.get_clients()`. Open actual Python, TypeScript, Terraform, YAML,
and Dockerfile projects to verify their project-specific servers and tools. In a
Ghostty tmux session, `echo "$TERM"` should show `tmux-256color`; try Ctrl-hjkl
between an editor split and shell pane, and confirm copied text reaches macOS.
Test OSC 52 only on a host you trust. Static checks cannot prove OS shortcut
routing or clipboard access.

## Version maintenance

- Neovim plugins: the committed Lazy lockfile pins exact commits. `:Lazy restore`
  replays it; `:Lazy update` changes it. Review diffs and test before committing.
- LazyVim and its extras are tracked through the committed `lazy-lock.json`.
  Mason is disabled to keep command-line language tools shared with the shell.
- Treesitter uses LazyVim's current **main** API; configured parsers are installed
  during `--plugins`. `:TSUpdate` updates parser revisions after plugin changes.
- tmux: TPM manages a tiny plugin set. `tmux/plugins.lock` records the commits
  used in the initial tested installation, but TPM itself does not enforce it.
  For exact replay, checkout each recorded SHA in `~/.tmux/plugins/<name>` after
  cloning. Otherwise `prefix U` follows upstream: record/test the new commits.
- Node fallback CLIs are pinned by `tooling/node/pnpm-lock.yaml`; update them with
  `pnpm --dir tooling/node update --latest`, review, smoke-test, and commit both files.
- CLI tool versions installed by Homebrew are **not** pinned by Brewfile. For hard reproducibility,
  use project lockfiles/container images; don't claim Homebrew is hermetic.
- Update formatters as a team and pin them per project to prevent noisy diffs.

The shell uses zsh's native completion and Starship's prompt; it has no large
shell framework or autosuggestions/highlighting plugins. Installed tools need not
all run at startup. Keep work and production kube contexts visible in command
output and confirm target context before making changes; do not create dangerous
shortcuts.
