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


vim.keymap.set("n", "<leader>gg", function()
        -- 1. Go to quickfix window
        local info = vim.fn.getqflist({ winid = 0 })
        local qf_win = info.winid or 0

        if qf_win == 0 or not vim.api.nvim_win_is_valid(qf_win) then
                print("No quickfix window open")
                return
        end

        -- Jump to quickfix and close other windows (like you manually closing diff)
        vim.api.nvim_set_current_win(qf_win)
        pcall(vim.cmd, "only")

        -- 2. Delete current quickfix entry (the one you just finished)
        pcall(vim.cmd, "QfDelete")

        -- If list is now empty, stop
        local qf = vim.fn.getqflist()
        if #qf == 0 then
                print("Quickfix list is empty")
                return
        end

        -- 3. Open current entry (same as pressing <CR> in quickfix)
        vim.cmd("cc")

        -- 4. Rebuild diff view for this file vs base commit
        pcall(vim.cmd, "DiffBase")

        -- 5. Minimize quickfix window (if it's still open)
        local info2 = vim.fn.getqflist({ winid = 0 })
        local qf_win2 = info2.winid or 0
        if qf_win2 ~= 0 and vim.api.nvim_win_is_valid(qf_win2) then
                -- make it 1 line high; tweak this number if you want a bit more
                vim.api.nvim_win_set_height(qf_win2, 1)
        end
end, { silent = true, noremap = true })

