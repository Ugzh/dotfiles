return {
	"mbbill/undotree",
	cmd = "UndotreeToggle",
	init = function()
		vim.g.undotree_SetFocusWhenToggle = 1
	end,
	keys = {
		{ "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Historique des modifications" },
	},
}
