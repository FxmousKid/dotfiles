local common = require("keymaps.common")

local function register_java_keymaps(bufnr)
	common.which_key_register({
		C = {
			name = "Java",
			o = { "<cmd>lua require'jdtls'.organize_imports()<cr>", "Organize Imports" },
			v = { "<cmd>lua require('jdtls').extract_variable()<cr>", "Extract Variable" },
			c = { "<cmd>lua require('jdtls').extract_constant()<cr>", "Extract Constant" },
			t = { "<cmd>lua require'jdtls'.test_nearest_method()<cr>", "Test Method" },
			T = { "<cmd>lua require'jdtls'.test_class()<cr>", "Test Class" },
			u = { "<cmd>JdtUpdateConfig<cr>", "Update Config" },
		},
	}, { mode = "n", prefix = "\\", buffer = bufnr, silent = true, noremap = true, nowait = true })

	common.which_key_register({
		C = {
			name = "Java",
			v = { "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", "Extract Variable" },
			c = { "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", "Extract Constant" },
			m = { "<esc><cmd>lua require('jdtls').extract_method(true)<cr>", "Extract Method" },
		},
	}, { mode = "v", prefix = "\\", buffer = bufnr, silent = true, noremap = true, nowait = true })
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserJavaKeymaps", { clear = true }),
	pattern = "java",
	callback = function(args)
		register_java_keymaps(args.buf)
	end,
})
