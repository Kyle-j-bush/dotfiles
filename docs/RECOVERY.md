# Persistence and recovery

## Closing Ghostty / losing the terminal

tmux is a separate server process. Closing the client/window or detaching with
`prefix d` normally leaves sessions and their running programs intact. Open
Ghostty, press Ctrl-f, and select the running project; nothing needs resurrection.
This holds for remote tmux after an SSH connection drops as well.

This is **not** protection against `tmux kill-server`, killing a pane's process,
logout policies that terminate user processes, a host shutdown, or a host crash.
Don't confuse an attached terminal dying with its tmux server dying.

## Reboot / tmux server death

- tmux-resurrect saves sessions, window names, pane layouts, working directories,
  and active selections to local state (default `~/.tmux/resurrect`).
- tmux-continuum asks resurrect to save every **5 minutes** while the status-line
  mechanism is running. This is best effort, not a synchronous crash guarantee.
- `prefix Ctrl-s` saves immediately; do this before a planned reboot or risky
  change. `prefix Ctrl-r` restores the last snapshot manually.
- `@continuum-restore on` restores on **tmux server startup**, not every attach or
  reload. Nothing launches tmux at boot/login automatically. After reboot, start
  `tmux` first, let restoration complete, then use Ctrl-f; this avoids racing the
  asynchronous restore with project creation. If necessary use the native `s`
  session tree or rerun the picker after startup.

No launch agent is installed. Ghostty startup stays a clean shell so plain SSH,
rescue shells, and non-tmux use don't get forced into an attachment loop.
Continuum relies on `status-right`; do not add a theme/plugin that replaces it
after continuum. Keep continuum last in the plugin load order. Without a running
attached client/status refresh, do not rely on its timer: manually save. Re-sourcing
our tmux config resets `status-right`, then re-runs TPM so continuum can re-add its
hook. Check `tmux show-options -gv status-right` if autosave stops working.

## What this setup deliberately does not restore

`@resurrect-processes false` disables automatic program replay. Restored panes
contain fresh shells in the saved directories, **not** resumed Neovim/server/SSH
processes. This is safer than replaying arbitrary command lines after a reboot.
Even when replay is enabled, resurrect starts new processes; it cannot checkpoint
their memory, open connections, virtualenv activation, credentials, shell-local
variables, jobs, port-forwards, containers, or the exact interactive shell state.
Shell history lives independently in `~/.zsh_history`.

Pane-content capture is **off** to avoid archiving logs/secrets by default.
tmux history is in-memory, not persisted here. Old snapshots and command metadata
can still disclose project paths or command arguments: never commit snapshot data
to this public repository. Protect/back up them according to your threat model.

The sessionizer's `@project_dir` metadata is not guaranteed to survive resurrect;
the deterministic session name lets it reconnect to restored sessions anyway.
Moved/deleted project directories may no longer restore cleanly; fix the path
manually. Plugins do not synchronize sessions between machines.

## Neovim recovery

- Regularly **write files** (`Space w`). Git commits and backups protect saved
  content; tmux snapshots do not protect editor contents.
- Persistent undo is enabled under Neovim's private state directory, so saved
  files retain useful undo history across editor restarts.
- Swapfiles are enabled in that state directory. After a crash, use `nvim -r`
  or `:recover` and inspect recovered content before writing. Recovery is
  best-effort; don't delete a swapfile without checking whether its editor lives.
- ShaDa retains marks/history/register state as Neovim allows, not a perfect
  workspace or unsaved-buffer snapshot.
- To save an editor layout explicitly without another plugin:

```vim
:mksession! ~/.local/state/nvim/project-a.vim
```

```sh
nvim -S ~/.local/state/nvim/project-a.vim
```

A native editor session restores file/window context, **not unsaved text**. Keep
it outside dotfiles; it may contain sensitive paths. Add a Neovim session plugin
only if you actually need automatic per-project buffer layouts after using the
baseline. It would complement—not replace—tmux's terminal layout recovery.

## Test your own failure modes

1. Create two test project sessions with task windows and splits.
2. Save with `prefix Ctrl-s`, detach, close Ghostty, reattach: programs should still run.
3. Test restore in an expendable tmux environment, not by killing your working server.
   With multiple test sockets, disable continuum automatic restore/save or use a
   separate snapshot directory so test state does not replace your real snapshot.
4. After a planned reboot, start tmux and inspect restored layout/cwd. Restart
   Neovim/services explicitly. Verify editor swap recovery separately.

Do not advertise persistence as reliable until you have tested it on the actual
machine, login/SSH environment, and terminal shortcut configuration.
