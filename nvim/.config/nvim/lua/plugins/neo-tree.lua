return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	opts = {
	},
	config = function()
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
	end,
}
