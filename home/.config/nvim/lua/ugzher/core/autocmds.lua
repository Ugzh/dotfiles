local group = vim.api.nvim_create_augroup("ugzher-comfort", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Surligner brièvement le texte copié",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	desc = "Restaurer la dernière position du curseur",
	callback = function(event)
		local mark = vim.api.nvim_buf_get_mark(event.buf, [["]])
		local line_count = vim.api.nvim_buf_line_count(event.buf)
		if vim.api.nvim_win_get_buf(0) == event.buf and mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	desc = "Rééquilibrer les fenêtres après un redimensionnement",
	command = "wincmd =",
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = group,
	desc = "Recharger les fichiers modifiés hors de Neovim",
	command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "checkhealth", "help", "lspinfo", "man", "qf", "startuptime" },
	desc = "Fermer les fenêtres temporaires avec q",
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})
