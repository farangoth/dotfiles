return {
	{
		"zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
			vim.g.copilot_filetypes = { ["*"] = false }
			vim.g.copilot_no_tab_map = true

			vim.keymap.set("i", "<C-M-Space>", "copilot#Suggest()", {
				expr = true,
				replace_keycodes = false,
			})
            

			vim.keymap.set("i", "<C-Enter>", 'copilot#Accept("")', {
				expr = true,
				replace_keycodes = false,
			})
		end,
	},
	-- {
	--     "zbirenbaum/copilot-cmp",
	--     config = function()
	--         require("copilot_cmp").setup()
	--     end,
	-- },
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		opts = {},
	},
}
