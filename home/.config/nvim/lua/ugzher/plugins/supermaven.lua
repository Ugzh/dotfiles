return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-l>",
				accept_word = "<M-l>",
				clear_suggestion = "<C-]>",
			},
			log_level = "off",
			condition = function()
				local blink = package.loaded["blink.cmp"]
				return blink ~= nil and blink.is_visible()
			end,
		})
	end,
}
