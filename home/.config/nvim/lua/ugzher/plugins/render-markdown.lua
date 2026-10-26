return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim", "nvim-tree/nvim-web-devicons" },
	---@module 'render-markdown'
	opts = {
		checkbox = {
			unchecked = { icon = "☐ " },
			checked = { icon = "☑ " },
		},
		latex = { enabled = false },
	},
}
