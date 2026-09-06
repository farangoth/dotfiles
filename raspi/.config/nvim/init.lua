-- Minimal, dependency-free Neovim config for low-resource machines
-- (Raspberry Pi). No plugin manager, no external LSP/treesitter — built-ins
-- only, so it works offline and doesn't ask an ARM board to compile or fetch
-- anything just to open a file.
--
-- The colorscheme is Catppuccin Frappe, hand-rolled below with plain
-- highlight calls rather than the catppuccin.nvim plugin (this config has
-- no plugin manager) -- matching the theme foot itself switches to for the
-- SSH session this nvim is normally opened inside (see
-- foot/.local/bin/foot-theme on the desktop). The titlestring below adds
-- a second "which machine is this" signal.

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

-- colorscheme: Catppuccin Frappe, hand-rolled (see header comment).
local frappe = {
    pink = "#f4b8e4",
    mauve = "#ca9ee6",
    red = "#e78284",
    peach = "#ef9f76",
    yellow = "#e5c890",
    green = "#a6d189",
    teal = "#81c8be",
    sky = "#99d1db",
    blue = "#8caaee",
    text = "#c6d0f5",
    overlay0 = "#737994",
    surface1 = "#51576d",
    surface0 = "#414559",
    base = "#303446",
    mantle = "#292c3c",
    crust = "#232634",
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = frappe.text, bg = frappe.base })
hl("NormalFloat", { fg = frappe.text, bg = frappe.mantle })
hl("Comment", { fg = frappe.overlay0, italic = true })
hl("Constant", { fg = frappe.peach })
hl("String", { fg = frappe.green })
hl("Character", { fg = frappe.teal })
hl("Number", { fg = frappe.peach })
hl("Boolean", { fg = frappe.peach })
hl("Identifier", { fg = frappe.blue })
hl("Function", { fg = frappe.blue, bold = true })
hl("Statement", { fg = frappe.mauve })
hl("Keyword", { fg = frappe.mauve })
hl("Operator", { fg = frappe.sky })
hl("PreProc", { fg = frappe.pink })
hl("Type", { fg = frappe.yellow })
hl("Special", { fg = frappe.pink })
hl("Underlined", { fg = frappe.blue, underline = true })
hl("Todo", { fg = frappe.crust, bg = frappe.yellow, bold = true })
hl("Error", { fg = frappe.crust, bg = frappe.red, bold = true })
hl("ErrorMsg", { fg = frappe.red, bold = true })
hl("WarningMsg", { fg = frappe.yellow, bold = true })

hl("LineNr", { fg = frappe.overlay0 })
hl("CursorLineNr", { fg = frappe.blue, bold = true })
hl("CursorLine", { bg = frappe.surface0 })
hl("Visual", { bg = frappe.surface1 })
hl("Search", { fg = frappe.crust, bg = frappe.yellow })
hl("IncSearch", { fg = frappe.crust, bg = frappe.peach })
hl("MatchParen", { fg = frappe.red, bold = true, underline = true })

hl("StatusLine", { fg = frappe.text, bg = frappe.surface0 })
hl("StatusLineNC", { fg = frappe.overlay0, bg = frappe.mantle })
hl("WinSeparator", { fg = frappe.surface0 })
hl("SignColumn", { bg = frappe.base })
hl("Folded", { fg = frappe.overlay0, bg = frappe.surface0 })

hl("Pmenu", { fg = frappe.text, bg = frappe.mantle })
hl("PmenuSel", { fg = frappe.crust, bg = frappe.blue })
hl("PmenuSbar", { bg = frappe.surface0 })
hl("PmenuThumb", { bg = frappe.overlay0 })

hl("NonText", { fg = frappe.surface1 })
hl("EndOfBuffer", { fg = frappe.surface1 })
hl("Whitespace", { fg = frappe.surface1 })

hl("DiffAdd", { fg = frappe.green, bg = frappe.base })
hl("DiffChange", { fg = frappe.yellow, bg = frappe.base })
hl("DiffDelete", { fg = frappe.red, bg = frappe.base })
hl("DiffText", { fg = frappe.blue, bg = frappe.base, bold = true })

hl("DiagnosticError", { fg = frappe.red })
hl("DiagnosticWarn", { fg = frappe.yellow })
hl("DiagnosticInfo", { fg = frappe.sky })
hl("DiagnosticHint", { fg = frappe.teal })

vim.o.background = "dark"
vim.g.colors_name = "catppuccin-frappe-minimal"
