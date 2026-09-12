vim.pack.add({
    {
        src = "https://github.com/Saghen/blink.cmp",
        version = "v1.10.1",
    },
    {
        src = "https://github.com/windwp/nvim-autopairs"
    },
    {
        src = "https://github.com/rafamadriz/friendly-snippets",
    }
})

require("blink.cmp").setup({
    sources = {
        default = { "lsp", "path", "snippets", "buffer", },
    },
    keymap = {
        preset = "super-tab",
    },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
        },
    },
    appearance = {
        nerd_font_variant = "mono",
    },
    signature = {
        enabled = true,
        window = {
            border = "rounded",
            show_documentation = true
        },
    },
})

require("nvim-autopairs").setup({})
