# Claude Code session ids for zellij resurrection.
#
# Zellij can only resurrect a pane onto a specific Claude conversation if that
# conversation's id is part of the argv it serialized. Claude picks its session id
# internally unless you pass one, so pin it up front; the paired hook
# (../hooks/claude-resurrect.sh) then rewrites `--session-id` into `--resume` when
# the session is serialized, because replaying `--session-id` verbatim fails with
# "Session ID <uuid> is already in use."
#
# Scope: this only affects what *you* type. zsh functions are not exported, so
# scripts, CI, and Claude's own child processes still hit the real binary.
# Subcommands (`claude mcp`, `claude doctor`, ...) and every explicit-session or
# non-interactive flag are passed straight through.

claude() {
  case ${1:-} in
    agents|auth|auto-mode|doctor|gateway|install|mcp|plugin|plugins|project\
    |setup-token|ultrareview|update|upgrade|help)
      command claude "$@"
      return
      ;;
  esac

  local arg
  for arg in "$@"; do
    case $arg in
      -r|--resume|-c|--continue|--session-id|--session-id=*|--from-pr\
      |-p|--print|--fork-session|-h|--help|-v|--version)
        command claude "$@"
        return
        ;;
    esac
  done

  local uuid=""
  if (( $+commands[uuidgen] )); then
    uuid=${$(uuidgen)::l}
  elif [[ -r /proc/sys/kernel/random/uuid ]]; then
    uuid=$(</proc/sys/kernel/random/uuid)
  fi

  # No uuid source: behave exactly as before rather than guessing.
  [[ -z $uuid ]] && { command claude "$@"; return }

  command claude --session-id "$uuid" "$@"
}
