return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = { "rafamadriz/friendly-snippets" },
	opts = {
		keymap = {
			preset = "enter",
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},
		appearance = { nerd_font_variant = "mono" },
		completion = {
			accept = { auto_brackets = { enabled = true } },
			documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
			menu = { auto_show = true, border = "rounded", draw = { treesitter = { "lsp" } } },
			ghost_text = { enabled = false },
			trigger = {
				show_on_keyword = true,
				show_on_trigger_character = true,
			},
		},
		signature = { enabled = true, window = { border = "rounded" } },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				lsp = { min_keyword_length = 2 },
			},
		},
		cmdline = { enabled = true },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
