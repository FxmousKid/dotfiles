local cscope_prefix = "<leader>c"

require("cscope_maps").setup({

  -- maps related defaults
	disable_maps = false, -- "true" disables default keymaps
	skip_input_prompt = false, -- "true" doesn't ask for input
	prefix = cscope_prefix, -- prefix to trigger maps

	-- cscope related defaults
	cscope = {
		-- location of cscope db file
		db_file = "./cscope.out", -- DB or table of DBs
                              -- NOTE:
                              --   when table of DBs is provided -
                              --   first DB is "primary" and others are "secondary"
                              --   primary DB is used for build and project_rooter
		-- cscope executable
		exec = "cscope", -- "cscope" or "gtags-cscope"
		-- choose your fav picker
		picker = "telescope", -- "quickfix", "location", "telescope", "fzf-lua", "mini-pick" or "snacks"
		-- qf_window_size = 5, -- deprecated, replaced by picket_opts below, but still supported for backward compatibility
		-- qf_window_pos = "bottom", -- deprecated, replaced by picket_opts below, but still supported for backward compatibility
		picker_opts = {
			window_size = 5, -- any positive integer
			window_pos = "bottom", -- "bottom", "right", "left" or "top"
			-- options for Snacks picker (---@class snacks.picker.Config)
			-- pass-through options for Snacks picker
			snacks = {}, -- snacks config
		},
		-- "true" does not open picker for single result, just JUMP
		skip_picker_for_single_result = false, -- "false" or "true"
		-- custom script can be used for db build
    	db_build_cmd = { script = "default", args = { "-bqkv" } },
    	-- statusline indicator, default is cscope executable
    	statusline_indicator = nil,
    	-- try to locate db_file in parent dir(s)
    	project_rooter = {
			enable = false, -- "true" or "false"
			-- change cwd to where db_file is located
			change_cwd = false, -- "true" or "false"
		},
		-- cstag related defaults
		tag = {
			-- bind ":Cstag" to "<C-]>"
			keymap = true, -- "true" or "false"
			-- order of operation to run for ":Cstag"
			order = { "cs", "tag_picker", "tag" }, -- any combination of these 3 (ops can be excluded)
			-- cmd to use for "tag" op in above table
			tag_cmd = "tjump",
		},
	},

  -- stack view defaults
	stack_view = {
		tree_hl = true, -- toggle tree highlighting
	}
})

local ok, wk = pcall(require, "which-key")
if ok then
	local cscope_mappings = {
		name = "Cscope",
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

	wk.register(cscope_mappings, { mode = "n", prefix = cscope_prefix })
	wk.register(cscope_mappings, { mode = "v", prefix = cscope_prefix })
end
