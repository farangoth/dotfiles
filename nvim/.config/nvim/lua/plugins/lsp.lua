vim.pack.add({
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "ruff",
        "basedpyright",
        "bashls",
        "jsonls",
        "yamlls",
        "taplo",
        "cssls",
        "html",
    }
})

vim.diagnostic.config({ virtual_lines = { current_line = true } })

-- Format-on-save (gated on vim.g.autoformat, toggled via <leader>tf) lives
-- in plugins/conform.lua now, not here -- conform.nvim's own
-- format_on_save with lsp_format="fallback" replaces the BufWritePre/
-- vim.lsp.buf.format autocmd this file used to set up, so there's one
-- format-on-save mechanism instead of two potentially competing ones.
