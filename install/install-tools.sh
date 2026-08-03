#!/bin/sh
# =============================================================================
#  install/install-tools.sh — install the CLI tools these dotfiles expect.
#
#  Strategy (package-manager-first hybrid), per tool, in order:
#    1. already on PATH           -> skip
#    2. custom installer          -> run it      (lvim, zap, nvim-via-bob, ...)
#    3. Homebrew  (macOS)         -> brew install
#    4. dnf       (Fedora)        -> sudo dnf install  (+ copr enable if needed)
#    5. apt-get   (Debian/Ubuntu) -> sudo apt-get install
#    6. GitHub release            -> eget <repo> --to ~/.local/bin   (no root)
#    7. nothing applies           -> warn and skip
#
#  eget figures out the OS + arch and grabs the right file, so there's no
#  per-arch logic here. It gets installed once into ~/.local/bin.
#
#  Interactive by default (pick what to install); -y installs the missing
#  defaults (DEFAULT_OFF entries like glow stay opt-in), -n dry-runs (prints
#  the method per tool, changes nothing).
#
#  Add a tool = add one row to install/manifests/tools.sh.
# =============================================================================

set -eu

OS="$(uname)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
# Make this run's own installs visible to itself: on a fresh Ubuntu,
# ~/.local/bin isn't on PATH until the next login (its .profile only adds it
# if the dir already existed), so tools installed early in a run (bob via
# eget) were invisible to later steps — install_neovim said "bob not
# installed yet" right after bob was installed.
PATH="$LOCAL_BIN:$PATH"; export PATH
# If nvm was installed on an earlier run, expose its newest Node toolchain now.
# nvm normally mutates only an interactive shell, but LunarVim/Mason need npm
# while this POSIX installer is still running.
NVM_NODE_BIN="$(find "$HOME/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin 2>/dev/null \
  | sort | tail -n 1)"
[ -n "$NVM_NODE_BIN" ] && PATH="$NVM_NODE_BIN:$PATH" && export PATH
EGET="$LOCAL_BIN/eget"
# Keep eget away from package-format assets: if a .deb/.rpm/.AppImage asset
# gets picked, eget "extracts" it by copying the package file itself into
# ~/.local/bin — tool NOT installed, zero errors (a .deb just sits in bin).
# --asset takes a substring, ^ negates it, and the flag is repeatable; the
# match is case-sensitive, so cover both AppImage spellings.
EGET_FILTER='--asset ^.deb --asset ^.rpm --asset ^.AppImage --asset ^.appimage'
DRY=0
ASSUME_YES=0

# Keep editable data and distro mechanics out of this orchestrator. A custom
# manifest path is useful for testing a small subset without editing the repo.
MANIFEST_FILE="${INSTALL_TOOLS_MANIFEST:-$SCRIPT_DIR/manifests/tools.sh}"
PACKAGE_MANAGERS_FILE="$SCRIPT_DIR/lib/package-managers.sh"
for required_file in "$MANIFEST_FILE" "$PACKAGE_MANAGERS_FILE"; do
  [ -r "$required_file" ] \
    || { printf 'missing installer module: %s\n' "$required_file" >&2; exit 1; }
done
# Runtime paths are validated above; INSTALL_TOOLS_MANIFEST may intentionally
# point at a temporary test manifest, so ShellCheck cannot follow it statically.
# shellcheck disable=SC1090
. "$MANIFEST_FILE"
# shellcheck disable=SC1090
. "$PACKAGE_MANAGERS_FILE"

# --- output helpers ----------------------------------------------------------
if [ -t 1 ]; then
  GRN='\033[0;32m'; YLW='\033[0;33m'; RED='\033[0;31m'; DIM='\033[0;90m'; BOLD='\033[1m'; RST='\033[0m'
else
  GRN=''; YLW=''; RED=''; DIM=''; BOLD=''; RST=''
fi
say() { printf '%b\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  say "Usage: ./install/install-tools.sh [-y] [-n] [-h]"
  say "  -y   install the default selection of missing tools (glow is opt-in)"
  say "  -n   dry run (print the method per tool, install nothing)"
  say "  -h   this help"
}

# --- bob's nvim proxy dir ------------------------------------------------------
# bob does NOT put nvim on PATH by itself: it drops a proxy binary in its
# installation_location (this repo's linked config: "$HOME/Releases/nvim-bin",
# stored with a LITERAL $HOME), falling back to bob's default.
bob_nvim_dir() {
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/bob/config.json"
  dir=""
  if [ -f "$cfg" ]; then
    # dumb grep/sed on purpose — no jq dependency; -o keeps it correct even on
    # minified one-line JSON
    dir="$(grep -o '"installation_location"[^,}]*' "$cfg" 2>/dev/null \
           | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')" || dir=""
  fi
  [ -n "$dir" ] || dir="${XDG_DATA_HOME:-$HOME/.local/share}/bob/nvim-bin"
  case "$dir" in '$HOME'*) dir="$HOME${dir#\$HOME}" ;; esac
  printf '%s' "$dir"
}

# --- per-tool presence (zap is a sourced plugin, nvm a sourced function) -----
is_installed() {
  case "$1" in
    zap) [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] ;;
    nvm) [ -s "$HOME/.nvm/nvm.sh" ] ;;
    java) [ -x "${SDKMAN_DIR:-$HOME/.sdkman}/candidates/java/$JAVA_SDKMAN_VERSION/bin/java" ] ;;
    # nvm installs node inside ~/.nvm, invisible to this script's PATH —
    # glob-through-ls spots any installed version (POSIX-fine).
    node) have node || ls "$HOME/.nvm/versions/node"/*/bin/node >/dev/null 2>&1 ;;
    # Eget archives can contain executable support files. In particular,
    # Fastfetch's archive also contains a Bash completion named `fastfetch`,
    # which `command -v` alone would falsely accept as the program.
    fastfetch) have fastfetch && fastfetch --version 2>/dev/null | grep -q '^fastfetch ' ;;
    # A launcher alone is not enough: the standalone installer writes this
    # marker only after plugins, native modules, Mason packages, and headless
    # startup all verify.
    lvim) have lvim && [ -f "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/lvim-install.ok" ] ;;
    # bob's proxy dir is on no PATH on a fresh machine (only hosts/<name>.zsh
    # adds it) — check the proxy too. EXECUTE rather than test -x: a wrong-arch
    # binary (x86_64 nvim on an arm64 box) exists, is executable, and doesn't run.
    nvim) nvim --version >/dev/null 2>&1 || "$(bob_nvim_dir)/nvim" --version >/dev/null 2>&1 ;;
    *)   have "$1" ;;
  esac
}

# --- custom installers -------------------------------------------------------
install_zap() {
  # zsh is a manual prerequisite (installing it differs too much per system)
  # and the installer below pipes into `zsh -s`, so bail out if it's missing.
  if ! have zsh; then
    say "  ${YLW}zap needs zsh — zsh is a prerequisite, install it with your system package manager first${RST}"
    return 1
  fi
  # POSIX-safe: pipe the installer to zsh -s, passing flags after `--`.
  curl -fsSL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh \
    | zsh -s -- --branch release-v1 --keep
}
ensure_bob_dirs() {
  # bob hard-errors (yet exits 0!) when a directory from its config is
  # missing: "ERROR Custom directory /home/ubuntu/Releases/ doesn't exist!".
  # The linked config stores paths with a LITERAL $HOME in the value
  # (e.g. "downloads_location": "$HOME/Releases/"), so expand that ourselves
  # and pre-create every "*_location" path. Dumb grep/sed on purpose (no jq).
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/bob/config.json"
  # no config: bob's defaults live under ~/.local/share, which it creates itself
  [ -f "$cfg" ] || return 0
  # -o tokenizes per key, so this stays correct even on minified one-line JSON
  # (the plain-grep + greedy-sed form collapsed such a file to a single junk
  # value and silently created none of bob's dirs).
  grep -o '"[a-z_]*_location"[^,}]*' "$cfg" 2>/dev/null \
    | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' \
    | while IFS= read -r loc; do
        [ -n "$loc" ] || continue
        case "$loc" in '$HOME'*) loc="$HOME${loc#\$HOME}" ;; esac
        # a value ending in .version names a file — create its parent dir
        case "$loc" in
          *.version) mkdir -p "$(dirname "$loc")" ;;
          *)         mkdir -p "$loc" ;;
        esac
      done
}
install_neovim() {
  if ! have bob; then
    say "  ${YLW}bob not installed yet — rerun after bob, or use brew/eget${RST}"; return 1
  fi
  ensure_bob_dirs
  bob install "$NVIM_DEFAULT" && bob use "$NVIM_DEFAULT" || return 1
  # bob's proxy lands in its installation_location, which is on no PATH on a
  # fresh machine (only hosts/<name>.zsh adds it) — link it into ~/.local/bin
  # so this run's verify pass, future shells, and the lvim launcher find it.
  dir="$(bob_nvim_dir)"
  # execute, don't just stat: bob happily installs a wrong-arch tarball
  # (e.g. x86_64 nvim on arm64 — upstream has no arm64 build before 0.10.4)
  "$dir/nvim" --version >/dev/null 2>&1 \
    || { say "  ${YLW}bob ran but $dir/nvim doesn't execute (wrong arch? check \`bob list\`)${RST}"; return 1; }
  mkdir -p "$LOCAL_BIN"
  ln -sf "$dir/nvim" "$LOCAL_BIN/nvim"
}
install_sdkman() {
  sdkman_dir="${SDKMAN_DIR:-$HOME/.sdkman}"
  SDKMAN_DIR="$sdkman_dir"
  export SDKMAN_DIR
  if [ -s "$sdkman_dir/bin/sdkman-init.sh" ]; then
    say "  ${DIM}[ok]     SDKMAN already installed at $sdkman_dir${RST}"
    return 0
  fi

  say "  ${GRN}[sdkman]${RST} install version manager (CI mode; no profile edits)"
  tmp_sdkman=$(mktemp)
  if ! curl --connect-timeout 20 --max-time 180 -fsSL "$SDKMAN_INSTALL_URL" -o "$tmp_sdkman" \
    || ! bash "$tmp_sdkman"; then
    rm -f "$tmp_sdkman"
    return 1
  fi
  rm -f "$tmp_sdkman"
  [ -s "$sdkman_dir/bin/sdkman-init.sh" ]
}
install_java() {
  install_sdkman || return 1
  sdkman_dir="${SDKMAN_DIR:-$HOME/.sdkman}"
  say "  ${GRN}[sdkman]${RST} java $JAVA_SDKMAN_VERSION (install + default)"
  SDKMAN_DIR="$sdkman_dir" bash -c '
    . "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk install java "$1" || exit 1
    sdk default java "$1"
  ' _ "$JAVA_SDKMAN_VERSION" || return 1

  java_home="$sdkman_dir/candidates/java/current"
  [ -x "$java_home/bin/java" ] || return 1
  JAVA_HOME="$java_home"
  PATH="$JAVA_HOME/bin:$PATH"
  export JAVA_HOME PATH

  # These stable links follow SDKMAN's `current` symlink, so changing the
  # default with `sdk default java ...` also updates non-interactive callers.
  mkdir -p "$LOCAL_BIN"
  for java_command in java javac jar javadoc javap; do
    [ ! -x "$java_home/bin/$java_command" ] \
      || ln -sf "$java_home/bin/$java_command" "$LOCAL_BIN/$java_command"
  done
  "$java_home/bin/java" -version >/dev/null 2>&1
}
install_nvm() {
  # PROFILE=/dev/null: the stock installer appends source lines to the shell
  # profile, but our zshrc is a symlink into this repo and already sources nvm
  # itself — so tell it to write nowhere.  The upstream installer's stdout
  # includes a misleading "Profile not found" help block for this intentional
  # setup, so keep only stderr and verify the installed file ourselves.
  curl --connect-timeout 15 --max-time 120 -fsSL \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh \
    | PROFILE=/dev/null bash >/dev/null
  [ -s "$HOME/.nvm/nvm.sh" ] || return 1
  say "  ${DIM}nvm installed; shell startup remains managed by zsh/zshrc${RST}"
}
install_node() {
  if ! [ -s "$HOME/.nvm/nvm.sh" ]; then
    say "  ${YLW}nvm not installed yet — rerun after nvm${RST}"; return 1
  fi
  # nvm.sh is not POSIX sh, so run it through bash; `nvm install` ships npm
  # with node.
  bash -c 'export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"; nvm install --lts'
  # The child Bash cannot update this POSIX shell's PATH. Locate the version it
  # just installed so LunarVim and Mason can see node/npm later in this run.
  node_bin="$(find "$HOME/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin 2>/dev/null \
    | sort | tail -n 1)"
  [ -n "$node_bin" ] && PATH="$node_bin:$PATH" && export PATH
}
install_lvim() {
  # Decoupled: the real logic (nvim-via-bob prerequisite + LunarVim installer)
  # lives in the standalone script next to this one.
  "$SCRIPT_DIR/install-lvim.sh"
}

# --- eget bootstrap (the only thing we fetch to fetch others) ----------------
ensure_eget() {
  have eget && { EGET=eget; return 0; }
  [ -x "$EGET" ] && return 0
  if [ "$DRY" -eq 1 ]; then say "  ${DIM}(would bootstrap eget -> $EGET)${RST}"; return 0; fi
  say "  ${DIM}bootstrapping eget...${RST}"
  mkdir -p "$LOCAL_BIN"
  tmp="$(mktemp -d)"
  if ( cd "$tmp" && curl --connect-timeout 15 --max-time 120 -fsSL https://zyedidia.github.io/eget.sh | sh ) >/dev/null 2>&1 \
     && [ -f "$tmp/eget" ]; then
    mv "$tmp/eget" "$EGET"; chmod +x "$EGET"; rm -rf "$tmp"; return 0
  fi
  rm -rf "$tmp"
  say "  ${RED}failed to bootstrap eget${RST}"; return 1
}

# A GitHub/CDN connection can occasionally remain open after eget prints 100%,
# leaving a fresh-machine install blocked forever.  Bound each attempt where
# coreutils `timeout` exists (Linux) and retry once; macOS keeps eget's normal
# behavior unless GNU coreutils has supplied timeout.
run_eget() {
  attempt=1
  while [ "$attempt" -le 2 ]; do
    if have timeout; then
      timeout 120 "$EGET" "$@" && return 0
    else
      "$EGET" "$@" && return 0
    fi
    [ "$attempt" -eq 2 ] && return 1
    say "  ${YLW}(eget attempt timed out or failed; retrying once)${RST}"
    attempt=$((attempt + 1))
  done
}

# --- field lookup ------------------------------------------------------------
load_fields() {
  brewf=; dnfp=; copr=; aptp=; ghrepo=; custom=; egetfilters=; egetfile=
  while IFS='|' read -r k b d c a g f ef efile; do
    [ "$k" = "$1" ] || continue
    brewf=$b; dnfp=$d; copr=$c; aptp=$a; ghrepo=$g; custom=$f
    egetfilters=$ef; egetfile=$efile
    # Bob's release calls aarch64 "arm" and its names do not let eget reliably
    # distinguish that from x86_64. Resolve the exact archive ourselves.
    if [ "$egetfilters" = '@bob' ]; then
      case "$(uname -s)/$(uname -m)" in
        Linux/aarch64|Linux/arm64)  egetfilters='--asset bob-linux-arm.zip' ;;
        Linux/x86_64|Linux/amd64)   egetfilters='--asset bob-linux-x86_64.zip' ;;
        Darwin/arm64|Darwin/aarch64) egetfilters='--asset bob-macos-arm.zip' ;;
        Darwin/x86_64|Darwin/amd64) egetfilters='--asset bob-macos-x86_64.zip' ;;
        *) egetfilters='' ;;
      esac
    fi
    return 0
  done <<EOF
$TOOLS
EOF
}

# short label of the method that WOULD be used (for the menu)
method_of() {
  is_installed "$1" && { printf 'present'; return; }
  load_fields "$1"
  if   [ -n "$custom" ];                   then printf 'custom'
  elif have brew && [ -n "$brewf" ];       then printf 'brew'
  elif have dnf  && [ -n "$dnfp" ];        then printf 'dnf'
  elif have apt-get && [ -n "$aptp" ];     then printf 'apt'
  elif [ -n "$ghrepo" ];                   then printf 'eget'
  else printf 'none'; fi
}

# --- ensure one tool is installed --------------------------------------------
ensure_tool() {
  key="$1"
  if is_installed "$key"; then say "  ${DIM}[ok]     $key already installed${RST}"; return 0; fi
  load_fields "$key"
  if [ -n "$custom" ]; then
    say "  ${GRN}[custom]${RST} $key ($custom)"
    [ "$DRY" -eq 1 ] || "$custom" || say "  ${YLW}($key custom installer reported a problem)${RST}"
  elif have brew && [ -n "$brewf" ]; then
    install_brew_package "$key" "$brewf"
  elif have dnf && [ -n "$dnfp" ]; then
    install_dnf_package "$key" "$dnfp" "$copr"
  elif have apt-get && [ -n "$aptp" ]; then
    install_apt_package "$key" "$aptp"
  elif [ -n "$ghrepo" ]; then
    ensure_eget || { say "  ${YLW}[skip]   $key (no eget)${RST}"; return 0; }
    say "  ${GRN}[eget]${RST}   $key ($ghrepo -> $LOCAL_BIN)"
    # shellcheck disable=SC2086  # both filter variables are flag lists on purpose
    if [ "$DRY" -eq 1 ]; then
      :
    elif [ -n "$egetfile" ]; then
      run_eget $EGET_FILTER $egetfilters --file "$egetfile" "$ghrepo" --to "$LOCAL_BIN" \
        || say "  ${YLW}($key eget failed — verify below will flag it)${RST}"
    else
      run_eget $EGET_FILTER $egetfilters "$ghrepo" --to "$LOCAL_BIN" \
        || say "  ${YLW}($key eget failed — verify below will flag it)${RST}"
    fi
  else
    say "  ${YLW}[skip]${RST}   $key — no install method for this machine"
  fi
}

# --- selection state ---------------------------------------------------------
is_default_off() { case "$DEFAULT_OFF" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
KEYS=""; ENABLED=" "
while IFS='|' read -r k _b _d _c _a _g _f _ef _efile; do
  [ -z "$k" ] && continue
  KEYS="$KEYS $k"
  # default-on only what's missing and not opted out
  is_installed "$k" || is_default_off "$k" || ENABLED="$ENABLED$k "
done <<EOF
$TOOLS
EOF

is_enabled() { case "$ENABLED" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
toggle() {
  if is_enabled "$1"; then ENABLED=$(printf '%s' "$ENABLED" | sed "s/ $1 / /")
  else ENABLED="$ENABLED$1 "; fi
}

# --- interactive menu --------------------------------------------------------
render() {
  # what `clear -x` emits: clear screen + home cursor, but keep scrollback
  [ -t 1 ] && printf '\033[2J\033[H'
  say "${BOLD}== install tools ==${RST}   ${DIM}os: $OS   (✓ = already installed)${RST}"
  say "${DIM}number = toggle    a = all    n = none    c = continue    q = quit${RST}"
  say ""
  i=0
  for k in $KEYS; do
    i=$((i + 1))
    if is_installed "$k"; then mark="${DIM}[✓]${RST}"
    elif is_enabled "$k";  then mark="${GRN}[x]${RST}"
    else                        mark="${DIM}[ ]${RST}"; fi
    printf "  %2d) %b %-10s ${DIM}%s${RST}\n" "$i" "$mark" "$k" "$(method_of "$k")"
  done
  say ""
}
menu() {
  while :; do
    render
    printf 'choice> '
    if ! read -r choice; then echo; break; fi
    case "$choice" in
      ''|c|C) break ;;
      q|Q)    say "aborted — nothing installed."; exit 0 ;;
      a|A)    ENABLED=" "; for k in $KEYS; do ENABLED="$ENABLED$k "; done ;;
      n|N)    ENABLED=" " ;;
      *[!0-9]*) ;;
      *)
        j=0; sel=""
        for k in $KEYS; do j=$((j + 1)); [ "$j" = "$choice" ] && { sel="$k"; break; }; done
        [ -n "$sel" ] && toggle "$sel" ;;
    esac
  done
}
confirm() {
  say ""
  say "${BOLD}== will install ==${RST}"
  any=0
  for k in $KEYS; do
    is_enabled "$k" && ! is_installed "$k" && { say "  ${GRN}+${RST} $k ${DIM}($(method_of "$k"))${RST}"; any=1; }
  done
  [ "$any" -eq 0 ] && { say "${YLW}nothing to install — all selected tools are present.${RST}"; exit 0; }
  say ""
  printf 'proceed? [y/N] '
  read -r ans || ans=""
  case "$ans" in y|Y|yes|YES) return 0 ;; *) say "aborted — nothing installed."; exit 0 ;; esac
}

# --- options -----------------------------------------------------------------
while getopts "ynh" opt; do
  case "$opt" in
    y) ASSUME_YES=1 ;;
    n) DRY=1 ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

[ "$DRY" -eq 1 ] && say "${YLW}(dry run — nothing will be installed)${RST}"

if [ "$ASSUME_YES" -eq 1 ]; then
  :
elif [ -t 0 ] || [ "${INSTALL_INTERACTIVE:-0}" = 1 ]; then
  menu
  confirm
else
  say "${YLW}no TTY: installing the default selection of missing tools (pass -y to silence).${RST}"
fi

# Remember what this run actually attempts (selected AND missing at start),
# so the verification pass below only judges those.
ATTEMPTED=""
for k in $KEYS; do
  is_enabled "$k" || continue
  is_installed "$k" || ATTEMPTED="$ATTEMPTED $k"
  ensure_tool "$k"
done

# --- outcome verification ------------------------------------------------------
# Exit codes lie: bob prints ERROR yet exits 0, and eget's .deb trap fails
# silently — so trust only a fresh presence check per attempted tool.
if [ "$DRY" -eq 0 ] && [ -n "$ATTEMPTED" ]; then
  say ""
  say "${BOLD}== verify ==${RST}"
  FAILED=0
  for k in $ATTEMPTED; do
    if is_installed "$k"; then
      say "  ${DIM}[ok]     $k${RST}"
    else
      say "  ${RED}[FAILED]${RST} $k — still not installed; rerun this script to retry"
      FAILED=$((FAILED + 1))
    fi
  done
  if [ "$FAILED" -gt 0 ]; then
    say ""
    say "${YLW}$FAILED tool(s) failed to install — see [FAILED] above.${RST}"
    exit 1
  fi
  say "${GRN}all attempted tools verified.${RST}"
fi

say ""
say "${GRN}done.${RST} (binaries in $LOCAL_BIN are already on your PATH via ~/.zshenv)"
