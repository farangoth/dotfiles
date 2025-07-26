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
