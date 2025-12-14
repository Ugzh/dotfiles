--New
return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				-- Use ONLY prettier for JS/TS formatting
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },

				-- Prettier for everything else
				html = { "prettier" },
				htmlangular = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },

				-- Other formatters
				lua = { "stylua" },
				go = { "goimports", "gofumpt" },
				prisma = { "prettier" },
			},

			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000, -- Increased timeout
			},

			formatters = {
				prettier = {
					prepend_args = function(self, ctx)
						-- Use the file's directory (not global CWD)
						local bufname = vim.api.nvim_buf_get_name(ctx.buf)
						local root = vim.fn.fnamemodify(bufname, ":h")
						local has_config = vim.fn.filereadable(root .. "/.prettierrc") == 1
							or vim.fn.filereadable(root .. "/.prettierrc.json") == 1
							or vim.fn.filereadable(root .. "/.prettierrc.js") == 1
							or vim.fn.filereadable(root .. "/prettier.config.js") == 1

						if has_config then
							return {}
						else
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
						end
					end,
				},
			},
		})

		-- Auto format on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				require("conform").format({
					bufnr = args.buf,
					timeout_ms = 2000,
					lsp_fallback = true,
				})
			end,
		})

		-- Manual format keymaps
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({ lsp_fallback = true, async = false, timeout_ms = 2000 })
		end, { desc = "Format file or selection" })

		vim.keymap.set("n", "<leader>f", function()
			conform.format({ lsp_fallback = true, async = false, timeout_ms = 2000 })
		end, { desc = "Format file" })
	end,
}

-- return {
-- 	"stevearc/conform.nvim",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	config = function()
-- 		local conform = require("conform")
--
-- 		conform.setup({
-- 			formatters_by_ft = {
-- 				javascript = { "eslint", "prettier" },
-- 				typescript = { "eslint", "prettier" },
-- 				javascriptreact = { "eslint", "prettier" },
-- 				typescriptreact = { "eslint", "prettier" },
--
-- 				-- ✅ Prettier for everything else
-- 				html = { "prettier" },
-- 				htmlangular = { "prettier" },
-- 				css = { "prettier" },
-- 				scss = { "prettier" },
-- 				less = { "prettier" },
-- 				json = { "prettier" },
-- 				jsonc = { "prettier" },
-- 				lua = { "stylua" },
-- 				go = { "goimports", "gofumpt" },
-- 				prisma = { "prettier" },
-- 				markdown = { "prettier" },
-- 			},
--
-- 			format_on_save = {
-- 				lsp_fallback = true,
-- 				async = false,
-- 				timeout_ms = 1000,
-- 			},
--
-- 			formatters = {
-- 				eslint = {
-- 					command = "npx",
-- 					args = { "eslint", "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
-- 				},
-- 			},
--
-- 			prettier = {
-- 				prepend_args = function(ctx)
-- 					-- Use the file’s directory (not global CWD)
-- 					local root = vim.fn.fnamemodify(ctx.bufname, ":h")
-- 					local has_config = vim.fn.filereadable(root .. "/.prettierrc") == 1
-- 						or vim.fn.filereadable(root .. "/.prettierrc.json") == 1
-- 						or vim.fn.filereadable(root .. "/.prettierrc.js") == 1
-- 						or vim.fn.filereadable(root .. "/prettier.config.js") == 1
--
-- 					if has_config then
-- 						return {}
-- 					else
-- 						return {
-- 							"--single-quote",
-- 							"--trailing-comma",
-- 							"es5",
-- 							"--print-width",
-- 							"100",
-- 							"--tab-width",
-- 							"2",
-- 							"--use-tabs",
-- 							"false",
-- 							"--semi",
-- 							"--html-whitespace-sensitivity",
-- 							"css",
-- 							"--bracket-same-line",
-- 							"false",
-- 						}
-- 					end
-- 				end,
-- 			},
-- 		})
--
-- 		-- 🔧 Auto format on save
-- 		vim.api.nvim_create_autocmd("BufWritePre", {
-- 			callback = function(args)
-- 				require("conform").format({ bufnr = args.buf })
-- 			end,
-- 		})
--
-- 		-- Manual format keymaps
-- 		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
-- 			conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
-- 		end, { desc = "Format file or selection" })
--
-- 		vim.keymap.set("n", "<leader>f", function()
-- 			conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
-- 		end, { desc = "Format file" })
-- 	end,
-- }
