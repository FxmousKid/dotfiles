lvim.plugins = {
	{ "github/copilot.vim" },
	{ "fxmouskid/codesnap.nvim", build = "make build_generator" },
	{ "p00f/clangd_extensions.nvim" },
	{ "Djancyp/better-comments.nvim" },
	{ "mg979/vim-visual-multi" },
	{ "mfussenegger/nvim-jdtls" },
	{ "j-hui/fidget.nvim" }, -- Better Notifications
	{ "windwp/nvim-ts-autotag" },
	{
		"danymat/neogen",
		-- Uncomment next line if you want to follow only stable versions
		-- version = "*"
	},


	{
		"ludovicchabant/vim-gutentags",
		init = function()
			vim.g.gutentags_modules = {"cscope_maps"} -- This is required. Other config is optional
			vim.g.gutentags_cscope_build_inverted_index_maps = 1
			vim.g.gutentags_cache_dir = (vim.env.XDG_CACHE_HOME or (vim.fn.expand("~/.cache"))) .. "/gutentags"
			-- ⚠️ WARNING: This limits tags to .c and .h files only, add more extensions (e.g., `-e py`) or remove to avoid skipping other files.
			vim.g.gutentags_file_list_command = "fd -e c -e h -e py"

			-- vim.g.gutentags_trace = 1
		end,
	},


	{
		"nosduco/remote-sshfs.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim"
		},
		opts = {
		-- Refer to the configuration section below
		-- or leave empty for defaults
		}
	},

	{
		"dhananjaylatkar/cscope_maps.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			-- "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
			-- "echasnovski/mini.pick", -- optional [for picker="mini-pick"]
			-- "folke/snacks.nvim", -- optional [for picker="snacks"]
		},
		opts = {
		-- USE EMPTY FOR DEFAULT OPTIONS
		-- DEFAULTS ARE LISTED BELOW
		},
	},

	{
		"FabijanZulj/blame.nvim",
		lazy = false,
		config = function()
			require('blame').setup {}
		end,
		opts = {
			blame_options = { '-w' },
		},
	},

	{
		"let-def/texpresso.vim",
	},

	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.tex_flavor = "latex"
			-- vim.g.vimtex_view_method = "zathura"
			-- vim.g.vimtex_view_method = "general"
			-- vim.g.vimtex_view_general_viewer = "zathura"
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_view_general_options = "@pdf"
			vim.g.vimtex_view_general_viewer = "open"
			vim.g.vimtex_view_general_options = "-a Preview @pdf"
			vim.g.vimtex_compiler_latexmk_engines = { ["_"] = "-lualatex"}
			vim.g.vimtex_compiler_method = "latexmk"
		end,
	},

	{
		"meznaric/key-analyzer.nvim",
		opts = {}
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},

	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim"
		}
	},

	{
		"MunifTanjim/nui.nvim",
		lazy = false
	},

	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		enabled = lvim.builtin.dap.active,
		config = function()
			require("lvim.core.dap").setup_ui()
		end,
	},

	{
		"Diogo-ss/42-header.nvim",
		lazy = false,
		config = function()
			local header = require("42header")
			header.setup({
				default_map = false, -- default mapping <F1> in normal mode
				auto_update = true,
			})
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				signature = {
					auto_open = {
						-- automaticall show signature help when typing a trigger character from the LSP
						trigger = true,
					},
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},

	{
		"amrbashir/nvim-docs-view",
		lazy = true,
		cmd = "DocsViewToggle",
		opts = {
			position = "top",
			height = 6,
		},
	},

	-- install without yarn or npm
	{
		"wallpants/github-preview.nvim",
		cmd = { "GithubPreviewToggle" },
		opts = {
			-- config goes here
		},
		config = function(_, opts)
			local gpreview = require("github-preview")
			gpreview.setup(opts)
		end,
	},

	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		-- For `nvim-treesitter` users.
		-- priority = 49,
		opts = {
			experimental = {
				check_rtp_message = false
			}
		}
	},

	{
		"leath-dub/snipe.nvim",

		-- Apparent fix for issue #8 i posted
		branch = "snipe2",

		keys = {
			{";;", function () require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu"}
		},
		opts = {},
		config = function()
			local snipe = require("snipe")
			snipe.setup({
				hints = {
					-- Charaters to use for hints
					-- make sure they don't collide with the navigation keymaps
					-- If you remove `j` and `k` from below, you can navigate in the plugin
					-- dictionary = "sadflewcmpghio",
					dictionary = "asdfghl;wertyuiop",
				},
				navigate = {
					-- In case you changed your mind, provide a keybind that lets you
					-- cancel the snipe and close the window.
					-- cancel_snipe = "<esc>",
					cancel_snipe = "q",

					-- Remove "j" and "k" from your dictionary to navigate easier to delete
					-- Close the buffer under the cursor
					-- NOTE: Make sure you don't use the character below on your dictionary
					-- close_buffer = "d",
				},
				-- Define the way buffers are sorted by default
				-- Can be any of "default" (sort buffers by their number) or "last" (sort buffers by last accessed)
				-- If you choose "last", it will be modifying sorting the boffers by last
				-- accessed, so the "a" will always be assigned to your latest accessed
				-- buffer
				-- If you want the letters not to change, leave the sorting at default
				sort = "default",
			})
		end,
	},
}
