return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },

	opts = {
		ensure_installed = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"go",
			"yaml",
			"html",
			"css",
			"scss",
			"python",
			"http",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"kubernetes",
			"c++",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"java",
			"rust",
			"ron",
			"angular",
		},

		highlight = {
			enable = true,
		},

		indent = {
			enable = true,
		},
	},
}
