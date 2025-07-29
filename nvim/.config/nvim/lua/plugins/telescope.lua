return {
	{
		"nvim-telescope/telescope.nvim",
		name = "telescope",
		dependencies = { "nvim-lua/plenary.nvim" },

		config = function()
			local builtin = require("telescope.builtin")
			require("telescope").setup({
			pickers = {
                find_files = {
                    find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*"},
                },
            },
                extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "(telescope) find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "(telescope) live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "(telescope) buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "(telescope) help tags" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "(telescope) symbols" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
}
