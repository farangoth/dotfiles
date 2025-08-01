return {
	{
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
						visible = true,
						hide_dotfiles = false,
						hide_gitignored = true,
					},
				},
				sources = {
					"filesystem",
					"buffers",
					"git_status",
					"document_symbols",
					"diagnostics",
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
				{ desc = "(neo-tree) Toggle git explorer" }
			)
			vim.keymap.set(
				"n",
				"<leader>td",
				":Neotree diagnostics reveal left toggle<CR>",
				{ desc = "(neo-tree) Toggle diagnostics explorer" }
			)
			vim.keymap.set(
				"n",
				"<leader>ts",
				":Neotree document_symbols reveal left toggle<CR>",
				{ desc = "(neo-tree) Toggle symbols explorer" }
			)
		end,
	},
	{
		"mrbjarksen/neo-tree-diagnostics.nvim",
		dependencies = {
			"nvim-neo-tree/neo-tree.nvim",
		},
	},
}
