return {
	{
		"mason-org/mason.nvim",
	},
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = false,
		opts = {},
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {},
			},
			"hrsh7th/cmp-nvim-lsp",
			"neovim/nvim-lspconfig",
		},
		config = function()
			vim.diagnostic.enable(true)
			vim.diagnostic.config({ virtual_text = true })
			vim.diagnostic.config({ update_in_insert = true })
			vim.lsp.inlay_hint.enable(true)
			vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "(LSP) Show Code Actions" })
			vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "(LSP) Rename symbol" })
			vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "(LSP) Format buffer" })
			vim.keymap.set("n", "<leader>lc", vim.diagnostic.open_float, { desc = "(LSP) Show Diagnostics" })
			-- vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "(LSP) Go to Definition" })
    		-- vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "(LSP) Go to Implementation" })
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, { desc = "(LSP) Show description" })
			vim.keymap.set("n", "<leader>lk", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, { desc = "(LSP) Show description" })

			local on_attach = function(client, bufnr)
				vim.lsp.buf.signature_help()
				vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
			require("lspconfig")["bashls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["lua_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["clangd"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["cmake"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["djlsp"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["html"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["jsonls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["marksman"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {},
			})
			require("lspconfig")["ruff"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				init_options = {
					settings = {
						lineLength = 100,
					},
				},
			})
			require("lspconfig")["pyright"].setup({
				on_attach = on_attach,
				settings = {
					pyright = {
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							ignore = { "*" },
						},
					},
				},
			})
		end,
	},
}
