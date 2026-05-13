local common = require("keymaps.common")
local leader = common.personal_leader

local function qf_close_if_open()
	for _, w in ipairs(vim.fn.getwininfo()) do
		if w.quickfix == 1 then
			vim.cmd.cclose()
			return
		end
	end
end

local function next_reviewed_qf_diff()
	local info = vim.fn.getqflist({ winid = 0 })
	local qf_win = info.winid or 0

	if qf_win == 0 or not vim.api.nvim_win_is_valid(qf_win) then
		print("No quickfix window open")
		return
	end

	vim.api.nvim_set_current_win(qf_win)
	pcall(vim.cmd, "only")
	pcall(vim.cmd, "QfDelete")

	local qf = vim.fn.getqflist()
	if #qf == 0 then
		print("Quickfix list is empty")
		return
	end

	vim.cmd("cc")
	pcall(vim.cmd, "DiffBase")

	local qf_win2 = vim.fn.getqflist({ winid = 0 }).winid or 0
	if qf_win2 ~= 0 and vim.api.nvim_win_is_valid(qf_win2) then
		vim.api.nvim_win_set_height(qf_win2, 1)
	end
end

vim.keymap.set("n", leader .. "s", function()
	vim.cmd.update()
	pcall(vim.cmd.cnext)
	qf_close_if_open()
end, { silent = true, desc = "Update, cnext, hide quickfix" })

vim.keymap.set("n", leader .. "x", function()
	vim.cmd.write()
	vim.cmd.bdelete()
	pcall(vim.cmd.cnext)
	qf_close_if_open()
end, { silent = true, desc = "Write, bdelete, cnext, hide quickfix" })

vim.keymap.set("n", leader .. "gd", "<cmd>DiffBase<cr>",
	{ silent = true, noremap = true, desc = "Diff against base commit" })
vim.keymap.set("n", leader .. "gg", next_reviewed_qf_diff,
	{ silent = true, noremap = true, desc = "Next reviewed quickfix diff" })

common.which_key_register({
	g = {
		name = "Git / Diff",
		d = { "<cmd>DiffBase<cr>", "Diff against base commit" },
		g = { next_reviewed_qf_diff, "Next reviewed quickfix diff" },
	},
	s = { "Update, cnext, hide quickfix" },
	x = { "Write, bdelete, cnext, hide quickfix" },
}, { mode = "n", prefix = leader })
