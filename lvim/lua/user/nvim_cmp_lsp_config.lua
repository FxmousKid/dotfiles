-- Clangd constant warning fix

local cmp_nvim_lsp = require "cmp_nvim_lsp"
require("lspconfig").clangd.setup {
	capabilities = cmp_nvim_lsp.default_capabilities(),
	cmd = {
		"clangd",
		"--offset-encoding=utf-16",
	},
}

-- local keymap_opts = { noremap = true, silent = true }
-- vim.keymap.set({'n'}, 'gd', vim.lsp.buf.definition, {table.unpack(keymap_opts), desc="Goto Definition"})
