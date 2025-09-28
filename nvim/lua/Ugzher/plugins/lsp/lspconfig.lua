return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		-- "saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- NOTE: LSP Keybinds
		vim.g.auto_format_enabled = true
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings
				-- Check `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- keymaps
				opts.desc = "Show LSP references"
				vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				vim.keymap.set({ "n", "v" }, "<leader>vca", function()
					vim.lsp.buf.code_action()
				end, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessarily

				-- Modified auto-format to exclude HTML files
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = ev.buf,
					callback = function()
						-- Get the current buffer's filetype
						local filetype = vim.bo[ev.buf].filetype

						-- Skip formatting for HTML files
						if vim.g.auto_format_enabled and filetype ~= "html" then
							vim.lsp.buf.format({
								async = false,
								id = ev.data.client_id,
							})
						end
					end,
				})

				vim.api.nvim_create_user_command("ToggleAutoFormat", function()
					vim.g.auto_format_enabled = not vim.g.auto_format_enabled
					print("Auto-format on save: " .. (vim.g.auto_format_enabled and "enabled" or "disabled"))
				end, {})

				vim.keymap.set("i", "<C-h>", function()
					vim.lsp.buf.signature_help()
				end, opts)
			end,
		})

		-- NOTE : Moved all this to Mason including local variables
		-- used to enable autocompletion (assign to every lsp server config)
		-- local capabilities = cmp_nvim_lsp.default_capabilities()
		-- Change the Diagnostic symbols in the sign column (gutter)

		-- Define sign icons for each severity
		local signs = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		}

		-- Set the diagnostic config with all icons
		vim.diagnostic.config({
			signs = {
				text = signs, -- Enable signs in the gutter
			},
			virtual_text = true, -- Specify Enable virtual text for diagnostics
			underline = true, -- Specify Underline diagnostics
			update_in_insert = false, -- Keep diagnostics active in insert mode
		})

		-- NOTE :
		-- Moved back from mason_lspconfig.setup_handlers from mason.lua file
		-- as mason setup_handlers is deprecated & its causing issues with lsp settings
		--
		-- Setup servers
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Config lsp servers here
		-- lua_ls
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
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
				},
			},
		})

		-- emmet_language_server
		lspconfig.emmet_language_server.setup({
			capabilities = capabilities,
			filetypes = {
				"css",
				"eruby",
				"html",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"pug",
				"typescriptreact",
			},
			init_options = {
				includeLanguages = {},
				excludeLanguages = {},
				extensionsPath = {},
				preferences = {},
				showAbbreviationSuggestions = true,
				showExpandedAbbreviation = "always",
				showSuggestionsAsSnippets = false,
				syntaxProfiles = {},
				variables = {},
			},
		})

		-- HTML LSP setup with formatting disabled
		lspconfig.html.setup({
			capabilities = capabilities,
			filetypes = { "html", "htm" },
			init_options = {
				configurationSection = { "html", "css", "javascript" },
				embeddedLanguages = {
					css = true,
					javascript = true,
				},
				provideFormatter = false, -- Disable HTML formatter
			},
			-- Disable formatting capability on attach
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end,
		})

		-- denols
		lspconfig.denols.setup({
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
		})

		-- ts_ls (replaces tsserver)
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			root_dir = function(fname)
				local util = lspconfig.util
				return not util.root_pattern("deno.json", "deno.jsonc")(fname)
					and util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
			end,
			single_file_support = false,
			init_options = {
				preferences = {
					includeCompletionsWithSnippetText = true,
					includeCompletionsForImportStatements = true,
				},
			},
		})

		lspconfig.angularls.setup({
			cmd = {
				"ngserver",
				"--stdio",
				"--tsProbeLocations",
				vim.fn.getcwd(),
				"--ngProbeLocations",
				vim.fn.getcwd(),
				"--includePackageJsonAutoImports",
				"on",
			},
			on_new_config = function(new_config, new_root_dir)
				local function get_typescript_server_path(root_dir)
					local project_root = lspconfig.util.find_node_modules_ancestor(root_dir)
					return project_root
							and (lspconfig.util.path.join(project_root, "node_modules", "typescript", "lib"))
						or ""
				end

				if new_config.init_options == nil then
					new_config.init_options = {}
				end

				-- Explicitly set the working directory and probe locations
				new_config.init_options.typescript = {
					serverPath = get_typescript_server_path(new_root_dir),
				}
				new_config.init_options.angular = {
					suggest = {
						includeCompletionsWithSnippetText = true,
						includeAutomaticOptionalChainCompletions = true,
					},
				}

				-- Override the command to include explicit probe locations
				new_config.cmd = {
					"ngserver",
					"--stdio",
					"--tsProbeLocations",
					new_root_dir,
					"--ngProbeLocations",
					new_root_dir,
					"--includePackageJsonAutoImports",
					"on",
				}
			end,

			filetypes = {
				"html",
				"angularHtml",
				"htmlangular",
				"typescriptreact",
				"typescript.tsx",
			},

			root_dir = lspconfig.util.root_pattern("angular.json", "project.json"),

			capabilities = vim.tbl_deep_extend("force", capabilities, {
				general = {
					positionEncodings = { "utf-16" },
				},
			}),
		})

		-- lspconfig.angularls.setup({
		--   on_new_config = function(new_config, new_root_dir)
		--     local function get_typescript_server_path(root_dir)
		--       local project_root = lspconfig.util.find_node_modules_ancestor(root_dir)
		--       return project_root
		--           and (lspconfig.util.path.join(project_root, "node_modules", "typescript", "lib"))
		--           or ""
		--     end
		--     if new_config.init_options == nil then
		--       new_config.init_options = {}
		--     end
		--     new_config.init_options.typescript = {
		--       serverPath = get_typescript_server_path(new_root_dir),
		--     }
		--     new_config.init_options.angular = {
		--       suggest = {
		--         includeCompletionsWithSnippetText = true,
		--         includeAutomaticOptionalChainCompletions = true,
		--       },
		--     }
		--   end,
		--   -- Add angularHtml to the filetypes list
		--   filetypes = {
		--     "typescript",
		--     "html",
		--     "angularHtml",
		--     "htmlangular",
		--     "typescriptreact",
		--     "typescript.tsx",
		--   },
		--   root_dir = lspconfig.util.root_pattern("angular.json", "project.json"),
		--   capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		--     general = {
		--       positionEncodings = { "utf-16" },
		--     },
		--   }),
		-- })
		--
		-- CSS Language Server
		lspconfig.cssls.setup({
			capabilities = capabilities,
			filetypes = { "css", "scss", "sass", "less" },
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
						duplicateProperties = "warning",
						emptyRuleSet = "warning",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
						duplicateProperties = "warning",
						emptyRuleSet = "warning",
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
						duplicateProperties = "warning",
						emptyRuleSet = "warning",
					},
				},
			},
		})

		lspconfig.jsonls.setup({
			capabilities = capabilities,
			filetypes = { "json", "jsonc" },
			settings = {
				json = {
					schemas = {
						-- Add common JSON schemas for better validation
						{
							fileMatch = { "package.json" },
							url = "https://json.schemastore.org/package.json",
						},
						{
							fileMatch = { "tsconfig.json", "tsconfig*.json" },
							url = "https://json.schemastore.org/tsconfig.json",
						},
						{
							fileMatch = { ".eslintrc", ".eslintrc.json" },
							url = "https://json.schemastore.org/eslintrc.json",
						},
						{
							fileMatch = { ".prettierrc", ".prettierrc.json" },
							url = "https://json.schemastore.org/prettierrc.json",
						},
						{
							fileMatch = { "composer.json" },
							url = "https://json.schemastore.org/composer.json",
						},
						-- Add more schemas as needed
					},
					validate = { enable = true },
					format = { enable = true },
				},
			},
		})
		-- tailwindcss
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
			filetypes = {
				"html",
				"css",
				"scss",
				"sass",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"svelte",
				"vue",
				"astro",
				"rust",
				"php",
				"blade",
			},
			init_options = {
				userLanguages = {
					-- If you want to add support for other filetypes, e.g.:
					-- elixir = "html-eex",
					-- eruby = "erb",
				},
			},
			settings = {
				tailwindCSS = {
					experimental = {
						classRegex = {
							-- If you use custom class regexes, add them here
							-- Example for Twig:
							-- {{[\t ]*([^}\s]*)
							-- 'tw`([^`]*)',
							-- tw="([^"]*)",
							-- tw={'([^']*)'},
							-- Tw\.(?:c|class)\(['"]([^'"]*)['"]\)
						},
					},
				},
			},
		})

		-- gopls LSP configuration
		lspconfig.gopls.setup({
			capabilities = capabilities,
			cmd = { "gopls" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
			on_attach = function(client, bufnr)
				-- disable LSP formatting for Go
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end,
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						shadow = true,
						fieldalignment = false, -- Can be noisy, disable if needed
						nilness = true,
						unusedwrite = true,
						useany = true,
					},
					codelenses = {
						generate = true, -- Show generate code lens
						gc_details = false, -- Show GC details code lens
						test = true, -- Show test code lens
						tidy = true, -- Show tidy code lens
						upgrade_dependency = true, -- Show upgrade dependency code lens
						vendor = true, -- Show vendor code lens
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true, -- Enable staticcheck analysis
					gofumpt = false, -- Enable gofumpt formatting (if installed)
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					semanticTokens = true, -- Enable semantic tokens for better highlighting
					-- Build flags and environment
					env = {
						GOFLAGS = "-tags=integration", -- Add any build tags you commonly use
					},
					-- Directory filters
					directoryFilters = {
						"-node_modules",
						"-.git",
						"-vendor", -- Exclude vendor directory from analysis
					},
				},
			},
		})
		-- Alternative: Create a separate command for HTML-only formatting toggle
		vim.api.nvim_create_user_command("ToggleHtmlFormat", function()
			local html_format_enabled = vim.g.html_format_enabled or false
			vim.g.html_format_enabled = not html_format_enabled
			print("HTML auto-format on save: " .. (vim.g.html_format_enabled and "enabled" or "disabled"))
		end, {})
	end,
}
