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
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function() vim.fn["mkdp#util#install"]() end,
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
					dictionary = "asfghl;wertyuiop",
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
