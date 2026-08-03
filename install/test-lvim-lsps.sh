#!/usr/bin/env bash
# Open representative files and prove that every configured LunarVim LSP
# client attaches to its buffer. Runs sequentially to keep memory bounded.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LVIM_BIN="${LVIM_BIN:-$HOME/.local/bin/lvim}"
SMOKE_LUA="$SCRIPT_DIR/lvim-lsp-smoke.lua"
export PATH="$HOME/.local/bin:$HOME/Releases/nvim-bin:$PATH"
export TERM="${TERM:-xterm-256color}"

# Mason's npm-backed servers use /usr/bin/env node.  nvm normally adds Node
# only to interactive shell startup, so expose its newest installation when
# this harness runs from CI, cloud-init, or an SSH command.
if [[ -d "$HOME/.nvm/versions/node" ]]; then
  node_bin="$(find "$HOME/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin | sort | tail -1)"
  [[ -z "$node_bin" ]] || export PATH="$node_bin:$PATH"
fi

if [[ ! -x "$LVIM_BIN" ]]; then
  printf 'LunarVim launcher is missing: %s\n' "$LVIM_BIN" >&2
  exit 1
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-lsp-smoke.XXXXXX")"
trap 'rm -rf -- "$work_dir"' EXIT
mkdir -p "$work_dir/.git"

printf '#include <stdio.h>\nint main(void) { return 0; }\n' > "$work_dir/main.c"
printf 'answer: int = 42\n' > "$work_dir/main.py"
printf '#!/usr/bin/env bash\nprintf "ok\\n"\n' > "$work_dir/test.sh"
printf 'local answer = 42\nreturn answer\n' > "$work_dir/init.lua"
printf 'public class Main { public static void main(String[] args) {} }\n' > "$work_dir/Main.java"
printf 'fun main() { println("ok") }\n' > "$work_dir/Main.kt"

cases=(
  'clangd|main.c'
  'pyright|main.py'
  'bashls|test.sh'
  'lua_ls|init.lua'
  'jdtls|Main.java'
  'kotlin_language_server|Main.kt'
)

cd "$work_dir"
for test_case in "${cases[@]}"; do
  server="${test_case%%|*}"
  file="${test_case#*|}"
  printf 'Testing %-24s %s\n' "$server" "$file"
  output="$(DOTFILES_EXPECT_LSP="$server" "$LVIM_BIN" --headless "$file" \
    -c "lua dofile('$SMOKE_LUA')" 2>&1)" || {
      printf '%s\n' "$output" >&2
      exit 1
    }
  printf '%s\n' "$output"
  if printf '%s\n' "$output" | grep -Eiq '\[WARN|\[ERROR|Error detected|job failed|LSP smoke failed'; then
    printf 'Unexpected warning or error while testing %s\n' "$server" >&2
    exit 1
  fi
done

printf 'All configured LSP clients attached successfully.\n'
