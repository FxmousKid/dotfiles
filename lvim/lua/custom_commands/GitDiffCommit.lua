-- Global base commit
_G.git_base_commit = nil

local function git_set_base(commit)
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not root or root == "" then
    print("Not inside a git repository")
    return
  end

  _G.git_base_commit = commit

  -- List files changed between commit and HEAD
  local cmd = string.format(
    "git -C %s diff --name-only %s HEAD",
    vim.fn.shellescape(root),
    commit
  )
  local files = vim.fn.systemlist(cmd)

  local qf_items = {}
  for _, f in ipairs(files) do
    if f ~= "" then
      table.insert(qf_items, {
        filename = root .. "/" .. f,
        lnum = 1,
        col = 1,
        text = "changed in " .. commit,
      })
    end
  end

  if #qf_items == 0 then
    print("No files changed between " .. commit .. " and HEAD")
    return
  end

  vim.fn.setqflist(qf_items, "r")
  vim.cmd("copen")
end

vim.api.nvim_create_user_command("GitSetBase", function(opts)
  git_set_base(opts.args)
end, { nargs = 1 })



local function diff_against_base()
  local commit = _G.git_base_commit
  if not commit then
    print("Base commit not set. Run :GitSetBase <commit> first.")
    return
  end

  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    print("Current buffer has no file name")
    return
  end

  -- Save the current window as the LEFT (real file)
  local left_win = vim.api.nvim_get_current_win()
  local left_buf = vim.api.nvim_get_current_buf()

  -- Find repo root
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not root or root == "" then
    print("Not inside a git repository")
    return
  end

  -- Path relative to repo root for git show
  local relpath
  if filepath:sub(1, #root) == root then
    relpath = filepath:sub(#root + 2) -- strip "/root/"
  else
    relpath = vim.fn.fnamemodify(filepath, ":.")
  end

  -- Create right split for old version
  vim.cmd("vsplit")
  local right_win = vim.api.nvim_get_current_win()
  vim.cmd("enew")
  local right_buf = vim.api.nvim_get_current_buf()

  -- Make right buffer scratch-like
  vim.bo[right_buf].buftype  = "nofile"
  vim.bo[right_buf].bufhidden = "wipe"
  vim.bo[right_buf].swapfile = false
  vim.bo[right_buf].modifiable = true
  vim.bo[right_buf].buflisted = false    -- 👈 hide from :ls / bufferline

  -- Give it a nicer name instead of [No Name] (optional)
  local short_commit = commit:sub(1, 7)
  local scratch_name = string.format("%s (%s)", relpath, short_commit)
  vim.api.nvim_buf_set_name(right_buf, scratch_name)

  -- Get file contents from the commit
  local show_cmd = string.format("git show %s:%s", commit, relpath)
  local lines = vim.fn.systemlist(show_cmd)

  if #lines == 1 and lines[1]:match("^fatal:") then
    vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, { "Error: " .. lines[1] })
  else
    vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, lines)
  end

  vim.bo[right_buf].modifiable = false
  vim.bo[right_buf].filetype = vim.bo[left_buf].filetype
  -- Turn OFF any old diffs just in these two windows
  for _, win in ipairs({ left_win, right_win }) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      pcall(vim.cmd, "diffoff!")
    end
  end

  -- Enable diff only for left & right
  for _, win in ipairs({ left_win, right_win }) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      vim.cmd("diffthis")
    end
  end

  -- Optional: return cursor to left window
  if vim.api.nvim_win_is_valid(left_win) then
    vim.api.nvim_set_current_win(left_win)
  end
end

vim.api.nvim_create_user_command("DiffBase", function()
  diff_against_base()
end, {})


vim.keymap.set("n", "<leader>gd", ":DiffBase<CR>", { silent = true, noremap = true })
