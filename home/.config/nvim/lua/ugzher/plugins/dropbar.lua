return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dropbar").setup()
		local dropbar = require("dropbar.api")
		vim.keymap.set("n", "<leader>;", dropbar.pick, { desc = "Choisir un symbole dans le fil d'Ariane" })
		vim.keymap.set("n", "[;", dropbar.goto_context_start, { desc = "Début du contexte courant" })
		vim.keymap.set("n", "];", dropbar.select_next_context, { desc = "Contexte suivant" })
	end,
}
