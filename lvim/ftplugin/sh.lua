lvim.builtin.treesitter.ensure_installed = { "bash" }
lvim.builtin.treesitter.ensure_installed = { "sh" }
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "bashls" })


-- Avoid running twice if you open multiple sh buffers
if vim.b.did_setup_bashls then return end
vim.b.did_setup_bashls = true

local opts = require("lvim.lsp").get_common_opts()

-- ---- From your nvim-lspconfig snippet ----
opts.cmd = { "bash-language-server", "start" }
opts.settings = {
  bashIde = {
    -- Keep your env override exactly as in upstream
    globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command|.zsh|.bashrc|.bash_profile|.profile|.zshrc|.zprofile|.zlogin|.zlogout)",
  },
}
opts.filetypes = { "bash", "sh", "zsh"}
opts.single_file_support = true

-- root_dir equivalent:
-- Try lspconfig.util if available, otherwise fall back to vim.fs
local util_ok, util = pcall(require, "lspconfig.util")
if util_ok then
  opts.root_dir = util.root_pattern(".git")
else
  opts.root_dir = function(fname)
    local git = vim.fs.find(".git", { path = fname, upward = true })[1]
    return git and vim.fs.dirname(git) or vim.fn.getcwd()
  end
end
-- ------------------------------------------

require("lvim.lsp.manager").setup("bashls", opts)
