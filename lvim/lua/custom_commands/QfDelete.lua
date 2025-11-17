-- Delete the quickfix entry under the cursor
vim.api.nvim_create_user_command("QfDelete", function()
  -- Make sure we're in a quickfix window
  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  if wininfo == nil or wininfo.quickfix == 0 then
    print("Not in a quickfix window")
    return
  end

  local qf = vim.fn.getqflist()
  local lnum = vim.fn.line(".")  -- line in quickfix window

  if lnum < 1 or lnum > #qf then
    return
  end

  table.remove(qf, lnum)

  -- Rewrite list and keep cursor on a sensible entry
  vim.fn.setqflist({}, "r", { items = qf, idx = math.min(lnum, #qf) })
end, {})
