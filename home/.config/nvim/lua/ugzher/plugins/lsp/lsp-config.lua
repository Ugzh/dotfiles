return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	init = function()
		vim.filetype.add({
			pattern = {
				[".*/compose%.ya?ml"] = "yaml.docker-compose",
				[".*/compose%..+%.ya?ml"] = "yaml.docker-compose",
				[".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
				[".*/docker%-compose%..+%.ya?ml"] = "yaml.docker-compose",
			},
		})
	end,
	dependencies = {
		"saghen/blink.cmp",
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		"b0o/SchemaStore.nvim",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		local diagnostic_virtual_text = { spacing = 3, prefix = "●", source = "if_many" }
		local function format_diagnostic_virtual_line(diagnostic)
			local message = diagnostic.message:gsub("\r", "")
			if diagnostic.source then
				message = diagnostic.source .. ": " .. message
			end
			if diagnostic.code then
				message = diagnostic.code .. ": " .. message
			end

			local width = math.max(40, math.min(100, vim.api.nvim_win_get_width(0) - 12))
			local lines = {}
			for source_line in (message .. "\n"):gmatch("(.-)\n") do
				local line = ""
				for word in source_line:gmatch("%S+") do
					local candidate = line == "" and word or line .. " " .. word
					if line ~= "" and vim.fn.strdisplaywidth(candidate) > width then
						table.insert(lines, line)
						line = word
					else
						line = candidate
					end
				end
				table.insert(lines, line)
			end

			return table.concat(lines, "\n")
		end
		local diagnostic_virtual_lines = { format = format_diagnostic_virtual_line }
		local typescript_servers = { "auto", "tsgo", "ts_ls" }
		local typescript_server_set = { tsgo = true, ts_ls = true }
		local typescript_filetypes = {
			javascript = true,
			javascriptreact = true,
			typescript = true,
			typescriptreact = true,
		}
		local typescript_state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "ugzher", "typescript-lsp.json")
		local default_typescript_root_dirs = {
			tsgo = vim.lsp.config.tsgo.root_dir,
			ts_ls = vim.lsp.config.ts_ls.root_dir,
		}
		local typescript_executables = {}
		local typescript_preferences

		local function canonical_path(path)
			return path and vim.fs.normalize(vim.uv.fs_realpath(path) or path) or nil
		end

		local function project_uses_tsgo(root)
			local package_file = canonical_path(root) and root .. "/package.json"
			if not package_file then
				return false
			end

			local ok, lines = pcall(vim.fn.readfile, package_file)
			if not ok then
				return false
			end

			local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
			if not decoded or type(package) ~= "table" then
				return false
			end

			local dependencies = package.dependencies or {}
			local dev_dependencies = package.devDependencies or {}
			return dependencies["@effect/tsgo"] ~= nil
				or dev_dependencies["@effect/tsgo"] ~= nil
				or dependencies["@typescript/native-preview"] ~= nil
				or dev_dependencies["@typescript/native-preview"] ~= nil
		end

		local function resolve_tsgo_executable(root)
			root = canonical_path(root)
			if not root then
				return "tsgo"
			end
			if typescript_executables[root] then
				return typescript_executables[root]
			end

			local local_tsgo = vim.fs.joinpath(root, "node_modules", ".bin", "tsgo")
			local executable = vim.fn.executable(local_tsgo) == 1 and local_tsgo or "tsgo"
			local effect_tsgo = vim.fs.joinpath(root, "node_modules", ".bin", "effect-tsgo")
			if vim.fn.executable(effect_tsgo) == 1 and vim.fn.executable("node") == 1 then
				local script = table.concat({
					"import getExePath from '@effect/tsgo/lib/getExePath';",
					"console.log(getExePath());",
				}, " ")
				local result = vim.system(
					{ "node", "--input-type=module", "--eval", script },
					{ text = true, cwd = root }
				)
					:wait()
				local effect_executable = vim.trim(result.stdout or "")
				if result.code == 0 and vim.fn.executable(effect_executable) == 1 then
					executable = effect_executable
				end
			end

			typescript_executables[root] = executable
			return executable
		end

		local function detected_typescript_server(root)
			return project_uses_tsgo(root) and "tsgo" or "ts_ls"
		end

		local function load_typescript_preferences()
			if typescript_preferences then
				return typescript_preferences
			end

			typescript_preferences = {}
			local ok, lines = pcall(vim.fn.readfile, typescript_state_file)
			if not ok then
				return typescript_preferences
			end

			local decoded, values = pcall(vim.json.decode, table.concat(lines, "\n"))
			if decoded and type(values) == "table" then
				for root, server in pairs(values) do
					if type(root) == "string" and typescript_server_set[server] then
						typescript_preferences[canonical_path(root)] = server
					end
				end
			end

			return typescript_preferences
		end

		local function typescript_server_for(root)
			return load_typescript_preferences()[canonical_path(root)] or detected_typescript_server(root)
		end

		local function save_typescript_preferences()
			vim.fn.mkdir(vim.fs.dirname(typescript_state_file), "p")
			local encoded = vim.json.encode(load_typescript_preferences())
			local ok, err = pcall(vim.fn.writefile, { encoded }, typescript_state_file)
			if not ok then
				vim.notify("Impossible d'enregistrer le choix LSP TypeScript : " .. tostring(err), vim.log.levels.ERROR)
			end
			return ok
		end

		local function resolve_typescript_root(bufnr)
			local root
			default_typescript_root_dirs.tsgo(bufnr, function(directory)
				root = canonical_path(directory)
			end)
			return root
		end

		local function selected_typescript_root_dir(server)
			return function(bufnr, on_dir)
				default_typescript_root_dirs[server](bufnr, function(directory)
					local root = canonical_path(directory)
					if typescript_server_for(root) == server then
						on_dir(root)
					end
				end)
			end
		end

		local function buffer_belongs_to_root(bufnr, root)
			if not vim.api.nvim_buf_is_loaded(bufnr) or not typescript_filetypes[vim.bo[bufnr].filetype] then
				return false
			end
			local filename = canonical_path(vim.api.nvim_buf_get_name(bufnr))
			return filename ~= nil and (filename == root or vim.startswith(filename, root .. "/"))
		end

		local function start_typescript_server(server, root)
			local config = vim.deepcopy(vim.lsp.config[server])
			config.root_dir = root
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if buffer_belongs_to_root(bufnr, root) then
					vim.lsp.start(config, { bufnr = bufnr })
				end
			end
		end

		local function set_typescript_server(root, server)
			root = canonical_path(root)
			if not root then
				return
			end
			if server ~= "auto" and not typescript_server_set[server] then
				vim.notify("LSP TypeScript inconnu : " .. tostring(server), vim.log.levels.ERROR)
				return
			end

			local current = typescript_server_for(root)
			local preferences = load_typescript_preferences()
			local previous_preference = preferences[root]
			if server == "auto" then
				preferences[root] = nil
				server = detected_typescript_server(root)
			else
				preferences[root] = server
			end

			if current == server and previous_preference == preferences[root] then
				vim.notify(("TypeScript utilise déjà %s pour %s"):format(server, root), vim.log.levels.INFO)
				return
			end

			if not save_typescript_preferences() then
				preferences[root] = previous_preference
				return
			end

			for _, client in ipairs(vim.lsp.get_clients()) do
				if typescript_server_set[client.name] and canonical_path(client.root_dir) == root then
					client:stop(true)
				end
			end

			start_typescript_server(server, root)
			vim.notify(("LSP TypeScript : %s pour %s"):format(server, root), vim.log.levels.INFO)
		end

		local function select_typescript_server(requested)
			local root = resolve_typescript_root(0)
			if not root then
				vim.notify("Aucun projet TypeScript/JavaScript standard détecté ici", vim.log.levels.WARN)
				return
			end

			if requested and requested ~= "" then
				set_typescript_server(root, requested)
				return
			end

			local current = typescript_server_for(root)
			vim.ui.select(typescript_servers, {
				prompt = "LSP TypeScript pour " .. vim.fn.fnamemodify(root, ":~"),
				format_item = function(server)
					local description
					if server == "auto" then
						description = "détection du projet (" .. detected_typescript_server(root) .. ")"
					elseif server == "tsgo" then
						description = "natif TypeScript 7"
					else
						description = "TypeScript classique, basé sur tsserver"
					end
					local selected = (
						server == current or (server == "auto" and not load_typescript_preferences()[root])
					)
							and "  ✓ actuel"
						or ""
					return ("%s — %s%s"):format(server, description, selected)
				end,
			}, function(server)
				if server then
					set_typescript_server(root, server)
				end
			end)
		end

		local oxlint_config_files = {
			".oxlintrc.json",
			".oxlintrc.jsonc",
			"oxlint.config.ts",
			"oxlint.config.mts",
		}

		local function package_dependency_root(filename, dependency)
			local dirname = vim.fs.dirname(filename)
			while dirname do
				local package_file = dirname .. "/package.json"
				if vim.uv.fs_stat(package_file) then
					local ok, lines = pcall(vim.fn.readfile, package_file)
					if ok then
						local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
						if decoded then
							local dependencies = package.dependencies or {}
							local dev_dependencies = package.devDependencies or {}
							if dependencies[dependency] or dev_dependencies[dependency] then
								return dirname
							end
						end
					end
				end

				local parent = vim.fs.dirname(dirname)
				if parent == dirname then
					break
				end
				dirname = parent
			end
		end

		local function oxlint_root(bufnr)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			local config_file = vim.fs.find(oxlint_config_files, { path = filename, upward = true })[1]
			if config_file then
				return vim.fs.dirname(config_file)
			end
			return package_dependency_root(filename, "oxlint")
		end

		local function without_oxlint(root_dir)
			return function(bufnr, on_dir)
				if oxlint_root(bufnr) then
					return
				end
				root_dir(bufnr, on_dir)
			end
		end

		vim.diagnostic.config({
			severity_sort = true,
			underline = true,
			update_in_insert = false,
			virtual_text = false,
			virtual_lines = diagnostic_virtual_lines,
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
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and typescript_server_set[client.name]
					and typescript_server_for(client.root_dir) ~= client.name
				then
					client:stop(true)
					return
				end

				local opts = { buffer = event.buf, silent = true }
				local map = function(lhs, rhs, desc, modes, extra_opts)
					local map_opts = vim.tbl_extend("force", opts, extra_opts or {})
					map_opts.desc = "LSP: " .. desc
					vim.keymap.set(modes or "n", lhs, rhs, map_opts)
				end

				map("gd", vim.lsp.buf.definition, "Définition")
				map("gD", vim.lsp.buf.declaration, "Déclaration")
				map("gi", vim.lsp.buf.implementation, "Implémentations")
				map("gy", vim.lsp.buf.type_definition, "Définition du type")
				map("gr", vim.lsp.buf.references, "Références")
				map("K", vim.lsp.buf.hover, "Documentation")
				map("<leader>ca", vim.lsp.buf.code_action, "Action de code", { "n", "v" })
				map("<leader>cr", function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end, "Renommer avec aperçu", "n", { expr = true, silent = false })
				map("<C-k>", vim.lsp.buf.signature_help, "Signature", "i")
				map("<leader>co", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.organizeImports" }, diagnostics = {} },
						apply = true,
					})
				end, "Organiser les imports")
				map("<leader>cd", vim.diagnostic.open_float, "Diagnostic de la ligne")
				map("<leader>cR", "<cmd>lsp restart<cr>", "Redémarrer le serveur")
				map("<leader>uv", function()
					local enabled = vim.diagnostic.config().virtual_lines ~= false
					vim.diagnostic.config({
						virtual_lines = enabled and false or diagnostic_virtual_lines,
						virtual_text = enabled and diagnostic_virtual_text or false,
					})
				end, "Afficher/masquer les diagnostics multilignes")

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

		vim.lsp.config("tsgo", {
			root_dir = selected_typescript_root_dir("tsgo"),
			cmd = function(dispatchers, config)
				local root = canonical_path((config or {}).root_dir)
				local executable = resolve_tsgo_executable(root)
				return vim.lsp.rpc.start({ executable, "--lsp", "--stdio" }, dispatchers)
			end,
			settings = {
				typescript = {
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
		vim.lsp.config("ts_ls", {
			root_dir = selected_typescript_root_dir("ts_ls"),
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "literals",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
					updateImportsOnFileMove = { enabled = "always" },
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "literals",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
					updateImportsOnFileMove = { enabled = "always" },
				},
			},
		})

		vim.api.nvim_create_user_command("TypeScriptLsp", function(command)
			select_typescript_server(command.args)
		end, {
			nargs = "?",
			complete = function()
				return typescript_servers
			end,
			desc = "Choisir le LSP TypeScript pour le projet courant",
		})
		vim.keymap.set("n", "<leader>cT", function()
			select_typescript_server()
		end, { desc = "Choisir le LSP TypeScript du projet" })

		vim.lsp.config("oxlint", {
			root_dir = function(bufnr, on_dir)
				local root = oxlint_root(bufnr)
				if root then
					on_dir(root)
				end
			end,
		})

		local eslint_before_init = vim.lsp.config.eslint.before_init
		vim.lsp.config("eslint", {
			root_dir = without_oxlint(vim.lsp.config.eslint.root_dir),
			before_init = function(params, config)
				if eslint_before_init then
					eslint_before_init(params, config)
				end

				local package_file = config.root_dir and config.root_dir .. "/node_modules/eslint/package.json"
				if not package_file then
					return
				end

				local ok, lines = pcall(vim.fn.readfile, package_file)
				if not ok then
					return
				end

				local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
				local version = decoded and type(package.version) == "string" and package.version
				local major = version and tonumber(version:match("^(%d+)"))
				if major == 8 then
					config.settings.experimental.useFlatConfig = true
				end
			end,
		})

		vim.lsp.config("biome", {
			root_dir = without_oxlint(vim.lsp.config.biome.root_dir),
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
			root_dir = function(bufnr, on_dir)
				local filename = vim.api.nvim_buf_get_name(bufnr)
				on_dir(vim.fs.root(filename, ".git") or vim.fs.dirname(filename))
			end,
			settings = {
				yaml = {
					schemaStore = { enable = false, url = "" },
					schemas = require("schemastore").yaml.schemas(),
				},
			},
		})
		vim.lsp.config("docker_language_server", {
			initializationOptions = { telemetry = "off" },
		})
		vim.lsp.config("rust_analyzer", {
			settings = { ["rust-analyzer"] = { check = { command = "clippy", extraArgs = { "--no-deps" } } } },
		})
		vim.lsp.config("gopls", {
			settings = { gopls = { staticcheck = true, completeUnimported = true, usePlaceholders = true } },
		})
		vim.lsp.config("ruff", {
			on_attach = function(client)
				-- Pyright reste la source de documentation et de typage ; Ruff gère le lint.
				client.server_capabilities.hoverProvider = false
			end,
		})

		vim.lsp.enable({
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
		})
	end,
}
