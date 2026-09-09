vim.pack.add({
    "https://www.github.com/nvim-lua/plenary.nvim",
    "https://www.github.com/olimorris/codecompanion.nvim",
})

require("codecompanion").setup({
    adapters = {
        http = {
            mistral = function()
                return require("codecompanion.adapters").extend("mistral", {
                    schema = {
                        model = {
                            default = "mistral-large-latest"
                        }
                    },
                    defaults = {
                        auth_method = "mistral-api-key",
                    },
                    env = {
                        api_key = function()
                            return os.getenv("MISTRAL_API_KEY")
                        end
                    }
                })
            end,
        },
        acp = {
            mistral_vibe = function()
                return require("codecompanion.adapters").extend("mistral_vibe", {
                    schema = {
                        model = {
                            default = "mistral-large-latest"
                        }
                    },
                    defaults = {
                        auth_method = "mistral-api-key",
                    },
                    env = {
                        api_key = function()
                            return os.getenv("MISTRAL_API_KEY")
                        end
                    }
                })
            end,
        },
    },
    interactions = {
        chat = {
            adapter = "mistral_vibe"
        },
        inline = {
            adapter = "mistral"
        },
        cmd = {
            adapter = "mistral"
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

vim.keymap.set({ "n", "v" }, "<leader>ma", "<cmd>CodeCompanionActions<cr>",
    { noremap = true, silent = true, desc = "codecompanion actions" })
-- chat
vim.keymap.set({ "v", "n" }, "<leader>mt", "<cmd>CodeCompanionChat Toggle<cr>",
    { noremap = true, silent = true, desc = "toggle chat" })
vim.keymap.set("n", "<leader>mn", "<cmd>CodeCompanionChat New<cr>",
    { noremap = true, silent = true, desc = "new chat" })
-- Additional keymaps
vim.keymap.set({ "n", "v" }, "<leader>mi", "<cmd>CodeCompanion<cr>",
    { noremap = true, silent = true, desc = "prompt inline" })
vim.keymap.set({ "v" }, "<leader>mr", ":'<,'>CodeCompanion prompt=refactor<cr>",
    { noremap = true, silent = true, desc = "refactor" })
vim.keymap.set({ "v" }, "<leader>md", ":'<,'>CodeCompanion prompt=document<cr>",
    { noremap = true, silent = true, desc = "document" })
vim.keymap.set({ "v" }, "<leader>mf", ":'<,'>CodeCompanion prompt=tests<cr>",
    { noremap = true, silent = true, desc = "tests" })
vim.keymap.set({ "v" }, "<leader>mF", ":'<,'>CodeCompanion prompt=fix<cr>",
    { noremap = true, silent = true, desc = "fix" })
vim.keymap.set("n", "<leader>m?", ":CodeCompanion prompt=explain #{buffer}<cr>",
    { noremap = true, silent = true, desc = "explain" })
vim.keymap.set("v", "<leader>m?", ":'<,'>CodeCompanion prompt=explain<cr>",
    { noremap = true, silent = true, desc = "explain" })
