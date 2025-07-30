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
vim.keymap.set('n', 'gV', '<C-W>v<C-]>',
	vim.tbl_extend("force", keymap_opts, { desc = "Go to definition in vertical split" }))
vim.keymap.set('n', 'gS', '<C-W>s<C-]>',
	vim.tbl_extend("force", keymap_opts, { desc = "Go to definition in horizontal split" }))

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
