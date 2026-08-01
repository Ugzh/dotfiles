local M = {}

function M.apply(theme)
	require("cyberdream").setup({
		transparent = false,
		terminal_colors = true,
		borderless_pickers = false,
		colors = {
			bg = theme.bg,
			bg_alt = theme.bg_alt,
			bg_highlight = theme.bg_highlight,
			fg = theme.fg,
			grey = theme.fg_dim,
			green = theme.accent,
			cyan = theme.bright,
			blue = theme.blue,
			red = theme.red,
			yellow = theme.yellow,
			orange = theme.orange,
			magenta = theme.magenta,
			pink = theme.pink,
		},
		overrides = function(colors)
			return {
				Normal = { fg = colors.fg, bg = colors.bg },
				NormalNC = { fg = colors.fg, bg = colors.bg },
				SignColumn = { bg = colors.bg },
				Folded = { bg = colors.bg_alt },
				FloatBorder = { fg = colors.green, bg = colors.bg_alt },
				WinSeparator = { fg = theme.border },
				CursorLine = { bg = theme.bg_alt },
				Visual = { bg = theme.muted },
				Search = { fg = theme.bg, bg = colors.green },
				IncSearch = { fg = theme.bg, bg = colors.cyan },
				NotifyBackground = { bg = theme.bg },
				["@type"] = { fg = colors.magenta },
				["@constructor"] = { fg = colors.magenta },
				["@function"] = { fg = colors.blue },
				["@function.method"] = { fg = colors.cyan },
				["@variable.member"] = { fg = theme.blue },
				["@property"] = { fg = theme.blue },
				["@constant"] = { fg = colors.orange },
				["@keyword"] = { fg = colors.pink },
				["@string"] = { fg = colors.green },
				["@comment"] = { fg = colors.grey, italic = true },
				["@lsp.type.class"] = { fg = colors.magenta },
				["@lsp.type.enum"] = { fg = colors.magenta },
				["@lsp.type.interface"] = { fg = colors.magenta },
				["@lsp.type.typeParameter"] = { fg = colors.magenta },
				["@lsp.type.function"] = { fg = colors.orange },
				["@lsp.type.method"] = { fg = colors.orange },
				["@lsp.type.property"] = { fg = colors.yellow },
				["@lsp.type.variable"] = { fg = colors.fg },
				["@lsp.type.parameter"] = { fg = colors.fg },
				["@lsp.type.enumMember"] = { fg = colors.yellow },
				["@lsp.typemod.variable.readonly"] = { fg = colors.yellow },
				["@lsp.typemod.property.readonly"] = { fg = colors.yellow },
				LspInlayHint = { fg = theme.fg_dim, bg = theme.bg_alt },
				DiagnosticVirtualTextError = { fg = colors.red, bg = theme.bg_alt },
				DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = theme.bg_alt },
				DiagnosticVirtualTextInfo = { fg = colors.cyan, bg = theme.bg_alt },
				DiagnosticVirtualTextHint = { fg = colors.grey, bg = theme.bg_alt },
			}
		end,
		extensions = {
			blinkcmp = true,
			gitsigns = true,
			lazy = true,
			mini = true,
			snacks = true,
			treesitter = true,
		},
	})

	vim.cmd.colorscheme("cyberdream")
end

return M
