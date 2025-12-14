-- lua/Ugzher/plugins/lsp/lspconfig.lua
-- LSP configuration with all language servers
--
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

		-- LSP attach function with keymaps
		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }
			-- Keybindings
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)
			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		-- Enhanced capabilities
		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = "  ",
				},
			},
			virtual_text = { prefix = "●" },
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = "always",
			},
		})

		-- Helper function for root_dir patterns
		local function root_pattern(...)
			local patterns = { ... }
			return function(fname)
				local util = require("lspconfig.util")
				return util.root_pattern(unpack(patterns))(fname) or vim.fn.getcwd()
			end
		end

		-- Clangd LSP
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
			root_dir = root_pattern(
				"compile_commands.json",
				"compile_flags.txt",
				".clangd",
				".clang-format",
				"CMakeLists.txt",
				"Makefile",
				".git"
			),
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				clangd = {
					fallbackFlags = {
						"-std=c++17",
						"-Wall",
						"-Wextra",
					},
				},
			},
		})

		-- Lua LSP (lua_ls)
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- Go LSP (gopls)
		vim.lsp.config("gopls", {
			cmd = { "gopls", "serve" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_dir = root_pattern("go.work", "go.mod", ".git"),
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						shadow = true,
						nilness = true,
						unusedwrite = true,
						useany = true,
					},
					codelenses = {
						generate = true,
						gc_details = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						regenerate_cgo = true,
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					matcher = "Fuzzy",
					deepCompletion = true,
					symbolMatcher = "FastFuzzy",
					symbolStyle = "Dynamic",
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					diagnosticsDelay = "500ms",
					semanticTokens = true,
					directoryFilters = {
						"-**/node_modules",
						"-**/.git",
						"-**/vendor",
					},
					buildFlags = {},
					env = {
						GOFLAGS = "-tags=",
					},
				},
			},
		})

		-- TypeScript/JavaScript LSP (ts_ls)
		vim.lsp.config("ts_ls", {
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
			root_dir = root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		-- Angular LSP
		vim.lsp.config("angularls", {
			root_dir = root_pattern("angular.json", "project.json"),
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- HTML LSP
		vim.lsp.config("html", {
			filetypes = { "html", "htmlangular" },
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- CSS LSP
		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})

		-- Tailwind CSS LSP
		vim.lsp.config("tailwindcss", {
			filetypes = {
				"html",
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
					experimental = {
						classRegex = {
							{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
							{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
						},
					},
				},
			},
		})

		-- JSON LSP
		vim.lsp.config("jsonls", {
			filetypes = { "json", "jsonc" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				json = {
					schemas = {
						{
							fileMatch = { "package.json" },
							url = "https://json.schemastore.org/package.json",
						},
						{
							fileMatch = { "tsconfig*.json" },
							url = "https://json.schemastore.org/tsconfig.json",
						},
						{
							fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
							url = "https://json.schemastore.org/prettierrc.json",
						},
						{
							fileMatch = { ".eslintrc", ".eslintrc.json" },
							url = "https://json.schemastore.org/eslintrc.json",
						},
					},
					validate = { enable = true },
				},
			},
		})

		-- Prisma LSP
		vim.lsp.config("prismals", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Enable the LSP servers
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
		})
	end,
}

-- return {
-- 	"neovim/nvim-lspconfig",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	dependencies = {
-- 		{ "hrsh7th/cmp-nvim-lsp", lazy = false },
-- 		{ "antosha417/nvim-lsp-file-operations", config = true },
-- 		{ "folke/neodev.nvim", opts = {} },
-- 	},
-- 	config = function()
-- 		local lspconfig = require("lspconfig")
-- 		local cmp_nvim_lsp = require("cmp_nvim_lsp")
-- 		local keymap = vim.keymap
--
-- 		-- LSP attach function with keymaps
-- 		local on_attach = function(client, bufnr)
-- 			local opts = { noremap = true, silent = true, buffer = bufnr }
-- 			-- Keybindings
-- 			opts.desc = "Show LSP references"
-- 			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
-- 			opts.desc = "Go to declaration"
-- 			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
-- 			opts.desc = "Show LSP definitions"
-- 			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
-- 			opts.desc = "Show LSP implementations"
-- 			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
-- 			opts.desc = "Show LSP type definitions"
-- 			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
-- 			opts.desc = "See available code actions"
-- 			keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
-- 			opts.desc = "Smart rename"
-- 			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
-- 			opts.desc = "Show buffer diagnostics"
-- 			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
-- 			opts.desc = "Show line diagnostics"
-- 			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
-- 			opts.desc = "Show documentation for what is under cursor"
-- 			keymap.set("n", "K", vim.lsp.buf.hover, opts)
-- 			opts.desc = "Restart LSP"
-- 			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
-- 		end
--
-- 		-- Enhanced capabilities
-- 		local capabilities = cmp_nvim_lsp.default_capabilities()
--
-- 		vim.diagnostic.config({
-- 			signs = {
-- 				text = {
-- 					[vim.diagnostic.severity.ERROR] = " ",
-- 					[vim.diagnostic.severity.WARN] = " ",
-- 					[vim.diagnostic.severity.HINT] = "󰠠 ",
-- 					[vim.diagnostic.severity.INFO] = "  ",
-- 				},
-- 			},
-- 			virtual_text = { prefix = "●" },
-- 			underline = true,
-- 			update_in_insert = false,
-- 			severity_sort = true,
-- 			float = {
-- 				border = "rounded",
-- 				source = "always",
-- 			},
-- 		})
--
-- 		lspconfig.clangd.setup({
-- 			on_attach = on_attach,
-- 			capabilities = capabilities,
-- 			cmd = {
-- 				"clangd",
-- 				"--background-index",
-- 				"--clang-tidy",
-- 				"--completion-style=detailed",
-- 				"--cross-file-rename",
-- 				"--header-insertion=never", -- Prevents automatic header insertion
-- 			},
-- 			filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
-- 			-- Make root_dir more flexible - it will work even without project files
-- 			root_dir = function(fname)
-- 				return lspconfig.util.root_pattern(
-- 					"compile_commands.json",
-- 					"compile_flags.txt",
-- 					".clangd",
-- 					".clang-format",
-- 					"CMakeLists.txt",
-- 					"Makefile",
-- 					".git"
-- 				)(fname) or vim.fn.getcwd() -- Fallback to current working directory
-- 			end,
-- 			init_options = {
-- 				clangdFileStatus = true,
-- 				usePlaceholders = true,
-- 				completeUnimported = true,
-- 				semanticHighlighting = true,
-- 			},
-- 			-- Add formatting settings
-- 			settings = {
-- 				clangd = {
-- 					fallbackFlags = {
-- 						"-std=c++17",
-- 						"-Wall",
-- 						"-Wextra",
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- Lua LSP (lua_ls)
-- 		lspconfig.lua_ls.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			settings = {
-- 				Lua = {
-- 					diagnostics = {
-- 						globals = { "vim" },
-- 					},
-- 					completion = {
-- 						callSnippet = "Replace",
-- 					},
-- 					workspace = {
-- 						library = {
-- 							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
-- 							[vim.fn.stdpath("config") .. "/lua"] = true,
-- 						},
-- 					},
-- 					telemetry = {
-- 						enable = false,
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		lspconfig.gopls.setup({
-- 			on_attach = on_attach,
-- 			capabilities = capabilities,
-- 			cmd = { "gopls", "serve" },
-- 			filetypes = { "go", "gomod", "gowork", "gotmpl" },
-- 			root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
-- 			settings = {
-- 				gopls = {
-- 					-- Analysis settings
-- 					analyses = {
-- 						unusedparams = true,
-- 						shadow = true,
-- 						nilness = true,
-- 						unusedwrite = true,
-- 						useany = true,
-- 					},
--
-- 					-- Code lens
-- 					codelenses = {
-- 						generate = true, -- Show "run go generate" lens
-- 						gc_details = true, -- Show garbage collection details
-- 						test = true, -- Show "run test" lens
-- 						tidy = true, -- Show "run go mod tidy" lens
-- 						upgrade_dependency = true,
-- 						regenerate_cgo = true,
-- 					},
--
-- 					-- Completion settings
-- 					usePlaceholders = true, -- Placeholders for function parameters
-- 					completeUnimported = true, -- Autocomplete unimported packages
-- 					staticcheck = true, -- Enable staticcheck
-- 					matcher = "Fuzzy", -- Fuzzy matching for completion
-- 					deepCompletion = true, -- Enable deep completion
--
-- 					-- Symbol matching
-- 					symbolMatcher = "FastFuzzy",
-- 					symbolStyle = "Dynamic", -- Show full package paths
--
-- 					-- Hints
-- 					hints = {
-- 						assignVariableTypes = true,
-- 						compositeLiteralFields = true,
-- 						compositeLiteralTypes = true,
-- 						constantValues = true,
-- 						functionTypeParameters = true,
-- 						parameterNames = true,
-- 						rangeVariableTypes = true,
-- 					},
--
-- 					-- Diagnostics
-- 					diagnosticsDelay = "500ms",
--
-- 					-- Semantic tokens
-- 					semanticTokens = true,
--
-- 					-- Workspace settings
-- 					directoryFilters = {
-- 						"-**/node_modules",
-- 						"-**/.git",
-- 						"-**/vendor",
-- 					},
--
-- 					-- Build flags
-- 					buildFlags = {},
-- 					env = {
-- 						GOFLAGS = "-tags=",
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- TypeScript/JavaScript LSP (ts_ls)
-- 		lspconfig.ts_ls.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			filetypes = {
-- 				"javascript",
-- 				"javascriptreact",
-- 				"javascript.jsx",
-- 				"typescript",
-- 				"typescriptreact",
-- 				"typescript.tsx",
-- 			},
-- 			root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
-- 			settings = {
-- 				typescript = {
-- 					inlayHints = {
-- 						includeInlayParameterNameHints = "all",
-- 						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
-- 						includeInlayFunctionParameterTypeHints = true,
-- 						includeInlayVariableTypeHints = true,
-- 						includeInlayPropertyDeclarationTypeHints = true,
-- 						includeInlayFunctionLikeReturnTypeHints = true,
-- 						includeInlayEnumMemberValueHints = true,
-- 					},
-- 				},
-- 				javascript = {
-- 					inlayHints = {
-- 						includeInlayParameterNameHints = "all",
-- 						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
-- 						includeInlayFunctionParameterTypeHints = true,
-- 						includeInlayVariableTypeHints = true,
-- 						includeInlayPropertyDeclarationTypeHints = true,
-- 						includeInlayFunctionLikeReturnTypeHints = true,
-- 						includeInlayEnumMemberValueHints = true,
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- Angular LSP
-- 		lspconfig.angularls.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			root_dir = lspconfig.util.root_pattern("angular.json", "project.json"),
-- 		})
--
-- 		-- HTML LSP
-- 		lspconfig.html.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			filetypes = { "html", "htmlangular" },
-- 		})
--
-- 		-- CSS LSP
-- 		lspconfig.cssls.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			settings = {
-- 				css = {
-- 					validate = true,
-- 					lint = {
-- 						unknownAtRules = "ignore",
-- 					},
-- 				},
-- 				scss = {
-- 					validate = true,
-- 					lint = {
-- 						unknownAtRules = "ignore",
-- 					},
-- 				},
-- 				less = {
-- 					validate = true,
-- 					lint = {
-- 						unknownAtRules = "ignore",
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- Tailwind CSS LSP
-- 		lspconfig.tailwindcss.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			filetypes = {
-- 				"html",
-- 				"css",
-- 				"scss",
-- 				"javascript",
-- 				"javascriptreact",
-- 				"typescript",
-- 				"typescriptreact",
-- 				"vue",
-- 				"svelte",
-- 			},
-- 			settings = {
-- 				tailwindCSS = {
-- 					experimental = {
-- 						classRegex = {
-- 							{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
-- 							{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
-- 						},
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- JSON LSP
-- 		lspconfig.jsonls.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			filetypes = { "json", "jsonc" },
-- 			settings = {
-- 				json = {
-- 					schemas = {
-- 						{
-- 							fileMatch = { "package.json" },
-- 							url = "https://json.schemastore.org/package.json",
-- 						},
-- 						{
-- 							fileMatch = { "tsconfig*.json" },
-- 							url = "https://json.schemastore.org/tsconfig.json",
-- 						},
-- 						{
-- 							fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
-- 							url = "https://json.schemastore.org/prettierrc.json",
-- 						},
-- 						{
-- 							fileMatch = { ".eslintrc", ".eslintrc.json" },
-- 							url = "https://json.schemastore.org/eslintrc.json",
-- 						},
-- 					},
-- 					validate = { enable = true },
-- 				},
-- 			},
-- 		})
--
-- 		-- Prisma LSP
-- 		lspconfig.prismals.setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 		})
-- 	end,
-- }
