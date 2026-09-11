vim.pack.add({
    "https://github.com/folke/todo-comments.nvim",
})

require("todo-comments").setup({})

-- Snacks doesn't ship a first-party todo-comments picker source, so this
-- uses todo-comments' own built-in quickfix dump instead of assuming an
-- integration that may not exist.
vim.keymap.set("n", "<leader>st", "<cmd>TodoQuickFix<CR>", { desc = "search todos" })

-- todo-comments.nvim only highlights/finds TODOs, it doesn't insert one --
-- opens a new line below with a correctly-commented "TODO: " for the
-- current filetype (via commentstring) and drops into insert mode after it.
vim.keymap.set("n", "<leader>rt", function()
    local commentstring = vim.bo.commentstring
    if commentstring == "" then
        commentstring = "# %s"
    end
    local line = commentstring:format("TODO: ")
    vim.api.nvim_put({ line }, "l", true, true)
    vim.cmd("startinsert!")
end, { desc = "add TODO comment" })
