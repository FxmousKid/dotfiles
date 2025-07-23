
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.api.nvim_set_hl(0, 'Comment', { fg = '#f699cd', italic = true })
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })

reload('options')
require('keybinds')
reload('plugins')
