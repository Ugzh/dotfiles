return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	config = function()
		-- 1. Set the Sakura Colors
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#C8A8C8" })
		vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#C8A8C8" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#C8A8C8" })
		vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = "#C8A8C8" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#C8A8C8" })

		-- 2. Setup Noice
		require("noice").setup({
			views = {
				cmdline_popup = {
					border = {
						style = "rounded", -- You can use "single", "double", or "rounded"
						padding = { 0, 1 },
					},
				},
			},
			presets = {
				command_palette = true, -- This centers the prompt
				long_message_to_split = true,
			},
		})
	end,
}
