# install

Scripts to set these dotfiles up on a machine.

- `install.sh` — makes the symlinks (configs).
- `install-tools.sh` — installs the CLI programs.

Both are POSIX sh, safe to re-run, and ask before changing anything.

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

## Flags (both scripts)

| Flag | What it does |
| --- | --- |
| (none) | menu: pick, review, confirm |
| `-y` | skip the menu, just do the defaults |
| `-n` | dry run: show what would happen, change nothing |
| `-h` | help |

Menu keys: a number toggles a row, `a` = all, `n` = none, `c` = continue, `q` = quit.

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
It stops at the first one that works. `bin` is the command it checks for; leave
a field blank if it doesn't apply. `apt` is filled only where the Debian/Ubuntu
package ships exactly the binary in `bin` — `fd` stays blank because apt's
`fd-find` installs it as `fdfind`, which would break the presence check; those
fall through to eget. For odd installers, write a function and name it in
`custom_fn` (see `install_lvim`, `install_zap` — zap refuses to run without
zsh, since its installer pipes into `zsh -s`).

## Not handled on purpose

- `ssh/config` — your live one differs per machine, so do it by hand.
- `~/.gitconfig` — not in the repo yet. To add it: put `git/gitconfig` in the
  repo, add a `git` row, and `git) link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig" ;;`.

## Notes

- Safe to re-run; it skips what's already done.
- Backups are never deleted for you.
- `~/.local/bin` is already on your PATH (set in `zsh/zshenv`).
