return {
	{
		"ellisonleao/gruvbox.nvim",
		config = function()
			require("gruvbox").setup({
				terminal_colors = true,
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = false,
					emphasis = false,
					comments = false,
					folds = false,
					operators = false,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				invert_intend_guides = false,
				inverse = true,
				contrast = "",
				palette_overrides = {},
				overrides = {
					Pmenu = { bg = "" },
				},
				dim_inactive = false,
				transparent_mode = true,
			})
		end,
	},
	{
		"cocopon/iceberg.vim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "iceberg",
				callback = function()
					vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
					vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
				end,
			})
		end,
	},
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_italic = false

			local groups = {
				Normal = { fg = "#edecee", bg = "none" },
				NormalNC = { fg = "#edecee", bg = "none" },
				CursorLine = { bg = "#1c1b22" },
				Visual = { bg = "#434C5E" },

				FloatBorder = { fg = "#edecee" },
				WinSeparator = { fg = "#21202e" },

				URL = { fg = "#61ffca", underline = true },

				SignColumn = { bg = "none" },
				Folded = { bg = "none" },
			}

			for group, opts in pairs(groups) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end,
	},
}
