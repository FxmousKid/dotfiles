vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright", "ruff", "ruff_lsp" })

local opts = require("lvim.lsp").get_common_opts()

opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
	python = {
		analysis = {
			diagnosticSeverityOverrides = {
				reportUnusedClass = "none",
				reportUnusedFunction = "none",
				reportUnusedImport = "none",
				reportUnusedParameter = "none",
				reportUnusedVariable = "none",
			},
		},
	},
})

local function filter_pyright_unused_diagnostics(diagnostics)
	local filtered = {}

	for _, diagnostic in ipairs(diagnostics) do
		local message = diagnostic.message or ""
		local is_unused = message:match("is not accessed")
			or message:match("is assigned to but never used")
			or message:match("imported but unused")

		if not is_unused then
			table.insert(filtered, diagnostic)
		end
	end

	return filtered
end

if not vim.g.python_unused_diagnostics_filter_enabled then
	vim.g.python_unused_diagnostics_filter_enabled = true

	local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
	vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
		if result and result.uri then
			local bufnr = vim.uri_to_bufnr(result.uri)
			local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)

			if client and client.name == "pyright" and vim.bo[bufnr].filetype == "python" then
				result.diagnostics = filter_pyright_unused_diagnostics(result.diagnostics or {})
			end
		end

		return publish_diagnostics(err, result, ctx, config)
	end
end

require("lvim.lsp.manager").setup("pyright", opts)
