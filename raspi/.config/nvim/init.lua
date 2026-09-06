-- Minimal, dependency-free Neovim config for low-resource machines
-- (Raspberry Pi). No plugin manager, no external LSP/treesitter — built-ins
-- only, so it works offline and doesn't ask an ARM board to compile or fetch
-- anything just to open a file.
--
-- The colorscheme is Catppuccin Latte, hand-rolled below with plain
-- highlight calls rather than the catppuccin.nvim plugin (this config has
-- no plugin manager) -- matching the theme foot itself switches to for the
-- SSH session this nvim is normally opened inside (see
-- foot/.local/bin/foot-theme on the desktop). The background matches
-- foot-theme's dimmed alternative rather than Latte's own near-white
-- default, for the same reason foot dims it: less glaring on a screen.
-- The titlestring below adds a second "which machine is this" signal.

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

-- colorscheme: Catppuccin Latte, hand-rolled (see header comment).
-- Background hex matches foot-theme's FOOT_THEME_LATTE_BG default
-- (surface1); this machine has no way to inherit that env var over SSH,
-- so keep the two in sync by hand if you change one.
local latte = {
    rosewater = "#dc8a78",
    flamingo = "#dd7878",
    pink = "#ea76cb",
    mauve = "#8839ef",
    red = "#d20f39",
    maroon = "#e64553",
    peach = "#fe640b",
    yellow = "#df8e1d",
    green = "#40a02b",
    teal = "#179299",
    sky = "#04a5e5",
    blue = "#1e66f5",
    text = "#4c4f69",
    overlay0 = "#9ca0b0",
    surface1 = "#bcc0cc",
    surface0 = "#ccd0da",
    -- dimmed alternative background, not Latte's own #eff1f5 -- reads
    -- $FOOT_THEME_LATTE_BG in case that ever gets forwarded over SSH,
    -- otherwise falls back to the same default foot-theme uses
    base = "#" .. (os.getenv("FOOT_THEME_LATTE_BG") or "bcc0cc"),
    mantle = "#e6e9ef",
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = latte.text, bg = latte.base })
hl("NormalFloat", { fg = latte.text, bg = latte.mantle })
hl("Comment", { fg = latte.overlay0, italic = true })
hl("Constant", { fg = latte.peach })
hl("String", { fg = latte.green })
hl("Character", { fg = latte.teal })
hl("Number", { fg = latte.peach })
hl("Boolean", { fg = latte.peach })
hl("Identifier", { fg = latte.blue })
hl("Function", { fg = latte.blue, bold = true })
hl("Statement", { fg = latte.mauve })
hl("Keyword", { fg = latte.mauve })
hl("Operator", { fg = latte.sky })
hl("PreProc", { fg = latte.pink })
hl("Type", { fg = latte.yellow })
hl("Special", { fg = latte.pink })
hl("Underlined", { fg = latte.blue, underline = true })
hl("Todo", { fg = latte.base, bg = latte.yellow, bold = true })
hl("Error", { fg = latte.base, bg = latte.red, bold = true })
hl("ErrorMsg", { fg = latte.red, bold = true })
hl("WarningMsg", { fg = latte.yellow, bold = true })

hl("LineNr", { fg = latte.overlay0 })
hl("CursorLineNr", { fg = latte.blue, bold = true })
hl("CursorLine", { bg = latte.surface0 })
hl("Visual", { bg = latte.surface1 })
hl("Search", { fg = latte.base, bg = latte.yellow })
hl("IncSearch", { fg = latte.base, bg = latte.peach })
hl("MatchParen", { fg = latte.red, bold = true, underline = true })

hl("StatusLine", { fg = latte.text, bg = latte.surface0 })
hl("StatusLineNC", { fg = latte.overlay0, bg = latte.mantle })
hl("WinSeparator", { fg = latte.surface0 })
hl("SignColumn", { bg = latte.base })
hl("Folded", { fg = latte.overlay0, bg = latte.surface0 })

hl("Pmenu", { fg = latte.text, bg = latte.mantle })
hl("PmenuSel", { fg = latte.base, bg = latte.blue })
hl("PmenuSbar", { bg = latte.surface0 })
hl("PmenuThumb", { bg = latte.overlay0 })

hl("NonText", { fg = latte.surface1 })
hl("EndOfBuffer", { fg = latte.surface1 })
hl("Whitespace", { fg = latte.surface1 })

hl("DiffAdd", { fg = latte.green, bg = latte.base })
hl("DiffChange", { fg = latte.yellow, bg = latte.base })
hl("DiffDelete", { fg = latte.red, bg = latte.base })
hl("DiffText", { fg = latte.blue, bg = latte.base, bold = true })

hl("DiagnosticError", { fg = latte.red })
hl("DiagnosticWarn", { fg = latte.yellow })
hl("DiagnosticInfo", { fg = latte.sky })
hl("DiagnosticHint", { fg = latte.teal })

vim.o.background = "light"
vim.g.colors_name = "catppuccin-latte-minimal"
