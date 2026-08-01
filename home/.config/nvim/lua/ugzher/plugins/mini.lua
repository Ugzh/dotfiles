return {
	"nvim-mini/mini.nvim",
	version = false,
	config = function()
		require("mini.ai").setup({ n_lines = 200 })
		require("mini.surround").setup({
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		})
	end,
}
