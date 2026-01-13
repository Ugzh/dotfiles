return {
	"gelguy/wilder.nvim",
	-- "nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"romgrk/fzy-lua-native",
	},
	config = function()
		local wilder = require("wilder")

		wilder.setup({ modes = { ":", "/", "?" } })

		wilder.set_option("pipeline", {
			wilder.branch(
				wilder.cmdline_pipeline({
					language = "vim",
					fuzzy = 1,
				}),
				wilder.search_pipeline()
			),
		})

		wilder.set_option("highlighter", {
			wilder.lua_fzy_highlighter(),
			wilder.lua_pcre2_highlighter(),
		})
	end,
}
