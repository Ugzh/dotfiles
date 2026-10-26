local function code_action_number_keys()
	local keys = {}

	for index = 1, 9 do
		keys[tostring(index)] = {
			"select_code_action_" .. index,
			mode = { "n", "i" },
			desc = "Choisir l'action " .. index,
		}
	end

	return keys
end

local function code_action_number_actions()
	local actions = {}

	for index = 1, 9 do
		actions["select_code_action_" .. index] = function(picker)
			if index <= picker.list:count() then
				picker.list:move(index, true)
				picker:action("confirm")
			end
		end
	end

	return actions
end

-- Snacks has read the chunk shape from either `indent` or `scope`
-- depending on the version. Keep both paths in sync.
local indent_chunk = {
	enabled = true,
	char = {
		corner_top = "┌",
		corner_bottom = "└",
		horizontal = "─",
		vertical = "│",
		arrow = "─",
	},
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true, replace_netrw = true },
		indent = {
			enabled = true,
			chunk = indent_chunk,
		},
		input = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		picker = {
			enabled = true,
			hidden = true,
			sources = {
				explorer = {
					hidden = true,
					ignored = false,
					jump = { close = true },
					layout = {
						preview = false,
						hidden = { "input" },
						layout = {
							backdrop = 60,
							width = 0.72,
							min_width = 70,
							max_width = 120,
							height = 0.72,
							min_height = 20,
							box = "vertical",
							border = "rounded",
							title = "   {title} ",
							title_pos = "left",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					},
					win = {
						list = {
							keys = {
								["/"] = { "picker_files", desc = "Rechercher un fichier dans le dossier" },
							},
						},
					},
				},
				select = {
					kinds = {
						codeaction = {
							actions = code_action_number_actions(),
							win = {
								input = { keys = code_action_number_keys() },
							},
						},
					},
				},
			},
		},
		quickfile = { enabled = true },
		scope = {
			enabled = true,
			chunk = indent_chunk,
		},
		statuscolumn = { enabled = true },
		terminal = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Recherche intelligente",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Fichiers",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Fichiers récents",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.grep()
			end,
			desc = "Rechercher du texte",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Mot sous le curseur",
			mode = { "n", "x" },
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Aide",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Raccourcis",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>fm",
			function()
				Snacks.picker.lsp_symbols({
					filter = { default = { "Method" } },
					tree = false,
				})
			end,
			desc = "Méthodes du fichier",
		},
		{
			"<leader>go",
			function()
				Snacks.gitbrowse({ what = "file" })
			end,
			desc = "Ouvrir la ligne sur le dépôt distant",
			mode = { "n", "x" },
		},
		{
			"<leader>eF",
			function()
				Snacks.explorer()
			end,
			desc = "Explorateur Snacks",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Masquer les notifications",
		},
		{
			"<leader>nh",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Historique des notifications",
		},
		{
			"<leader>tt",
			function()
				Snacks.terminal()
			end,
			desc = "Terminal",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Ouvrir/fermer le bloc-notes",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd
			end,
		})
	end,
}
