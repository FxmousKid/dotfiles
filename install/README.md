# Install

Bootstrap scripts for these dotfiles. Two independent, table-driven layers:

| Script | Table | Job |
| --- | --- | --- |
| `install.sh` | `REGISTRY` | **Symlink configs** into `~` / `~/.config` |
| `install-tools.sh` | `TOOLS` | **Install the CLI binaries** (brew → dnf → eget) |

Both are POSIX `sh`, idempotent, non-destructive, and interactive by default. The
menus build themselves from the tables — to add a program you edit a table, never
the menu code.

## Quick start

```sh
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./install/install.sh        # pick configs, then it offers to install tools too
```

On a fresh machine you only need `sh`, `git`, and `curl`.

## Flags

Both scripts share the same flags:

| Flag | Effect |
| --- | --- |
| *(none)* | Interactive menu: pick what you want, review, confirm. |
| `-y` | Non-interactive. `install.sh` links this OS's defaults; `install-tools.sh` installs all missing tools. Use for `curl \| sh` / no-TTY. |
| `-n` | Dry run — print exactly what would happen, change nothing. **Run this first if unsure.** |
| `-h` | Help. |

Menu controls: `number` = toggle a row, `a` = all, `n` = none, `c` = continue, `q` = quit. Then a final `[y/N]` confirm before anything is touched.

## How symlinking works (`install.sh`)

`REGISTRY` rows are `key|default|platform|label`:

| Field | Meaning |
| --- | --- |
| `key` | Short id. Must match the `do_links()` case. Shown in the menu. |
| `default` | `on` = pre-checked, `off` = listed but unchecked. |
| `platform` | `all`, `darwin` (macOS), or `linux`. Row only appears/links on that OS. |
| `label` | Description shown in the menu. |

The matching `do_links()` case decides *where* it links via the `link SRC DEST` helper:

```sh
bat) link "$DOTFILES/bat" "$CONFIG/bat" ;;
```

`link` is safe by design:

- Already the correct symlink → **skipped** (`[ok]`).
- A real file/dir in the way → **moved to `<target>.bak.<timestamp>`**, then linked.
- A wrong symlink → repointed.

`DEST` is usually `$CONFIG/<name>` (XDG) or `$HOME/.<name>` (a home dotfile, like `tmux`).

## How tool install works (`install-tools.sh`)

`TOOLS` rows are `bin|brew|dnf|copr|gh_repo|custom_fn`:

| Field | Meaning |
| --- | --- |
| `bin` | Command used to check presence (`command -v <bin>`). |
| `brew` | Homebrew formula (macOS). |
| `dnf` | dnf package (Fedora). |
| `copr` | Optional copr repo to enable first (blank if none). |
| `gh_repo` | `owner/repo` for the eget release-binary fallback. |
| `custom_fn` | Name of a shell function, for bespoke installers only (blank usually). |

For each selected tool the resolver stops at the first method that applies:

```
already present  →  custom_fn  →  brew  →  dnf (+copr)  →  eget  →  skip
```

- **eget** is the release-binary fallback. It is bootstrapped once into `~/.local/bin`,
  then `eget owner/repo --to ~/.local/bin` auto-detects OS + arch and extracts the right
  asset — so there is no per-arch logic to maintain, and no root needed.
- `~/.local/bin` is already on `PATH` via `zsh/zshenv`.
- The menu marks installed tools `[✓]` and missing ones `[x]` with the method that will be used.

**Custom installers** (no package, bespoke steps — e.g. `lvim`, `zap`, `nvim` via `bob`)
are shell functions named in the `custom_fn` column:

```sh
install_bat() { curl -fsSL https://example/install.sh | sh; }
# then in TOOLS:   bat|||||install_bat
```

## Adding a program

A program can live in **either or both** layers: config-only, binary-only (e.g. `rg`,
`tree`), or both. Example — manage `bat`'s config *and* auto-install it everywhere:

```sh
# 1. install/install.sh  (symlink its config)
#    REGISTRY  -> add a row:
bat|on|all|cat clone with syntax highlighting
#    do_links()-> add a case:
bat) link "$DOTFILES/bat" "$CONFIG/bat" ;;

# 2. install/install-tools.sh  (install the binary)
#    TOOLS     -> add a row:
bat|bat|bat||sharkdp/bat|
```

(Plus drop the actual config in the repo, e.g. `bat/config`.) That's it — `bat` now
appears in both menus, links to `~/.config/bat`, and installs via brew / dnf / eget.

## Intentionally not handled

- **`ssh/config`** — the live `~/.ssh/config` tends to diverge per machine; reconcile by hand before adding a row.
- **`~/.gitconfig`** — no `git/` dir in the repo yet. To manage it: add `git/gitconfig`, a `git|on|all|git config` REGISTRY row, and `git) link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig" ;;`.

## Notes

- **Always safe to re-run** — both scripts skip what's already done.
- `INSTALL_INTERACTIVE=1` forces the menu even without a TTY (used for testing).
- Backups (`*.bak.<timestamp>`) are never deleted automatically — clean them up yourself once you're happy.
- Tools live in their own folders at the repo root; this folder only holds the installers.
