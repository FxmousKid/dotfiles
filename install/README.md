# install

Scripts to set these dotfiles up on a machine.

- `install.sh` — makes the symlinks (configs).
- `install-tools.sh` — installs the CLI programs.
- `install-lvim.sh` — standalone LunarVim installer (needs `make` and `cargo`;
  installs Neovim via Bob first). Called by `install-tools.sh`, runnable alone.
- `manifests/tools.sh` — editable tool/source table and version pins.
- `lib/package-managers.sh` — small Homebrew, DNF/COPR, and apt adapters.
- `test-manifest.sh` — network-free contract check for manifest edits.

All three are POSIX sh and safe to re-run. `install.sh` and `install-tools.sh`
are menu-driven and ask before changing anything; `install-lvim.sh` runs
non-interactively (preview with `-n`).

## Run it

On a fresh machine, install only `git` and `curl` first. `install-tools.sh`
installs zsh through Homebrew, DNF, or apt when it is not already present.

```sh
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./install/install.sh -y
./install/install-tools.sh -y
```

Link first so Bob and LunarVim see their repository configs during installation.
In an interactive run, accept `install.sh`'s offer to install the tools and it
will retry the default-shell step once zsh is available. With the two explicit
non-interactive commands above, rerun `install.sh -y` from a terminal if you
also want it to run `chsh`.

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

### Install its binary (`manifests/tools.sh`)

Add a row to `TOOLS` in `install/manifests/tools.sh` —
`bin|brew|dnf|copr|apt|gh_repo|custom_fn|eget_filters|eget_file`:

```
bat|bat|bat||bat|sharkdp/bat|||
```

For each tool it tries, in order: already installed → custom function → brew →
dnf (+copr) → apt → eget (downloads the GitHub release into `~/.local/bin`).
It uses the first method *available* on the machine — there's no fallback to
the next method if that install then fails; the verify pass at the end flags
the miss, and you rerun to retry. `bin` is the command it checks for; leave
a field blank if it doesn't apply. `apt` is filled only where the Debian/Ubuntu
package ships exactly the binary in `bin` — `fd` stays blank because apt's
`fd-find` installs it as `fdfind`, which would break the presence check; those
fall through to eget. For odd installers, write a function in
`install-tools.sh` and name it in
`custom_fn` (see `install_neovim`, `install_zap` — zap refuses to run without
zsh, since its installer pipes into `zsh -s`). `install_lvim` is a thin wrapper
around `install/install-lvim.sh`: LunarVim's installer assumes Neovim is
already there, so the script installs it first via bob (pinned v0.10.4, same
as the `nvim` row — it passes LunarVim's ≥0.9 check), then runs the installer. `nvm` and
`node` are custom too: nvm's official script runs with `PROFILE=/dev/null` —
the zshrc is a repo symlink, so it sources nvm itself instead of letting the
installer append lines. Its misleading "Profile not found" help block is
suppressed, while stderr and a post-install file check still expose real
failures. Then `nvm install --lts` brings node and npm.

The default tool set also installs zsh, `make`, `zip`/`unzip`, Cargo/Rust,
cscope, tmux, Clang/clangd, and JDK 21. SDKMAN owns Java on every platform:
the manifest pins an exact Temurin 21 candidate, the installer runs SDKMAN in
noninteractive mode without editing the linked shell config, and the zsh config
initializes it explicitly. Stable links in `~/.local/bin` follow SDKMAN's
`candidates/java/current`, so `sdk default java ...` also controls
noninteractive callers. Cargo is needed to build CodeSnap's native generator on Linux
ARM64; that build explicitly uses Clang because Fedora 44's GCC 15 rejects the
plugin's bundled Oniguruma signatures. After
LunarVim and its plugins finish, `lvim-mason.lua` refreshes Mason and installs
the servers explicitly configured here: pyright, bash-language-server,
lua-language-server, jdtls, and kotlin-language-server. The helper waits for
and verifies every package, so the installer cannot report success while a
background Mason job is still failing.

The last two fields make GitHub-release installs deterministic. Put extra
space-separated `--asset` filters in `eget_filters`, and use `eget_file` when
an archive contains several executable files. The shipped rows use these to
avoid prompts on Zellij/Yazi/Atuin and to prevent Fastfetch's executable Bash
completion from being mistaken for the real binary. Bob's `@bob` marker is
resolved to its exact OS/architecture archive by the script.

The separation is intentional: most edits are a one-line manifest change;
package-manager syntax stays in `lib/package-managers.sh`; sequencing, custom
installers, and final verification stay in `install-tools.sh`. After editing
the table, run `./install/test-manifest.sh` and
`./install/install-tools.sh -n -y`. Tests may point the orchestrator at a small
alternate manifest with `INSTALL_TOOLS_MANIFEST=/path/to/tools.sh`.

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
- eget runs with `.deb`/`.rpm`/`.AppImage` assets excluded and deterministic
  per-tool asset filters. On Linux, a download is capped at two minutes and
  retried once so a CDN connection cannot block the install forever.
- Installing `nvim` via bob also links the proxy into `~/.local/bin/nvim`
  (bob's own dir is only on PATH via `hosts/<name>.zsh`). The `nvim` and
  `lvim` rows both pin v0.10.4, so they agree on bob's single global version;
  switch anytime with `bob install <v> && bob use <v>`.
- The v0.10.4 pin is deliberate: it's the first release with upstream
  linux-arm64 binaries (older versions make bob fetch a non-runnable x86_64
  tarball on arm boxes — the scripts catch that by *executing* the result),
  and the last comfortably close to LunarVim 1.4's Neovim-0.9 target.
