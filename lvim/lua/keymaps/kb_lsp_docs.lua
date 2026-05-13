local common = require("keymaps.common")
local leader = common.personal_leader

vim.keymap.set({ "n", "i" }, leader .. "l", function() vim.cmd.DocsViewToggle() end,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Show Documentation" }))
vim.keymap.set({ "n", "i" }, leader .. "ld", function() vim.cmd.DocsViewToggle() end,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Show Documentation" }))
vim.keymap.set({ "n", "i" }, leader .. "ls", "<cmd>LspStop<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Stop LSP" }))

common.which_key_register({
	l = {
		name = "Docs / LSP",
		d = { "<cmd>DocsViewToggle<cr>", "Show Documentation" },
		s = { "<cmd>LspStop<cr>", "Stop LSP" },
	},
}, { mode = "n", prefix = leader })

common.which_key_register({
	l = {
		name = "Docs / LSP",
		d = { "<cmd>DocsViewToggle<cr>", "Show Documentation" },
		s = { "<cmd>LspStop<cr>", "Stop LSP" },
	},
}, { mode = "i", prefix = leader })
