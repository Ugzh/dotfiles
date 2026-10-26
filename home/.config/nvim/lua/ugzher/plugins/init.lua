return {
	{
		"christoomey/vim-tmux-navigator",
		cond = function()
			return vim.env.TMUX ~= nil
		end,
	},
}
