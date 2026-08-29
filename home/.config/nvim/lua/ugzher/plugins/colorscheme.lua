return {
	"catppuccin/nvim",
	name = "catppuccin",
	dependencies = {
		{ "nyoom-engineering/oxocarbon.nvim", lazy = false },
		{ "savq/melange-nvim", lazy = false },
	},
	priority = 1001,
	lazy = false,
	config = function()
		require("ugzher.core.theme-preview").apply(require("generated-theme"))
	end,
}
