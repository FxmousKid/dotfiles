# zellij

Zellij terminal multiplexer config.

## Files

- `config.kdl` — main config (keybinds, theme, layout).
- `config.kdl.bak` — a backup Zellij generated.

## Subfolders

- [layouts](layouts/README.md) — custom layouts.
- [themes](themes/README.md) — theme files.
- [plugins](plugins/README.md) — local plugin binaries.

## Highlights

- Theme: tokyo-night · layout: zj-minimal
- Mouse on, pane frames off, startup tips off.
- `Alt m` toggles the vendored MultiView monitoring dashboard.
- Clipboard transport uses portable OSC52.

## Notes

Clipboard copying uses Zellij's default OSC52 path so the same config works on
macOS, Linux, and over SSH. Set `copy_command` locally only when a terminal does
not support OSC52.
