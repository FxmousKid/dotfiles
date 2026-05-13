local common = require("keymaps.common")
local leader = common.personal_leader

vim.keymap.set({ "n", "i" }, leader .. "ad", "<cmd>Copilot disable<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Disable Copilot" }))
vim.keymap.set({ "n", "i" }, leader .. "ae", "<cmd>Copilot enable<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Enable Copilot" }))

common.which_key_register({
	a = {
		name = "Copilot",
		d = { "<cmd>Copilot disable<cr>", "Disable Copilot" },
		e = { "<cmd>Copilot enable<cr>", "Enable Copilot" },
	},
}, { mode = "n", prefix = leader })

common.which_key_register({
	a = {
		name = "Copilot",
		d = { "<cmd>Copilot disable<cr>", "Disable Copilot" },
		e = { "<cmd>Copilot enable<cr>", "Enable Copilot" },
	},
}, { mode = "i", prefix = leader })
