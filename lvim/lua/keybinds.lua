lvim.builtin.comment.opleader = {
  line = "gc",
  block = "gb",
}


local keymap_opts = { noremap = true, silent = true }

-- Keymap for file navigation
-- To keep the cursor in the middle of the screen
vim.keymap.set('n', '<C-d>', '<C-d>zz', {table.unpack(keymap_opts), desc="Scroll Down"})
vim.keymap.set('n', '<C-u>', '<C-u>zz', {table.unpack(keymap_opts), desc="Scroll Up"})
vim.keymap.set('n', '<C-b>', '<C-b>zz', {table.unpack(keymap_opts), desc="Page Up"})
vim.keymap.set('n', '<C-f>', '<C-f>zz', {table.unpack(keymap_opts), desc="Page Down"})

-- Keymap for definition navigating
vim.keymap.set('n', 'gv', '<C-]>', {table.unpack(keymap_opts), desc="Go to immediate definition"})
vim.keymap.set('n', 'gV', '<C-W>v<C-]>', {table.unpack(keymap_opts), desc="Go to definition in vertical split"})
vim.keymap.set('n', 'gS', '<C-W>s<C-]>', {table.unpack(keymap_opts), desc="Go to definition in horizontal split"})

-- Keymap for nice keybinds
vim.keymap.set({'n','i'}, '<leader>l', function() vim.cmd.DocsViewToggle() end, {table.unpack(keymap_opts), desc="Show Documentation"})
vim.keymap.set({'n','i'}, '<leader>p', function() vim.cmd.noh() end, {table.unpack(keymap_opts), desc="Clear Search Highlight"})
vim.keymap.set({'n','i'}, '<leader>-', function() vim.cmd.MarkdownPreviewToggle() end, {table.unpack(keymap_opts), desc="Toggle Markdown Preview"})

-- Copilot keybinds
vim.keymap.set({'n', 'i'}, '<leader>cd', ':Copilot disable<CR>', {table.unpack(keymap_opts), desc="Disable Copilot"})
vim.keymap.set({'n', 'i'}, '<leader>ce', ':Copilot enable<CR>', {table.unpack(keymap_opts), desc="Enable Copilot"})

-- todo.nvim keybind
-- vim.keymap.set('n', '<leader>t', function() vim.cmd.TodoTelescope() end, {table.unpack(keymap_opts), desc="Show Todo List in telescope"})

-- Telescope keybinds
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<Space>tf', function() telescope.find_files() end, {table.unpack(keymap_opts), desc="Find Files"})
vim.keymap.set('n', '<Space>tl', function() telescope.live_grep() end, {table.unpack(keymap_opts), desc="Live Grep"})
vim.keymap.set('n', '<Space>tg', function() telescope.git_files() end, {table.unpack(keymap_opts), desc="Git Files"})
vim.keymap.set('n', '<Space>tb', function() telescope.buffers() end, {table.unpack(keymap_opts), desc="Buffers"})
vim.keymap.set('n', '<Space>th', function() telescope.help_tags() end, {table.unpack(keymap_opts), desc="Help Tags"})
vim.keymap.set('n', '<Space>ts', function() telescope.lsp_document_symbols() end, {table.unpack(keymap_opts), desc="Document Symbols"})
vim.keymap.set('n', '<Space>tr', function() telescope.lsp_references() end, {table.unpack(keymap_opts), desc="References"})
vim.keymap.set('n', '<Space>td', function() telescope.lsp_definitions() end, {table.unpack(keymap_opts), desc="Definitions"})
vim.keymap.set('n', '<Space>ti', function() telescope.lsp_implementations() end, {table.unpack(keymap_opts), desc="Implementations"})

-- which key for telescope
local wk = require("which-key")

wk.register({
	t = {
		name = "Telescope",
		f = { "<cmd>Telescope find_files<cr>", "Find Files" },
 	   	l = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
 	   	g = { "<cmd>Telescope git_files<cr>", "Git Files" },
 	   	b = { "<cmd>Telescope buffers<cr>", "Buffers" },
 	   	h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
 	   	s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
 	   	r = { "<cmd>Telescope lsp_references<cr>", "References" },
 	   	d = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },
 	   	i = { "<cmd>Telescope lsp_implementations<cr>", "Implementations" },
 	}},
	{ prefix = "<Space>" }
)

