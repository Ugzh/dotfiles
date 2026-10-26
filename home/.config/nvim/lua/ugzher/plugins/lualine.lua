return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local colors = require("generated-theme")
		local statusline_theme = {
			normal = {
				a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
				b = { fg = colors.bright, bg = colors.bg_highlight },
				c = { fg = colors.fg, bg = colors.bg_alt },
			},
			insert = { a = { fg = colors.bg, bg = colors.green, gui = "bold" } },
			visual = { a = { fg = colors.bg, bg = colors.accent, gui = "bold" } },
			replace = { a = { fg = colors.bg, bg = colors.red, gui = "bold" } },
			command = { a = { fg = colors.bg, bg = colors.orange, gui = "bold" } },
			terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
			inactive = {
				a = { fg = colors.fg_dim, bg = colors.bg_alt },
				b = { fg = colors.fg_dim, bg = colors.bg_alt },
				c = { fg = colors.fg_dim, bg = colors.bg_alt },
			},
		}
		local filetype_labels = {
			cpp = "cpp",
			cs = "cs",
			dockerfile = "docker",
			javascript = "js",
			javascriptreact = "jsx",
			kotlin = "kt",
			markdown = "md",
			python = "py",
			ruby = "rb",
			terraform = "tf",
			typescript = "ts",
			typescriptreact = "tsx",
			yaml = "yml",
		}

		local function lsp_clients()
			local names = {}
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
				table.insert(names, client.name)
			end
			return #names > 0 and "  " .. table.concat(names, ", ") or ""
		end

		require("lualine").setup({
			options = {
				theme = statusline_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(mode)
							return mode:sub(1, 1)
						end,
					},
				},
				lualine_b = {
					{ "branch", color = { fg = colors.accent, gui = "bold" } },
					"diff",
				},
				lualine_c = {
					{ "filename", path = 0, color = { fg = colors.bright, gui = "bold" } },
				},
				lualine_x = {
					"diagnostics",
					{ lsp_clients, color = { fg = colors.cyan } },
				},
				lualine_y = {
					{
						"filetype",
						color = { fg = colors.blue },
						fmt = function(filetype)
							return filetype_labels[filetype] or filetype
						end,
					},
					"progress",
				},
				lualine_z = { "location" },
			},
		})
	end,
}
