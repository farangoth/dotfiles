local keymaps = {
    { "<leader>la", function() vim.lsp.buf.code_action() end, desc = "code actions" },
    { "H",          ":bprevious<CR>",                         desc = "prev buffer",       silent = true },
    { "L",          ":bnext<CR>",                             desc = "next buffer",       silent = true },
    { "<leader>v",  ":vsplit<CR>",                            desc = "split vertical",    silent = true },
    { "<leader>c",  ":split<CR>",                             desc = "split horizontal",  silent = true },
    { "<C-h>",      ":wincmd h<CR>",                          desc = "move to left win",  silent = true },
    { "<C-j>",      ":wincmd j<CR>",                          desc = "move to down win",  silent = true },
    { "<C-k>",      ":wincmd k<CR>",                          desc = "move to up win",    silent = true },
    { "<C-l>",      ":wincmd l<CR>",                          desc = "move to right win", silent = true },
    { "<leader>w",  ":w",                                     desc = "write files", },
    { "<leader>lr", function() vim.lsp.buf.rename() end,      desc = "rename symbol" },
    { "<leader>pu", function() vim.pack.update() end,         desc = "update package" },
    { "<leader>pc", ":e ~/.config/nvim/lua/plugins/<CR>",     desc = "config plugins" },
    { "<leader>pm", ":MasonUpdate<CR>",                       desc = "update LSPs" },
}

for _, map in ipairs(keymaps) do
    local lhs = map[1]
    local rhs = map[2]

    local opts = vim.deepcopy(map)
    opts[1] = nil
    opts[2] = nil

    local mode = opts.mode or "n"
    opts.mode = nil
    opts.noremap = opts.noremap ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
end
