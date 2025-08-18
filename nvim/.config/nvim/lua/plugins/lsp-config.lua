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
			vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, { desc = "(LSP) Show Code Actions" })
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.rename, { desc = "(LSP) Rename symbol" })
			vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "(LSP) Format buffer" })
			vim.keymap.set("n", "<leader>gc", vim.diagnostic.open_float, { desc = "(LSP) Show Diagnostics" })
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "(LSP) Go to Definition" })
			vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "(LSP) Go to Implementation" })
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, { desc = "(LSP) Show description" })
			vim.keymap.set("n", "<leader>gk", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, { desc = "(LSP) Show description" })
			vim.keymap.set({ "n" }, "<leader>gs", function()
				require("telescope.builtin").lsp_definitions()
			end, { desc = "(LSP) Go to Source file" })

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
			require("lspconfig")["bashls"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["lua_ls"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["clangd"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["cmake"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["djlsp"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["html"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["jsonls"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["marksman"].setup({
				capabilities = capabilities,
				settings = {},
			})
			require("lspconfig")["ruff"].setup({
				capabilities = capabilities,
				init_options = {
					settings = {
						lineLength = 100,
					},
				},
			})
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		opts = {
			hint_enable = false,
			bind = true,
			handler_opts = {
				border = "rounded",
			},
		},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
			vim.keymap.set({ "i", "n" }, "<C-s>", function()
				require("lsp_signature").toggle_float_win()
			end, { desc = "(LSP) Toggle signature", noremap = true })
		end,
	},
}
