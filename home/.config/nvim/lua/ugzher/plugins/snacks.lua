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

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true, replace_netrw = true },
		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		picker = {
			enabled = true,
			hidden = true,
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = { "dist" },
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
		scope = { enabled = true },
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
			"<leader>ef",
			function()
				Snacks.explorer()
			end,
			desc = "Explorateur",
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
