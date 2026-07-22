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
EGET="$LOCAL_BIN/eget"
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

# --- step 1-3: make sure nvim exists ------------------------------------------
if have nvim; then
  say "  ${DIM}[ok]${RST}     nvim already on PATH ($(command -v nvim))"
else
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
        "$EGET" MordechaiHadad/bob --to "$LOCAL_BIN"
      fi
    fi
    # freshly installed bob may not be on this process's PATH yet
    if have bob; then BOB=bob; else BOB="$LOCAL_BIN/bob"; fi
  fi

  # -- neovim via bob (0.9.x to match the LV_BRANCH pin) --
  say "  ${GRN}[bob]${RST}    neovim $NVIM_VERSION (install + use)"
  [ "$DRY" -eq 1 ] || { "$BOB" install "$NVIM_VERSION" && "$BOB" use "$NVIM_VERSION"; }

  # -- put bob's proxy dir on PATH for this process, then verify --
  NVIM_DIR="$(bob_nvim_dir)"
  say "  ${DIM}[path]${RST}   prepending $NVIM_DIR"
  PATH="$NVIM_DIR:$PATH"
  if [ "$DRY" -eq 0 ] && ! have nvim; then
    say "  ${RED}nvim still not found after bob install.${RST}"
    say "  ${RED}Check \`bob list\`, and that bob's installation_location${RST}"
    say "  ${RED}($NVIM_DIR) contains the nvim proxy; then rerun this script.${RST}"
    exit 1
  fi
fi

# --- step 4: LunarVim installer ------------------------------------------------
say "  ${GRN}[lvim]${RST}   LunarVim installer (LV_BRANCH=$LV_BRANCH)"
if [ "$DRY" -eq 1 ]; then
  say "  ${DIM}(would run the LunarVim install.sh from that branch)${RST}"
  exit 0
fi
# `bash -c "$(curl ...)"` keeps stdin on the terminal so its prompts work.
LV_BRANCH="$LV_BRANCH" \
  bash -c "$(curl -fsSL "https://raw.githubusercontent.com/LunarVim/LunarVim/$LV_BRANCH/utils/installer/install.sh")"
