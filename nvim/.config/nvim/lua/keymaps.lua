local transparent_background = false
local function toggle_background_color()
    if transparent_background then
        vim.cmd.colorscheme("catppuccin")
        transparent_background = false
    else
        local highlights = {
            "Normal", "NormalNC", "NormalFloat", "FloatBorder", "EndOfBuffer",
            "SignColumn", "ColorColumn", "CursorLine", "WinSeparator", "VertSplit",
            "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
            "NeoTreeNormal", "TelescopeNormal"
        }
        for _, group in ipairs(highlights) do
            vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
        end
        transparent_background = true
    end
end

vim.keymap.set('n', '<leader>bg', toggle_background_color, {desc="Toggle background color"})

-- Deactivate arrows to force Vim motion
vim.keymap.set('n', '<Left>', '<Esc>:echoe "Use h!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('n', '<Right>', '<Esc>:echoe "Use l!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('n', '<Up>', '<Esc>:echoe "Use k!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('n', '<Down>', '<Esc>:echoe "Use j!"<CR>', {desc="Enforce Vim motions"})

vim.keymap.set('i', '<Left>', '<Esc>:echoe "Use h!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('i', '<Right>', '<Esc>:echoe "Use l!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('i', '<Up>', '<Esc>:echoe "Use k!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('i', '<Down>', '<Esc>:echoe "Use j!"<CR>', {desc="Enforce Vim motions"})

vim.keymap.set('v', '<Left>', '<Esc>:echoe "Use h!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('v', '<Right>', '<Esc>:echoe "Use l!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('v', '<Up>', '<Esc>:echoe "Use k!"<CR>', {desc="Enforce Vim motions"})
vim.keymap.set('v', '<Down>', '<Esc>:echoe "Use j!"<CR>', {desc="Enforce Vim motions"})

-- better move between buffers
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>', {desc="Vim motion for navigate windows"})
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>', {desc="Vim motion for navigate windows"})
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>', {desc="Vim motion for navigate windows"})
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>', {desc="Vim motion for navigate windows"})