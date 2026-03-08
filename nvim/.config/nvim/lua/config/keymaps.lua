local keymaps = {
    { "<leader>la", function() vim.lsp.buf.code_action() end, desc = "code actions" },
}

for _, map in ipairs(keymaps) do
    local opts = { desc = map.desc }
    if map.silent ~= nil then
        opts.silent = map.silent
    end
    if map.noremap ~= nil then
        opts.noremap = map.noremap
    else
        opts.noremap = true
    end
    if map.expr ~= nil then
        opts.expr = map.expr
    end

    local mode = map.mode or "n"
    vim.keymap.set(mode, map[1], map[2], opts)
end
