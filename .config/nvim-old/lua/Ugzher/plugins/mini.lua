return {
	"echasnovski/mini.surround",
	version = "*",
	config = function()
		local surround = require("mini.surround")

		surround.setup({
			-- Add custom surroundings to be used on top of builtin ones
			custom_surroundings = nil,

			-- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
			highlight_duration = 500,

			-- Module mappings. Use `''` (empty string) to disable one
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`

				suffix_last = "l", -- Suffix to search with "prev" method
				suffix_next = "n", -- Suffix to search with "next" method
			},

			-- Number of lines within which surrounding is searched
			n_lines = 20,

			-- Whether to respect selection type:
			-- - Place surroundings on separate lines in linewise mode
			-- - Place surroundings on each line in blockwise mode
			respect_selection_type = false,

			-- How to search for surrounding (first inside current line, then inside neighborhood)
			search_method = "cover",

			-- Whether to disable showing non-error feedback
			silent = false,
		})

		-- Optional: Add custom keymaps or modifications
		-- Example: Use 'gz' prefix instead of 's' if preferred
		-- vim.keymap.set({ "n", "v" }, "gza", "sa", { remap = true, desc = "Add surrounding" })
		-- vim.keymap.set("n", "gzd", "sd", { remap = true, desc = "Delete surrounding" })
		-- vim.keymap.set("n", "gzr", "sr", { remap = true, desc = "Replace surrounding" })
	end,
}
