local common = require("keymaps.common")
local leader = common.personal_leader

vim.keymap.set("n", leader .. "hx", ":%!xxd<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Convert to Hex" }))
vim.keymap.set("n", leader .. "hX", ":%!xxd -r<cr>",
	vim.tbl_extend("force", common.keymap_opts, { desc = "Convert from Hex" }))

common.which_key_register({
	h = {
		name = "Hex",
		x = { ":%!xxd<cr>", "Convert to Hex" },
		X = { ":%!xxd -r<cr>", "Convert from Hex" },
	},
}, { mode = "n", prefix = leader })
