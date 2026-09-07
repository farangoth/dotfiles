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
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
            buffer = args.buf,
            callback = function()
                if not vim.g.autoformat then
                    return
                end
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
            end
        })
    end,

})

vim.keymap.set("n", "<leader>tf", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("format on save: " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "toggle format on save" })
