local M = {}

local function extend_highlight(name, attributes)
	local current = vim.api.nvim_get_hl(0, { name = name, link = false })
	vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", current, attributes))
end

function M.apply_shared_styles(theme)
	-- Keep the richer font variants and scope guides that make Melange easy to
	-- scan, while retaining the colors supplied by the active theme.
	extend_highlight("String", { italic = true })
	extend_highlight("@string", { italic = true })
	extend_highlight("@variable.builtin", { fg = theme.cyan, italic = true })
	extend_highlight("@lsp.typemod.variable.globalScope", { italic = true })

	for _, group in ipairs({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite" }) do
		extend_highlight(group, { underline = true })
	end

	vim.api.nvim_set_hl(0, "SnacksIndent", { fg = theme.border })
	vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = theme.accent })
end

function M.apply_melange(theme)
	vim.opt.background = "dark"
	vim.cmd.colorscheme("melange")
	M.apply_shared_styles(theme)
end

function M.apply(theme)
	if theme.name == "melange-dark" then
		M.apply_melange(theme)
		return
	end

	if theme.name == "oxocarbon" then
		vim.opt.background = "dark"
		vim.cmd.colorscheme("oxocarbon")
		M.apply_shared_styles(theme)
		return
	end

	local is_elysia = theme.name:match("^elysia%-") ~= nil

	require("catppuccin").setup({
		flavour = "mocha",
		background = { dark = "mocha" },
		transparent_background = false,
		term_colors = true,
		color_overrides = {
			mocha = {
				base = theme.bg,
				mantle = theme.bg_alt,
				crust = theme.bg,
				surface0 = theme.bg_highlight,
				surface1 = theme.muted,
				overlay0 = theme.border,
				overlay2 = theme.fg_dim,
				text = theme.fg,
				lavender = theme.bright,
				mauve = theme.accent,
				pink = theme.pink,
				red = theme.red,
				peach = theme.orange,
				yellow = theme.yellow,
				green = theme.green,
				teal = theme.cyan,
				sky = theme.cyan,
				blue = theme.blue,
			},
		},
		custom_highlights = function(colors)
			return {
				Normal = { fg = colors.text, bg = colors.base },
				NormalNC = { fg = colors.text, bg = colors.base },
				SignColumn = { bg = colors.base },
				Folded = { bg = colors.mantle },
				FloatBorder = { fg = theme.accent, bg = colors.mantle },
				WinSeparator = { fg = theme.border },
				VertSplit = { fg = theme.border },
				SnacksPickerBoxBorder = { fg = theme.accent, bg = theme.bg },
				SnacksPickerInputBorder = { fg = theme.bright, bg = theme.bg_alt },
				SnacksPickerInputTitle = { fg = theme.bg, bg = theme.accent, bold = true },
				SnacksPickerListCursorLine = { bg = theme.bg_highlight, bold = true },
				SnacksPickerPrompt = { fg = theme.pink, bold = true },
				SnacksPickerDirectory = { fg = theme.blue, bold = true },
				SnacksPickerTree = { fg = theme.border },
				CursorLine = { bg = theme.bg_alt },
				Visual = { bg = theme.muted },
				Search = { fg = theme.bg, bg = colors.green },
				IncSearch = { fg = theme.bg, bg = colors.teal },
				NotifyBackground = { bg = theme.bg },
				["@type"] = { fg = is_elysia and colors.peach or colors.mauve },
				["@constructor"] = { fg = is_elysia and colors.peach or colors.mauve },
				["@function"] = { fg = colors.blue },
				["@function.method"] = { fg = is_elysia and colors.blue or colors.teal },
				["@variable.member"] = { fg = theme.blue },
				["@property"] = { fg = theme.blue },
				["@constant"] = { fg = colors.peach },
				["@keyword"] = { fg = is_elysia and colors.mauve or colors.pink },
				["@string"] = { fg = colors.green },
				["@comment"] = { fg = colors.overlay2, italic = true },
				["@lsp.type.class"] = { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.enum"] = { fg = colors.mauve },
				["@lsp.type.interface"] = { fg = colors.mauve },
				["@lsp.type.type"] = { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.typeParameter"] = { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.function"] = { fg = is_elysia and colors.blue or colors.peach },
				["@lsp.type.method"] = { fg = is_elysia and colors.blue or colors.peach },
				["@lsp.type.property"] = { fg = is_elysia and theme.blue or colors.yellow },
				["@lsp.type.variable"] = { fg = colors.text },
				["@lsp.type.parameter"] = { fg = colors.text },
				["@lsp.type.enumMember"] = { fg = colors.yellow },
				["@lsp.typemod.variable.readonly"] = { fg = colors.yellow },
				["@lsp.typemod.property.readonly"] = { fg = colors.yellow },
				LspInlayHint = { fg = theme.fg_dim, bg = theme.bg_alt },
				DiagnosticVirtualTextError = { fg = colors.red, bg = theme.bg_alt },
				DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = theme.bg_alt },
				DiagnosticVirtualTextInfo = { fg = colors.teal, bg = theme.bg_alt },
				DiagnosticVirtualTextHint = { fg = colors.overlay2, bg = theme.bg_alt },
			}
		end,
		integrations = {
			blink_cmp = true,
			gitsigns = true,
			lazy = true,
			mini = { enabled = true },
			snacks = { enabled = true },
			treesitter = true,
		},
	})

	vim.cmd.colorscheme("catppuccin-mocha")
	M.apply_shared_styles(theme)
end

return M
