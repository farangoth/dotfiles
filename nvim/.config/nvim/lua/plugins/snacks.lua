return {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
        -- scroll = { enabled = true },
        zen = { enabled = true },
        dim = { enabled = true },
        lazygit = { enable = true },
        toggle = {
            map = vim.keymap.set,
            which_key = true,
            notify = true,
            icon = {
                enabled = " ",
                disabled = " ",
            },
            -- colors for enabled/disabled states
            color = {
                enabled = "green",
                disabled = "yellow",
            },
            wk_desc = {
                enabled = "Disable ",
                disabled = "Enable ",
            },
        },
    },
    keys = {
        {
            "<leader>hG",
            function()
                Snacks.lazygit()
            end,
            desc = "lazygit",
        },
        {
            "<leader>z",
            function()
                Snacks.zen()
                Snacks.toggle.dim()
            end,
            desc = "Toggle zen mode",
        },
    },
}
