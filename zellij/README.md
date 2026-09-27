# zellij

Zellij terminal multiplexer config.

## Files

- `config.kdl` — main config (keybinds, theme, layout).
- `config.kdl.bak` — a backup Zellij generated.

## Subfolders

- [hooks](hooks/) — legacy command-rewrite hook, disabled.
- [shell](shell/) — legacy Claude wrapper, no longer sourced.
- [layouts](layouts/README.md) — custom layouts.
- [themes](themes/README.md) — theme files.
- [plugins](plugins/README.md) — local plugin binaries.

## Highlights

- Theme: tokyo-night · layout: zj-minimal
- Built-in one-line compact bar: tabs and mode, with no weather, clock, Git
  polling, or external status-bar plugin.
- `Ctrl t`, then `n`, and `Ctrl b`, then `c`, explicitly load `zj-minimal`,
  including in running sessions that cached the previous default layout.
- Mouse on, pane frames off, startup tips off.
- `Alt m` toggles the vendored MultiView monitoring dashboard. The Alacritty
  keymap explicitly emits `Esc m` because macOS Option otherwise composes `µ`.
- Clipboard transport uses portable OSC52.
- Session/layout and scrollback saving remain enabled (`serialize_pane_viewport`
  + 10k lines). Automatic Claude conversation rewriting is disabled.

## Notes

### Performance and Claude recovery

Zellij 0.44.3 runs `post_command_discovery_hook` synchronously for every row of
`ps -ao ppid,args`, including processes outside the current session. Recurring
command discovery therefore spawned many shells and blocked the PTY thread.
The hook and its paired `--session-id` wrapper are disabled; their files are
retained for reference. MultiView remains available on demand and is not loaded
at startup.

During the September 2026 cleanup, the old status plugin panes were removed from
running sessions without restarting their terminals. Those existing tabs have
no status bar; newly created tabs use the built-in bar. A bare CLI
`zellij action new-tab` or a break-pane action can still use a running server's
cached old template. Until that session is eventually replaced, use the keyboard
shortcuts above or `zellij action new-tab --layout zj-minimal`.

See [diagnostic results](../reports/zellij-performance.md) for measurements.

New shells call Claude directly. In an already-open shell, run
`unfunction claude 2>/dev/null` to remove the old wrapper without restarting the
shell. Existing Claude processes are unaffected. To reopen a conversation, use
`claude --resume <id>` (or `claude --continue` for the last chat in that directory).
An older saved command containing `--session-id <id>` must use `--resume <id>`
when replayed. Detaching and reattaching a running session still keeps its
processes alive normally.

### Clipboard

Clipboard copying uses Zellij's default OSC52 path so the same config works on
macOS, Linux, and over SSH. Set `copy_command` locally only when a terminal does
not support OSC52.
