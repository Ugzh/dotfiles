vim.cmd("let g:netrw_banner = 0")

vim.opt.guicursor = {
	"n-v-c:block",
	"i-ci-ve:ver25",
	"r-cr:hor20",
	"o:hor50",
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
	"sm:block-blinkwait175-blinkoff150-blinkon175",
}
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false

local swap_directory = vim.fs.joinpath(vim.fn.stdpath("state"), "swap")
vim.fn.mkdir(swap_directory, "p")
vim.opt.directory = swap_directory .. "//"
vim.opt.swapfile = true
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.backspace = { "start", "eol", "indent" }

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.smoothscroll = true
vim.opt.jumpoptions = "view"

vim.opt.isfname:append("@-@")
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400
vim.opt.colorcolumn = ""
vim.opt.pumheight = 12
vim.opt.diffopt:append("linematch:60")

vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true

vim.opt.mouse = "a"
vim.g.editorconfig = true

vim.opt.termguicolors = true
vim.opt.conceallevel = 2
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.confirm = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
