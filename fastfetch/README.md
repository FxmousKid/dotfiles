# fastfetch

Fastfetch config (the system info shown when a login shell opens).

## Files

- `config.jsonc` — the modules, labels, colors, and commands to show.

## Subfolders

- [logos](logos/README.md) — the custom logo it uses.

## Notes

Grouped into hardware / software / uptime. It detects Linux via `/etc/os-release`
and falls back to `uname`, so it works on macOS too.
