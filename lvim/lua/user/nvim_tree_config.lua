require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive"
	},
	view = {
		width = 20
	},
	renderer = {
		group_empty = true
	},
	filters = {
		dotfiles = true
	}
})
