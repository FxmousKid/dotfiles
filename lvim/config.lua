-- DO NOT REMOVE -- some plugins need this (nvim-tree, ..)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- JVM-based LSPs (kotlin-language-server, ..) resolve java via JAVA_HOME or
-- PATH; SDKMAN only exports those in interactive shells, so fill them in here
-- when the launching environment didn't.
local sdkman_java = (os.getenv("SDKMAN_DIR") or (os.getenv("HOME") .. "/.sdkman")) .. "/candidates/java/current"
if not vim.env.JAVA_HOME and vim.fn.isdirectory(sdkman_java) == 1 then
  vim.env.JAVA_HOME = sdkman_java
  vim.env.PATH = sdkman_java .. "/bin:" .. vim.env.PATH
end

-- important config
require('options')
lvim.leader = "space"
require('user.python_lsp')
require('keybinds')
require('plugins')

-- plugins config
require('user.telescope')
require('user.nvim-tree_config')
require('user.neogen')
require('user.codesnap')
require('user.clangd_extensions')
require('user.cscope_maps')
require('user.remote-sshfs')
require('user.nvim-ts-autotag')

-- snippets
require('snippets.c')

-- commands
reload('custom_commands.FoldBlockComments')
reload('custom_commands.GitDiffCommit')
reload('custom_commands.QfDelete')

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.o.guifont = "JetBrains Mono Nerd Font"
vim.opt.incsearch = true
vim.opt.shell = "/bin/zsh"
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "lunar"

vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.terminal.hide_numbers = false
lvim.builtin.terminal.direction = 'float'
-- lvim.reload_config_on_save = true
lvim.builtin.breadcrumbs.active = true
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.dap.active = true


---- So our overrides survive colorscheme changes:
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Softer backgrounds for diff
    vim.api.nvim_set_hl(0, "DiffAdd",    { fg = "NONE", bg = "#193824" })
    vim.api.nvim_set_hl(0, "DiffChange", { fg = "NONE", bg = "#1b2838" })
    vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#553333", bg = "#2a1717" })
    vim.api.nvim_set_hl(0, "DiffText",   { fg = "NONE", bg = "#34485e", bold = true })
  end,
})

-- Apply once on startup too
vim.api.nvim_exec_autocmds("ColorScheme", {})

-- Machine-local / private overrides (lua/local.lua, gitignored). Optional.
pcall(require, "local")
