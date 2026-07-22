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
#  Interactive by default (pick what to install); -y installs all missing,
#  -n dry-runs (prints the method per tool, changes nothing).
#
#  Add a tool = add one row to the TOOLS table below.
# =============================================================================

set -eu

OS="$(uname)"
LOCAL_BIN="$HOME/.local/bin"
EGET="$LOCAL_BIN/eget"
DRY=0
ASSUME_YES=0

# Tool manifest — fields:  bin | brew | dnf | copr | apt | gh_repo | custom_fn
# (empty field = method not available for that tool)
# (apt is filled only where the Debian/Ubuntu package ships exactly the binary
#  in `bin`; fd stays blank because apt's fd-find installs it as `fdfind`,
#  which would break the presence check — others fall through to eget)
TOOLS="
zellij|zellij|zellij|varlad/zellij||zellij-org/zellij|
yazi|yazi|yazi|lihaohong/yazi||sxyazi/yazi|
atuin|atuin|atuin|||atuinsh/atuin|
lazygit|lazygit|lazygit|atim/lazygit||jesseduffield/lazygit|
fastfetch|fastfetch|fastfetch|||fastfetch-cli/fastfetch|
eza|eza|eza|||eza-community/eza|
delta|git-delta|git-delta|||dandavison/delta|
rg|ripgrep|ripgrep||ripgrep|BurntSushi/ripgrep|
fd|fd|fd-find|||sharkdp/fd|
fzf|fzf|fzf||fzf|junegunn/fzf|
glow|glow|glow|||charmbracelet/glow|
tree|tree|tree||tree||
gh|gh|gh||gh|cli/cli|
ag|the_silver_searcher|the_silver_searcher||silversearcher-ag||
bob|||||MordechaiHadad/bob|
nvim|neovim|neovim||||install_nvim
zap||||||install_zap
lvim||||||install_lvim
"

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
  say "  -y   install all missing tools (non-interactive)"
  say "  -n   dry run (print the method per tool, install nothing)"
  say "  -h   this help"
}

# --- per-tool presence (zap is a sourced plugin, not a binary) ---------------
is_installed() {
  case "$1" in
    zap) [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] ;;
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
install_nvim() {
  if have bob; then bob install stable && bob use stable
  else say "  ${YLW}bob not installed yet — rerun after bob, or use brew/eget${RST}"; return 1; fi
}
install_lvim() {
  # LunarVim is pinned to specific Neovim versions; bump branch/URL as needed.
  # `bash -c "$(curl ...)"` keeps stdin on the terminal so its prompts work.
  LV_BRANCH='release-1.4/neovim-0.9' \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)"
}

# --- eget bootstrap (the only thing we fetch to fetch others) ----------------
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

# --- field lookup: sets brewf/dnfp/copr/aptp/ghrepo/custom for a tool key ----
load_fields() {
  brewf=; dnfp=; copr=; aptp=; ghrepo=; custom=
  while IFS='|' read -r k b d c a g f; do
    [ "$k" = "$1" ] || continue
    brewf=$b; dnfp=$d; copr=$c; aptp=$a; ghrepo=$g; custom=$f; return 0
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
    say "  ${GRN}[brew]${RST}   $key ($brewf)"
    [ "$DRY" -eq 1 ] || brew install "$brewf"
  elif have dnf && [ -n "$dnfp" ]; then
    if [ -n "$copr" ]; then
      say "  ${GRN}[copr]${RST}   enable $copr ${DIM}(sudo)${RST}"
      [ "$DRY" -eq 1 ] || sudo dnf copr enable -y "$copr"
    fi
    say "  ${GRN}[dnf]${RST}    $key ($dnfp) ${DIM}(sudo)${RST}"
    [ "$DRY" -eq 1 ] || sudo dnf install -y "$dnfp"
  elif have apt-get && [ -n "$aptp" ]; then
    say "  ${GRN}[apt]${RST}    $key ($aptp) ${DIM}(sudo)${RST}"
    [ "$DRY" -eq 1 ] || sudo apt-get install -y "$aptp"
  elif [ -n "$ghrepo" ]; then
    ensure_eget || { say "  ${YLW}[skip]   $key (no eget)${RST}"; return 0; }
    say "  ${GRN}[eget]${RST}   $key ($ghrepo -> $LOCAL_BIN)"
    [ "$DRY" -eq 1 ] || "$EGET" "$ghrepo" --to "$LOCAL_BIN"
  else
    say "  ${YLW}[skip]${RST}   $key — no install method for this machine"
  fi
}

# --- selection state ---------------------------------------------------------
KEYS=""; ENABLED=" "
while IFS='|' read -r k _b _d _c _a _g _f; do
  [ -z "$k" ] && continue
  KEYS="$KEYS $k"
  is_installed "$k" || ENABLED="$ENABLED$k "   # default-on only what's missing
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
  [ -t 1 ] && printf '\033[2J\033[3J\033[H'
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
  [ -t 1 ] && printf '\033[2J\033[3J\033[H'
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
  say "${YLW}no TTY: installing all missing tools (pass -y to silence).${RST}"
fi

for k in $KEYS; do
  is_enabled "$k" || continue
  ensure_tool "$k"
done

say ""
say "${GRN}done.${RST} (binaries in $LOCAL_BIN are already on your PATH via ~/.zshenv)"
