# Terminal development environment

A keyboard-first **Ghostty → tmux → LazyVim** environment for Apple Silicon macOS
and modern Linux. tmux is the primary multiplexer; LazyVim supplies the Neovim
distribution, with local overlays for language tools and terminal navigation.

## Start here

```sh
git clone https://github.com/Kyle-j-bush/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
# Homebrew requires explicit trust for this third-party formula (once per Mac).
brew tap hashicorp/tap
brew trust --formula hashicorp/tap/terraform
./install.sh --all
exec zsh -l
```

Reload Ghostty's configuration from its menu (restart if a setting requires it).
Put repositories under `~/code`, `~/work`, or `~/labs`; press **Ctrl-f**.
On an existing tmux server, run `tmux source-file ~/.tmux.conf` once.
Git identity is private, per-machine: see [installation](docs/INSTALL.md).

| Document | Contents |
|---|---|
| [Installation](docs/INSTALL.md) | Exact packages, activation/backups, Linux, checks, updates |
| [Cheatsheet](docs/CHEATSHEET.md) | tmux, editor, project switching, search, Git, LSP |
| [Languages](docs/LANGUAGES.md) | Ownership, project-local tools, Python/JS/infra defaults |
| [Remote development](docs/REMOTE.md) | SSH, nesting, terminfo, clipboard, colors |
| [Recovery](docs/RECOVERY.md) | Surviving window closure, reboot, crashes; hard limits |

## Architecture critique: what not to build

1. **Project sessions are excellent, but not a universal workspace model.** A
   monorepo usually wants one session with task windows, not a session per package.
   A long-running incident or deployment can have its own named session. The picker
   includes existing sessions even if they are not under the configured roots.
2. **Directory basename alone is not an identity.** `~/code/api` and `~/work/api`
   collide. The sessionizer always appends a short SHA-256 path identity, so names
   are deterministic, independent of discovery order. Paths are shown in the UI.
3. **Global Ctrl-f/Ctrl-hjkl have costs.** Ctrl-f replaces Neovim's page-forward
   key inside tmux and zsh's forward-character key. Ctrl-h in insert mode no longer
   backspaces; Ctrl-j no longer inserts a newline. Use Backspace/Enter, arrows, and
   `prefix f` to send literal Ctrl-f. `prefix Ctrl-l` clears a shell screen.
4. **Persistence is not process checkpointing.** Restoring shells is safe;
   automatically replaying Terraform, Docker, SSH, or server commands is not. This
   configuration restores layout/cwd only. Unsaved text needs editor recovery.
5. **SSH adds a second machine boundary.** Prefer a direct SSH connection to remote
   tmux. Nested multiplexers need an explicit handoff, not more navigation plugins.
6. **Too much automatic discovery becomes latency and surprise.** No recursive
   walk of `$HOME`, no automatic editor cwd changes, and no runtime-manager setup.
   Starship handles prompt styling; LazyVim manages editor plugins and parsers.
7. **Editor plugins are not language tools.** Language servers, formatters, and
   linters are installed with Homebrew, uv, and pnpm so they work outside Neovim;
   project configuration remains the source of truth.

## Responsibility boundaries

| Layer | Owns | Does not own |
|---|---|---|
| Ghostty | Font/rendering, OS windows, Option key, Command copy/paste | Project tabs, splits, sessions |
| tmux | Project sessions, task windows, process panes, terminal scrollback, persistence | Editing, repository file search |
| Neovim + LazyVim | Editing, code splits, LSP, diagnostics, hunks, Snacks file/search picker | Background services, terminal layouts, full Git UI |
| zsh + Starship | Commands, history, completion, PATH, styled prompt | Automatic tmux attach, a shell framework |
| fzf | Fast shell/project picking | Another project database |
| fd / rg | File discovery / text search for the shell and editor picker | Persistent indexing or hidden global state |
| zoxide | Frequently visited shell directories (`z`, `zi`) | tmux session identity |
| lazygit | Staging review, branches, commits, conflicts, history, interactive rebase | Editing/LSP |
| Git / gh | Authoritative VCS operations / GitHub PRs, issues, checks | Editor navigation |
| uv / pnpm | Project environments, dependencies, reproducible lockfiles | Neovim plugin management |

### Daily layout

```text
Ghostty OS window
└── tmux session: project-a-<path-hash>
    ├── 1:editor  → Neovim (use Neovim splits for code)
    ├── 2:run     → app/server; split for closely related worker/test watcher
    ├── 3:ops     → Docker / Kubernetes / Terraform commands
    └── 4:review  → optional persistent lazygit or gh workflow
```

Only the first shell/window is created automatically. Run `nvim .`, then
`prefix c` and `prefix ,` to create/name task windows as needed. There is no
hard-coded process template to drift, and no automatic execution of project code.
New panes/windows inherit the active pane's cwd. Renumbering keeps indices compact
(at the cost of indices changing after a window is closed).

### Project/session manager

`scripts/tmux-sessionizer` is linked to `~/.local/bin/tmux-sessionizer`. zsh places
`~/.local/bin` on PATH. **Ctrl-f** invokes it directly from zsh or in a tmux popup,
including while Neovim is focused. Inside tmux it switches clients; outside it
attaches. Escape/cancellation changes nothing.

```sh
tmux-sessionizer                        # fd + fzf picker
tmux-sessionizer ~/labs/terraform       # direct create/attach/switch
tmux-sessionizer --list                 # human-readable candidates
tmux-sessionizer --name ~/code/api      # deterministic safe session name
```

Edit `tmux/project-roots` (symlinked to `~/.config/tmux/project-roots`) for shared
roots, or use `TMUX_PROJECT_ROOTS_FILE` for an untracked per-machine file. Each
line is a parent; direct child directories are projects. Missing roots are
ignored; roots must be absolute or begin with `~/`. No shell expressions are
evaluated. For `~/work/org/project`, add `~/work/org` as a root rather than making
the search arbitrarily recursive. `TMUX_PROJECT_DEPTH=2` is available when useful.
Hidden projects are included; `.git`, dependencies, caches, and build outputs
are excluded, and fd respects ignore files. `fd --no-ignore` is deliberately not
the default. Canonical paths deduplicate overlapping roots. Spaces and non-ASCII
paths work; paths containing tabs/newlines/carriage returns are explicitly unsupported.

Project names are sanitized to ASCII letters/digits/dash/underscore, capped at
40 characters plus a 12-hex SHA-256 suffix. Home-relative identities avoid baking
in the username. Even unlikely hash collisions with a recorded project path are
refused. A project directory move gets a new identity; the old session remains
selectable until you close it. Existing project entries and a separate running
session section can point at the same session: this intentional duplication makes
ad-hoc sessions recoverable without maintaining a second project registry.

## Shell prompt

Starship provides a compact two-line prompt with a truncated working directory,
Git branch/status, and long-command duration. Over SSH it also shows the remote
user and host. Edit `starship/starship.toml`; the prompt uses ordinary text/color
styles and does not require a Nerd Font.

## Chosen plugins and tradeoffs

### tmux: three repositories

| Plugin | Why |
|---|---|
| TPM | Familiar, simple plugin install/update keys |
| tmux-resurrect | Explicit layout/cwd snapshot, manual save/restore |
| tmux-continuum | Periodic saves and restore on server start; depends on resurrect |

**Not installed:** tmux-sensible (defaults are explicit here), tmux-yank (native
copy-pipe + OSC 52 already do the job), tmux themes, tmux session managers, and the
TPM copy of vim-tmux-navigator (its short tmux binding recipe is already in our
config). The navigator plugin is installed on the **Neovim side** only.

### Neovim: LazyVim distribution with local overlays

| Plugin | Responsibility |
|---|---|
| LazyVim | Distribution defaults, Snacks picker, completion, UI, LSP keymaps, Git signs |
| lazy.nvim | Plugin lifecycle and committed `lazy-lock.json` |
| LazyVim language extras | Python, Docker, JSON, Terraform, YAML and related editor support |
| nvim-lspconfig | Server definitions, configured to use external Homebrew/uv/pnpm tools |
| conform.nvim | Formatting on save and explicit formatting; LSP formatting fallback disabled |
| nvim-lint | Hadolint/markdownlint diagnostics and manually triggered TFLint |
| vim-tmux-navigator | Neovim ↔ tmux Ctrl-hjkl crossing |
| mini.ai / mini.surround / mini.files | Text objects, surround editing, and editable directory browser |

Mason is disabled: the installer-managed tools remain usable from the shell and
project tasks. Use `:Lazy profile` to measure startup and `:Lazy restore` to replay
the committed plugin lockfile. `Space ff` opens file search; **Space fm** opens
`mini.files` to browse and edit directories. `mini.map` is a separate code overview
plugin, not the file manager.

## Git workflow

- **Editor:** hunk navigation/preview, stage a small reviewed hunk, line blame, and
  current-buffer diff. Write files before staging; gitsigns can stage buffer changes
  before the working-tree file is saved. Hunk reset is destructive; no reset alias.
- **lazygit:** `prefix g` opens a cwd-aware popup. Review staged content, commit,
  switch branches, resolve conflicts, inspect history, and rebase. `lg` in a task
  window is useful for long reviews. No editor wrapper plugin required.
- **Shell Git:** authoritative scripting/worktrees/bisect and explicit recovery.
  `git diff --check`, `git diff --cached`, and project tests before a commit.
- **GitHub CLI:** `gh pr create`, `gh pr checkout NUMBER`, `gh pr checks`,
  `gh pr view --web`, `gh issue list`. Authentication stays in the system keychain.

Pull defaults to fast-forward-only (you choose how to resolve divergence), fetch
prunes stale remote references, `zdiff3` improves conflict context, and rerere
remembers resolutions. No personal Git identity or tokens are committed.

## Dotfile layout and maintenance

```text
~/.dotfiles/
├── Brewfile
├── install.sh
├── ghostty/config
├── git/gitconfig
├── tmux/{tmux.conf,project-roots}
├── zsh/{zshrc,zprofile}
├── scripts/tmux-sessionizer
├── starship/starship.toml
├── tooling/node/{package.json,pnpm-lock.yaml,pnpm-workspace.yaml}
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── config/{options,keymaps,autocmds,lazy}.lua
│       └── plugins/{editor,lsp,completion,treesitter}.lua
└── docs/{INSTALL,CHEATSHEET,LANGUAGES,REMOTE,RECOVERY}.md
```

The explicit symlink installer is smaller than a Stow dependency for this number
of files. It is idempotent, backs up conflicting files/directories/symlinks to
`~/.local/state/dotfiles-backups/<timestamp>-<pid>/`, and never adopts/merges
unfamiliar configurations. Private overrides live outside this public repository:
`~/.config/zsh/local.zsh`, `~/.config/tmux/local.conf`, and
`~/.config/git/local.gitconfig`. Keep credentials, history, SSH keys, sessions,
undo/swap/clipboard data, and project `.env` files out of Git.

Updates are deliberate: review `brew outdated`, `uv tool upgrade basedpyright`,
and `pnpm --dir tooling/node outdated`; run `:Lazy update`, review the lockfile,
and run `:TSUpdate` after parser changes. For an exact plugin replay use `:Lazy restore`.
TPM: `prefix U`. No auto-update checker interrupts the workday.
