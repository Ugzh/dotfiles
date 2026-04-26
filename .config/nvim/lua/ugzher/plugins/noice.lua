return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = function()
		vim.keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Noice Message" })
		return {
			routes = {
				{
					filter = {
						event = "notify",
						find = "No information available",
					},
					opts = { skip = true },
				},
			},
		}
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"rcarriga/nvim-notify",
			opts = {
				max_width = 40,
				max_height = 3,
			},
		},
	},
}
