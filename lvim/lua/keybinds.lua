-- Nvim navigation keymaps

local keymap_opts = { noremap = true, silent = true }
vim.keymap.set({'n','i'}, '<leader>l', function() vim.cmd.DocsViewToggle() end, keymap_opts)
vim.keymap.set({'n','i'}, '<leader>p', function() vim.cmd.noh() end, keymap_opts)
