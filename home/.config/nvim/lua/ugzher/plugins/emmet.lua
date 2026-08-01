return {
	"olrtg/nvim-emmet",
	config = function()
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ce",
			require("nvim-emmet").wrap_with_abbreviation,
			{ desc = "Entourer avec une abréviation Emmet" }
		)
	end,
}
