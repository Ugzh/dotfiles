return {
	"mbbill/undotree",
	config = function()
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle, { desc = "Historique des modifications" })
	end,
}
