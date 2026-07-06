return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp", lazy = false },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		{ "b0o/SchemaStore.nvim" },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }
			local builtin = require("telescope.builtin")

			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

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
			keymap.set("n", "<leader>rs", "<cmd>lsp restart<CR>", opts)
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()
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
			float = { border = "rounded", source = true, wrap = true, max_width = 80 },
		})

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
		-- vim.lsp.config("tsgo", {
		-- 	cmd = { "tsgo", "--lsp", "--stdio" },
		-- 	filetypes = {
		-- 		"javascript",
		-- 		"javascriptreact",
		-- 		"typescript",
		-- 		"typescriptreact",
		-- 	},
		-- 	root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- })
		--
		vim.lsp.config("ts_ls", {
			root_markers = { "package.json", "tsconfig.json", ".git" },
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
			root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				hostInfo = "neovim",
				maxTsServerMemory = 8192,
				preferences = {
					includePackageJsonAutoImports = "on",
					includeCompletionsForModuleExports = true,
					includeCompletionsWithInsertText = true,
				},
			},
			flags = {
				debounce_text_changes = 150,
			},
		})

		-- vim.lsp.config("ts_ls", {
		-- 	root_markers = { "package.json", "tsconfig.json", ".git" },
		-- 	cmd = { "typescript-language-server", "--stdio" },
		-- 	filetypes = {
		-- 		"javascript",
		-- 		"javascriptreact",
		-- 		"typescript",
		-- 		"typescriptreact",
		-- 	},
		-- 	root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	init_options = {
		-- 		hostInfo = "neovim",
		-- 		maxTsServerMemory = 8192,
		-- 	},
		-- 	settings = {
		-- 		typescript = {
		-- 			tsserver_max_memory = 8192,
		-- 			suggest = {
		-- 				includeCompletionsForModuleExports = true,
		-- 				includeCompletionsWithInsertText = true,
		-- 			},
		-- 		},
		-- 		javascript = {
		-- 			suggest = {
		-- 				includeCompletionsForModuleExports = true,
		-- 				includeCompletionsWithInsertText = true,
		-- 			},
		-- 		},
		-- 	},
		-- 	flags = {
		-- 		debounce_text_changes = 150,
		-- 	},
		-- })

		-- vim.lsp.config("angularls", {
		-- 	root_markers = { "angular.json", "nx.json" },
		--
		-- 	on_new_config = function(new_config, new_root_dir)
		-- 		if not new_root_dir then
		-- 			new_config.enabled = false
		-- 		end
		-- 	end,
		--
		-- 	single_file_support = false,
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- })

		vim.lsp.config("html", {
			filetypes = { "html", "htmlangular" },
			capabilities = capabilities,
			on_attach = on_attach,
		})

		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

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

		vim.lsp.config("jsonls", {
			filetypes = { "json", "jsonc" },
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
						diagnosticMode = "openFilesOnly",
						typeCheckingMode = "basic",
					},
				},
			},
		})

		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				["rust-analyzer"] = {
					check = {
						command = "clippy",
						extraArgs = { "--no-deps" },
					},
				},
			},
		})

		vim.lsp.config("yamlls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
				},
			},
		})

		vim.lsp.enable({
			"clangd",
			"lua_ls",
			"gopls",
			"yamlls",
			-- "tsgo",
			"ts_ls",
			"angularls",
			"html",
			"cssls",
			"tailwindcss",
			"jsonls",
			"pyright",
			"rust_analyzer",
		})
	end,
}
