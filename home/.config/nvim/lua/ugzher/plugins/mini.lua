return {
	"nvim-mini/mini.nvim",
	version = false,
	config = function()
		require("mini.ai").setup({ n_lines = 200 })

		local files = require("mini.files")
		files.setup({
			mappings = {
				go_in = "l",
				go_in_plus = "<CR>",
			},
			options = { permanent_delete = false, use_as_default_explorer = true },
			windows = {
				preview = true,
				width_focus = 34,
				width_nofocus = 18,
				width_preview = 50,
			},
		})

		vim.keymap.set("n", "<leader>ef", function()
			if files.get_explorer_state() then
				files.close()
				return
			end

			local path = vim.api.nvim_buf_get_name(0)
			if path == "" or vim.bo.buftype ~= "" then
				path = vim.uv.cwd()
			end
			files.open(path, true)
		end, { desc = "Explorateur de fichiers centré" })

		require("mini.jump2d").setup({
			mappings = { start_jumping = "s" },
			view = { dim = true, n_steps_ahead = 1 },
		})

		local sessions = require("mini.sessions")
		sessions.setup({ autoread = false, autowrite = true })

		local function project_session()
			local cwd = vim.fs.normalize(vim.fn.getcwd())
			local name = vim.fs.basename(cwd):gsub("[^%w_.-]", "-")
			return ("%s-%s.vim"):format(name, vim.fn.sha256(cwd):sub(1, 8))
		end

		vim.keymap.set("n", "<leader>qs", function()
			sessions.write(project_session(), { force = true })
		end, { desc = "Sauvegarder la session du projet" })

		vim.keymap.set("n", "<leader>qr", function()
			local name = project_session()
			if sessions.detected[name] then
				sessions.read(name)
			else
				vim.notify("Aucune session enregistrée pour ce projet", vim.log.levels.INFO)
			end
		end, { desc = "Restaurer la session du projet" })

		vim.keymap.set("n", "<leader>ql", function()
			sessions.select("read")
		end, { desc = "Choisir une session" })

		vim.keymap.set("n", "<leader>qd", function()
			sessions.select("delete")
		end, { desc = "Supprimer une session" })
	end,
}
