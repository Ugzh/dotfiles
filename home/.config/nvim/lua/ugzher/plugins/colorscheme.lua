local active_theme = require("generated-theme")

return {
	"catppuccin/nvim",
	name = "catppuccin",
	dependencies = {
		{
			"nyoom-engineering/oxocarbon.nvim",
			cond = active_theme.name == "oxocarbon" or active_theme.name == "oxocarbon-light",
		},
		{ "savq/melange-nvim", cond = active_theme.name == "melange-dark" },
		{ "Aejkatappaja/sora", cond = active_theme.name == "platinum-night" },
	},
	priority = 1001,
	lazy = false,
	config = function()
		require("ugzher.core.theme-preview").apply(active_theme)
	end,
}
