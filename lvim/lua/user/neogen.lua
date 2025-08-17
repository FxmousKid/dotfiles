require('neogen').setup {
  enabled = true,
  languages = {
    c = {
      template = {
	annotation_convention = "doxygen",
      },
    },
    lua = {
      template = {
	annotation_convention = "ldoc",
      },
    },
    python = {
      template = {
	annotation_convention = "google_docstrings",
      },
    },
    javascript = {
      template = {
	annotation_convention = "jsdoc",
      },
    },
    typescript = {
      template = {
	annotation_convention = "jsdoc",
      },
    },
  },
}
