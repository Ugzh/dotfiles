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

	if theme.name == "oxocarbon-light" then
		vim.opt.background = "light"
		vim.cmd.colorscheme("oxocarbon")

		local highlights = {
			Normal = { fg = theme.fg, bg = theme.bg },
			NormalNC = { fg = theme.fg, bg = theme.bg },
			SignColumn = { bg = theme.bg },
			CursorLine = { bg = theme.bg_alt },
			Visual = { bg = theme.bg_highlight },
			Comment = { fg = theme.fg_dim, italic = true },
			Keyword = { fg = theme.pink },
			Conditional = { fg = theme.pink },
			Repeat = { fg = theme.pink },
			Include = { fg = theme.pink },
			Exception = { fg = theme.pink },
			Type = { fg = theme.magenta },
			Function = { fg = theme.blue },
			String = { fg = theme.magenta, italic = true },
			Number = { fg = theme.orange },
			Operator = { fg = theme.red },
			["@keyword"] = { fg = theme.pink },
			["@keyword.function"] = { fg = theme.pink },
			["@keyword.return"] = { fg = theme.pink },
			["@keyword.conditional"] = { fg = theme.pink },
			["@type"] = { fg = theme.magenta },
			["@type.builtin"] = { fg = theme.magenta },
			["@constructor"] = { fg = theme.magenta },
			["@function"] = { fg = theme.blue },
			["@function.call"] = { fg = theme.blue },
			["@function.method"] = { fg = theme.blue },
			["@function.method.call"] = { fg = theme.blue },
			["@string"] = { fg = theme.magenta, italic = true },
			["@number"] = { fg = theme.orange },
			["@operator"] = { fg = theme.red },
			["@property"] = { fg = theme.cyan },
			["@variable.member"] = { fg = theme.cyan },
			["@constant"] = { fg = theme.green },
			["@lsp.type.class"] = { fg = theme.magenta },
			["@lsp.type.interface"] = { fg = theme.magenta },
			["@lsp.type.type"] = { fg = theme.magenta },
			["@lsp.type.function"] = { fg = theme.blue },
			["@lsp.type.method"] = { fg = theme.blue },
			["@lsp.type.property"] = { fg = theme.cyan },
			["@lsp.type.enumMember"] = { fg = theme.green },
		}

		for group, attributes in pairs(highlights) do
			vim.api.nvim_set_hl(0, group, attributes)
		end

		M.apply_shared_styles(theme)
		return
	end

	if theme.name == "platinum-night" then
		vim.opt.background = "dark"
		require("sora").setup({
			transparent = false,
			italic = true,
			italic_comments = true,
		})
		vim.cmd.colorscheme("sora")
		M.apply_shared_styles(theme)
		return
	end

	local is_elysia = theme.name:match("^elysia%-") ~= nil
	local is_mocha = theme.name == "catppuccin-mocha"
	local is_gruvbox_light = theme.name == "gruvbox-soft-light"
	local is_gruvbox = theme.name:match("^gruvbox%-soft%-") ~= nil

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
			local mocha_keyword = is_mocha and { fg = colors.mauve, italic = true } or nil
			local mocha_function = is_mocha and { fg = colors.teal } or nil
			local mocha_type = is_mocha and { fg = colors.lavender } or nil

			return {
				Normal = { fg = colors.text, bg = colors.base },
				NormalNC = { fg = colors.text, bg = colors.base },
				SignColumn = { bg = colors.base },
				Cursor = is_gruvbox and { fg = theme.bg, bg = theme.cyan, bold = true } or nil,
				lCursor = is_gruvbox and { fg = theme.bg, bg = theme.cyan, bold = true } or nil,
				CursorIM = is_gruvbox and { fg = theme.bg, bg = theme.cyan, bold = true } or nil,
				TermCursor = is_gruvbox and { fg = theme.bg, bg = theme.cyan, bold = true } or nil,
				CursorLineNr = is_gruvbox and { fg = theme.blue, bold = true } or nil,
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
				Visual = is_gruvbox_light and { fg = theme.bg, bg = theme.fg, bold = true }
					or { bg = theme.muted },
				VisualNOS = is_gruvbox_light and { fg = theme.bg, bg = theme.fg_dim }
					or { bg = theme.muted },
				Search = { fg = theme.bg, bg = colors.green },
				IncSearch = { fg = theme.bg, bg = colors.teal },
				NotifyBackground = { bg = theme.bg },
				Keyword = mocha_keyword,
				Conditional = mocha_keyword,
				Repeat = mocha_keyword,
				Include = mocha_keyword,
				Exception = mocha_keyword,
				Function = mocha_function,
				Comment = is_mocha and { fg = colors.overlay0, italic = true } or nil,
				["@type"] = is_mocha and mocha_type or { fg = is_elysia and colors.peach or colors.mauve },
				["@type.builtin"] = is_mocha and mocha_type or nil,
				["@constructor"] = is_mocha and mocha_type or { fg = is_elysia and colors.peach or colors.mauve },
				["@function"] = mocha_function or { fg = colors.blue },
				["@function.call"] = mocha_function,
				["@function.method"] = mocha_function or { fg = is_elysia and colors.blue or colors.teal },
				["@function.method.call"] = mocha_function,
				["@variable"] = is_mocha and { fg = colors.text } or nil,
				["@variable.parameter"] = is_mocha and { fg = colors.text } or nil,
				["@variable.member"] = { fg = is_mocha and colors.teal or theme.blue },
				["@property"] = { fg = is_mocha and colors.teal or theme.blue },
				["@constant"] = { fg = colors.peach },
				["@number"] = is_mocha and { fg = colors.peach } or nil,
				["@operator"] = is_mocha and { fg = colors.teal } or nil,
				["@keyword"] = mocha_keyword or { fg = is_elysia and colors.mauve or colors.pink },
				["@keyword.modifier"] = mocha_keyword,
				["@keyword.type"] = mocha_keyword,
				["@keyword.coroutine"] = mocha_keyword,
				["@keyword.function"] = mocha_keyword,
				["@keyword.operator"] = mocha_keyword,
				["@keyword.import"] = mocha_keyword,
				["@keyword.repeat"] = mocha_keyword,
				["@keyword.return"] = mocha_keyword,
				["@keyword.exception"] = mocha_keyword,
				["@keyword.conditional"] = mocha_keyword,
				["@keyword.export"] = mocha_keyword,
				["@string"] = { fg = colors.green },
				["@comment"] = { fg = is_mocha and colors.overlay0 or colors.overlay2, italic = true },
				["@lsp.type.class"] = is_mocha and mocha_type or { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.enum"] = is_mocha and mocha_type or { fg = colors.mauve },
				["@lsp.type.interface"] = is_mocha and mocha_type or { fg = colors.mauve },
				["@lsp.type.type"] = is_mocha and mocha_type or { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.typeParameter"] = is_mocha and mocha_type
					or { fg = is_elysia and colors.peach or colors.mauve },
				["@lsp.type.namespace"] = is_mocha and { fg = colors.teal } or nil,
				["@lsp.type.function"] = mocha_function or { fg = is_elysia and colors.blue or colors.peach },
				["@lsp.type.method"] = mocha_function or { fg = is_elysia and colors.blue or colors.peach },
				["@lsp.type.property"] = {
					fg = is_mocha and colors.teal or (is_elysia and theme.blue or colors.yellow),
				},
				["@lsp.type.variable"] = { fg = colors.text },
				["@lsp.type.parameter"] = { fg = colors.text },
				["@lsp.type.enumMember"] = { fg = is_mocha and colors.mauve or colors.yellow },
				["@lsp.typemod.variable.readonly"] = { fg = is_mocha and colors.text or colors.yellow },
				["@lsp.typemod.property.readonly"] = { fg = is_mocha and theme.blue or colors.yellow },
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
