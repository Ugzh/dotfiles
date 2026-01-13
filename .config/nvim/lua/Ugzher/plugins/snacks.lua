return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = {
			enabled = true,
		},
		picker = {
			enabled = true,
			ui_select = true,
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts) -- Initialize first

		local pink = "#C8A8C8"

		-- We use a slightly broader list of highlight groups to
		-- catch any hidden "blue" defaults.
		local snacks_theme = {
			-- Picker Highlights
			["SnacksPickerBorder"] = { fg = pink },
			["SnacksPickerBorderTitle"] = { fg = pink, bold = true },
			["SnacksPickerPrompt"] = { fg = pink },
			["SnacksPickerMatch"] = { fg = pink, bold = true },

			-- Input Highlights (LSP Rename, etc)
			["SnacksInputNormal"] = { fg = "#DDD6DD" },
			["SnacksInputBorder"] = { fg = pink },
			["SnacksInputTitle"] = { fg = pink, bold = true },

			-- General Win Highlights that Snacks uses
			["SnacksNormal"] = { fg = "#DDD6DD" },
			["SnacksWinBorder"] = { fg = pink },
		}

		for group, hl in pairs(snacks_theme) do
			vim.api.nvim_set_hl(0, group, hl)
		end
	end,
}
