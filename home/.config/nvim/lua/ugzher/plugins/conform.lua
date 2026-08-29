local prettier_config_files = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.yaml",
	".prettierrc.yml",
	".prettierrc.toml",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.ts",
	".prettierrc.cts",
	".prettierrc.mts",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
	"prettier.config.cts",
	"prettier.config.mts",
}

local dprint_config_files = {
	"dprint.json",
	".dprint.json",
	"dprint.jsonc",
	".dprint.jsonc",
}

local function has_prettier_config(dirname)
	if #vim.fs.find(prettier_config_files, { path = dirname, upward = true }) > 0 then
		return true
	end

	local package_file = vim.fs.find("package.json", { path = dirname, upward = true })[1]
	if not package_file then
		return false
	end

	local ok, lines = pcall(vim.fn.readfile, package_file)
	if not ok then
		return false
	end

	local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	return decoded and package.prettier ~= nil
end

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			desc = "Formater le fichier",
			mode = { "n", "v" },
		},
	},
	opts = {
		default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
		format_on_save = { lsp_format = "fallback", timeout_ms = 3000 },
		formatters_by_ft = {
			lua = { "stylua" },
			kotlin = { "ktlint" },
			python = { "ruff_organize_imports", "ruff_format" },
			rust = { "rustfmt", lsp_format = "fallback" },
			go = { "goimports", "gofumpt", stop_after_first = true },
			javascript = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			javascriptreact = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			typescript = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			typescriptreact = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			html = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			htmlangular = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			css = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			scss = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			less = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			yaml = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			json = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			jsonc = { "dprint", "biome", "prettier", "oxfmt", stop_after_first = true },
			markdown = { "dprint", "prettier", "oxfmt", stop_after_first = true },
			prisma = { "prettier" },
		},
		formatters = {
			dprint = {
				condition = function(_, ctx)
					return #vim.fs.find(dprint_config_files, { path = ctx.dirname, upward = true }) > 0
				end,
			},
			biome = {
				condition = function(_, ctx)
					return #vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.dirname, upward = true }) > 0
				end,
			},
			prettier = {
				condition = function(_, ctx)
					return has_prettier_config(ctx.dirname)
				end,
			},
		},
	},
}
