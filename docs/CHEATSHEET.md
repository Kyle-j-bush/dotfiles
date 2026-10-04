# Keyboard cheatsheet

**tmux prefix = Ctrl-a. Neovim leader = Space.** Lowercase actions, uppercase
variants; `f` = find, `c` = code, `g` = Git hunks, `b` = buffers. `[`/`]` traverse.
OS Command keys stay in Ghostty; terminal/editor bindings use Control/Meta.

## Projects and shell

| Key/command | Action |
|---|---|
| Ctrl-f | Project/session picker (shell or anywhere in tmux) |
| `t DIRECTORY` | Create/attach/switch directly |
| `z NAME`, `zi` | Jump to frequent directory / interactive zoxide |
| Ctrl-r | fzf shell command history |
| Ctrl-t | Insert chosen file path into shell command |
| Option-c (left Option) | fzf change directory |
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
| Space ff | Project files (respects ignores) |
| Space fr | Recent files in cwd |
| Space fb | Open buffers |
| Space fg | Live rg text search |
| Space f/ | Current-buffer line search; native `/` still works |
| Space fv | Git files |
| Space fs / fS | Document / workspace symbols |
| Space fd | Workspace diagnostics |
| Space fc / fh | Editor command history / help tags |
| `gr` | References picker; native `grr` also available |
| Space e or `-` | Oil parent directory; Enter opens, `-` goes up |
| Oil: edit names, `:w` | Review and perform rename/move/delete operations |
| `[b` / `]b`, Space bd | Previous/next/delete buffer |
| Ctrl-w v / s | Native code split vertically / horizontally |
| Ctrl-hjkl | Navigate windows and tmux; insert mode exits to normal |
| Space w / q | Write / quit with confirmation |
| Space y / Y / p | Copy selection/motion / line / paste local system clipboard |

Start Neovim from the project root; finder cwd stays stable. Opening another file
does not silently `cd`. For a monorepo, narrow deliberately with `:lcd path`.

## Code, diagnostics, Git

| Key | Action |
|---|---|
| `gd` / `gD` / `gi` / `gy` | Definition / declaration / implementation / type |
| `K` | Hover documentation |
| Space cr / ca / cs | Rename / code action / signature |
| Space cf / cF | Format buffer/selection / toggle buffer format-on-save |
| Space cl | Run non-LSP linter; Terraform runs project tflint explicitly |
| Space cd / cq / co | Line diagnostic float / diagnostics to quickfix / open quickfix |
| `[d` / `]d` | Native previous/next diagnostic |
| `[q` / `]q` | Previous/next quickfix result |
| Space ch | Toggle inlay hints (if supported) |
| `[h` / `]h` | Previous/next Git hunk |
| Space gs / gp / gb | Stage / preview hunk / blame line |
| Space gd / gD | Diff against index / HEAD |
| Space gr | **Reset hunk, destructive** |
| `ih` | Git hunk text object |
| `gcc` / visual `gc` | Native line / selection comment |
| `sa` / `sd` / `sr` | mini.surround add / delete / replace |
| `af` / `if`, `aa` / `ia` | mini.ai function-call / argument text objects |
| Ctrl-space / Ctrl-y | Trigger completion / accept selected completion |
| Ctrl-n / Ctrl-p | Completion next / previous (no Ctrl-j/k collision) |
| Tab / Shift-Tab | Snippet next / previous placeholder |

For Git branches/commits/rebase use **tmux prefix g** or shell **lg**.
For PRs: `gh pr create`, `gh pr checkout N`, `gh pr checks`.
If macOS reserves Ctrl-space for input sources, use automatic completion or
remap that macOS shortcut; the tmux prefix deliberately avoids this conflict.
