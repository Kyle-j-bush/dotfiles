# SSH and remote Linux development

## Preferred topology: no nested multiplexer

```text
local Ghostty OS window → ssh -t host → remote tmux project session → remote Neovim
```

Use another Ghostty **OS window** for the SSH connection, not an elaborate tab/split
layout. This is a legitimate terminal boundary: the remote tmux owns remote
processes and survives disconnects. Local tmux cannot keep remote programs alive
if the SSH process dies. Remote tmux is essential for meaningful remote persistence.

```sh
ssh -t devbox
# On the remote host after installing configs/tools:
tmux-sessionizer ~/code/project-a
```

Project files, Git, servers, package managers, and Neovim run on the Linux host;
Ghostty and macOS clipboard remain local. A local tmux session is appropriate for
local code, or for an SSH relay alongside local tasks. Do not install Ghostty,
macOS clipboard commands, or Colima on the headless remote host.

## If nesting local and remote tmux

```text
Ghostty → local tmux relay pane → SSH → remote tmux → Neovim
```

1. Start SSH in a dedicated local task pane.
2. **Press F12 before interacting with remote tmux.** The local session's status
   turns amber; its prefix/root bindings are suspended. Ctrl-f, Ctrl-hjkl, and
   Ctrl-a now reach the remote server normally. On some Mac keyboards use Fn-F12
   or change the macOS function-key/media-key setting.
3. Press F12 again to reclaim local bindings. With local bindings active,
   `prefix h/j/k/l` forces local pane navigation; `prefix a` forwards a prefix
   to inner tmux. The unprefixed navigator recognizes SSH/mosh and forwards hjkl,
   but **Ctrl-f still opens the local picker unless passthrough is enabled**.

Passthrough is **session-scoped**, not per pane/client. Other clients attached
to that same local session are affected; use a dedicated relay session. The
passthrough key table intentionally has only an F12 binding: unmatched keys go to
the pane. Neovim's plugin cannot automatically traverse two multiplexers. Do not
install another navigation plugin to paper over this boundary. If the outer
session gets stuck, `tmux set-option -t SESSION prefix C-a` and
`tmux set-option -t SESSION key-table root` from another shell recover it.

## TERM and terminfo: do not lie globally

- Directly in Ghostty: normally `TERM=xterm-ghostty`.
- Inside either tmux: `TERM=tmux-256color`.
- SSH carries the current terminal identity. Linux needs the matching terminfo
  entry **before** interactive full-screen programs/tmux start.
- tmux's `terminal-features` marks Ghostty/xterm-256color as RGB-capable; Neovim
  uses `termguicolors`. Never set `TERM` in `.zshrc` or force it to `tmux-256color`
  outside tmux. Do not set `screen-256color` as a universal workaround.

Check remote support:

```sh
ssh devbox 'infocmp xterm-ghostty >/dev/null && infocmp tmux-256color >/dev/null'
```

If missing, install entries from your local, trusted installations. On macOS the
Ghostty app bundles its own terminfo. Example commands with the default app path:

```sh
TERMINFO=/Applications/Ghostty.app/Contents/Resources/terminfo \
  infocmp -x xterm-ghostty | ssh devbox 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo -'
/opt/homebrew/opt/ncurses/bin/infocmp -x tmux-256color \
  | ssh devbox 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo -'
```

Confirm the resource location on your installed Ghostty build if the first command
cannot find its entry. Linux may provide these entries in modern ncurses packages;
installing them in `~/.terminfo` does not require root. On a restricted host that
cannot accept new terminfo, use a **connection-scoped fallback**:

```sh
TERM=xterm-256color ssh -t devbox
```

This is a conscious downgrade for that connection, not a permanent global export.
When SSHing from local tmux, the remote must recognize `tmux-256color` too.
Very old remote tmux/ncurses may need upgrading; don't promise modern features
will work merely by changing TERM. Keep current Neovim and matching parsers.

## Clipboard: local APIs versus OSC 52

**Local macOS:** explicit `Space y` / `Space Y` uses pbcopy; `Space p` uses pbpaste.
tmux copy mode writes its buffer, sends OSC 52, and uses pbcopy on Darwin. No
`reattach-to-user-namespace` is required on a modern macOS/tmux installation.

**Remote SSH:** Neovim explicitly selects its native **write-only OSC 52 provider**.
`Space y` / `Space Y` copies through remote tmux (and outer tmux, if present) into
the local Ghostty clipboard. tmux `set-clipboard on` accepts application OSC 52
and forwards it; broad DCS passthrough is not enabled. Remote copy mode uses native
tmux copying/OSC 52, not a nonexistent remote pbcopy.

Clipboard **reading** is intentionally disabled in remote Neovim: clipboard-query
support and consent vary, and queries can block on unsupported terminal chains.
Use **Cmd-v** to send a bracketed paste from local Ghostty to remote Neovim; enter
insert mode first. `Space p` is for local API-backed paste, not remote magic.
Native registers remain local to Neovim; ordinary yanks/deletes do not continually
replace the macOS clipboard. No unnamedplus default is used.

Ghostty allows clipboard writes but asks before reads. OSC 52 means code on a
trusted remote can overwrite your clipboard: consider this a permission/security
tradeoff. Disable clipboard writes for untrusted hosts. SSH does not otherwise
transport your OS clipboard, and remote GUI clipboard tools don't copy to your
Mac. Oversized clipboard data can be limited by terminal/tmux implementations.

If an SSH connection is opened **after** a remote tmux server was started, existing
panes may have stale environment variables. Start a new pane or ensure the SSH
variables are present before launching Neovim. `SSH_TTY`/`SSH_CONNECTION` detection
is not a substitute for verifying the actual attached client path; a remote tmux
server attached simultaneously from local GUI and SSH clients still has one
server environment. Customize the clipboard provider for such unusual setups.

## OS keys

Ghostty's **left Option** sends Alt/Meta; right Option remains available for native
character entry. `Option-c` invokes fzf's shell directory picker. macOS Command
stays outside the terminal protocol for copy/paste/font/window actions. Avoid
Cmd-based editor bindings if Linux/SSH portability matters. If macOS captures a
Control combination (especially Ctrl-space or F12), adjust its OS shortcut;
Neovim/tmux cannot receive a key that the OS consumed.
