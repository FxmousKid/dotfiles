lvim.builtin.comment.opleader = {
  line = "gc",
  block = "gb",
}


local keymap_opts = { noremap = true, silent = true }

vim.keymap.set('n', 'gv', '<C-]>', {table.unpack(keymap_opts), desc="Go to immediate definition"})
vim.keymap.set('n', 'gV', '<C-W>v<C-]>', {table.unpack(keymap_opts), desc="Go to definition in vertical split"})
vim.keymap.set('n', 'gS', '<C-W>s<C-]>', {table.unpack(keymap_opts), desc="Go to definition in horizontal split"})

vim.keymap.set({'n','i'}, '<leader>l', function() vim.cmd.DocsViewToggle() end, {table.unpack(keymap_opts), desc="Show Documentation"})
vim.keymap.set({'n','i'}, '<leader>p', function() vim.cmd.noh() end, {table.unpack(keymap_opts), desc="Clear Search Highlight"})
vim.keymap.set({'n','i'}, '<leader>-', function() vim.cmd.MarkdownPreviewToggle() end, {table.unpack(keymap_opts), desc="Toggle Markdown Preview"})
