return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Documents/obsidian",
			},
		},
		templates = {
			folder = "Templates",
			date_format = "%d-%m-%Y",
			time_format = "%H:%M",
			substitutions = {
				title = function()
					return vim.fn.expand("%:t:r")
				end,
			},
		},
		ui = {
			enable = false,
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)
		local map = vim.keymap.set
		map("n", "<leader>ti", "<cmd>ObsidianTemplate<cr>", { desc = "Insert Template" })
		map("n", "<leader>tn", "<cmd>ObsidianNewFromTemplate<cr>", { desc = "New Note from Template" })
	end,
}
