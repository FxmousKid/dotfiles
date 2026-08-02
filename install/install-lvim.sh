#!/bin/sh
# =============================================================================
#  install/install-lvim.sh — install LunarVim, providing Neovim first.
#
#  LunarVim's installer requires Neovim to already exist; the old inline
#  function in install-tools.sh just curl'd the installer, so on a machine
#  without nvim it fell over. This script makes nvim-via-bob a first-class
#  step:
#
#    1. nvim already on PATH        -> skip straight to the LunarVim installer
#    2. otherwise ensure bob        -> brew, or eget (GitHub release, no root)
#    3. bob install/use Neovim 0.10.4 -> then put bob's proxy dir on PATH
#    4. run the LunarVim installer  -> its own prompts handle the rest
#
#  -n dry-runs (prints the plan, changes nothing), -h shows help.
# =============================================================================

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

# LunarVim 1.4 officially targets Neovim 0.9, but 0.9 has no upstream
# linux-arm64 build (bob fetches a non-runnable x86_64 one on arm boxes).
# 0.10.4 is the first arm64 release and passes the installer's ">= 0.9" check —
# expect deprecation warnings, LunarVim upstream is discontinued. Keep this in
# lockstep with install-tools.sh's NVIM_DEFAULT.
LV_BRANCH='release-1.4/neovim-0.9'
NVIM_VERSION='0.10.4'

LOCAL_BIN="$HOME/.local/bin"
# Fresh machines don't have ~/.local/bin on PATH until the next login; without
# this the script can't see tools installed moments ago (a fresh Ubuntu VM
# re-downloaded bob that install-tools.sh had just eget-installed).
PATH="$LOCAL_BIN:$PATH"; export PATH
# nvm does not expose Node in non-interactive shells. Mason uses npm for
# pyright and bash-language-server, so activate an earlier nvm install here.
NVM_NODE_BIN="$(find "$HOME/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin 2>/dev/null \
  | sort | tail -n 1)"
[ -n "$NVM_NODE_BIN" ] && PATH="$NVM_NODE_BIN:$PATH" && export PATH
EGET="$LOCAL_BIN/eget"
# eget copies .deb/.rpm/.AppImage into bin as-is instead of installing — silent
# trap. The anti-match is case-sensitive, so cover both AppImage spellings.
EGET_FILTER='--asset ^.deb --asset ^.rpm --asset ^.AppImage --asset ^.appimage'
DRY=0

# --- output helpers ----------------------------------------------------------
if [ -t 1 ]; then
  GRN='\033[0;32m'; YLW='\033[0;33m'; RED='\033[0;31m'; DIM='\033[0;90m'; RST='\033[0m'
else
  GRN=''; YLW=''; RED=''; DIM=''; RST=''
fi
say() { printf '%b\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  say "Usage: ./install/install-lvim.sh [-n] [-h]"
  say "  -n   dry run (print the plan, install nothing)"
  say "  -h   this help"
}

while getopts "nh" opt; do
  case "$opt" in
    n) DRY=1 ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

[ "$DRY" -eq 1 ] && say "${YLW}(dry run — nothing will be installed)${RST}"

# --- eget bootstrap (same as install-tools.sh) --------------------------------
ensure_eget() {
  have eget && { EGET=eget; return 0; }
  [ -x "$EGET" ] && return 0
  if [ "$DRY" -eq 1 ]; then say "  ${DIM}(would bootstrap eget -> $EGET)${RST}"; return 0; fi
  say "  ${DIM}bootstrapping eget...${RST}"
  mkdir -p "$LOCAL_BIN"
  tmp="$(mktemp -d)"
  if ( cd "$tmp" && curl -fsSL https://zyedidia.github.io/eget.sh | sh ) >/dev/null 2>&1 \
     && [ -f "$tmp/eget" ]; then
    mv "$tmp/eget" "$EGET"; chmod +x "$EGET"; rm -rf "$tmp"; return 0
  fi
  rm -rf "$tmp"
  say "  ${RED}failed to bootstrap eget${RST}"; return 1
}

# Bob's release names aarch64 archives "arm", which eget cannot reliably
# distinguish from the x86_64 archive. Return an exact asset filter so the
# standalone LunarVim installer stays non-interactive too.
bob_asset_filter() {
  case "$(uname -s)/$(uname -m)" in
    Linux/aarch64|Linux/arm64)   printf '%s' '--asset bob-linux-arm.zip' ;;
    Linux/x86_64|Linux/amd64)    printf '%s' '--asset bob-linux-x86_64.zip' ;;
    Darwin/arm64|Darwin/aarch64) printf '%s' '--asset bob-macos-arm.zip' ;;
    Darwin/x86_64|Darwin/amd64)  printf '%s' '--asset bob-macos-x86_64.zip' ;;
    *)                           printf '%s' '' ;;
  esac
}

# --- bob's nvim proxy dir ------------------------------------------------------
# bob does NOT put nvim on PATH by itself: it drops a proxy binary in its
# installation_location. Read that from bob's config if present (this repo's
# linked config sets "installation_location": "$HOME/Releases/nvim-bin"; the
# value may contain a literal $HOME to expand), falling back to bob's default.
bob_nvim_dir() {
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/bob/config.json"
  dir=""
  if [ -f "$cfg" ]; then
    # dumb grep/sed on purpose — no jq dependency
    dir="$(grep -o '"installation_location"[^,}]*' "$cfg" 2>/dev/null \
           | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')" || dir=""
  fi
  [ -n "$dir" ] || dir="${XDG_DATA_HOME:-$HOME/.local/share}/bob/nvim-bin"
  # expand a literal $HOME (bob stores it unexpanded)
  case "$dir" in
    '$HOME'*) dir="$HOME${dir#\$HOME}" ;;
  esac
  printf '%s' "$dir"
}

# --- bob's custom dirs ---------------------------------------------------------
# bob hard-errors on missing custom dirs ("Custom directory ... doesn't exist!")
# yet still exits 0 — proven on a real Ubuntu run, where the script sailed past
# a failed `bob install` and only the final nvim verification caught it. So we
# pre-create every *_location from bob's config rather than trust it.
ensure_bob_dirs() {
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/bob/config.json"
  [ -f "$cfg" ] || return 0
  # dumb grep/sed on purpose — no jq dependency (same as bob_nvim_dir)
  locs="$(grep -o '"[a-z_]*_location"[^,}]*' "$cfg" 2>/dev/null \
          | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')" || locs=""
  [ -n "$locs" ] || return 0
  made=0
  seen="
"
  oldIFS=$IFS; IFS='
'
  for loc in $locs; do
    IFS=$oldIFS
    # expand a literal $HOME (bob stores it unexpanded)
    case "$loc" in
      '$HOME'*) loc="$HOME${loc#\$HOME}" ;;
    esac
    loc="${loc%/}"
    # filename-like values (version_sync_file_location -> .../nvim.version):
    # create the parent dir, not the file itself
    case "${loc##*/}" in
      *.*) dir="${loc%/*}" ;;
      *)   dir="$loc" ;;
    esac
    [ -n "$dir" ] || continue
    # several *_location values can share a dir — handle each once
    case "$seen" in *"
$dir
"*) continue ;; esac
    seen="$seen$dir
"
    if [ -d "$dir" ]; then
      continue
    elif [ "$DRY" -eq 1 ]; then
      say "  ${DIM}(would create bob dir $dir)${RST}"
      made=1
    else
      mkdir -p "$dir"
      say "  ${DIM}[dirs]   created bob dir $dir${RST}"
      made=1
    fi
  done
  IFS=$oldIFS
  [ "$made" -eq 0 ] && say "  ${DIM}[dirs]   bob's custom dirs already exist${RST}"
  return 0
}

# --- step 1-3: make sure nvim exists at the pinned version --------------------
# Presence isn't enough: bob keeps ONE global active version and LunarVim 1.4
# requires Neovim >=0.9. Accept an existing nvim only if it is the selected
# 0.10 series, otherwise pin via bob (which flips bob's one global proxy).
NVIM_SERIES="v${NVIM_VERSION%.*}."   # -> "v0.10."
if have nvim && nvim --version 2>/dev/null | head -n 1 | grep -qF "NVIM $NVIM_SERIES"; then
  say "  ${DIM}[ok]${RST}     nvim ${NVIM_SERIES}x already on PATH ($(command -v nvim))"
else
  if have nvim; then
    say "  ${YLW}nvim on PATH is \"$(nvim --version 2>/dev/null | head -n 1)\" but this setup pins ${NVIM_SERIES}x —${RST}"
    say "  ${YLW}pinning via bob. bob's proxy has ONE global active version; switch back later with: bob use stable${RST}"
  fi
  # -- bob --
  if have bob; then
    BOB=bob
    say "  ${DIM}[ok]${RST}     bob already installed"
  else
    if have brew; then
      say "  ${GRN}[brew]${RST}   bob"
      [ "$DRY" -eq 1 ] || brew install bob
    else
      say "  ${GRN}[eget]${RST}   bob (MordechaiHadad/bob -> $LOCAL_BIN)"
      if [ "$DRY" -eq 0 ]; then
        ensure_eget || { say "  ${RED}cannot install bob without eget${RST}"; exit 1; }
        BOB_ASSET_FILTER="$(bob_asset_filter)"
        # shellcheck disable=SC2086  # both variables are deliberate flag-lists
        "$EGET" $EGET_FILTER $BOB_ASSET_FILTER MordechaiHadad/bob --to "$LOCAL_BIN"
      fi
    fi
    # freshly installed bob may not be on this process's PATH yet
    if have bob; then BOB=bob; else BOB="$LOCAL_BIN/bob"; fi
  fi

  # -- neovim via bob --
  ensure_bob_dirs
  say "  ${GRN}[bob]${RST}    neovim $NVIM_VERSION (install + use)"
  if [ "$DRY" -eq 0 ]; then
    # guarded: bob's exit codes lie anyway — the presence check below decides
    if "$BOB" install "$NVIM_VERSION" && "$BOB" use "$NVIM_VERSION"; then
      :
    else
      say "  ${YLW}(bob reported a problem — checked below)${RST}"
    fi
  fi

  # -- put bob's proxy dir on PATH for this process, then verify --
  NVIM_DIR="$(bob_nvim_dir)"
  say "  ${DIM}[path]${RST}   prepending $NVIM_DIR"
  PATH="$NVIM_DIR:$PATH"
  # persist visibility beyond this process: bob's dir is on no PATH on a fresh
  # machine (only hosts/<name>.zsh adds it) — link the proxy into ~/.local/bin
  # so future shells and the lvim launcher find nvim. Gate on the binary
  # actually EXECUTING (-x passes for a wrong-arch binary that can't run).
  if [ "$DRY" -eq 0 ] && "$NVIM_DIR/nvim" --version >/dev/null 2>&1; then
    mkdir -p "$LOCAL_BIN"; ln -sf "$NVIM_DIR/nvim" "$LOCAL_BIN/nvim"
    say "  ${DIM}[link]${RST}   $LOCAL_BIN/nvim -> $NVIM_DIR/nvim"
  fi
  # verify by RUNNING it and checking the series — presence isn't runnability:
  # upstream Neovim ships no linux-arm64 build before 0.10.4, so on an arm64
  # box bob "successfully" installs the x86_64 0.9.5 tarball, which the kernel
  # refuses to exec ("ELF: not found" when sh falls back to parsing it).
  if [ "$DRY" -eq 0 ] && ! nvim --version 2>/dev/null | head -n 1 | grep -qF "NVIM $NVIM_SERIES"; then
    say "  ${RED}no runnable Neovim ${NVIM_SERIES}x after bob install.${RST}"
    say "  ${RED}Check \`bob list\`, the active version, and the architecture of $NVIM_DIR/nvim.${RST}"
    exit 1
  fi
fi

# --- step 4: LunarVim installer ------------------------------------------------
say "  ${GRN}[lvim]${RST}   LunarVim installer (LV_BRANCH=$LV_BRANCH)"
if [ "$DRY" -eq 1 ]; then
  say "  ${DIM}(would run the LunarVim install.sh from that branch)${RST}"
  exit 0
fi
if ! have make || ! have cargo; then
  say "  ${RED}make and cargo are required by LunarVim and the configured native plugins.${RST}"
  say "  ${RED}Install them with your package manager, or run install-tools.sh first.${RST}"
  exit 1
fi
# Download first, run after: a failed curl inside $() is invisible to set -e —
# `bash -c ""` would "succeed" with nothing installed. Capturing into a variable
# still keeps stdin on the terminal, so the installer's prompts work.
lv_installer="$(curl -fsSL "https://raw.githubusercontent.com/LunarVim/LunarVim/$LV_BRANCH/utils/installer/install.sh")" \
  || { say "  ${RED}failed to download the LunarVim installer (branch $LV_BRANCH) — check network, then rerun${RST}"; exit 1; }
[ -n "$lv_installer" ] \
  || { say "  ${RED}LunarVim installer download was empty${RST}"; exit 1; }
# Dependencies are owned by install-tools.sh. --yes removes prompts and
# --no-install-dependencies avoids pip's PEP 668 warnings and cargo surprises.
LV_BRANCH="$LV_BRANCH" bash -c "$lv_installer" -- --yes --no-install-dependencies \
  || say "  ${YLW}(LunarVim installer exited non-zero — checked below)${RST}"

# outcome check, same posture as the nvim step above: exit codes lie
if ! have lvim && ! [ -x "$LOCAL_BIN/lvim" ]; then
  say "  ${RED}lvim still not installed — see the installer's output above; rerun to retry${RST}"
  exit 1
fi
LVIM_BIN="$(command -v lvim 2>/dev/null || printf '%s' "$LOCAL_BIN/lvim")"
say "  ${GRN}[plugins]${RST} configured plugin graph and native modules"
if ! "$LVIM_BIN" --headless \
  -c "lua local ok, err = pcall(dofile, '$SCRIPT_DIR/lvim-plugin-smoke.lua'); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  -c 'quitall'; then
  say "  ${RED}one or more configured plugins failed validation.${RST}"
  exit 1
fi
say "  ${GRN}[mason]${RST}  configured language servers"
if ! "$LVIM_BIN" --headless \
  -c "lua local ok, err = pcall(dofile, '$SCRIPT_DIR/lvim-mason.lua'); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  -c 'quitall'; then
  say "  ${RED}one or more configured language servers failed to install.${RST}"
  exit 1
fi
if ! "$LVIM_BIN" --headless -c 'quitall' >/dev/null 2>&1; then
  say "  ${RED}lvim launcher exists but headless startup failed with the linked config.${RST}"
  say "  ${RED}Run: $LVIM_BIN --headless -c quitall${RST}"
  exit 1
fi
say "  ${GRN}[ok]${RST}     lvim, plugins, and configured language servers installed; headless startup passed."
LVIM_MARKER="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/lvim-install.ok"
mkdir -p "$(dirname "$LVIM_MARKER")"
: > "$LVIM_MARKER"
