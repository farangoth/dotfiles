vim.pack.add({
    "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup({})

vim.keymap.set("n", "]h", function() require("gitsigns").nav_hunk("next") end, { desc = "next hunk" })
vim.keymap.set("n", "[h", function() require("gitsigns").nav_hunk("prev") end, { desc = "prev hunk" })
vim.keymap.set("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "preview hunk" })
vim.keymap.set("n", "<leader>ga", function() require("gitsigns").stage_hunk() end, { desc = "stage hunk" })
vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "reset hunk" })
vim.keymap.set("n", "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end, { desc = "toggle inline blame" })
