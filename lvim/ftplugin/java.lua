vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

local status, jdtls = pcall(require, "jdtls")
if not status then
  return
end

local home = os.getenv "HOME"
local workspace_path = home .. "/.local/share/lunarvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

-- Detect installed JDKs (SDKMAN) instead of hardcoding versions.
-- When empty, jdtls just uses the JDK that launches it.
local function detect_runtimes()
  local runtimes = {}
  local java_dir = (os.getenv("SDKMAN_DIR") or (home .. "/.sdkman")) .. "/candidates/java"
  for _, dir in ipairs(vim.fn.glob(java_dir .. "/*", true, true)) do
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(runtimes, { name = "JavaSE-" .. vim.fn.fnamemodify(dir, ":t"), path = dir })
    end
  end
  return runtimes
end

local capabilities = require("lvim.lsp").common_capabilities()
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
local bundles = vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar", true, true)
local debug_bundles = vim.fn.glob(
  mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
  true,
  true
)
vim.list_extend(bundles, debug_bundles)

local os_config = "linux"
if vim.fn.has "mac" == 1 then
  os_config = "mac"
end

lvim.builtin.dap.active = true
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=false",
    "-Dlog.level=ERROR",
    "-Xms1g",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. mason_path .. "packages/jdtls/lombok.jar",
    "-jar",
    vim.fn.glob(mason_path .. "packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    mason_path .. "packages/jdtls/config_" .. os_config,
    "-data",
    workspace_dir,
  },
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
  capabilities = capabilities,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = detect_runtimes(),
      },
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = true,
      },
    },
    signatureHelp = { enabled = true },
    extendedClientCapabilities = extendedClientCapabilities,
  },
  init_options = {
    bundles = bundles,
  },
}

config["on_attach"] = function(client, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)
  require("lvim.lsp").common_on_attach(client, bufnr)
  -- DAP is optional. Calling these helpers without Mason's Java debug adapter
  -- emits a startup error even though jdtls itself is healthy.
  if #debug_bundles > 0 then
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
    local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
    if status_ok then
      jdtls_dap.setup_dap_main_class_configs()
    end
  end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.java" },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

require("jdtls").start_or_attach(config)
