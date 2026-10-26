return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	init = function()
		local pending
		_G.LazygitEdit = function(file, line)
			pending = { file = file, line = line }
		end
		vim.g.lazygit_on_exit_callback = function()
			if not pending then
				return
			end
			vim.cmd.edit(vim.fn.fnameescape(pending.file))
			if pending.line then
				vim.cmd(tostring(pending.line))
			end
			pending = nil
		end
	end,
	keys = {
		{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Ouvrir LazyGit" },
	},
}
