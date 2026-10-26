return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	config = function()
		local gitsigns = require("gitsigns")
		gitsigns.setup({
			signs = {
				add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
				change = {
					hl = "GitSignsChange",
					text = "│",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
				delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
				topdelete = {
					hl = "GitSignsDelete",
					text = "‾",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				changedelete = {
					hl = "GitSignsChange",
					text = "~",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
			},
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1500,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%d-%m-%Y> - <summary>",
			on_attach = function(bufnr)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, "Changement Git suivant")
				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, "Changement Git précédent")
				map("n", "<leader>gp", gitsigns.preview_hunk, "Prévisualiser le changement")
				map("n", "<leader>gs", gitsigns.stage_hunk, "Indexer le changement")
				map("v", "<leader>gs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Indexer la sélection")
				map("n", "<leader>gr", gitsigns.reset_hunk, "Annuler le changement")
				map("v", "<leader>gr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Annuler les changements sélectionnés")
				map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Afficher/masquer le blame")
			end,
		})
	end,
}
