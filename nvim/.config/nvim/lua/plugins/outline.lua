vim.pack.add({
    "https://github.com/hedyhli/outline.nvim"
})
require("outline").setup({
    position = "left",
    auto_width = {
        enabled = true,
        max_width = 35,
    }
})
vim.keymap.set("n", "<leader>to", "<cmd>Outline<CR>", { desc = "toggle outline" })
