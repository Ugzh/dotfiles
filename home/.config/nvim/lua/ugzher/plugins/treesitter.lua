local languages = {
	"angular",
	"bash",
	"c",
	"cpp",
	"css",
	"dockerfile",
	"gitignore",
	"go",
	"graphql",
	"html",
	"http",
	"java",
	"javascript",
	"json",
	"kotlin",
	"lua",
	"markdown",
	"markdown_inline",
	"prisma",
	"python",
	"query",
	"ron",
	"rust",
	"scss",
	"svelte",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		if #vim.api.nvim_list_uis() > 0 then
			treesitter.install(languages)
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("ugzher-treesitter", { clear = true }),
			pattern = languages,
			callback = function(event)
				pcall(vim.treesitter.start, event.buf)
				if not vim.tbl_contains({ "python", "yaml" }, vim.bo[event.buf].filetype) then
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
