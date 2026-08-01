return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			mode = "buffers",
			separator_style = "thin",
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			close_command = "bdelete! %d",
			right_mouse_command = "bdelete! %d",
		},
		highlights = {
			fill = {
				bg = "none",
			},
			background = {
				bg = "none",
			},
			buffer_selected = {
				bg = "none",
				bold = true,
				italic = false,
			},
			separator = {
				fg = "none",
				bg = "none",
			},
			separator_selected = {
				fg = "none",
				bg = "none",
			},
			modified_selected = {
				bg = "none",
			},
			duplicate_selected = {
				bg = "none",
			},
			indicator_selected = {
				bg = "none",
			},
			close_button = {
				bg = "none",
			},
			close_button_selected = {
				bg = "none",
			},
		},
	},
	keys = {
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer précédent" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer suivant" },
		{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Fermer le buffer" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Épingler le buffer" },
	},
}
