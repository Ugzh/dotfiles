return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Find project root directory
		local function find_project_root()
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				return vim.fn.getcwd()
			end

			local root_patterns = {
				"biome.json",
				"biome.jsonc",
				"package.json",
				".git",
			}

			local root = vim.fs.dirname(vim.fs.find(root_patterns, {
				upward = true,
				path = vim.fs.dirname(bufname),
			})[1])

			return root or vim.fn.getcwd()
		end

		-- Check if biome config exists in project root
		local function has_biome_config()
			local root = find_project_root()
			local biome_files = {
				"biome.json",
				"biome.jsonc",
				".biomerc",
				".biomerc.json",
				".biomerc.jsonc",
				".biomerc.cjs",
			}

			for _, file in ipairs(biome_files) do
				local full_path = root .. "/" .. file
				if vim.fn.filereadable(full_path) == 1 then
					return true
				end
			end
			return false
		end

		local function get_js_linters()
			if has_biome_config() then
				return { "biomejs" }
			end

			if vim.fn.executable("eslint_d") == 1 then
				return { "eslint_d" }
			end

			return {}
		end

		lint.linters_by_ft = {
			javascript = get_js_linters(),
			typescript = get_js_linters(),
			javascriptreact = get_js_linters(),
			typescriptreact = get_js_linters(),
			json = get_js_linters(),
			jsonc = get_js_linters(),
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
