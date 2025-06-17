lvim.colorscheme = 'lunar'
lvim.builtin.comment.opleader = {
  line = "gc",
  block = "gb",
}

local keymap_opts = { noremap = true, silent = true }

-- Keymap for file navigation
-- To keep the cursor in the middle of the screen
vim.keymap.set('n', '<C-d>', '<C-d>zz', vim.tbl_extend("force", keymap_opts, { desc = "Scroll Down" }))
vim.keymap.set('n', '<C-u>', '<C-u>zz', vim.tbl_extend("force", keymap_opts, { desc = "Scroll Up" }))
vim.keymap.set('n', '<C-b>', '<C-b>zz', vim.tbl_extend("force", keymap_opts, { desc = "Page Up" }))
vim.keymap.set('n', '<C-f>', '<C-f>zz', vim.tbl_extend("force", keymap_opts, { desc = "Page Down" }))

-- Keymap for definition navigating
vim.keymap.set('n', 'gv', '<C-]>', vim.tbl_extend("force", keymap_opts, { desc = "Go to immediate definition" }))
vim.keymap.set('n', 'gV', '<C-W>v<C-]>', vim.tbl_extend("force", keymap_opts, { desc = "Go to definition in vertical split" }))
vim.keymap.set('n', 'gS', '<C-W>s<C-]>', vim.tbl_extend("force", keymap_opts, { desc = "Go to definition in horizontal split" }))

-- Keymap for nice keybinds
vim.keymap.set({ 'n', 'i' }, '<leader>l', function() vim.cmd.DocsViewToggle() end,
  vim.tbl_extend("force", keymap_opts, { desc = "Show Documentation" }))
vim.keymap.set({ 'n', 'i' }, '<leader>p', function() vim.cmd.noh() end,
  vim.tbl_extend("force", keymap_opts, { desc = "Clear Search Highlight" }))
vim.keymap.set({ 'n', 'i' }, '<leader>-', function() vim.cmd.MarkdownPreviewToggle() end,
  vim.tbl_extend("force", keymap_opts, { desc = "Toggle Markdown Preview" }))


-- LSP keybinds
vim.keymap.set({ 'n', 'i' }, '<leader>ls', ':LspStop<CR>',
  vim.tbl_extend("force", keymap_opts, { desc = "Stop LSP" }))


-- Copilot keybinds
vim.keymap.set({ 'n', 'i' }, '<leader>cd', ':Copilot disable<CR>',
  vim.tbl_extend("force", keymap_opts, { desc = "Disable Copilot" }))
vim.keymap.set({ 'n', 'i' }, '<leader>ce', ':Copilot enable<CR>',
  vim.tbl_extend("force", keymap_opts, { desc = "Enable Copilot" }))

-- Telescope keybinds
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<Space>tf', function() telescope.find_files() end, vim.tbl_extend("force", keymap_opts, { desc = "Find Files" }))
vim.keymap.set('n', '<Space>tl', function() telescope.live_grep() end, vim.tbl_extend("force", keymap_opts, { desc = "Live Grep" }))
vim.keymap.set('n', '<Space>tg', function() telescope.git_files() end, vim.tbl_extend("force", keymap_opts, { desc = "Git Files" }))
vim.keymap.set('n', '<Space>tb', function() telescope.buffers() end,  vim.tbl_extend("force", keymap_opts, { desc = "Buffers" }))
vim.keymap.set('n', '<Space>th', function() telescope.help_tags() end, vim.tbl_extend("force", keymap_opts, { desc = "Help Tags" }))
vim.keymap.set('n', '<Space>ts', function() telescope.lsp_document_symbols() end, vim.tbl_extend("force", keymap_opts, { desc = "Document Symbols" }))
vim.keymap.set('n', '<Space>tr', function() telescope.lsp_references() end, vim.tbl_extend("force", keymap_opts, { desc = "References" }))
vim.keymap.set('n', '<Space>td', function() telescope.lsp_definitions() end, vim.tbl_extend("force", keymap_opts, { desc = "Definitions" }))
vim.keymap.set('n', '<Space>ti', function() telescope.lsp_implementations() end, vim.tbl_extend("force", keymap_opts, { desc = "Implementations" }))
-- adding Telescope projects to keybinds
vim.keymap.set('n', '<Space>tp', function() telescope.projects() end, vim.tbl_extend("force", keymap_opts, { desc = "Projects" }))

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
	p = { "<cmd>Telescope projects<cr>", "Projects" },
  }
}, { prefix = "<Space>" })

