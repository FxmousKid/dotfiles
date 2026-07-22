# install

Scripts to set these dotfiles up on a machine.

- `install.sh` — makes the symlinks (configs).
- `install-tools.sh` — installs the CLI programs.
- `install-lvim.sh` — standalone LunarVim installer (needs Neovim; installs it via bob first). Called by `install-tools.sh`, runnable alone.

All three are POSIX sh and safe to re-run. `install.sh` and `install-tools.sh`
are menu-driven and ask before changing anything; `install-lvim.sh` runs
straight through (preview with `-n`) — its only prompts come from LunarVim's
own installer and eget's asset picker.

## Run it

One manual prerequisite: **zsh** (macOS ships it · Debian/Ubuntu
`sudo apt install zsh` · Fedora `sudo dnf install zsh`). Installing zsh varies
too much per system to script, so that step is deliberately yours — everything
after it is automated, including switching your default shell.

```sh
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./install/install.sh
```

It warns early if zsh is missing, shows a menu, you pick what you want, it
links it, then offers to install the tools too. Beyond zsh, a fresh machine
only needs `sh`, `git`, and `curl`.

### Default shell

If you picked the zsh component, the last step makes zsh your default shell:
checks `$SHELL`, adds the zsh path to `/etc/shells` if it's missing, runs
`chsh -s`. Skipped when there's no TTY (it prints the manual command instead);
`-n` only shows what it would do.

## Flags (`install.sh` / `install-tools.sh`)

| Flag | What it does |
| --- | --- |
| (none) | menu: pick, review, confirm |
| `-y` | skip the menu, just do the defaults |
| `-n` | dry run: show what would happen, change nothing |
| `-h` | help |

`install-lvim.sh` takes only `-n` (dry run) and `-h`.

Menu keys: a number toggles a row, `a` = all, `n` = none, `c` = continue, `q` = quit.

A few entries are listed but not pre-checked (glow in the tools menu; bash,
hyprland and xmodmap on the links side) — toggle them on if you want them.
`-y` and the no-TTY path install the defaults, so those stay skipped.

## Adding a program

Each script reads a table. You add a row — you never touch the menu code.

A program can be in either or both scripts:

- it has a config to link → `install.sh`
- it needs its binary installed → `install-tools.sh`

### Link its config (`install.sh`)

1. Put the config in the repo (e.g. `bat/config`).
2. Add a row to `REGISTRY` — `key|default|platform|label`:

   ```
   bat|on|all|cat with colors
   ```

3. Add a line to `do_links()`:

   ```sh
   bat) link "$DOTFILES/bat" "$CONFIG/bat" ;;
   ```

`link` backs up anything real already in the way (`*.bak.<time>`) and skips links
that are already correct. `default` is on/off (pre-checked in the menu),
`platform` is `all`, `darwin`, or `linux`.

### Install its binary (`install-tools.sh`)

Add a row to `TOOLS` — `bin|brew|dnf|copr|apt|gh_repo|custom_fn`:

```
bat|bat|bat||bat|sharkdp/bat|
```

For each tool it tries, in order: already installed → custom function → brew →
dnf (+copr) → apt → eget (downloads the GitHub release into `~/.local/bin`).
It uses the first method *available* on the machine — there's no fallback to
the next method if that install then fails; the verify pass at the end flags
the miss, and you rerun to retry. `bin` is the command it checks for; leave
a field blank if it doesn't apply. `apt` is filled only where the Debian/Ubuntu
package ships exactly the binary in `bin` — `fd` stays blank because apt's
`fd-find` installs it as `fdfind`, which would break the presence check; those
fall through to eget. For odd installers, write a function and name it in
`custom_fn` (see `install_neovim`, `install_zap` — zap refuses to run without
zsh, since its installer pipes into `zsh -s`). `install_lvim` is a thin wrapper
around `install/install-lvim.sh`: LunarVim's installer assumes Neovim is
already there, so the script installs it first via bob (pinned 0.9.5 to match
LunarVim 1.4's Neovim-0.9 requirement), then runs the installer. `nvm` and
`node` are custom too: nvm's official script runs with `PROFILE=/dev/null` —
the zshrc is a repo symlink, so it sources nvm itself instead of letting the
installer append lines (the installer's "Profile not found" notice is that,
harmless) — then `nvm install --lts` brings node and npm.

## Not handled on purpose

- `ssh/config` — your live one differs per machine, so do it by hand.
- `~/.gitconfig` — not in the repo yet. To add it: put `git/gitconfig` in the
  repo, add a `git` row, and `git) link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig" ;;`.

## Notes

- Safe to re-run; it skips what's already done.
- Backups are never deleted for you.
- `~/.local/bin` is already on your PATH (set in `zsh/zshenv`).
- `install-tools.sh` verifies outcomes at the end and lists anything that
  didn't actually land (exit 1) — installers can lie: bob prints ERROR yet
  exits 0, eget "succeeds" copying a `.deb` into bin.
- eget runs with `.deb`/`.rpm`/`.AppImage` assets excluded — pick a
  `.tar.gz`/`.zip` when it prompts.
- Installing `nvim` via bob also links the proxy into `~/.local/bin/nvim`
  (bob's own dir is only on PATH via `hosts/<name>.zsh`). Selecting `lvim`
  pins bob's single global nvim to 0.9.x — switch back with `bob use stable`.
