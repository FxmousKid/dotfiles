-- lvim.builtin.nvimtree.on_config_done = function()
-- 	require("nvim-tree").setup({})
-- end

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too

-- ADD A FLOATING WINDOW FOR nvim-tree
lvim.builtin.nvimtree.setup.view = {
	float = {
		enable = true,
		open_win_config = function()
			local screen_w = vim.opt.columns:get()
			local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
			local window_w = screen_w * WIDTH_RATIO
			local window_h = screen_h * HEIGHT_RATIO
			local window_w_int = math.floor(window_w)
			local window_h_int = math.floor(window_h)
			local center_x = (screen_w - window_w) / 2
			local center_y = ((vim.opt.lines:get() - window_h) / 2)
				- vim.opt.cmdheight:get()
			return {
				border = 'rounded',
				relative = 'editor',
				row = center_y,
				col = center_x,
				width = window_w_int,
				height = window_h_int,
			}
		end,
	},
	width = function()
		return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
	end,
}


lvim.builtin.nvimtree.setup.filters = {
	dotfiles = true,
}


-- ALL THE BELOW CODE IS FOR RESIZING FLOATING THE ABOVE WINDOW WINDOW
local api = require("nvim-tree.api")

vim.api.nvim_create_augroup("NvimTreeResize", {
	clear = true,
})

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
	group = "NvimTreeResize",
	callback = function()
		-- Get the nvim-tree window ID
		local winid = api.tree.winid()
		if (winid) then
			api.tree.reload()
		end
	end
})
