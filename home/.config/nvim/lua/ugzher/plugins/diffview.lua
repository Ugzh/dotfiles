return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewToggleFiles",
	},
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Voir les modifications Git" },
		{ "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Historique Git du fichier" },
	},
}
