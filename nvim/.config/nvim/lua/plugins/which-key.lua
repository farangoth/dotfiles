return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "(which-key) Buffer Local Keymaps",
        },
    },
    config = function()
        local wk = require("which-key")
        wk.add({
            { "<leader>f", group = "fuzzy (telescope)" },
            { "<leader>t", group = "neotree" },
            { "<leader>h", group = "git/hunk" },
            { "<leader>g", group = "LSP/GoTo" },
        })
    end,
}
