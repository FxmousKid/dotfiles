
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- local group = vim.api.nvim_create_augroup("RememberFolds", {clear = true})
-- vim.api.nvim_create_autocmd("BufWinEnter", {command = "mkview 1", group = group})
-- vim.api.nvim_create_autocmd("BufWinLeave", {command = "loadview 1", group = group})

-- reload('user.config')

-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = "css,eruby,html,htmldjango,javascriptreact,less,pug,sass,scss,typescriptreact",
--   callback = function()
--     vim.lsp.start({
--       cmd = { "emmet-language-server", "--stdio" },
--       root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
--       -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
--       -- **Note:** only the options listed in the table are supported.
--       init_options = {
--         ---@type table<string, string>
--         includeLanguages = {},
--         --- @type string[]
--         excludeLanguages = {},
--         --- @type string[]
--         extensionsPath = {},
--         --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
--         preferences = {},
--         --- @type boolean Defaults to `true`
--         showAbbreviationSuggestions = true,
--         --- @type "always" | "never" Defaults to `"always"`
--         showExpandedAbbreviation = "always",
--         --- @type boolean Defaults to `false`
--         showSuggestionsAsSnippets = false,
--         --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
--         syntaxProfiles = {},
--         --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
--         variables = {},
--       },
--     })
--   end,
-- })

reload('options')
require('keybinds')
reload('plugins')
