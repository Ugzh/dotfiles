return {
	"williamboman/mason.nvim",
	cond = function()
		return #vim.api.nvim_list_uis() > 0
	end,
	lazy = false,
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local has_ui = #vim.api.nvim_list_uis() > 0

		require("mason").setup({
			ui = { border = "rounded" },
		})

		require("mason-lspconfig").setup({
			automatic_enable = false,
			ensure_installed = has_ui and {
				"lua_ls",
				"tsgo",
				"ts_ls",
				"oxlint",
				"kotlin_lsp",
				"angularls",
				"eslint",
				"biome",
				"html",
				"cssls",
				"tailwindcss",
				"jsonls",
				"yamlls",
				"docker_language_server",
				"marksman",
				"pyright",
				"ruff",
				"gopls",
				"clangd",
				"rust_analyzer",
				"sqls",
			} or {},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"dprint",
				"oxfmt",
				"stylua",
				"ktlint",
				"prettier",
				"ruff",
				"goimports",
				"gofumpt",
			},
			run_on_start = has_ui,
			start_delay = 1500,
			debounce_hours = 24,
		})
	end,
}
