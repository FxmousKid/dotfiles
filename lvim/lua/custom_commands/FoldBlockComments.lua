vim.api.nvim_create_user_command("FoldBlockComments", function()
  local buf = 0
  vim.wo.foldmethod = "manual"
  vim.cmd.normal({ args = { "zE" }, bang = true }) -- clear existing manual folds

  local folds = {}

  -- ---------- Tree-sitter path (preferred) ----------
  local ok_parser, parser = pcall(vim.treesitter.get_parser, buf)
  if ok_parser and parser then
    local tree = parser:parse()[1]
    if tree then
      local root = tree:root()
      local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
      local query = lang and vim.treesitter.query.get(lang, "highlights") or nil
      if query then
        for id, node in query:iter_captures(root, buf, 0, -1) do
          if query.captures[id] == "comment" then
            local sr, _, er, _ = node:range()
            -- Only fold *multi-line* comments (block comments)
            if er > sr then
              table.insert(folds, { sr + 1, er + 1 }) -- 1-based lines
            end
          end
        end
      end
    end
  end

  -- ---------- Fallback using block delimiters ----------
  local function add_delim_folds(left_delim, right_delim)
    local lpat = vim.pesc(left_delim)
    local rpat = vim.pesc(right_delim)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local start = nil
    for i, line in ipairs(lines) do
      if not start then
        local s = line:find(lpat, 1, false)
        local e = s and line:find(rpat, s + #left_delim, false) or nil
        if s and not e then
          start = i
        elseif s and e and e > s then
          -- single-line /* ... */ — skip as it's not multi-line
        end
      else
        if line:find(rpat, 1, false) then
          table.insert(folds, { start, i })
          start = nil
        end
      end
    end
  end

  if #folds == 0 then
    -- Try to infer from 'commentstring' first
    local cs = vim.bo.commentstring or ""
    local left, right = cs:match("^(.*)%%s(.*)$")
    if left and right and left:match("%S") and right:match("%S") then
      add_delim_folds(vim.trim(left), vim.trim(right))
    else
      -- Common language-specific fallbacks
      local map = {
        c       = { "/*",  "*/" }, cpp     = { "/*",  "*/" }, java   = { "/*","*/" },
        javascript = { "/*","*/" }, typescript = { "/*","*/" }, css = { "/*","*/" },
        rust    = { "/*",  "*/" },
        lua     = { "--[[", "]]" },
        haskell = { "{-",  "-}" },
        ocaml   = { "(*",  "*)" },
        fsharp  = { "(*",  "*)" },
        pascal  = { "{",   "}"  },
      }
      local m = map[vim.bo.filetype]
      if m then add_delim_folds(m[1], m[2]) end
    end
  end

  -- Merge overlapping/adjacent ranges and create folds
  table.sort(folds, function(a,b) return a[1] < b[1] end)
  local merged = {}
  for _, r in ipairs(folds) do
    if #merged == 0 or r[1] > merged[#merged][2] + 1 then
      table.insert(merged, { r[1], r[2] })
    else
      if r[2] > merged[#merged][2] then merged[#merged][2] = r[2] end
    end
  end
  for _, r in ipairs(merged) do
    if r[2] > r[1] then
      vim.cmd(string.format("%d,%dfold", r[1], r[2]))
    end
  end
  vim.notify(("Folded %d block comment(s)."):format(#merged))
end, { desc = "Fold all multi-line block comments in the current buffer" })


-- vim.api.nvim_create_autocmd("BufReadPost", {
--   callback = function()
--     require("user.fold_block_comments").fold_block_comments()
--   end,
-- })
