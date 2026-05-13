local common = require("keymaps.common")
local prefix = "\\c"

local maps = {
	s = { "<cmd>CsPrompt s<cr>", "Find symbol references" },
	g = { "<cmd>CsPrompt g<cr>", "Find global definition" },
	c = { "<cmd>CsPrompt c<cr>", "Find callers" },
	t = { "<cmd>CsPrompt t<cr>", "Find text string" },
	e = { "<cmd>CsPrompt e<cr>", "Egrep pattern" },
	f = { "<cmd>CsPrompt f<cr>", "Find file" },
	i = { "<cmd>CsPrompt i<cr>", "Find includers" },
	d = { "<cmd>CsPrompt d<cr>", "Find callees" },
	a = { "<cmd>CsPrompt a<cr>", "Find assignments" },
	b = { "<cmd>Cs db build<cr>", "Build database" },
}

for key, spec in pairs(maps) do
	vim.keymap.set({ "n", "v" }, prefix .. key, spec[1],
		vim.tbl_extend("force", common.keymap_opts, { desc = spec[2] }))
end

local wk_maps = vim.tbl_extend("force", { name = "Cscope" }, maps)
common.which_key_register(wk_maps, { mode = "n", prefix = prefix })
common.which_key_register(wk_maps, { mode = "v", prefix = prefix })
