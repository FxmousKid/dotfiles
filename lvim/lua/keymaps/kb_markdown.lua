local common = require("keymaps.common")
local leader = common.personal_leader

local function github_preview()
	common.load_plugin("github-preview.nvim")
	return require("github-preview")
end

local function github_preview_toggle()
	github_preview().fns.toggle()
end

local function github_preview_running_action(action)
	return function()
		common.load_plugin("github-preview.nvim")
		local utils = require("github-preview.utils")
		if utils.get_client_channel() == nil then
			vim.notify("Start GitHub preview with \\mpt first", vim.log.levels.WARN)
			return
		end
		require("github-preview").fns[action]()
	end
end

vim.keymap.set({ "n", "i" }, leader .. "p", function() vim.cmd.noh() end,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Clear Search Highlight" }))
vim.keymap.set({ "n", "i" }, leader .. "-", function() vim.cmd.MarkdownPreviewToggle() end,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Toggle Markdown Preview" }))
vim.keymap.set("n", leader .. "mpt", github_preview_toggle,
	vim.tbl_extend("force", common.keymap_opts, { desc = "Toggle GitHub preview" }))
vim.keymap.set("n", leader .. "mps", github_preview_running_action("single_file_toggle"),
	vim.tbl_extend("force", common.keymap_opts, { desc = "Toggle single-file preview" }))
vim.keymap.set("n", leader .. "mpd", github_preview_running_action("details_tags_toggle"),
	vim.tbl_extend("force", common.keymap_opts, { desc = "Toggle details tags" }))

common.which_key_register({
	m = {
		name = "Markdown",
		p = {
			name = "GitHub Preview",
			t = { github_preview_toggle, "Toggle GitHub preview" },
			s = { github_preview_running_action("single_file_toggle"), "Toggle single-file preview" },
			d = { github_preview_running_action("details_tags_toggle"), "Toggle details tags" },
		},
	},
	["-"] = { "<cmd>MarkdownPreviewToggle<cr>", "Toggle Markdown Preview" },
	p = { "<cmd>noh<cr>", "Clear Search Highlight" },
}, { mode = "n", prefix = leader })

common.which_key_register({
	["-"] = { "<cmd>MarkdownPreviewToggle<cr>", "Toggle Markdown Preview" },
	p = { "<cmd>noh<cr>", "Clear Search Highlight" },
}, { mode = "i", prefix = leader })
