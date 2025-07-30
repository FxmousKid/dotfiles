lvim.format_on_save = false
-- lvim.diagnostics.config = { virtual_text = false }

lvim.builtin.treesitter.highlight.enable = true

-- auto install treesitter parsers
lvim.builtin.treesitter.ensure_installed = { "lua" }

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "lua_ls", "sumneko_lua" })


local opts = require("lvim.lsp").get_common_opts()
-- you can merge any custom settings here
opts.settings = {
	Lua = {
		runtime = { version = "LuaJIT" },
		workspace = {
			checkThirdParty = false,
			library = { vim.env.VIMRUNTIME },
		},
	},
}

require("lvim.lsp.manager").setup("sumneko_lua", opts)
