return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")

		-- Sakura Theme Color Palette
		local colors = {
			bg = "#2B272B",
			fg = "#DDD6DD",
			pink = "#C8A8C8", -- color5 (Sakura)
			blue = "#B0A8D0", -- color4
			cyan = "#A8C8C8", -- color6
			red = "#D27D88", -- color1
			green = "#ADC8B0", -- color2
			grey = "#3A353A", -- selection_background
			darkgrey = "#2F2B2F", -- active_tab_background
		}

		local bubbles_theme = {
			normal = {
				a = { fg = colors.bg, bg = colors.pink, gui = "bold" },
				b = { fg = colors.fg, bg = colors.grey },
				c = { fg = colors.fg },
			},

			insert = { a = { fg = colors.bg, bg = colors.blue, gui = "bold" } },
			visual = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
			replace = { a = { fg = colors.bg, bg = colors.red, gui = "bold" } },
			command = { a = { fg = colors.bg, bg = colors.green, gui = "bold" } },

			inactive = {
				a = { fg = colors.fg, bg = colors.darkgrey },
				b = { fg = colors.fg, bg = colors.darkgrey },
				c = { fg = colors.fg },
			},
		}

		lualine.setup({
			options = {
				theme = bubbles_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_b = { "filename", "branch" },
				lualine_c = {
					"%=", -- Centering spacer
				},
				lualine_x = {
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = { fg = colors.red },
					},
				},
				lualine_y = { "filetype", "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		})
	end,
}
-- return {
--   "nvim-lualine/lualine.nvim",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   config = function()
--     local lualine = require("lualine")
--     local lazy_status = require("lazy.status") -- to configure lazy pending updates count
--
--     local colors = {
--       blue = "#80a0ff",
--       cyan = "#79dac8",
--       black = "#080808",
--       white = "#c6c6c6",
--       red = "#ff5189",
--       violet = "#d183e8",
--       grey = "#303030",
--     }
--
--     local bubbles_theme = {
--       normal = {
--         a = { fg = colors.black, bg = colors.violet },
--         b = { fg = colors.white, bg = colors.grey },
--         c = { fg = colors.white },
--       },
--
--       insert = { a = { fg = colors.black, bg = colors.blue } },
--       visual = { a = { fg = colors.black, bg = colors.cyan } },
--       replace = { a = { fg = colors.black, bg = colors.red } },
--
--       inactive = {
--         a = { fg = colors.white, bg = colors.black },
--         b = { fg = colors.white, bg = colors.black },
--         c = { fg = colors.white },
--       },
--     }
--
--     lualine.setup({
--       options = {
--         theme = bubbles_theme,
--         component_separators = "",
--         section_separators = { left = "", right = "" },
--       },
--       sections = {
--         lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
--         lualine_b = { "filename", "branch" },
--         lualine_c = {
--           "%=", --
--         },
--         lualine_x = {},
--         lualine_y = { "filetype", "progress" },
--         lualine_z = {
--           { "location", separator = { right = "" }, left_padding = 2 },
--         },
--       },
--       inactive_sections = {
--         lualine_a = { "filename" },
--         lualine_b = {},
--         lualine_c = {},
--         lualine_x = {},
--         lualine_y = {},
--         lualine_z = { "location" },
--       },
--       tabline = {},
--       extensions = {},
--     })
--   end,
-- }
