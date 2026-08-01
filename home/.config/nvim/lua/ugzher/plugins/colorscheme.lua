return {
	"scottmckendry/cyberdream.nvim",
	priority = 1001,
	lazy = false,
	config = function()
		require("ugzher.core.theme-preview").apply(require("generated-theme"))
	end,
}
