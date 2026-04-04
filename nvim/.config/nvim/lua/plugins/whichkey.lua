vim.pack.add({
    "https://github.com/folke/which-key.nvim",
})

require("which-key").add({
    { "<leader>f",  group = "finder" },
    { "<leader>s",  group = "search" },
    { "<leader>g",  group = "git" },
    { "<leader>gh", group = "GitHub" },
    { "<leader>l",  group = "lsp" },
    { "<leader>t",  group = "toggle" },
    { "<leader>h",  group = "helper" },
    { "<leader>m",  group = "mistral" },
    { "g",          group = "goto" },
    { "<leader>r",  group = "run" },
    { "<leader>p",  group = "vim.pack" },


})
