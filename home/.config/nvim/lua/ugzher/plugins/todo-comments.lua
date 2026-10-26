return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {},
	keys = {
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Commentaire TODO suivant",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Commentaire TODO précédent",
		},
		{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODO du projet" },
	},
}
