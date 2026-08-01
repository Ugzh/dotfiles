return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-l>",
				accept_word = "<M-l>",
				clear_suggestion = "<C-]>",
			},
			log_level = "off",
			condition = function()
				local ok, blink = pcall(require, "blink.cmp")
				return ok and blink.is_visible()
			end,
		})
	end,
}
