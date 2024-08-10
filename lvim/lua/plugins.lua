lvim.plugins = {

	{	"github/copilot.vim" },
	{	"pocco81/auto-save.nvim" },
	{	"Djancyp/better-comments.nvim" },
	{	"mg979/vim-visual-multi" },
	{	"mfussenegger/nvim-jdtls"},
	{	"j-hui/fidget.nvim" },


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
	},


}

