-- Headless smoke test for one LunarVim LSP client.
-- Usage:
--   DOTFILES_EXPECT_LSP=clangd lvim --headless file.c \
--     -c "lua dofile('install/lvim-lsp-smoke.lua')"

local expected = vim.env.DOTFILES_EXPECT_LSP

local function fail(message)
  vim.api.nvim_err_writeln("LSP smoke failed: " .. message)
  vim.cmd("cquit 1")
end

if not expected or expected == "" then
  fail("DOTFILES_EXPECT_LSP is empty")
  return
end

local attached = vim.wait(120000, function()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if client.name == expected then
      return true
    end
  end
  return false
end, 100)

if not attached then
  local active = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    table.insert(active, client.name)
  end
  fail(expected .. " did not attach (active: " .. table.concat(active, ", ") .. ")")
  return
end

print("LSP attached: " .. expected)
vim.cmd("quitall!")
