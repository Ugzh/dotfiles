local theme = require("generated-theme")

return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			-- Les buffers représentent les fichiers ; les tabpages restent des espaces de travail.
			mode = "buffers",
			separator_style = "slant",
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			indicator = {
				icon = "▎",
				style = "icon",
			},
			buffer_close_icon = "×",
			modified_icon = "●",
			close_icon = "×",
			left_trunc_marker = "‹",
			right_trunc_marker = "›",
			max_name_length = 28,
			max_prefix_length = 18,
			truncate_names = true,
			show_buffer_close_icons = true,
			show_close_icon = false,
			diagnostics_indicator = function(count)
				return " " .. count
			end,
			hover = {
				enabled = true,
				delay = 150,
				reveal = { "close" },
			},
		},
		highlights = {
			fill = {
				bg = theme.bg,
			},
			background = {
				fg = theme.fg_dim,
				bg = theme.bg_alt,
			},
			buffer_selected = {
				fg = theme.fg,
				bg = theme.bg_highlight,
				bold = true,
				italic = false,
			},
			separator = {
				fg = theme.bg,
				bg = theme.bg_alt,
			},
			separator_selected = {
				fg = theme.bg,
				bg = theme.bg_highlight,
			},
			indicator_selected = {
				fg = theme.accent,
				bg = theme.bg_highlight,
			},
			modified = {
				fg = theme.yellow,
				bg = theme.bg_alt,
			},
			modified_selected = {
				fg = theme.yellow,
				bg = theme.bg_highlight,
			},
			duplicate = {
				fg = theme.fg_dim,
				bg = theme.bg_alt,
				italic = true,
			},
			duplicate_selected = {
				fg = theme.fg,
				bg = theme.bg_highlight,
				italic = true,
			},
			close_button = {
				fg = theme.fg_dim,
				bg = theme.bg_alt,
			},
			close_button_selected = {
				fg = theme.red,
				bg = theme.bg_highlight,
			},
			diagnostic = {
				fg = theme.fg_dim,
				bg = theme.bg_alt,
			},
			diagnostic_selected = {
				fg = theme.fg,
				bg = theme.bg_highlight,
				bold = true,
			},
			error = {
				fg = theme.red,
				bg = theme.bg_alt,
			},
			error_selected = {
				fg = theme.red,
				bg = theme.bg_highlight,
				bold = true,
			},
			warning = {
				fg = theme.yellow,
				bg = theme.bg_alt,
			},
			warning_selected = {
				fg = theme.yellow,
				bg = theme.bg_highlight,
				bold = true,
			},
		},
	},
	keys = {
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer précédent" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer suivant" },
		{
			"<leader>bd",
			function()
				require("snacks.bufdelete").delete()
			end,
			desc = "Fermer le buffer",
		},
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Épingler le buffer" },
	},
}
