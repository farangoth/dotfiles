vim.o.number = true
vim.o.cursorline = true
vim.o.winborder = "none"
vim.o.scrolloff = 10

-- indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = false

-- visual
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.showmatch = true
vim.o.showmode = false

--perf
vim.o.synmaxcol = 300
vim.o.updatetime = 300

-- files handling
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.autoread = true
vim.o.autowrite = true

-- undo
vim.o.undofile = true
vim.o.undolevels = 10000
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.o.undodir = undodir



vim.g.autoformat = true

