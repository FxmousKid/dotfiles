# Atuin themes

## Lunar Moon

[lunar-moon.toml](lunar-moon.toml) is a dark-terminal palette combining
LazyGit's Tokyo Night accents with LunarVim's `lunar` colors and the default
Atuin theme's separation between timestamps, commands, and arguments.

| Role | Color |
| --- | --- |
| Main text | Pale moonlight `#c8d3f5` |
| Active tabs / emphasis | Soft purple `#a184df` |
| Command names | Icy blue `#82aaff` |
| Flags / titles | Lavender `#c099ff` |
| Quoted strings / warnings | Warm amber `#ffc777` |
| Variables | Cyan `#89ddff` |
| Successful duration (exit 0) / errors | Lunar green `#9ece6a` / rose `#f7768e` |
| Timestamps / metadata / comments | Muted slate `#737aa2` |

The theme sets foreground colors, preserving the terminal background and
transparency. In `vim-normal` mode, Atuin reverses the selected row's colors.

## Usage

The existing `~/.config/atuin` symlink exposes the theme automatically. Open a
new Atuin search (`Ctrl-R`) to apply it.

To tweak the palette, edit [lunar-moon.toml](lunar-moon.toml). To reset, set
`name = "default"` under `[theme]` in [config.toml](../config.toml).

See the [Atuin theming guide](https://docs.atuin.sh/latest/guide/theming/).
