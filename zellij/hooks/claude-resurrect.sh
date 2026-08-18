#!/bin/sh
# zellij post_command_discovery_hook — keep Claude Code panes on their own chat.
#
# Zellij serializes the literal argv of whatever it finds running in a pane, so a
# resurrected Claude pane re-runs plain `claude` and lands in a brand-new, empty
# conversation. This rewrites the command *before* it is serialized:
#
#   claude --session-id <uuid>  ->  claude --resume <uuid>   (that exact chat)
#   claude                      ->  claude --continue        (last chat in the pane's cwd)
#   claude --resume/-c/-p/...   ->  unchanged
#   claude <subcommand> ...     ->  unchanged
#   anything that is not claude ->  unchanged
#
# Contract, verified on zellij 0.44.3: the hook is handed ONLY $RESURRECT_COMMAND
# (the full discovered argv) and whatever it prints on STDOUT is serialized in its
# place. It gets no pane identity — no pane id, no pane cwd; $PWD is the zellij
# server's cwd — which is why the session id has to be planted in argv at launch
# time by ../shell/claude-session.zsh. Measured at ~20 calls/second, so this stays
# on shell builtins only: no pipes, no subprocesses.
#
# `--session-id` cannot simply be replayed: a second run with the same id exits
# with "Session ID <uuid> is already in use." `--resume <uuid>` is the verb that
# reopens it.

cmd=$RESURRECT_COMMAND

# Not a Claude Code pane -> hand it back untouched.
case $cmd in
  claude|*/claude|claude\ *|*/claude\ *) ;;
  *) printf '%s\n' "$cmd"; exit 0 ;;
esac

# Subcommands (`claude agents`, `claude gateway`, `claude ultrareview`, ...) take no
# session flags at all -- appending one would serialize a command that cannot run.
args=${cmd#* }
[ "$args" = "$cmd" ] && args=""
case ${args%% *} in
  agents|auth|auto-mode|doctor|gateway|install|mcp|plugin|plugins|project|setup-token|ultrareview|update|upgrade|help)
    printf '%s\n' "$cmd"
    exit 0
    ;;
esac

case " $cmd " in
  # Already points at a conversation, or is a headless one-shot.
  *' --resume '*|*' -r '*|*' --continue '*|*' -c '*|*' --from-pr '*|*' -p '*|*' --print '*)
    printf '%s\n' "$cmd"
    ;;
  # Launched through the wrapper: flip the create verb into the resume verb,
  # keeping any trailing flags (--model, --permission-mode, ...).
  *' --session-id '*)
    rest=${cmd#* --session-id }
    uuid=${rest%% *}
    printf '%s --resume %s%s\n' "${cmd%% --session-id *}" "$uuid" "${rest#"$uuid"}"
    ;;
  # Bare `claude` (or an id we cannot parse): fall back to the most recent chat in
  # this pane's directory. Zellij serializes each pane's cwd, so this resolves per
  # pane — it just cannot tell two panes in the same directory apart.
  *)
    printf '%s --continue\n' "$cmd"
    ;;
esac
