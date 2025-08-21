return {
	"folke/snacks.nvim",
	lazy = false,
	keys = {
		{
			"<leader>hG",
			function()
				Snacks.lazygit()
			end,
			desc = "lazygit",
		},
        {
            "<leader>hB",
            function ()
                Snacks.git.blame_line()
            end,
            desc = "blame line (float)"
        },
		{
			"<leader>hw",
			function()
				Snacks.gitbrowse()
			end,
			desc = "open repo in web browser",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
				Snacks.toggle.dim()
			end,
            desc = "toggle zen mode",
		},
        {
            "<leader>ts",
            function ()
                Snacks.toggle.option()
            end,
            desc = "toggle signature"
        }
	},
}
