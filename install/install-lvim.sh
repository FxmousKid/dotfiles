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
#    3. bob install/use Neovim 0.9  -> then put bob's proxy dir on PATH
#    4. run the LunarVim installer  -> its own prompts handle the rest
#
#  -n dry-runs (prints the plan, changes nothing), -h shows help.
# =============================================================================

set -eu

# LunarVim 1.4 is pinned to Neovim 0.9 — keep LV_BRANCH and the bob version
# below in lockstep when bumping.
LV_BRANCH='release-1.4/neovim-0.9'
NVIM_VERSION='0.9.5'

LOCAL_BIN="$HOME/.local/bin"
# Fresh machines don't have ~/.local/bin on PATH until the next login; without
# this the script can't see tools installed moments ago (a fresh Ubuntu VM
# re-downloaded bob that install-tools.sh had just eget-installed).
PATH="$LOCAL_BIN:$PATH"; export PATH
EGET="$LOCAL_BIN/eget"
# eget copies .deb/.rpm/.AppImage into bin as-is instead of installing — silent
# trap. The anti-match is case-sensitive, so cover both AppImage spellings.
EGET_FILTER='--asset ^.deb --asset ^.rpm --asset ^.AppImage --asset ^.appimage'
DRY=0

# --- output helpers ----------------------------------------------------------
if [ -t 1 ]; then
  GRN='\033[0;32m'; YLW='\033[0;33m'; RED='\033[0;31m'; DIM='\033[0;90m'; BOLD='\033[1m'; RST='\033[0m'
else
  GRN=''; YLW=''; RED=''; DIM=''; BOLD=''; RST=''
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

# --- step 1-3: make sure nvim exists (at the pinned 0.9.x) ---------------------
# Presence isn't enough: bob keeps ONE global active version and LunarVim 1.4
# only supports Neovim 0.9 — accept an existing nvim only if it's the right
# series, otherwise pin via bob (and say so, since that flips the global proxy).
NVIM_SERIES="v${NVIM_VERSION%.*}."   # -> "v0.9."
if have nvim && nvim --version 2>/dev/null | head -n 1 | grep -qF "NVIM $NVIM_SERIES"; then
  say "  ${DIM}[ok]${RST}     nvim ${NVIM_SERIES}x already on PATH ($(command -v nvim))"
else
  if have nvim; then
    say "  ${YLW}nvim on PATH is \"$(nvim --version 2>/dev/null | head -n 1)\" but LunarVim $LV_BRANCH needs ${NVIM_SERIES}x —${RST}"
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
        # shellcheck disable=SC2086  # EGET_FILTER is a deliberate flag-list
        "$EGET" $EGET_FILTER MordechaiHadad/bob --to "$LOCAL_BIN"
      fi
    fi
    # freshly installed bob may not be on this process's PATH yet
    if have bob; then BOB=bob; else BOB="$LOCAL_BIN/bob"; fi
  fi

  # -- neovim via bob (0.9.x to match the LV_BRANCH pin) --
  ensure_bob_dirs
  say "  ${GRN}[bob]${RST}    neovim $NVIM_VERSION (install + use)"
  if [ "$DRY" -eq 0 ]; then
    # guarded: bob's exit codes lie anyway — the presence check below decides
    "$BOB" install "$NVIM_VERSION" && "$BOB" use "$NVIM_VERSION" \
      || say "  ${YLW}(bob reported a problem — checked below)${RST}"
  fi

  # -- put bob's proxy dir on PATH for this process, then verify --
  NVIM_DIR="$(bob_nvim_dir)"
  say "  ${DIM}[path]${RST}   prepending $NVIM_DIR"
  PATH="$NVIM_DIR:$PATH"
  # persist visibility beyond this process: bob's dir is on no PATH on a fresh
  # machine (only hosts/<name>.zsh adds it) — link the proxy into ~/.local/bin
  # so future shells and the lvim launcher find nvim.
  if [ "$DRY" -eq 0 ] && [ -x "$NVIM_DIR/nvim" ]; then
    mkdir -p "$LOCAL_BIN"; ln -sf "$NVIM_DIR/nvim" "$LOCAL_BIN/nvim"
    say "  ${DIM}[link]${RST}   $LOCAL_BIN/nvim -> $NVIM_DIR/nvim"
  fi
  if [ "$DRY" -eq 0 ] && ! have nvim; then
    say "  ${RED}nvim still not found after bob install.${RST}"
    say "  ${RED}bob's custom dirs were pre-created this run, so a missing dir is${RST}"
    say "  ${RED}not the cause — check \`bob list\` and bob's own output above, and${RST}"
    say "  ${RED}that its installation_location ($NVIM_DIR) contains the nvim${RST}"
    say "  ${RED}proxy; then rerun this script.${RST}"
    exit 1
  fi
fi

# --- step 4: LunarVim installer ------------------------------------------------
say "  ${GRN}[lvim]${RST}   LunarVim installer (LV_BRANCH=$LV_BRANCH)"
if [ "$DRY" -eq 1 ]; then
  say "  ${DIM}(would run the LunarVim install.sh from that branch)${RST}"
  exit 0
fi
# Download first, run after: a failed curl inside $() is invisible to set -e —
# `bash -c ""` would "succeed" with nothing installed. Capturing into a variable
# still keeps stdin on the terminal, so the installer's prompts work.
lv_installer="$(curl -fsSL "https://raw.githubusercontent.com/LunarVim/LunarVim/$LV_BRANCH/utils/installer/install.sh")" \
  || { say "  ${RED}failed to download the LunarVim installer (branch $LV_BRANCH) — check network, then rerun${RST}"; exit 1; }
[ -n "$lv_installer" ] \
  || { say "  ${RED}LunarVim installer download was empty${RST}"; exit 1; }
LV_BRANCH="$LV_BRANCH" bash -c "$lv_installer" \
  || say "  ${YLW}(LunarVim installer exited non-zero — checked below)${RST}"

# outcome check, same posture as the nvim step above: exit codes lie
if ! have lvim && ! [ -x "$LOCAL_BIN/lvim" ]; then
  say "  ${RED}lvim still not installed — see the installer's output above; rerun to retry${RST}"
  exit 1
fi
say "  ${GRN}[ok]${RST}     lvim installed."
