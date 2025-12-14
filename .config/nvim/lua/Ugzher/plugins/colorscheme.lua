return {
	-- NOTE: Rose pine
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "main", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				-- disable_background = true,
				-- 	disable_nc_background = false,
				-- 	disable_float_background = false,
				-- extend_background_behind_borders = false,
				styles = {
					bold = true,
					italic = false,
					transparency = true,
				},
				highlight_groups = {
					ColorColumn = { bg = "#1C1C21" },
					Normal = { bg = "#0d1117" }, -- Main background remains transparent
					Pmenu = { bg = "", fg = "#e0def4" }, -- Completion menu background
					PmenuSel = { bg = "#4a465d", fg = "#f8f5f2" }, -- Highlighted completion item
					PmenuSbar = { bg = "#191724" }, -- Scrollbar background
					PmenuThumb = { bg = "#9ccfd8" }, -- Scrollbar thumb
				},
				enable = {
					terminal = false,
					legacy_highlights = false, -- Improve compatibility for previous versions of Neovim
					migrations = true, -- Handle deprecated options automatically
				},
			})

			-- HACK: set this on the color you want to be persistent
			-- when quit and reopening nvim
			-- vim.cmd("colorscheme rose-pine")
		end,
	},
	-- NOTE: gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		-- priority = 1000 ,
		config = function()
			require("gruvbox").setup({
				terminal_colors = true, -- add neovim terminal colors
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
				inverse = true, -- invert background for search, diffs, statuslines and errors
				contrast = "", -- can be "hard", "soft" or empty string
				palette_overrides = {},
				overrides = {
					Pmenu = { bg = "" }, -- Completion menu background
				},
				dim_inactive = false,
				transparent_mode = true,
			})
		end,
	},
	-- NOTE: Kanagwa
	{
		"rebelot/kanagawa.nvim",
		config = function()
			require("kanagawa").setup({
				compile = false, -- enable compiling the colorscheme
				undercurl = true, -- enable undercurls
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = { italic = false },
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = true, -- do not set background color
				dimInactive = false, -- dim inactive window `:h hl-NormalNC`
				terminalColors = true, -- define vim.g.terminal_color_{0,17}
				colors = { -- add/modify theme and palette colors
					palette = {},
					theme = {
						wave = {},
						dragon = {},
						all = {
							ui = {
								bg_gutter = "none",
								border = "rounded",
							},
						},
					},
				},
				overrides = function(colors) -- add/modify highlights
					local theme = colors.theme
					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },
						Pmenu = { fg = theme.ui.shade0, bg = "NONE", blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency
						PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },

						-- Save an hlgroup with dark background and dimmed foreground
						-- so that you can use it where your still want darker windows.
						-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

						-- Popular plugins that open floats will link to NormalFloat by default;
						-- set their background accordingly if you wish to keep them dark and borderless
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						TelescopeTitle = { fg = theme.ui.special, bold = true },
						TelescopePromptBorder = { fg = theme.ui.special },
						TelescopeResultsNormal = { fg = theme.ui.fg_dim },
						TelescopeResultsBorder = { fg = theme.ui.special },
						TelescopePreviewBorder = { fg = theme.ui.special },
					}
				end,
				theme = "wave", -- Load "wave" theme when 'background' option is not set
				background = { -- map the value of 'background' option to a theme
					dark = "wave", -- try "dragon" !
				},
			})
		end,
	},
	-- NOTE: neosolarized
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = false,
		config = function()
			require("solarized-osaka").setup({
				transparent = true,
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = true },
					keywords = { italic = false },
					functions = {},
					variables = {},
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "dark", -- style for sidebars, see below
					floats = "dark", -- style for floating windows
				},
				sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
				day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
				hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
				dim_inactive = false, -- dims inactive windows
				lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
				on_highlights = function(hl, c)
					local prompt = "#2d3149"
					hl.TelescopeNormal = {
						bg = c.bg_dark,
						fg = c.fg_dark,
					}
					hl.TelescopeBorder = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
					hl.TelescopePromptNormal = {
						bg = c.bg_dark,
					}
					hl.TelescopePromptBorder = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
					hl.TelescopePromptTitle = {
						bg = prompt,
						fg = "#2C94DD",
					}
					hl.TelescopePreviewTitle = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
					hl.TelescopeResultsTitle = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
				end,
			})
		end,
	},

	-- NOTE : Tokyonight moon
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "moon", -- this sets the 'moon' variant
			transparent = true, -- set to true if you like transparent backgrounds
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			-- vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- NOTE: Catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				background = { -- :h background
					light = "latte",
					dark = "mocha",
				},
				transparent_background = true, -- disables setting the background color.
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
				dim_inactive = {
					enabled = false, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.15, -- percentage of the shade to apply to the inactive window
				},
				no_italic = false, -- Force no italic
				no_bold = false, -- Force no bold
				no_underline = false, -- Force no underline
				styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
					comments = { "italic" }, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				color_overrides = {},
				custom_highlights = function(colors)
					return {
						-- Completion menu customization for transparency
						Pmenu = { bg = "NONE", fg = colors.text },
						PmenuSel = { bg = colors.surface0, fg = colors.text },
						PmenuSbar = { bg = colors.surface0 },
						PmenuThumb = { bg = colors.overlay0 },

						-- Float window transparency
						NormalFloat = { bg = "NONE" },
						FloatBorder = { bg = "NONE", fg = colors.blue },

						-- Telescope customization
						TelescopeNormal = { bg = "NONE" },
						TelescopeBorder = { bg = "NONE", fg = colors.blue },
						TelescopePromptBorder = { bg = "NONE", fg = colors.blue },
						TelescopeResultsBorder = { bg = "NONE", fg = colors.blue },
						TelescopePreviewBorder = { bg = "NONE", fg = colors.blue },
					}
				end,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
					-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
				},
			})
		end,
	},
	-- NOTE: Dracula
	{
		"Mofiqul/dracula.nvim",
		config = function()
			local dracula = require("dracula")
			dracula.setup({
				-- customize dracula color palette
				colors = {
					bg = "#282A36",
					fg = "#F8F8F2",
					selection = "#44475A",
					comment = "#6272A4",
					red = "#FF5555",
					orange = "#FFB86C",
					yellow = "#F1FA8C",
					green = "#50fa7b",
					purple = "#BD93F9",
					cyan = "#8BE9FD",
					pink = "#FF79C6",
					bright_red = "#FF6E6E",
					bright_green = "#69FF94",
					bright_yellow = "#FFFFA5",
					bright_blue = "#D6ACFF",
					bright_magenta = "#FF92DF",
					bright_cyan = "#A4FFFF",
					bright_white = "#FFFFFF",
					menu = "#21222C",
					visual = "#3E4452",
					gutter_fg = "#4B5263",
					nontext = "#3B4048",
					white = "#ABB2BF",
					black = "#191A21",
				},
				-- show the '~' characters after the end of buffers
				show_end_of_buffer = true,
				-- use transparent background
				transparent_bg = false,
				-- set custom lualine background color
				lualine_bg_color = "#44475a",
				-- set italic comment
				italic_comment = true,
				-- overrides the default highlights with table see `:h synIDattr`
				overrides = function(colors)
					return {
						-- Completion menu customization for transparency
						Pmenu = { bg = "NONE", fg = colors.fg },
						PmenuSel = { bg = colors.selection, fg = colors.fg },
						PmenuSbar = { bg = colors.selection },
						PmenuThumb = { bg = colors.comment },

						-- Float window transparency
						Normal = { bg = "NONE" },
						NormalFloat = { bg = "NONE" },
						FloatBorder = { bg = "NONE", fg = colors.purple },

						-- Telescope customization
						TelescopeNormal = { bg = "NONE" },
						TelescopeBorder = { bg = "NONE", fg = colors.purple },
						TelescopePromptBorder = { bg = "NONE", fg = colors.purple },
						TelescopeResultsBorder = { bg = "NONE", fg = colors.purple },
						TelescopePreviewBorder = { bg = "NONE", fg = colors.purple },
						TelescopePromptTitle = { bg = colors.purple, fg = colors.bg },
						TelescopeResultsTitle = { bg = colors.comment, fg = colors.fg },
						TelescopePreviewTitle = { bg = colors.green, fg = colors.bg },

						-- Additional transparency
						SignColumn = { bg = "NONE" },
						ColorColumn = { bg = colors.selection },
						CursorLine = { bg = colors.selection },

						-- Tree-sitter overrides
						["@variable"] = { fg = colors.fg },
						["@function"] = { fg = colors.green },
						["@keyword"] = { fg = colors.pink },
						["@string"] = { fg = colors.yellow },
					}
				end,
			})
		end,
	},
	-- NOTE: github
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		config = function()
			require("github-theme").setup({
				options = {
					compile_path = vim.fn.stdpath("cache") .. "/github-theme",
					compile_file_suffix = "_compiled", -- Compiled file suffix
					hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer for a cleaner look
					hide_nc_statusline = true, -- Override the underline style for non-active statuslines
					transparent = false, -- Enable setting bg (disable transparency)
					terminal_colors = false, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
					dim_inactive = false, -- Non focused panes set to alternative background
					module_default = true, -- Default enable value for modules
					styles = { -- Style to be applied to different syntax groups
						comments = "italic", -- Value is any valid attr-list value `:help attr-list`
						functions = "NONE",
						keywords = "bold",
						variables = "NONE",
						conditionals = "NONE",
						constants = "NONE",
						numbers = "NONE",
						operators = "NONE",
						strings = "NONE",
						types = "NONE",
					},
					inverse = { -- Inverse highlight for different types
						match_paren = false,
						visual = false,
						search = false,
					},
				},
				palettes = {},
				specs = {},
				groups = {
					github_dark_default = {
						ColorColumn = { bg = "#21262d" },
						Normal = { bg = "#0d1117" }, -- Main background with GitHub dark color
						Pmenu = { bg = "#21262d", fg = "#f0f6fc" }, -- Completion menu background
						PmenuSel = { bg = "#388bfd", fg = "#ffffff" }, -- Highlighted completion item
						PmenuSbar = { bg = "#21262d" }, -- Scrollbar background
						PmenuThumb = { bg = "#58a6ff" }, -- Scrollbar thumb
						CursorLine = { bg = "#21262d" }, -- Current line highlight
						CursorColumn = { bg = "#21262d" }, -- Current column highlight
						LineNr = { fg = "#484f58" }, -- Line numbers
						CursorLineNr = { fg = "#f0f6fc", bold = true }, -- Current line number
						SignColumn = { bg = "#0d1117" }, -- Sign column with background
						VertSplit = { fg = "#30363d" }, -- Vertical split
						StatusLine = { bg = "#21262d", fg = "#f0f6fc" }, -- Status line
						StatusLineNC = { bg = "#161b22", fg = "#8b949e" }, -- Non-current status line
						TabLine = { bg = "#161b22", fg = "#8b949e" }, -- Tab line
						TabLineFill = { bg = "#0d1117" }, -- Tab line fill
						TabLineSel = { bg = "#21262d", fg = "#f0f6fc" }, -- Selected tab
						FloatBorder = { fg = "#30363d" }, -- Floating window border
						NormalFloat = { bg = "#161b22" }, -- Floating window background
					},
				},
			})
			-- HACK: set this on the color you want to be persistent
			-- when quit and reopening nvim
			-- vim.cmd("colorscheme github_dark_default")
		end,
	},

	--Aura
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"baliestri/aura-theme",
		lazy = false,
		priority = 1000,
		config = function(plugin)
			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")

			-- Load colorscheme FIRST
			vim.cmd([[colorscheme aura-dark]])

			-- Then set transparency AFTER
			vim.cmd([[highlight Normal ctermbg=none guibg=none]])
			vim.cmd([[highlight NormalNC ctermbg=none guibg=none]])
			vim.cmd([[highlight LineNr ctermbg=none guibg=none]])
			vim.cmd([[highlight SignColumn ctermbg=none guibg=none]])
			vim.cmd([[highlight NormalFloat ctermbg=none guibg=none]])
			vim.cmd([[highlight FloatBorder ctermbg=none guibg=none]])
		end,
	},
}
