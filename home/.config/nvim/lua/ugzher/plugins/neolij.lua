return {
	"y2w8/neolij.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{ "<C-h>", "<cmd>NeolijLeftTab<cr>", mode = { "n", "t" }, desc = "Pane/fenêtre/onglet à gauche", silent = true },
		{ "<C-j>", "<cmd>NeolijDown<cr>", mode = { "n", "t" }, desc = "Pane/fenêtre en bas" },
		{ "<C-k>", "<cmd>NeolijUp<cr>", mode = { "n", "t" }, desc = "Pane/fenêtre en haut" },
		{ "<C-l>", "<cmd>NeolijRightTab<cr>", mode = { "n", "t" }, desc = "Pane/fenêtre/onglet à droite", silent = true },
		{ "<leader>zt", "<cmd>NeolijNewTab<cr>", desc = "Nouvel onglet Zellij" },
		{ "<leader>zr", "<cmd>NeolijRenameTab<cr>", desc = "Renommer l'onglet Zellij" },
		{ "<leader>z,", "<cmd>NeolijMoveTabLeft<cr>", desc = "Déplacer l'onglet Zellij à gauche" },
		{ "<leader>z.", "<cmd>NeolijMoveTabRight<cr>", desc = "Déplacer l'onglet Zellij à droite" },
	},
}
