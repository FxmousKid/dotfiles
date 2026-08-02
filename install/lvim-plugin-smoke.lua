-- Verify that Lazy finished installing the complete configured plugin graph and
-- that CodeSnap's platform-specific native generator can actually be loaded.

local config = require("lazy.core.config")
local missing = {}
local total = 0

for name, plugin in pairs(config.plugins) do
  total = total + 1
  if not plugin._.installed then
    table.insert(missing, name)
  end
end

assert(#missing == 0, "plugins not installed: " .. table.concat(missing, ", "))
assert(require("telescope").extensions.file_browser, "Telescope file_browser extension is not loaded")

local generator_ok, generator = pcall(require, "generator")
assert(generator_ok, "CodeSnap native generator failed to load: " .. tostring(generator))

print(string.format("Plugins verified: %d installed; CodeSnap native generator loaded", total))
