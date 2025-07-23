lvim.plugins = {
	{ "github/copilot.vim" },
	-- {	"pocco81/auto-save.nvim" },
	{ "Djancyp/better-comments.nvim" },
	{ "mg979/vim-visual-multi" },
	{ "mfussenegger/nvim-jdtls" },
	{ "j-hui/fidget.nvim" },


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
        'brianhuster/live-preview.nvim',
        dependencies = {
            --'brianhuster/autosave.nvim',  -- Not required, but recomended for autosaving and sync scrolling
            'nvim-telescope/telescope.nvim' -- Not required, but recommended for integrating with Telescope
        },
        opts = {


			commands = {
				start = 'LivePreview', -- Command to start the live preview server and open the default browser.
				stop = 'StopPreview', -- Command to stop the live preview. 
			},
			port = 5500, -- Port to run the live preview server on.
			autokill = false, -- If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
			browser = 'default', -- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
			dynamic_root = false, -- If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:lua print(vim.uv.cwd())`).
			sync_scroll = false, -- If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
			telescope = {
				true, -- If true, the plugin will automatically load the `Telescope livepreview` extension.
			},
		},
	},

	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set({ "n", "v" }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
		end,
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
		"shortcuts/no-neck-pain.nvim",
		version = "*"
	},

	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim"
		}
	},

	{
		"echasnovski/mini.surround",
		version = false
	},

	{
		"MunifTanjim/nui.nvim",
		lazy = false
	},

	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			"rcarriga/nvim-dap-ui",
		},
		enabled = lvim.builtin.dap.active,

		config = function()
			require("lvim.core.dap").setup()
			local dap = require("lvim.core.dap")
			local dapui = require("dapui")
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.keymap.set('n', '<Leader>dt', dap.toggle_breakpoint, {})
			vim.keymap.set('n', "<leader>dc", dap.continue, {})
		end,
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
		events = "VeryLazy",
		opts = {
			lsp = {
				signature = {
					auto_open = {
						-- automaticall show signature help when typing a trigger character from the LSP
						typeitrigger = false,
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
		keys = { "<leader>mpt" },
		opts = {
			-- config goes here
		},
		config = function(_, opts)
			local gpreview = require("github-preview")
			gpreview.setup(opts)

			local fns = gpreview.fns
			vim.keymap.set("n", "<leader>mpt", fns.toggle)
			vim.keymap.set("n", "<leader>mps", fns.single_file_toggle)
			vim.keymap.set("n", "<leader>mpd", fns.details_tags_toggle)
		end,
	},


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
