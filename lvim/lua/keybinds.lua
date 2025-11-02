lvim.builtin.comment.opleader = {
	line = "gc",
	block = "gb",
}

local keymap_opts = { noremap = true, silent = true }

local function qf_close_if_open()
  for _, w in ipairs(vim.fn.getwininfo()) do
    if w.quickfix == 1 then
      vim.cmd.cclose()
      return
    end
  end
end

-- <leader>s: save-if-modified, goto next, hide qf window if open
vim.keymap.set("n", "<leader>s", function()
  vim.cmd.update()
  pcall(vim.cmd.cnext)
  qf_close_if_open()
end, { silent = true, desc = "Update, cnext, hide quickfix" })

-- <leader>x: save, close buffer, goto next, hide qf window if open
vim.keymap.set("n", "<leader>x", function()
  vim.cmd.write()
  vim.cmd.bdelete()
  pcall(vim.cmd.cnext)
  qf_close_if_open()
end, { silent = true, desc = "Write, bdelete, cnext, hide quickfix" })

-- Keymapf for hex with xxd
vim.keymap.set('n', '<leader>hx', ':%!xxd<CR>',
	vim.tbl_extend("force", keymap_opts, { desc = "Convert to Hex" }))
vim.keymap.set('n', '<leader>hX', ':%!xxd -r<CR>',
	vim.tbl_extend("force", keymap_opts, { desc = "Convert from Hex" }))

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
vim.g.mapleader = "\\"
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
