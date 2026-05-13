local cscope_prefix = "\\c"

require("cscope_maps").setup({

	-- maps related defaults
	disable_maps = true, -- keymaps live in lua/keymaps/kb_cscope.lua
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
			keymap = false, -- keymap lives in lua/keymaps/kb_navigation.lua
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
