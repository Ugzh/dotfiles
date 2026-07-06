return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				background = { light = "frappe", dark = "mocha" },
				transparent_background = true,
				term_colors = true,
				integrations = {
					treesitter = true,
					native_lsp = {
						enabled = true,
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
					},
					gitsigns = true,
					telescope = true,
					lualine = true,
					mini = true,
				},
			})
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "catppuccin",
				callback = function()
					vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
					vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
				end,
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
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function() end,
	},
}
