return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("t", "  Browse cwd", ":Neotree filesystem reveal left<CR>"),
            dashboard.button("n", "⌹  Edit notes", ":e ~/git/gitjournal/<CR>"),
			dashboard.button("r", "  Browse code", ":e ~/code/<CR>"),
			dashboard.button("c", "  Config", ":e ~/dotfiles/<CR>"),
			dashboard.button("p", "  Plugins", ":Lazy<CR>"),
			dashboard.button("q", "󰅙  Quit", ":q!<CR>"),
		}
		alpha.setup(dashboard.opts)
	end,
}
