  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.tex",
    callback = function()
      if vim.fn.exists("*vimtex#compiler#is_running") == 0 then return end
      if vim.fn["vimtex#compiler#is_running"]() == 1 then
        vim.cmd("VimtexView")
      end
    end,
  })
