return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		---------------------------------------------------------------------------
		-- Helpers
		---------------------------------------------------------------------------

		local biome_files = {
			"biome.json",
			"biome.jsonc",
			".biomerc",
			".biomerc.json",
			".biomerc.jsonc",
			".biomerc.cjs",
		}

		local function has_biome_config(bufnr)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			if fname == "" then
				return false
			end

			return vim.fs.find(biome_files, {
				upward = true,
				path = vim.fs.dirname(fname),
			})[1] ~= nil
		end

		---------------------------------------------------------------------------
		-- Setup
		---------------------------------------------------------------------------

		conform.setup({
			-------------------------------------------------------------------------
			-- Formatters per filetype
			-------------------------------------------------------------------------
			formatters_by_ft = {
				javascript = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				typescript = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				javascriptreact = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				typescriptreact = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				json = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				jsonc = function(bufnr)
					return has_biome_config(bufnr) and { "biome" } or { "prettier" }
				end,

				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				prisma = { "prettier" },
				lua = { "stylua" },
				go = { "goimports", "gofumpt" },
			},

			-------------------------------------------------------------------------
			-- Formatter definitions
			-------------------------------------------------------------------------
			formatters = {
				prettier = {
					prepend_args = function(self, ctx)
						-- ctx can be nil in some Conform execution paths
						if not ctx or not ctx.buf then
							return {}
						end

						local bufname = vim.api.nvim_buf_get_name(ctx.buf)
						if bufname == "" then
							return {}
						end

						local dir = vim.fn.fnamemodify(bufname, ":h")

						local has_config = vim.fn.filereadable(dir .. "/.prettierrc") == 1
							or vim.fn.filereadable(dir .. "/.prettierrc.json") == 1
							or vim.fn.filereadable(dir .. "/.prettierrc.js") == 1
							or vim.fn.filereadable(dir .. "/prettier.config.js") == 1

						if has_config then
							return {}
						end

						return {
							"--single-quote",
							"--trailing-comma=es5",
							"--print-width=100",
							"--tab-width=2",
							"--use-tabs=false",
							"--semi",
							"--html-whitespace-sensitivity=css",
							"--bracket-same-line=false",
						}
					end,
				},

				biome = {
					command = "biome",
					args = { "format", "--stdin-file-path", "$FILENAME" },
				},
			},
		})

		---------------------------------------------------------------------------
		-- Auto format on save
		---------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				conform.format({
					bufnr = args.buf,
					timeout_ms = 2000,
					lsp_fallback = true,
				})
			end,
		})

		---------------------------------------------------------------------------
		-- Keymaps
		---------------------------------------------------------------------------
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			})
		end, { desc = "Format file or selection" })

		vim.keymap.set("n", "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			})
		end, { desc = "Format file" })
	end,
}
