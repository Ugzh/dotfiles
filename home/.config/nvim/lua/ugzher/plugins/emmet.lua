return {
	"olrtg/nvim-emmet",
	keys = {
		{
			"<leader>ce",
			function()
				require("nvim-emmet").wrap_with_abbreviation()
			end,
			mode = { "n", "v" },
			desc = "Entourer avec une abréviation Emmet",
		},
	},
}
