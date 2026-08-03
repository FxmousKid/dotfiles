#!/bin/sh
# Fast, network-free contract checks for the editable tool manifest.
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
MANIFEST="$SCRIPT_DIR/manifests/tools.sh"

# Resolved relative to this script at runtime.
# shellcheck disable=SC1090
. "$MANIFEST"

printf '%s\n' "$TOOLS" | awk -F '|' '
  NF == 0 || (NF == 1 && $1 == "") { next }
  NF != 9 {
    printf "manifest row %d has %d fields, expected 9: %s\n", NR, NF, $0 > "/dev/stderr"
    bad = 1
    next
  }
  $1 == "" {
    printf "manifest row %d has an empty command key\n", NR > "/dev/stderr"
    bad = 1
  }
  seen[$1]++ {
    printf "duplicate manifest command key: %s\n", $1 > "/dev/stderr"
    bad = 1
  }
  END { exit bad }
'

for required in zsh nvim lvim atuin zellij yazi lazygit clang clangd java; do
  printf '%s\n' "$TOOLS" | awk -F '|' -v key="$required" '$1 == key { found = 1 } END { exit !found }' \
    || { printf 'required manifest command is missing: %s\n' "$required" >&2; exit 1; }
done

case "$NVIM_DEFAULT" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *) printf 'NVIM_DEFAULT is not an exact vX.Y.Z release: %s\n' "$NVIM_DEFAULT" >&2; exit 1 ;;
esac
case "$JAVA_SDKMAN_VERSION" in
  21.*-*) ;;
  *) printf 'JAVA_SDKMAN_VERSION must pin a Java 21 SDKMAN candidate: %s\n' "$JAVA_SDKMAN_VERSION" >&2; exit 1 ;;
esac
case "$SDKMAN_INSTALL_URL" in
  'https://get.sdkman.io?ci=true&rcupdate=false') ;;
  *) printf 'SDKMAN install URL must keep CI mode and profile mutation disabled\n' >&2; exit 1 ;;
esac

printf 'Tool manifest contract passed.\n'
