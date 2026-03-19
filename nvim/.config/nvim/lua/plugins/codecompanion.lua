vim.pack.add({
    "https://www.github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://www.github.com/olimorris/codecompanion.nvim",
})

require("codecompanion").setup({
    adapters = {
        http = {
            my_gemini_pro = function()
                return require("codecompanion.adapters").extend("gemini", {
                    schema = {
                        model = {
                            default = "gemini-3.1-pro"
                        }
                    },
                    defaults = {
                        auth_method = "gemini-api-key",
                    },
                    env = {
                        api_key = function()
                            return os.getenv("GEMINI_API_KEY")
                        end
                    }
                })
            end,
            my_gemini_flash = function()
                return require("codecompanion.adapters").extend("gemini", {
                    schema = {
                        model = {
                            default = "gemini-2.5-flash-lite"
                        }
                    },
                    defaults = {
                        api_key = function()
                            return os.getenv("GEMINI_API_KEY")
                        end
                    },
                    env = {
                        api_key = "GEMINI_API_KEY"
                    }
                })
            end
        },
    },
    interactions = {
        chat = {
            adapter = "my_gemini_pro"
        },
        cmd = {
            adapter = "my_gemini_flash"
        },
        inline = {
            adapter = "my_gemini_flash"
        },
        agent = {
            adapter = "my_gemini_flash"
        },
    },
    display = {
        chat = {
            render_headers = false,
            show_reasoning = true,
            window = {
                position = "right",
                width = 0.4,
            },
        },
    },
})

vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>",
    { noremap = true, silent = true, desc = "CodeCompanion Actions" })
vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>",
    { noremap = true, silent = true, desc = "CodeCompanion Chat" })
vim.keymap.set("v", "<leader>ai", "<cmd>CodeCompanion<cr>",
    { noremap = true, silent = true, desc = "CodeCompanion Inline" })
vim.keymap.set("n", "<leader>ta", "<cmd>CodeCompanionChat Toggle<cr>",
    { noremap = true, silent = true, desc = "CodeCompanion Chat" })
