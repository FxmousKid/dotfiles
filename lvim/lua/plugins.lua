lvim.plugins = {

	{	"github/copilot.vim" },
	-- {	"pocco81/auto-save.nvim" },
	{	"Djancyp/better-comments.nvim" },
	{	"mg979/vim-visual-multi" },
	{	"mfussenegger/nvim-jdtls"},
	{	"j-hui/fidget.nvim" },

	{ "ellisonleao/gruvbox.nvim",
		priority = 1000 ,
		config = true
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
	}
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
}
