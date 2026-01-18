return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettier", "biome", stop_after_first = true },
				typescript = { "prettier", "biome", stop_after_first = true },
				html = { "prettier", "biome", stop_after_first = true },
				css = { "prettier", "biome", stop_after_first = true },
				scss = { "prettier", "biome", stop_after_first = true },
				less = { "prettier", "biome", stop_after_first = true },
				yaml = { "prettier" },
				markdown = { "prettier" },
				prisma = { "prettier" },
				go = { "goimports", "gofumpt", stop_after_first = true },
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				conform.format({
					bufnr = args.buf,
					lsp_fallback = true,
					timeout_ms = 500,
				})
			end,
		})
	end,
}
