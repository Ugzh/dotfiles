-- lua/Ugzher/plugins/treesitter.lua
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },

	opts = {
		ensure_installed = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"go",
			"yaml",
			"html",
			"css",
			"scss",
			"python",
			"http",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"java",
			"rust",
			"ron",
			"angular",
		},

		highlight = {
			enable = true,
		},

		indent = {
			enable = true,
		},
	},
}
-- return {
-- 	{
-- 		"nvim-treesitter/nvim-treesitter",
-- 		event = { "BufReadPre", "BufNewFile" },
-- 		build = ":TSUpdate",
-- 		config = function()
-- 			-- import nvim-treesitter plugin
-- 			local treesitter = require("nvim-treesitter.configs")
--
-- 			-- configure treesitter
-- 			treesitter.setup({ -- enable syntax highlighting
-- 				highlight = {
-- 					enable = true,
-- 				},
-- 				-- enable indentation
-- 				indent = { enable = true },
-- 				autotag = {
-- 					enable = true,
-- 				},
-- 				-- ensure these languages parsers are installed
-- 				ensure_installed = {
-- 					"json",
-- 					"javascript",
-- 					"typescript""json",
-- 					"javascript",
-- 					"typescript",
-- 					"tsx",
-- 					"go",
-- 					"yaml",
-- 					"html",
-- 					"css",
-- 					"scss",
-- 					"python",
-- 					"http",
-- 					"prisma",
-- 					"markdown",
-- 					"markdown_inline",
-- 					"svelte",
-- 					"graphql",
-- 					"bash",
-- 					"lua",
-- 					"vim",
-- 					"dockerfile",
-- 					"gitignore",
-- 					"query",
-- 					"vimdoc",
-- 					"c",
-- 					"java",
-- 					"rust",
-- 					"ron",
-- 					"angular",,
-- 					"tsx",
-- 					"go",
-- 					"yaml",
-- 					"html",
-- 					"css",
-- 					"scss",
-- 					"python",
-- 					"http",
-- 					"prisma",
-- 					"markdown",
-- 					"markdown_inline",
-- 					"svelte",
-- 					"graphql",
-- 					"bash",
-- 					"lua",
-- 					"vim",
-- 					"dockerfile",
-- 					"gitignore",
-- 					"query",
-- 					"vimdoc",
-- 					"c",
-- 					"java",
-- 					"rust",
-- 					"ron",
-- 					"angular",
-- 				},
-- 				incremental_selection = {
-- 					enable = true,
-- 					keymaps = {
-- 						init_selection = "<C-a>",
-- 						node_incremental = "<C-a>",
-- 						scope_incremental = false,
-- 					},
-- 				},
-- 				additional_vim_regex_highlighting = false,
-- 			})
-- 		end,
-- 	},
-- 	-- NOTE: js,ts,jsx,tsx Auto Close Tags
-- 	{
-- 		"windwp/nvim-ts-autotag",
-- 		enabled = true,
-- 		ft = {
-- 			"html",
-- 			"xml",
-- 			"javascript",
-- 			"typescript",
-- 			"javascriptreact",
-- 			"typescriptreact",
-- 			"svelte",
-- 			"angular.html",
-- 		},
-- 		config = function()
-- 			-- Independent nvim-ts-autotag setup
-- 			require("nvim-ts-autotag").setup({
-- 				opts = {
-- 					enable_close = true, -- Auto-close tags
-- 					enable_rename = true, -- Auto-rename pairs
-- 					enable_close_on_slash = false, -- Disable auto-close on trailing `</`
-- 				},
-- 				per_filetype = {
-- 					["html"] = {
-- 						enable_close = true, -- Disable auto-closing for HTML
-- 					},
-- 					["typescriptreact"] = {
-- 						enable_close = true, -- Explicitly enable auto-closing (optional, defaults to `true`)
-- 					},
-- 				},
-- 			})
-- 		end,
-- 	},
-- }
