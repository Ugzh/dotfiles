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

local function explorer_open_in_window(picker, item)
	if not item or item.dir then
		picker:action("confirm")
		return
	end

	local target_windows = vim.tbl_filter(function(window)
		local buffer = vim.api.nvim_win_get_buf(window)
		return vim.api.nvim_win_get_config(window).relative == "" and not vim.bo[buffer].filetype:find("^snacks")
	end, vim.api.nvim_tabpage_list_wins(0))

	if #target_windows <= 1 then
		picker:action("confirm")
		return
	end

	local cancelled = Snacks.picker.actions.pick_win(picker, item, {})
	if not cancelled then
		picker:action("confirm")
	end
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
					layout = {
						preset = "sidebar",
						preview = false,
						layout = {
							width = 44,
							min_width = 36,
							border = "rounded",
							title = "   {title} ",
							title_pos = "left",
						},
					},
					actions = {
						open_in_window = explorer_open_in_window,
					},
					win = {
						list = {
							keys = {
								["<CR>"] = { "open_in_window", desc = "Ouvrir dans une fenêtre" },
								["l"] = { "open_in_window", desc = "Ouvrir dans une fenêtre" },
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
