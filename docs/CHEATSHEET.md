# Keyboard cheatsheet

**tmux prefix = Ctrl-a. LazyVim leader = Space.** LazyVim's which-key popup shows
available bindings after pressing Space. OS Command keys stay in Ghostty;
terminal/editor bindings use Control/Meta.

## Projects and shell

| Key/command | Action |
|---|---|
| Ctrl-f | Project/session picker (shell or anywhere in tmux) |
| `t DIRECTORY` | Create/attach/switch directly |
| `z NAME`, `zi` | Jump to frequent directory / interactive zoxide |
| Ctrl-r | fzf shell command history |
| Ctrl-t | Insert chosen file path into shell command |
| Option-c (left Option) | fzf change directory |
| Right Arrow | Accept the zsh history suggestion, when shown |
| Cmd-c / Cmd-v | Ghostty selection copy / terminal paste |

## tmux

Every row below except Ctrl-hjkl, Ctrl-f, and F12 needs **prefix first**.

| Key | Action |
|---|---|
| Ctrl-h / j / k / l | Left/down/up/right Neovim split or tmux pane |
| `h / j / k / l` | Force tmux pane navigation (useful outside SSH) |
| `c` | New task window in current cwd |
| `,` | Rename current window |
| `|` / `-` | Split side-by-side / top-bottom, current cwd |
| `H / J / K / L` | Resize 5 cells; repeat without re-prefixing |
| `1…9` | Window by index |
| `p` / `n` | Previous/next window (repeatable) |
| Tab | Last window |
| `z` | Zoom/unzoom pane |
| `s` / `w` | Native session / window tree |
| `d` | Detach; programs continue running |
| `r` | Reload config |
| `g` | lazygit popup (current cwd) |
| `[` or PgUp | Enter copy mode |
| Copy mode: `/`, `v`, `y` | Search scrollback, select, copy and exit |
| Copy mode: Ctrl-v | Rectangle selection |
| `]` | Paste tmux buffer |
| Ctrl-s / Ctrl-r | resurrect save / restore |
| `I` / `U` | TPM install / update |
| Ctrl-l | Send shell clear-screen |
| `f` | Send literal Ctrl-f (Neovim page-forward) |
| `a` or Ctrl-a | Send literal Ctrl-a (shell beginning-of-line / inner prefix) |
| F12 (no prefix) | Toggle outer-session passthrough for nested tmux; amber status |

The familiar native copy/paste bindings remain available. On a MacBook, PageUp
is normally Fn-Up; **prefix [** is usually easier.

## Neovim: navigation and search

| Key | Action |
|---|---|
| Space ff | Find files with LazyVim's Snacks picker |
| Space fF | Find files from the current working directory |
| Space fg | Find Git-tracked files |
| Space fr / fR | Recent files / recent files in cwd |
| Space fb or Space , | Open buffers |
| Space / | Search text in the project root |
| Space sg / sG | Search project text / current directory |
| Space e / fe | Snacks file explorer at project root; Space E uses cwd |
| **Space fm** | Browse/manage files with mini.files (current file's directory) |
| Space fM | Open mini.files at the working directory |
| Space `<tab>` `]` / `[` | Next / previous Neovim tab page |
| Space `<tab>` `<tab>` | Create a Neovim tab page |
| Space `<tab>` d / l / f | Close / last / first Neovim tab page |
| `[b` / `]b`, Space bd | Previous/next/delete buffer |
| Ctrl-w v / s | Native code split vertically / horizontally |
| Ctrl-hjkl | Navigate windows and tmux; insert mode exits to normal |
| Ctrl-s | Save buffer |
| Space y / Y / p | Copy selection/motion / line / paste local system clipboard |

Start Neovim from the project root; finder cwd stays stable. Opening another file
does not silently `cd`. For a monorepo, narrow deliberately with `:lcd path`.

## Code, diagnostics, Git

| Key | Action |
|---|---|
| `gd` / `gD` / `gI` / `gy` | Definition / declaration / implementation / type |
| `K` | Hover documentation |
| Space cr / ca / cl | Rename / code action / LSP information |
| Space cf | Format buffer/selection |
| Space uf / uF | Toggle global / current-buffer format-on-save |
| Space cL | Run linter; Terraform runs project TFLint explicitly |
| Space cd / xx / xq | Line diagnostic / diagnostics list / quickfix list |
| `[d` / `]d` | Native previous/next diagnostic |
| `[q` / `]q` | Previous/next quickfix result |
| Space uh | Toggle inlay hints |
| `[h` / `]h` | Previous/next Git hunk |
| Space ghs / ghp / ghb | Stage / preview / blame hunk |
| Space ghd / ghD | Diff against index / base |
| Space ghr | **Reset hunk, destructive** |
| `ih` | Git hunk text object |
| `gcc` / visual `gc` | Native line / selection comment |
| `gsa` / `gsd` / `gsr` | mini.surround add / delete / replace |
| `af` / `if`, `aa` / `ia` | mini.ai function-call / argument text objects |
| Tab | Accept the selected completion; otherwise advance snippets or insert a tab |
| Enter | Insert a newline without accepting a completion |
| Ctrl-space | Trigger completion menu |

Inside mini.files, add a line to create an entry, edit a name to rename it, or
cut/paste entries between directory columns to move them. Press `=` to review and
confirm the queued operations. Deletes go to mini.files' trash, not permanent
deletion. Use `g?` or `:help MiniFiles` for the full key reference.

For Git branches/commits/rebase use **tmux prefix g** or shell **lg**.
For PRs: `gh pr create`, `gh pr checkout N`, `gh pr checks`.
If macOS reserves Ctrl-space for input sources, use automatic completion or
remap that macOS shortcut; the tmux prefix deliberately avoids this conflict.
