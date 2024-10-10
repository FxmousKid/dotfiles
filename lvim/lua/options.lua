-- typing Interactions 
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.mouse = "a"
--vim.opt.smartindent = true

-- editor interactions
vim.opt.showcmd = true

-- Hack to enable colorscheme changing : https://github.com/LunarVim/LunarVim/issues/3932#issuecomment-1466563537
-- lvim.lsp.on_attach_callback = function(client, _)
--     client.server_capabilities.semanticTokensProvider = nil
-- end

-- Changing the theme
lvim.colorscheme = 'lunar'
lvim.transparent_window = true

-- Disabling default plugins
lvim.builtin.gitsigns.active = false


-- Fixing treesitter "invalid node at position x" bug
lvim.builtin.treesitter.rainbow = {
	enable = false}

lvim.builtin.illuminate = {active = false}

-- lvim appearance

-- 42Header setup
vim.g.user  = "inazaria"
vim.g.mail = "inazaria@student.42.fr"


-- Blinking Cursor
vim.opt.guicursor = {
  'n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100'
}
