-- Minimal, dependency-free Neovim config for low-resource machines
-- (Raspberry Pi). No plugin manager, no external LSP/treesitter — built-ins
-- only, so it works offline and doesn't ask an ARM board to compile or fetch
-- anything just to open a file.
--
-- The colorscheme is intentionally NOT Catppuccin Macchiato (the desktop's
-- theme): landing on retrobox/desert instead of the usual cool blue/lavender
-- is the "which machine is this terminal on" signal at a glance. The
-- titlestring below repeats the same signal in the window title.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Skip loading built-in plugins this config never uses (archive/script
-- handling, 2html, etc.) to keep startup light on slow storage.
for _, plugin in ipairs({
    "gzip", "tar", "tarPlugin", "zip", "zipPlugin",
    "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
    "2html_plugin", "logipat", "rrhelper",
}) do
    vim.g["loaded_" .. plugin] = 1
end

-- visual
local o = vim.o
o.number = true
o.cursorline = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.mouse = "a"
o.title = true
o.titlestring = "[PI] %t"

-- indentation
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true

-- search
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = false

-- files: no swap/backup on SD-card storage, keep undo history
o.swapfile = false
o.backup = false
o.undofile = true
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
o.undodir = undodir

o.updatetime = 300

-- keymaps (subset of the desktop config's, for muscle memory)
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<CR>", { desc = "save" })
map("n", "H", "<cmd>bprevious<CR>", { silent = true, desc = "prev buffer" })
map("n", "L", "<cmd>bnext<CR>", { silent = true, desc = "next buffer" })
map("n", "<leader>e", vim.cmd.Ex, { desc = "file explorer (netrw)" })
map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "split vertical" })
map("n", "<leader>c", "<cmd>split<CR>", { desc = "split horizontal" })
map("n", "<C-h>", "<C-w>h", { desc = "move to left win" })
map("n", "<C-j>", "<C-w>j", { desc = "move to down win" })
map("n", "<C-k>", "<C-w>k", { desc = "move to up win" })
map("n", "<C-l>", "<C-w>l", { desc = "move to right win" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- colorscheme: retrobox (Neovim 0.10+) if available, else desert (bundled
-- since forever), else whatever ships as default. Either way, unmistakably
-- not Macchiato.
for _, name in ipairs({ "retrobox", "desert", "default" }) do
    if pcall(vim.cmd.colorscheme, name) then
        break
    end
end
