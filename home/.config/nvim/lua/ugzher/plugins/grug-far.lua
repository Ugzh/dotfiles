return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {},
	keys = {
		{
			"<leader>fR",
			function()
				require("grug-far").open({
					transient = true,
					visualSelectionUsage = "auto-detect",
				})
			end,
			mode = { "n", "x" },
			desc = "Rechercher et remplacer dans le projet",
		},
	},
}
