return {
    {
        "mason-org/mason.nvim",
    },

    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },
        opts = {
            ensure_installed = { "lua_ls", "pyright" },
        },
        config = function()
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "(LSP) Show Code Actions" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.rename, { desc = "(LSP) Rename" })
            vim.keymap.set("n", "<leader>gc", vim.diagnostic.open_float, { desc = "(LSP) Show Diagnostics" })
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "(LSP) Go to Definition" })
            vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "(LSP) Go to Implementation" })
            vim.keymap.set("n", "<leader>gk", vim.lsp.buf.hover, { desc = "(LSP) Show description" })
            vim.keymap.set({"i","n"}, "<C-k>", vim.lsp.buf.signature_help, { desc = "(LSP) Go to Type Definition" })


            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            require("lspconfig")["lua_ls"].setup({
                capabilities = capabilities,
                settings = {},
            })
            require("lspconfig")["pyright"].setup({
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            -- typeCheckingMode = "strict",
                        },
                    },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            vim.diagnostic.enable(true)
            vim.diagnostic.config({ virtual_text = true })
            vim.diagnostic.config({ update_in_insert = true })
            vim.lsp.inlay_hint.enable(true)
        end,
    },
}
