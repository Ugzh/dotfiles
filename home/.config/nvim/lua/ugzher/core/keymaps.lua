local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Déplacer la sélection vers le bas" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Déplacer la sélection vers le haut" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Joindre la ligne suivante" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Descendre d'une demi-page" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Monter d'une demi-page" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Résultat de recherche suivant" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Résultat de recherche précédent" })

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- remember yanked
vim.keymap.set("v", "p", '"_dp', opts)

-- Copies or Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copier la ligne dans le presse-papiers" })

-- leader d delete wont remember as yanked/clipboard when delete pasting
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Supprimer sans copier" })

-- ctrl c as escape cuz Im lazy to reach up to the esc key
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Quitter le mode insertion" })
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Effacer la recherche", silent = true })

-- Unmaps Q in normal mode
vim.keymap.set("n", "Q", "<nop>")

-- prevent x delete from registering when next paste
vim.keymap.set("n", "x", '"_x', opts)

-- Hightlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- tab stuff
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Nouvel onglet" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Fermer l'onglet" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Onglet suivant" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Onglet précédent" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Fichier dans un nouvel onglet" })

--split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Diviser verticalement" })
-- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Diviser horizontalement" })
-- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Égaliser les fenêtres" })
-- close current split window
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Fermer la fenêtre" })

vim.keymap.set("i", "jk", "<ESC>", { desc = "Quitter le mode insertion" })
--
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic de la ligne" })
-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
	vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
	print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copier le chemin du fichier" })

vim.keymap.set("n", "<leader>ko", function()
	vim.lsp.buf.code_action({
		context = { only = { "source.organizeImports" }, diagnostics = {} },
		apply = true,
	})
end, { desc = "Organiser les imports" })
