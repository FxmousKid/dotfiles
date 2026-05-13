local common = require("keymaps.common")
local keymap_opts = common.keymap_opts
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<Space>tf", function() telescope.find_files() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Find Files" }))
vim.keymap.set("n", "<Space>tl", function() telescope.live_grep() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Live Grep" }))
vim.keymap.set("n", "<Space>tg", function() telescope.git_files() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Git Files" }))
vim.keymap.set("n", "<Space>tb", function() telescope.buffers() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Buffers" }))
vim.keymap.set("n", "<Space>th", function() telescope.help_tags() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Help Tags" }))
vim.keymap.set("n", "<Space>ts", function() telescope.lsp_document_symbols() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Document Symbols" }))
vim.keymap.set("n", "<Space>tr", function() telescope.lsp_references() end,
	vim.tbl_extend("force", keymap_opts, { desc = "References" }))
vim.keymap.set("n", "<Space>td", function() telescope.lsp_definitions() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Definitions" }))
vim.keymap.set("n", "<Space>ti", function() telescope.lsp_implementations() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Implementations" }))
vim.keymap.set("n", "<Space>tp", function() telescope.projects() end,
	vim.tbl_extend("force", keymap_opts, { desc = "Projects" }))
vim.keymap.set("n", "<Space>tc", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
	vim.tbl_extend("force", keymap_opts, { desc = "File Browser" }))

common.which_key_register({
	t = {
		name = "Telescope",
		f = { "<cmd>Telescope find_files<cr>", "Find Files" },
		l = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
		g = { "<cmd>Telescope git_files<cr>", "Git Files" },
		b = { "<cmd>Telescope buffers<cr>", "Buffers" },
		h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
		s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
		r = { "<cmd>Telescope lsp_references<cr>", "References" },
		d = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },
		i = { "<cmd>Telescope lsp_implementations<cr>", "Implementations" },
		p = { "<cmd>Telescope projects<cr>", "Projects" },
		c = { "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", "File Browser" },
	}
}, { prefix = "<Space>" })
