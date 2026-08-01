return {
	"williamboman/mason.nvim",
	lazy = false,
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		require("mason").setup({
			ui = { border = "rounded" },
		})

		require("mason-lspconfig").setup({
			automatic_enable = false,
			ensure_installed = {
				"lua_ls",
				"vtsls",
				"kotlin_lsp",
				"angularls",
				"eslint",
				"biome",
				"html",
				"cssls",
				"tailwindcss",
				"jsonls",
				"yamlls",
				"marksman",
				"pyright",
				"ruff",
				"gopls",
				"clangd",
				"rust_analyzer",
				"sqls",
			},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"stylua",
				"ktlint",
				"prettier",
				"ruff",
				"goimports",
				"gofumpt",
			},
			run_on_start = true,
			start_delay = 1500,
			debounce_hours = 24,
		})
	end,
}
