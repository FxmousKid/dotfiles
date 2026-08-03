#!/usr/bin/env bash
# Claim-by-claim post-install smoke test. Run after install-tools.sh and
# install.sh; it is read-only apart from short-lived tmux server state.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:$HOME/Releases/nvim-bin:$PATH"
# SSH/cloud-init runners often omit TERM. Give terminal-aware startup hooks and
# CLI config validators a conservative value so a headless smoke run is quiet.
export TERM="${TERM:-xterm-256color}"

if [[ -d "$HOME/.nvm/versions/node" ]]; then
  node_bin="$(find "$HOME/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin | sort | tail -1)"
  [[ -z "$node_bin" ]] || export PATH="$node_bin:$PATH"
fi

assert_link() {
  local target="$1" source="$2"
  [[ -L "$target" && "$(readlink "$target")" == "$source" ]] || {
    printf 'Bad or missing link: %s (expected %s)\n' "$target" "$source" >&2
    exit 1
  }
  printf 'Link verified: %s\n' "$target"
}

assert_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing command: %s\n' "$1" >&2
    exit 1
  }
  printf 'Command verified: %s\n' "$1"
}

assert_link "$HOME/.zshenv" "$ROOT/zsh/zshenv"
assert_link "$HOME/.config/zsh/.zshrc" "$ROOT/zsh/zshrc"
assert_link "$HOME/.config/nvim" "$ROOT/nvim"
assert_link "$HOME/.config/lvim" "$ROOT/lvim"
assert_link "$HOME/.config/bob" "$ROOT/bob"
assert_link "$HOME/.config/atuin" "$ROOT/atuin"
assert_link "$HOME/.config/zellij" "$ROOT/zellij"
assert_link "$HOME/.config/yazi" "$ROOT/yazi"
assert_link "$HOME/.config/lazygit" "$ROOT/lazygit"
assert_link "$HOME/.tmux.conf" "$ROOT/tmux/tmux.conf"

commands=(zsh nvim lvim bob atuin zellij yazi lazygit tmux clang clangd java cargo cscope)
for command_name in "${commands[@]}"; do
  assert_command "$command_name"
done

nvim_version="$(nvim --version | head -1)"
[[ "$nvim_version" == 'NVIM v0.10.4' ]] || {
  printf 'Unexpected Neovim version: %s\n' "$nvim_version" >&2
  exit 1
}
printf 'Version verified: %s\n' "$nvim_version"

nvim --headless -c 'quitall' >/dev/null
lvim --headless -c 'quitall' >/dev/null
zsh -lic 'command -v nvim lvim atuin zellij yazi lazygit >/dev/null'
zellij setup --check >/dev/null

tmux_socket="dotfiles-smoke-$$"
tmux -L "$tmux_socket" -f "$HOME/.tmux.conf" start-server
tmux -L "$tmux_socket" kill-server 2>/dev/null || true

printf 'Installed tools, linked configs, shells, editors, Zellij, and tmux passed.\n'
