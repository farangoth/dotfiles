vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
})

-- Formatter binaries (stylua, shfmt) aren't managed by mason-lspconfig
-- (that's LSP servers only) -- install with `:MasonInstall stylua shfmt`
-- or via the system package manager.
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
    },
    format_on_save = function()
        if not vim.g.autoformat then
            return
        end
        -- lsp_format = "fallback": use the LSP formatter (ruff,
        -- basedpyright, etc.) for filetypes with no formatter listed
        -- above, instead of doing nothing for everything but lua/sh.
        return { lsp_format = "fallback", timeout_ms = 1000 }
    end,
})

vim.keymap.set("n", "<leader>tf", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("format on save: " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "toggle format on save" })
