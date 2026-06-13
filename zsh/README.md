# zsh

Shell config, split by when zsh loads each file, and set up to work on more than
one machine.

## The files

| File | Loaded | What's in it |
| --- | --- | --- |
| `zshenv` | every shell | env vars, PATH, the device helpers |
| `zprofile` | login shells | Homebrew, fastfetch (once) |
| `zshrc` | interactive shells | prompt, plugins, aliases, then the host file |
| `p10k.zsh` | from `zshrc` | the prompt theme (`p10k configure` to change) |
| `hosts/` | one file, from `zshrc` | per-machine paths and aliases |

`install/install.sh` links them to `~/.zshenv` and, under `~/.config/zsh`,
`.zshrc`, `.zprofile`, `.p10k.zsh`, and `hosts/`.

## PATH

PATH is built in `zshenv` with `typeset -U`, so it can't get duplicate entries
no matter how many shells open or reload.

macOS has a catch: it runs `path_helper` after `zshenv` and wipes custom PATH
entries. So `zprofile` rebuilds PATH again afterwards — that's why your dirs
survive.

## Per-machine config (`hosts/`)

Anything that's only true on one machine — version-locked paths, personal
aliases — goes in `hosts/<name>.zsh`, not in the shared files.

How a machine finds its file:

1. `get_device_id` makes a short hash from a hardware id. Only the hash goes in
   the repo, never the real id.
2. `device_name` matches that hash to a name.
3. `zshrc` loads `hosts/<name>.zsh` last, so it wins over everything else.

A machine that isn't in the list becomes `unknown` and just loads nothing.

### Add a machine

```sh
get_device_id                 # run on the new machine, copy the hash
# add to device_name() in zshenv:   <hash>) printf <name> ;;
# create zsh/hosts/<name>.zsh
```

Mapped now: `macm1` (this Mac). `asahim1` is ready but needs its hash added on
that box.

## Plugins

Plugin manager is Zap. It loads autosuggestions (grey hint, press → to accept),
supercharge, syntax-highlighting, and powerlevel10k. Completion is cached.
`atuin` handles history search.
