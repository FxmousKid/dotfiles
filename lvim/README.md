# lvim

My LunarVim config. LunarVim provides the base (LSP, completion, telescope,
treesitter, which-key, dap); these files add to and tweak it.

Built on LunarVim 1.4 (Neovim 0.9).

## How it loads

`config.lua` is the entry point — it `require()`s everything else: options →
python LSP → keybinds → plugins → per-plugin setup → snippets → custom commands.
A `lua/local.lua` (gitignored) is loaded last if present, for machine-local or
private overrides.

## Layout

- `config.lua` — entry point + core lvim settings.
- `lua/options.lua` — editor options (tabs = 4, lunar theme, transparent, cursor).
- `lua/plugins.lua` — extra plugins on top of LunarVim's defaults.
- `lua/keybinds.lua` → `lua/keymaps/` — keybindings, split by topic.
- `lua/user/` — per-plugin setup (telescope, nvim-tree, neogen, clangd, cscope,
  remote-sshfs, ts-autotag, python LSP).
- `lua/custom_commands/` — hand-written commands, each with a `.md` doc.
- `lua/snippets/` — LuaSnip snippets.
- `ftplugin/` — per-language settings + LSP (C, Java, sh, lua, tex, web).

## Keys

Two leaders:

- `Space` — LunarVim's default menus, plus `Space t…` for Telescope.
- `\` — personal maps: cscope (`\c…`), clangd (`\l…`), Java (`\C…`), hex (`\h…`),
  markdown (`\-`, `\mp…`), copilot (`\a…`), docs (`\l`), and the git-diff review
  flow (`\s`, `\x`, `\gd`, `\gg`).

## Custom commands

- `:FoldBlockComments` — fold every multi-line block comment.
- `:GitSetBase <commit>` + `:DiffBase` (`\gd`) — review changes against a base commit.
- `:QfDelete` — delete the quickfix entry under the cursor.

## Per-machine / private

Put machine-specific or private settings in `lua/local.lua` (gitignored, loaded
if present). The 42-header identity (`vim.g.user` / `vim.g.mail`) is set in the
42-header plugin block in `plugins.lua`.

## Notes

- `lazy-lock.json` is gitignored, so plugin versions aren't pinned across
  machines — track it if you ever want fully reproducible installs.
