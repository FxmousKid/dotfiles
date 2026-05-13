lvim.plugins = {
	{ "github/copilot.vim" },
	-- {	"pocco81/auto-save.nvim" },
	{ "fxmouskid/codesnap.nvim", build = "make build_generator" },
	{ "p00f/clangd_extensions.nvim" },
	{ "Djancyp/better-comments.nvim" },
	{ "mg979/vim-visual-multi" },
	{ "mfussenegger/nvim-jdtls" },
	{ "j-hui/fidget.nvim" }, -- Better Notifications
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

	-- Better Navigation
	-- {
	-- 	"folke/flash.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {},
	-- 	-- stylua: ignore
	-- 	keys = {
	-- 		{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
	-- 		{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
	-- 		{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
	-- 		{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
	-- 		{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
	-- 	},
	-- },

	-- Color Themes
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true
	},
	{
		'sainnhe/gruvbox-material',
		lazy = false,
		priority = 1000,
		config = function()
			-- Optionally configure and load the colorscheme
			-- directly inside the plugin declaration.
			vim.g.gruvbox_material_enable_italic = true
			vim.cmd.colorscheme('gruvbox-material')
		end
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

	-- {
	-- 	"mfussenegger/nvim-dap",
	-- 	lazy = true,
	-- 	dependencies = {
	-- 		"rcarriga/nvim-dap-ui",
	-- 	},
	-- 	enabled = lvim.builtin.dap.active,

	-- 	config = function()
	-- 		require("lvim.core.dap").setup()
	-- 		local dap = require("lvim.core.dap")
	-- 		local dapui = require("dapui")
	-- 		dap.listeners.before.attach.dapui_config = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.launch.dapui_config = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.event_terminated.dapui_config = function()
	-- 			dapui.close()
	-- 		end
	-- 		dap.listeners.before.event_exited.dapui_config = function()
	-- 			dapui.close()
	-- 		end

	-- 		vim.keymap.set('n', '<Leader>dt', dap.toggle_breakpoint, {})
	-- 		vim.keymap.set('n', "<leader>dc", dap.continue, {})
	-- 	end,
	-- },

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
		"fxmouskid/uparis-header.nvim",
		lazy = false,
		config = function()
			local header = require("uparis-header")
			header.setup({
				user = "Iyan Nazarian",
				mail = "iyan.nazarian@etu.u-paris.fr",
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




	-- NEEDS NVIM > 11.0 BUT NVIM > 11.0 Breaks Treesitter (at least in lvim stable)
	-- {
	-- 	"olimorris/codecompanion.nvim",
	-- 	opts = {},
	-- 	dependencie = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- },


	--{
	-- 	"neovim/nvim-lspconfig",
	-- 	opts = {
	-- 	servers = {
	-- 	  -- Ensure mason installs the server
	-- 	  clangd = {
	-- 		keys = {
	-- 		  { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
	-- 		},
	-- 		root_dir = function(fname)
	-- 		  return require("lspconfig.util").root_pattern(
	-- 			"Makefile",
	-- 			"configure.ac",
	-- 			"configure.in",
	-- 			"config.h.in",
	-- 			"meson.build",
	-- 			"meson_options.txt",
	-- 			"build.ninja"
	-- 		  )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
	-- 			fname
	-- 		  ) or require("lspconfig.util").find_git_ancestor(fname)
	-- 		end,
	-- 		capabilities = {
	-- 		  offsetEncoding = { "utf-16" },
	-- 		},
	-- 		cmd = {
	-- 		  "clangd",
	-- 		  "--background-index",
	-- 		  "--clang-tidy",
	-- 		  "--header-insertion=iwyu",
	-- 		  "--completion-style=detailed",
	-- 		  "--function-arg-placeholders",
	-- 		  "--fallback-style=llvm",
	-- 		},
	-- 		init_options = {
	-- 		  usePlaceholders = true,
	-- 		  completeUnimported = true,
	-- 		  clangdFileStatus = true,
	-- 		},
	-- 	  },
	-- 	},
	-- 	setup = {
	-- 	  clangd = function(_, opts)
	-- 		local clangd_ext_opts = lvim.opts("clangd_extensions.nvim")
	-- 		require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
	-- 		return false
	-- 	  end,
	-- 	},
	--   },
	-- }
	--  }
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
