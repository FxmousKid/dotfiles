#!/bin/sh
# Package-manager adapters sourced by install/install-tools.sh.
#
# These functions intentionally contain only distro/package-manager mechanics.
# Tool names and sources belong in manifests/tools.sh; selection, custom
# installers and final verification belong in install-tools.sh.

install_brew_package() {
  key=$1
  package=$2
  say "  ${GRN}[brew]${RST}   $key ($package)"
  [ "$DRY" -eq 1 ] && return 0
  brew install "$package" \
    || say "  ${YLW}($key brew install failed — verify below will flag it)${RST}"
}

ensure_dnf_copr() {
  dnf copr --help >/dev/null 2>&1 && return 0
  if [ "$DRY" -eq 1 ]; then
    say "  ${DIM}(would install DNF COPR support if missing)${RST}"
    return 0
  fi

  say "  ${GRN}[dnf]${RST}    COPR command support ${DIM}(sudo)${RST}"
  # DNF4 exposes COPR through dnf-plugins-core. DNF5 distributions can package
  # it separately as dnf5-plugins. Try the long-established package first and
  # verify the command instead of inferring support from the DNF version.
  sudo dnf install -y dnf-plugins-core >/dev/null 2>&1 \
    || sudo dnf install -y dnf5-plugins >/dev/null 2>&1 \
    || return 1
  dnf copr --help >/dev/null 2>&1
}

install_dnf_package() {
  key=$1
  package=$2
  copr_repo=$3

  if [ -n "$copr_repo" ]; then
    if ! ensure_dnf_copr; then
      say "  ${YLW}($key needs COPR $copr_repo, but DNF COPR support is unavailable — verify below will flag it)${RST}"
      return 0
    fi
    say "  ${GRN}[copr]${RST}   enable $copr_repo ${DIM}(sudo)${RST}"
    [ "$DRY" -eq 1 ] || sudo dnf copr enable -y "$copr_repo" \
      || say "  ${YLW}($key COPR enable failed — verify below will flag it)${RST}"
  fi

  say "  ${GRN}[dnf]${RST}    $key ($package) ${DIM}(sudo)${RST}"
  [ "$DRY" -eq 1 ] || sudo dnf install -y "$package" \
    || say "  ${YLW}($key dnf install failed — verify below will flag it)${RST}"
}

install_apt_package() {
  key=$1
  package=$2
  say "  ${GRN}[apt]${RST}    $key ($package) ${DIM}(sudo)${RST}"
  [ "$DRY" -eq 1 ] && return 0
  sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get -o Dpkg::Use-Pty=0 install -y "$package" \
    || say "  ${YLW}($key apt install failed — verify below will flag it)${RST}"
}
