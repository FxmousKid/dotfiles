#!/bin/sh
# =============================================================================
#  install.sh — link these dotfiles into place.
#
#  POSIX sh, safe to re-run. Anything real already in the way is moved to
#  <target>.bak.<time> first; links that are already correct are left alone.
#  Shows a menu (pick, confirm), then links only what you chose.
#
#  Usage:
#    ./install/install.sh        pick from a menu
#    ./install/install.sh -y     no menu, link this OS's defaults
#    ./install/install.sh -n     dry run: show what would happen, change nothing
#    ./install/install.sh -h     help
#
#  This only makes symlinks. To install the programs themselves, see
#  install/install-tools.sh (offered at the end here).
# =============================================================================

set -eu

# repo root is one level up from this script (install/)
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
OS="$(uname)"
TS="$(date +%Y%m%d-%H%M%S)"
DRY=0
ASSUME_YES=0

case "$OS" in
  Darwin) OSKEY=darwin ;;
  Linux)  OSKEY=linux ;;
  *)      OSKEY=other ;;
esac

# Component registry — one per line:  key|default(on/off)|platform(all/darwin/linux)|label
# Edit this table to add/remove components; the menu and linker both read it.
REGISTRY="
zsh|on|all|shell config (.zshenv .zshrc .zprofile p10k)
alacritty|on|all|terminal emulator
zellij|on|all|terminal multiplexer
lvim|on|all|LunarVim
nvim|on|all|Neovim (standalone)
bob|on|all|nvim version manager
atuin|on|all|shell history
fastfetch|on|all|system fetch
yazi|on|all|file manager
lazygit|on|all|git TUI
tmux|on|all|tmux
bash|off|all|bash fallback configs
karabiner|on|darwin|keyboard rules (Karabiner-Elements)
xmodmap|on|linux|X11 key remap
hyprland|on|linux|Wayland compositor
"

# --- output helpers ----------------------------------------------------------
if [ -t 1 ]; then
  GRN='\033[0;32m'; YLW='\033[0;33m'; DIM='\033[0;90m'; BOLD='\033[1m'; RST='\033[0m'
else
  GRN=''; YLW=''; DIM=''; BOLD=''; RST=''
fi
say() { printf '%b\n' "$*"; }

usage() {
  say "Usage: ./install/install.sh [-y] [-n] [-h]"
  say "  -y   non-interactive: link this OS's default components"
  say "  -n   dry run (print actions, make no changes)"
  say "  -h   this help"
}

platform_match() { [ "$1" = all ] || [ "$1" = "$OSKEY" ]; }

# Applicable keys for this OS (in registry order), and the initial selection.
KEYS=""
ENABLED=" "
while IFS='|' read -r key def plat label; do
  [ -z "$key" ] && continue
  platform_match "$plat" || continue
  KEYS="$KEYS $key"
  [ "$def" = on ] && ENABLED="$ENABLED$key "
done <<EOF
$REGISTRY
EOF

label_of() {
  while IFS='|' read -r key _def _plat label; do
    [ "$key" = "$1" ] && { printf '%s' "$label"; return 0; }
  done <<EOF
$REGISTRY
EOF
}

is_enabled() { case "$ENABLED" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
toggle() {
  if is_enabled "$1"; then ENABLED=$(printf '%s' "$ENABLED" | sed "s/ $1 / /")
  else ENABLED="$ENABLED$1 "; fi
}

# --- link SRC DEST -----------------------------------------------------------
# Symlink DEST -> SRC, backing up anything real that's already there.
link() {
  src="$1"; dest="$2"
  if [ ! -e "$src" ]; then
    say "  ${YLW}[miss]${RST}   $src ${DIM}(no source; skipped)${RST}"; return 0
  fi
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    say "  ${DIM}[ok]     $dest${RST}"; return 0
  fi
  if [ "$DRY" -eq 1 ]; then
    if   [ -L "$dest" ]; then say "  ${GRN}[relink]${RST} $dest ${DIM}(dry)${RST}"
    elif [ -e "$dest" ]; then say "  ${YLW}[backup+link]${RST} $dest ${DIM}(dry)${RST}"
    else                      say "  ${GRN}[link]${RST}   $dest ${DIM}(dry)${RST}"; fi
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"; say "  ${GRN}[relink]${RST} $dest -> $src"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.bak.$TS"; ln -sfn "$src" "$dest"
    say "  ${YLW}[backup]${RST} $dest -> $dest.bak.$TS"
    say "  ${GRN}[link]${RST}   $dest -> $src"
  else
    ln -sfn "$src" "$dest"; say "  ${GRN}[link]${RST}   $dest -> $src"
  fi
}

# --- per-component link sets -------------------------------------------------
do_links() {
  case "$1" in
    zsh)
      link "$DOTFILES/zsh/zshenv"   "$HOME/.zshenv"
      # also under $ZDOTDIR: nested zsh (a shell you type, a zellij pane) reads
      # $ZDOTDIR/.zshenv, not ~/.zshenv — without this it skips all of zshenv.
      link "$DOTFILES/zsh/zshenv"   "$CONFIG/zsh/.zshenv"
      link "$DOTFILES/zsh/zshrc"    "$CONFIG/zsh/.zshrc"
      link "$DOTFILES/zsh/zprofile" "$CONFIG/zsh/.zprofile"
      link "$DOTFILES/zsh/p10k.zsh" "$CONFIG/zsh/.p10k.zsh"
      link "$DOTFILES/zsh/hosts"    "$CONFIG/zsh/hosts" ;;
    alacritty) link "$DOTFILES/alacritty" "$CONFIG/alacritty" ;;
    zellij)    link "$DOTFILES/zellij"    "$CONFIG/zellij" ;;
    lvim)      link "$DOTFILES/lvim"      "$CONFIG/lvim" ;;
    nvim)      link "$DOTFILES/nvim"      "$CONFIG/nvim" ;;
    bob)       link "$DOTFILES/bob"       "$CONFIG/bob" ;;
    atuin)     link "$DOTFILES/atuin"     "$CONFIG/atuin" ;;
    fastfetch) link "$DOTFILES/fastfetch" "$CONFIG/fastfetch" ;;
    yazi)      link "$DOTFILES/yazi"      "$CONFIG/yazi" ;;
    lazygit)   link "$DOTFILES/lazygit"   "$CONFIG/lazygit" ;;
    tmux)      link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf" ;;
    bash)
      link "$DOTFILES/bash/bashrc"       "$HOME/.bashrc"
      link "$DOTFILES/bash/bash_profile" "$HOME/.bash_profile"
      link "$DOTFILES/bash/bash_logout"  "$HOME/.bash_logout" ;;
    karabiner)
      # only the complex-modification rule, not the whole live config dir
      link "$DOTFILES/karabiner/alacritty.json" \
           "$CONFIG/karabiner/assets/complex_modifications/alacritty.json" ;;
    xmodmap)   link "$DOTFILES/Xmodmap/Xmodmap" "$HOME/.Xmodmap" ;;
    hyprland)  link "$DOTFILES/hyprland"        "$CONFIG/hypr" ;;
  esac
}

# --- post-link: zjstatus permissions -----------------------------------------
# The zellij status bar (zjstatus.wasm) needs its plugin permissions granted or
# it renders an empty bar. The grant prompt can't be answered in a 1-row bar
# pane, so we pre-seed it. Path + format match exactly what zellij writes.
seed_zellij_perms() {
  wasm="$CONFIG/zellij/plugins/zjstatus.wasm"
  [ -e "$wasm" ] || return 0
  case "$OSKEY" in
    darwin) perm="$HOME/Library/Caches/org.Zellij-Contributors.Zellij/permissions.kdl" ;;
    *)      perm="${XDG_CACHE_HOME:-$HOME/.cache}/zellij/permissions.kdl" ;;
  esac
  if [ -f "$perm" ] && grep -qF "$wasm" "$perm" 2>/dev/null; then
    say "  ${DIM}[ok]     zjstatus permissions already granted${RST}"; return 0
  fi
  if [ "$DRY" -eq 1 ]; then
    say "  ${GRN}[grant]${RST}  zjstatus permissions ${DIM}(dry)${RST}"; return 0
  fi
  mkdir -p "$(dirname "$perm")"
  printf '"%s" {\n    RunCommands\n    ReadApplicationState\n    ChangeApplicationState\n}\n' \
    "$wasm" >> "$perm"
  say "  ${GRN}[grant]${RST}  zjstatus permissions -> $perm"
}

# --- post-link: make zsh the default shell ------------------------------------
# Installing zsh itself is a manual prerequisite — how you install it differs
# too much per system (macOS ships it, Debian/Ubuntu is `sudo apt install zsh`,
# Fedora is `sudo dnf install zsh`). But once zsh exists, switching the default
# shell is the same everywhere, so that part is automated here: register the
# zsh path in /etc/shells if needed, then chsh to it. Never hard-fails — on any
# snag it prints the manual command and moves on.
ensure_default_shell() {
  case "${SHELL:-}" in
    */zsh) say "  ${DIM}[ok]     default shell is already zsh ($SHELL)${RST}"; return 0 ;;
  esac
  if ! command -v zsh >/dev/null 2>&1; then
    say "  ${YLW}[skip]${RST}   zsh not on PATH — install it first (manual prerequisite, see above), then re-run"
    return 0
  fi
  zshpath="$(command -v zsh)"
  if [ "$DRY" -eq 1 ]; then
    say "  ${GRN}[chsh]${RST}   would set default shell to $zshpath ${DIM}(dry)${RST}"
    return 0
  fi
  if ! grep -qx "$zshpath" /etc/shells 2>/dev/null; then
    if printf '%s\n' "$zshpath" | sudo tee -a /etc/shells >/dev/null; then
      say "  ${GRN}[shells]${RST} added $zshpath to /etc/shells"
    else
      say "  ${YLW}[warn]${RST}   couldn't add $zshpath to /etc/shells — run manually:"
      say "  ${YLW}       ${RST}  printf '%s\\n' \"$zshpath\" | sudo tee -a /etc/shells && chsh -s \"$zshpath\""
      return 0
    fi
  fi
  if ! [ -t 0 ]; then
    say "  ${YLW}[skip]${RST}   no TTY for chsh — run manually: chsh -s \"$zshpath\""
    return 0
  fi
  # chsh may prompt for your password — that's normal.
  if chsh -s "$zshpath"; then
    say "  ${GRN}[chsh]${RST}   default shell set to $zshpath — log out/in or run: exec zsh -l"
  else
    say "  ${YLW}[warn]${RST}   chsh failed — run manually: chsh -s \"$zshpath\""
  fi
}

# --- interactive menu --------------------------------------------------------
render() {
  [ -t 1 ] && printf '\033[2J\033[3J\033[H'
  say "${BOLD}== choose what to symlink ==${RST}   ${DIM}os: $OSKEY${RST}"
  say "${DIM}number = toggle    a = all    n = none    c = continue    q = quit${RST}"
  say ""
  i=0
  for k in $KEYS; do
    i=$((i + 1))
    if is_enabled "$k"; then mark="${GRN}[x]${RST}"; else mark="${DIM}[ ]${RST}"; fi
    printf "  %2d) %b %-10s ${DIM}%s${RST}\n" "$i" "$mark" "$k" "$(label_of "$k")"
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
      q|Q)    say "aborted — nothing changed."; exit 0 ;;
      a|A)    ENABLED=" "; for k in $KEYS; do ENABLED="$ENABLED$k "; done ;;
      n|N)    ENABLED=" " ;;
      *[!0-9]*) ;;                       # ignore non-numeric junk
      *)
        j=0; sel=""
        for k in $KEYS; do j=$((j + 1)); [ "$j" = "$choice" ] && { sel="$k"; break; }; done
        [ -n "$sel" ] && toggle "$sel" ;;
    esac
  done
}

confirm() {
  [ -t 1 ] && printf '\033[2J\033[3J\033[H'
  say "${BOLD}== will symlink ==${RST}"
  any=0
  for k in $KEYS; do is_enabled "$k" && { say "  ${GRN}+${RST} $k"; any=1; }; done
  [ "$any" -eq 0 ] && { say "${YLW}nothing selected — aborting.${RST}"; exit 0; }
  say ""
  printf 'proceed? [y/N] '
  read -r ans || ans=""
  case "$ans" in y|Y|yes|YES) return 0 ;; *) say "aborted — nothing changed."; exit 0 ;; esac
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

say "${DIM}dotfiles: $DOTFILES${RST}"

# zsh is the one manual prerequisite (see ensure_default_shell below for why).
if ! command -v zsh >/dev/null 2>&1; then
  say "${YLW}${BOLD}warning: zsh not found on PATH.${RST}"
  say "${YLW}zsh is a prerequisite of these dotfiles, installed manually by design${RST}"
  say "${YLW}(it varies per system: macOS ships it; Debian/Ubuntu: sudo apt install zsh;${RST}"
  say "${YLW}Fedora: sudo dnf install zsh). linking will proceed — that's harmless and${RST}"
  say "${YLW}useful to do first — but the configs are inert until zsh exists.${RST}"
fi

[ "$DRY" -eq 1 ] && say "${YLW}(dry run — no changes will be made)${RST}"

# Choose selection: -y / no-TTY use defaults; otherwise drive the menu.
if [ "$ASSUME_YES" -eq 1 ]; then
  :
elif [ -t 0 ] || [ "${INSTALL_INTERACTIVE:-0}" = 1 ]; then
  menu
  confirm
else
  say "${YLW}no TTY: linking default selection (pass -y to silence, or run in a terminal to choose).${RST}"
fi

# --- apply -------------------------------------------------------------------
for k in $KEYS; do
  is_enabled "$k" || continue
  say ""
  say "${BOLD}== $k ==${RST}"
  do_links "$k"
  [ "$k" = zellij ] && seed_zellij_perms
  [ "$k" = zsh ] && ensure_default_shell
done

say ""
say "${DIM}not linked: ssh/config (live one diverges), gitconfig (no git/ in repo).${RST}"
say "${GRN}symlinks done.${RST} open a new terminal (or run: exec zsh -l) to pick them up."

# --- offer layer 2 (binaries) ------------------------------------------------
TOOLS_SCRIPT="$DOTFILES/install/install-tools.sh"
if [ -x "$TOOLS_SCRIPT" ] && [ "$ASSUME_YES" -ne 1 ] && { [ -t 0 ] || [ "${INSTALL_INTERACTIVE:-0}" = 1 ]; }; then
  printf '\ninstall/upgrade missing tools now? [y/N] '
  read -r ans || ans=""
  case "$ans" in
    y|Y|yes|YES) if [ "$DRY" -eq 1 ]; then "$TOOLS_SCRIPT" -n; else "$TOOLS_SCRIPT"; fi ;;
    *)           say "${DIM}skipped — run ./install/install-tools.sh whenever you want.${RST}" ;;
  esac
fi
