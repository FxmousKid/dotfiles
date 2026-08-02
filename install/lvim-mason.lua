-- Install the language servers explicitly configured by this repository.
-- LunarVim's own automatic installer races Mason's first registry refresh, so
-- config.lua disables that path and this script performs one synchronous,
-- bounded install after Lazy has finished setting up the editor.

local package_names = {
  "pyright",
  "bash-language-server",
  "lua-language-server",
  "jdtls",
  "kotlin-language-server",
}

local lazy_ok, lazy = pcall(require, "lazy")
assert(lazy_ok, "lazy.nvim is unavailable")
lazy.load({ plugins = { "mason.nvim", "mason-lspconfig.nvim" } })

local registry = require("mason-registry")
local finished = false
local pending = 0
local failures = {}

registry.refresh(function()
  for _, name in ipairs(package_names) do
    local found, package = pcall(registry.get_package, name)
    if not found then
      table.insert(failures, name .. " (not in registry)")
    elseif not package:is_installed() then
      pending = pending + 1
      package:install():once("closed", function()
        if not package:is_installed() then
          table.insert(failures, name .. " (install failed)")
        end
        pending = pending - 1
        if pending == 0 then
          finished = true
        end
      end)
    end
  end
  if pending == 0 then
    finished = true
  end
end)

local completed = vim.wait(600000, function()
  return finished
end, 100)

assert(completed, "timed out installing Mason packages")
assert(#failures == 0, "Mason failures: " .. table.concat(failures, ", "))

for _, name in ipairs(package_names) do
  assert(registry.is_installed(name), name .. " did not verify as installed")
  print("Mason verified: " .. name)
end
