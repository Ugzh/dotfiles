return {
	{
		"kevinhwang91/nvim-ufo",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"kevinhwang91/promise-async",
		},
		config = function()
			require("ufo").setup({
				provider_selector = function(_, _, _)
					return { "treesitter", "indent" }
				end,
				open_fold_hl_timeout = 0,
			})

			vim.o.foldenable = true
			vim.o.foldcolumn = "0"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99

			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Ouvrir tous les replis" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Fermer tous les replis" })
		end,
	},
}
