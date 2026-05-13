local common = require("keymaps.common")

local function register_clangd_keymaps(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "\\lh", "<cmd>ClangdSwitchSourceHeader<cr>",
		vim.tbl_extend("force", opts, { desc = "Switch source/header" }))
	vim.keymap.set("x", "\\lA", "<cmd>ClangdAST<cr>",
		vim.tbl_extend("force", opts, { desc = "Show Clangd AST" }))
	vim.keymap.set("n", "\\lH", "<cmd>ClangdTypeHierarchy<cr>",
		vim.tbl_extend("force", opts, { desc = "Show type hierarchy" }))
	vim.keymap.set("n", "\\lt", "<cmd>ClangdSymbolInfo<cr>",
		vim.tbl_extend("force", opts, { desc = "Show symbol info" }))
	vim.keymap.set("n", "\\lm", "<cmd>ClangdMemoryUsage<cr>",
		vim.tbl_extend("force", opts, { desc = "Show Clangd memory usage" }))

	common.which_key_register({
		l = {
			name = "Docs / LSP",
			h = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header" },
			H = { "<cmd>ClangdTypeHierarchy<cr>", "Show type hierarchy" },
			t = { "<cmd>ClangdSymbolInfo<cr>", "Show symbol info" },
			m = { "<cmd>ClangdMemoryUsage<cr>", "Show Clangd memory usage" },
		},
	}, { mode = "n", prefix = "\\", buffer = bufnr })
	common.which_key_register({
		l = {
			name = "Docs / LSP",
			A = { "<cmd>ClangdAST<cr>", "Show Clangd AST" },
		},
	}, { mode = "x", prefix = "\\", buffer = bufnr })
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserClangdKeymaps", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "clangd" then
			register_clangd_keymaps(args.buf)
		end
	end,
})
