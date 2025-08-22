return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "(which-key) Buffer Local Keymaps",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>f", group = "fuzzy finders" },
			{ "<leader>t", group = "toggle" },
			{ "<leader>h", group = "git/hunk" },
			{ "<leader>l", group = "LSP", icon = "" },
			{ "<leader>g", group = "GoTo", icon = "󱞩" },
		})
	end,
}
