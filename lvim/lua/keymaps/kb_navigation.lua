local common = require("keymaps.common")

lvim.builtin.comment.opleader = {
	line = "gc",
	block = "gb",
}

vim.keymap.set("n", "<C-d>", "<C-d>zz",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Scroll Down" }))
vim.keymap.set("n", "<C-u>", "<C-u>zz",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Scroll Up" }))
vim.keymap.set("n", "<C-b>", "<C-b>zz",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Page Up" }))
vim.keymap.set("n", "<C-f>", "<C-f>zz",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Page Down" }))

vim.keymap.set({ "n", "v" }, "<C-]>", "<cmd>Cstag<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Cscope tag jump" }))
vim.keymap.set("n", "gd", vim.lsp.buf.definition,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Go to LSP definition" }))
vim.keymap.set("n", "gv", "<C-]>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Go to tag definition" }))
vim.keymap.set("n", "gV", "<C-W>v<C-]>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Go to tag in vertical split" }))
vim.keymap.set("n", "gS", "<C-W>s<C-]>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Go to tag in horizontal split" }))

common.which_key_register({
	d = { vim.lsp.buf.definition, "Go to LSP definition" },
	v = { "<C-]>", "Go to tag definition" },
	V = { "<C-W>v<C-]>", "Go to tag in vertical split" },
	S = { "<C-W>s<C-]>", "Go to tag in horizontal split" },
}, { mode = "n", prefix = "g" })
