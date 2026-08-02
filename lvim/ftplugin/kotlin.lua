vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "kotlin_language_server" })

-- kotlin-language-server bundles an IntelliJ core whose JavaVersion parser
-- rejects JDK 25+ ("IllegalArgumentException: 25.0.3"), so run it on the
-- newest 21.x SDKMAN candidate regardless of the shell's default java.
local home = os.getenv "HOME"
local java_dir = (os.getenv("SDKMAN_DIR") or (home .. "/.sdkman")) .. "/candidates/java"
local jdk21
for _, dir in ipairs(vim.fn.glob(java_dir .. "/21*", true, true)) do
  if vim.fn.isdirectory(dir) == 1 then
    jdk21 = dir
  end
end

local util = require("lspconfig.util")
local opts = {
  root_dir = util.root_pattern(
    "settings.gradle",
    "settings.gradle.kts",
    "build.xml",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    ".git"
  ),
  single_file_support = true,
  init_options = {
    storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server",
  },
}
if jdk21 then
  opts.cmd_env = { JAVA_HOME = jdk21 }
end
require("lvim.lsp.manager").setup("kotlin_language_server", opts)
