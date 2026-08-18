# zellij

Zellij terminal multiplexer config.

## Files

- `config.kdl` — main config (keybinds, theme, layout).
- `config.kdl.bak` — a backup Zellij generated.

## Subfolders

- [hooks](hooks/) — `post_command_discovery_hook` scripts.
- [shell](shell/) — shell snippets sourced from `zsh/zshrc`.
- [layouts](layouts/README.md) — custom layouts.
- [themes](themes/README.md) — theme files.
- [plugins](plugins/README.md) — local plugin binaries.

## Highlights

- Theme: tokyo-night · layout: zj-minimal
- Mouse on, pane frames off, startup tips off.
- `Alt m` toggles the vendored MultiView monitoring dashboard. The Alacritty
  keymap explicitly emits `Esc m` because macOS Option otherwise composes `µ`.
- Clipboard transport uses portable OSC52.
- Sessions resurrect onto their own Claude Code conversation, and panes come back
  with their scrollback (`serialize_pane_viewport` + 10k lines).

## Notes

### Claude Code session resurrection

Zellij serializes the literal argv it finds running in a pane, so a resurrected
pane used to re-run bare `claude` and open an empty chat. Two pieces fix that:

- `shell/claude-session.zsh` pins `--session-id <uuid>` on every interactive
  `claude` (sourced from `zsh/zshrc`), so the conversation id is *in* the argv.
- `hooks/claude-resurrect.sh`, wired as `post_command_discovery_hook`, rewrites
  that into `claude --resume <uuid>` at serialization time — replaying
  `--session-id` verbatim fails with "Session ID <uuid> is already in use".

Panes started as bare `claude` fall back to `--continue`, which reopens the last
conversation in that pane's cwd (zellij serializes cwd per pane). Subcommands
(`claude agents`, `gateway`, `ultrareview`, ...) and headless `-p` runs take no
session flag, so both sides pass them through untouched.

Two limits worth knowing. The hook is handed only `$RESURRECT_COMMAND` — no pane
id and no pane cwd — so it cannot tell two panes apart on its own; and a pane
sitting at a shell prompt when the session was serialized comes back as a shell,
because Zellij records shell panes with no command at all. Resurrected commands
also wait behind a "Press ENTER to run" banner; `zellij attach -f` runs them
immediately.

### Clipboard

Clipboard copying uses Zellij's default OSC52 path so the same config works on
macOS, Linux, and over SSH. Set `copy_command` locally only when a terminal does
not support OSC52.
