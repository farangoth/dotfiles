vim.pack.add({
    "https://github.com/folke/todo-comments.nvim",
})

require("todo-comments").setup({})

-- Snacks doesn't ship a first-party todo-comments picker source, so this
-- uses todo-comments' own built-in quickfix dump instead of assuming an
-- integration that may not exist.
vim.keymap.set("n", "<leader>st", "<cmd>TodoQuickFix<CR>", { desc = "search todos" })
