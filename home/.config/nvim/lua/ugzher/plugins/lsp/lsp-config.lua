return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		"b0o/SchemaStore.nvim",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.diagnostic.config({
			severity_sort = true,
			underline = true,
			update_in_insert = false,
			virtual_text = { spacing = 3, prefix = "●", source = "if_many" },
			virtual_lines = false,
			float = { border = "rounded", source = true, max_width = 90 },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("ugzher-lsp-attach", { clear = true }),
			callback = function(event)
				local opts = { buffer = event.buf, silent = true }
				local map = function(lhs, rhs, desc, modes)
					opts.desc = "LSP: " .. desc
					vim.keymap.set(modes or "n", lhs, rhs, opts)
				end

				map("gd", vim.lsp.buf.definition, "Définition")
				map("gD", vim.lsp.buf.declaration, "Déclaration")
				map("gi", vim.lsp.buf.implementation, "Implémentations")
				map("gy", vim.lsp.buf.type_definition, "Définition du type")
				map("gr", vim.lsp.buf.references, "Références")
				map("K", vim.lsp.buf.hover, "Documentation")
				map("<leader>ca", vim.lsp.buf.code_action, "Action de code", { "n", "v" })
				map("<leader>cr", vim.lsp.buf.rename, "Renommer")
				map("<C-k>", vim.lsp.buf.signature_help, "Signature", "i")
				map("<leader>co", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.organizeImports" }, diagnostics = {} },
						apply = true,
					})
				end, "Organiser les imports")
				map("<leader>cd", vim.diagnostic.open_float, "Diagnostic de la ligne")
				map("<leader>cR", "<cmd>lsp restart<cr>", "Redémarrer le serveur")

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					map("<leader>uh", function()
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
					end, "Afficher/masquer les inlay hints")
				end
			end,
		})

		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					completion = { callSnippet = "Replace" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		})

		vim.lsp.config("vtsls", {
			root_dir = function(bufnr, on_dir)
				if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
					return
				end
				local root = vim.fs.root(bufnr, {
					"tsconfig.json",
					"jsconfig.json",
					"package.json",
					"pnpm-lock.yaml",
					"yarn.lock",
					"package-lock.json",
					"bun.lock",
					".git",
				})
				if root then
					on_dir(root)
				end
			end,
			settings = {
				complete_function_calls = true,
				typescript = {
					updateImportsOnFileMove = { enabled = "always" },
					suggest = { completeFunctionCalls = true },
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = false },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
			},
		})

		-- Mason expose actuellement le serveur Kotlin officiel sous ce nom.
		vim.lsp.config("kotlin_lsp", {
			cmd = { vim.fn.stdpath("data") .. "/mason/bin/intellij-server", "--stdio" },
			root_markers = {
				"settings.gradle.kts",
				"settings.gradle",
				"build.gradle.kts",
				"build.gradle",
				"pom.xml",
				"gradlew",
				".git",
			},
		})

		vim.lsp.config("angularls", {
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, { "angular.json", "nx.json" })
				if root then
					on_dir(root)
				end
			end,
		})

		vim.lsp.config("tailwindcss", {
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, {
					"tailwind.config.js",
					"tailwind.config.cjs",
					"tailwind.config.mjs",
					"tailwind.config.ts",
				})
				if not root then
					local package_file =
						vim.fs.find("package.json", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1]
					if package_file then
						local ok, package = pcall(vim.fn.readfile, package_file)
						if ok and table.concat(package, "\n"):find("tailwindcss", 1, true) then
							root = vim.fs.dirname(package_file)
						end
					end
				end
				if root then
					on_dir(root)
				end
			end,
		})

		vim.lsp.config("jsonls", {
			settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
		})
		vim.lsp.config("yamlls", {
			settings = {
				yaml = {
					schemaStore = { enable = false, url = "" },
					schemas = require("schemastore").yaml.schemas(),
				},
			},
		})
		vim.lsp.config("rust_analyzer", {
			settings = { ["rust-analyzer"] = { check = { command = "clippy", extraArgs = { "--no-deps" } } } },
		})
		vim.lsp.config("gopls", {
			settings = { gopls = { staticcheck = true, completeUnimported = true, usePlaceholders = true } },
		})

		vim.lsp.enable({
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
		})
	end,
}
