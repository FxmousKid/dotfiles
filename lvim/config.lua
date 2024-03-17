-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


-- typing Interactions 
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.mouse = "a"
vim.opt.smartindent = true


-- editor interactions
vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.showcmd = true


-- lvim appearance
lvim.builtin.lualine.options.theme = "horizon"

-- Blinking Cursor
vim.opt.guicursor = {
  'n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100'
}
