-- DO NOT REMOVE -- some plugins need this (nvim-tree, ..)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('options')
require('keybinds')
require('plugins')

require('user.telescope')
require('user.nvim-tree_config')


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
