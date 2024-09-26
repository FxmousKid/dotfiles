-- Nvim navigation keymaps

local keymap_opts = { noremap = true, silent = true }
vim.keymap.set({'n','i'}, '<leader>l', function() vim.cmd.DocsViewToggle() end, {table.unpack(keymap_opts), desc="Show Documentation"})
vim.keymap.set({'n','i'}, '<leader>p', function() vim.cmd.noh() end, {table.unpack(keymap_opts), desc="Clear Search Highlight"})
vim.keymap.set({'n','i'}, '<leader>-', function() vim.cmd.MarkdownPreviewToggle() end, {table.unpack(keymap_opts), desc="Toggle Markdown Preview"})
