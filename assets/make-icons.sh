#!/bin/sh
# =============================================================================
#  make-icons.sh — build the app-icon tiles used by the root README map.
#
#  Each tile is a 120x120 rounded square (the tool's color) with its logo and
#  name in white. Real logos come from Simple Icons (public domain / CC0); tools
#  Simple Icons doesn't have get a letter monogram instead.
#
#  Re-run after adding a tool:  ./assets/make-icons.sh
#  Needs: sh, curl, sed.
# =============================================================================
set -eu
OUT="$(cd "$(dirname "$0")" && pwd)/icons"
mkdir -p "$OUT"

# name | bg color | source     (si:<slug> = Simple Icons, mono:<letter> = monogram)
TILES="
zsh|5E60CE|si:zsh
bash|4EAA25|si:gnubash
lvim|57A143|si:neovim
nvim|57A143|si:neovim
bob|6A4C93|mono:B
alacritty|F46D01|si:alacritty
tmux|1BB91F|si:tmux
zellij|9D4EDD|mono:Z
atuin|0F8B8D|mono:A
yazi|7B2CBF|mono:Y
lazygit|F05133|si:git
fastfetch|2EA3FF|mono:F
ssh|4D4D4D|mono:S
karabiner|111111|si:apple
hyprland|18B5CE|si:hyprland
gnome|4A86CF|si:gnome
xmodmap|5A5A5A|mono:X
halloy|8338EC|mono:H
install|FB7233|si:homebrew
notes|0B66C3|si:markdown
"

# shared header/footer
open_svg() { printf '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120">\n  <rect width="120" height="120" rx="26" fill="#%s"/>\n' "$1"; }
label()    { printf '  <text x="60" y="104" fill="#ffffff" font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif" font-size="15" font-weight="600" text-anchor="middle">%s</text>\n</svg>\n' "$1"; }

tile_si() {  # name color slug
  d=$(curl -fsSL "https://cdn.simpleicons.org/$3" | sed -n 's/.*<path d="\([^"]*\)".*/\1/p' | head -1)
  { open_svg "$2"
    printf '  <g transform="translate(37,16) scale(1.916)" fill="#ffffff"><path d="%s"/></g>\n' "$d"
    label "$1"
  } > "$OUT/$1.svg"
}

tile_mono() {  # name color letter
  { open_svg "$2"
    printf '  <text x="60" y="56" fill="#ffffff" font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif" font-size="46" font-weight="700" text-anchor="middle" dominant-baseline="central">%s</text>\n' "$3"
    label "$1"
  } > "$OUT/$1.svg"
}

printf '%s\n' "$TILES" | while IFS='|' read -r name color src; do
  [ -z "$name" ] && continue
  case "$src" in
    si:*)   tile_si   "$name" "$color" "${src#si:}" ;;
    mono:*) tile_mono "$name" "$color" "${src#mono:}" ;;
  esac
  echo "  $name.svg"
done
echo "done -> $OUT"
