-- DO NOT REMOVE -- some plugins need this (nvim-tree, ..)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- important config
require('options')
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
lvim.leader = "space"

vim.opt.softtabstop = 8
vim.opt.shiftwidth = 8
vim.opt.tabstop = 8

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
