return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    lazy = false,
    opts = {},
    config = function()
        require("neo-tree").setup({
            filesystem = {
                filtered_items = {
                    visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
                    hide_dotfiles = false,
                    hide_gitignored = true,
                },
            },
        })
        vim.keymap.set(
            "n",
            "<leader>tf",
            ":Neotree filesystem reveal left toggle<CR>",
            { desc = "(neo-tree) Toggle file explorer" }
        )
        vim.keymap.set(
            "n",
            "<leader>tb",
            ":Neotree buffers reveal left toggle<CR>",
            { desc = "(neo-tree) Toggle buffer explorer" }
        )
        vim.keymap.set(
            "n",
            "<leader>tg",
            ":Neotree git_status reveal left toggle<CR>",
            {desc = "(neo-tree) Toggle git explorer"}
        )
    end,
}
