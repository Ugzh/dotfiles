return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp", lazy = false },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		------------------------------------------------------------------------
		-- on_attach
		------------------------------------------------------------------------
		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }
			local builtin = require("telescope.builtin")

			if client.server_capabilities.definitionProvider then
				keymap.set("n", "gd", builtin.lsp_definitions, opts)
			end
			if client.server_capabilities.referencesProvider then
				keymap.set("n", "gR", builtin.lsp_references, opts)
			end
			if client.server_capabilities.implementationProvider then
				keymap.set("n", "gi", builtin.lsp_implementations, opts)
			end
			if client.server_capabilities.typeDefinitionProvider then
				keymap.set("n", "gt", builtin.lsp_type_definitions, opts)
			end

			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			keymap.set("n", "K", vim.lsp.buf.hover, opts)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
			keymap.set("n", "<leader>D", builtin.diagnostics, opts)
			keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)
		end

		------------------------------------------------------------------------
		-- Capabilities
		------------------------------------------------------------------------
		local capabilities = cmp_nvim_lsp.default_capabilities()

		------------------------------------------------------------------------
		-- Diagnostics
		------------------------------------------------------------------------
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			virtual_text = { prefix = "●" },
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { border = "rounded", source = "always" },
		})

		------------------------------------------------------------------------
		-- LSP SERVER CONFIGS (Neovim 0.11+)
		------------------------------------------------------------------------

		-- clangd
		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--completion-style=detailed",
				"--cross-file-rename",
				"--header-insertion=never",
			},
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			root_dir = vim.fs.root(0, {
				"compile_commands.json",
				".clangd",
				"CMakeLists.txt",
				".git",
			}),
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				clangd = {
					fallbackFlags = { "-std=c++17", "-Wall", "-Wextra" },
				},
			},
		})

		-- lua_ls
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
					workspace = {
						library = {
							vim.fn.expand("$VIMRUNTIME/lua"),
							vim.fn.stdpath("config") .. "/lua",
						},
					},
					telemetry = { enable = false },
				},
			},
		})

		-- gopls
		vim.lsp.config("gopls", {
			cmd = { "gopls", "serve" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				gopls = {
					staticcheck = true,
					completeUnimported = true,
					usePlaceholders = true,
					semanticTokens = true,
				},
			},
		})

		-- tsserver
		vim.lsp.config("ts_ls", {
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
			root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Angular
		vim.lsp.config("angularls", {
			root_dir = vim.fs.root(0, { "angular.json", "project.json" }),
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- HTML
		vim.lsp.config("html", {
			filetypes = { "html", "htmlangular" },
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- CSS
		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Tailwind CSS
		vim.lsp.config("tailwindcss", {
			filetypes = {
				"html",
				"htmlangular",
				"css",
				"scss",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
				"svelte",
			},
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				tailwindCSS = {
					includeLanguages = {
						htmlangular = "html",
					},
				},
			},
		})

		-- JSON
		vim.lsp.config("jsonls", {
			filetypes = { "json", "jsonc" },
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Prisma
		vim.lsp.config("prismals", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		vim.lsp.config("pyright", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
						typeCheckingMode = "basic", -- can be "strict" for more aggressive typing
					},
				},
			},
		})

		------------------------------------------------------------------------
		-- ENABLE SERVERS
		------------------------------------------------------------------------
		vim.lsp.enable({
			"clangd",
			"lua_ls",
			"gopls",
			"ts_ls",
			"angularls",
			"html",
			"cssls",
			"tailwindcss",
			"jsonls",
			"prismals",
			"pyright",
		})
	end,
}
