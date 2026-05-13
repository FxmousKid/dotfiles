local M = {}

M.personal_leader = "\\"
M.keymap_opts = { noremap = true, silent = true }

function M.which_key_register(mappings, opts)
	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.register(mappings, opts)
	end
end

function M.load_plugin(name)
	local ok, lazy = pcall(require, "lazy")
	if ok then
		pcall(lazy.load, { plugins = { name } })
	end
end

return M
