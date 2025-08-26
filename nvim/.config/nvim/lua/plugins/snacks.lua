return {
	"folke/snacks.nvim",
	lazy = false,
	opts = {
		-- scroll = { enabled = true },
		zen = {
			enabled = true,
			toggles = {
				dim = true,
				git_signs = false,
				mini_diff_signs = false,
				inlay_hints = false,
				line_number = false,
				diagnostics = false,
				statuscolumn = false,
				animate = false,
				indent = false,
			},
            backdrop = {
                transparent = true,
                blend = 40,
            },
			show = {
				statusline = false,
                tabline = false,

			},
		},
		dim = { enable = true },
		lazygit = { enable = true },
		gitbrowse = { enabled = true },
		explorer = { replacenetrw = true },
		statuscolumn = { left = { "mark", "sign", "fold", "git" }, right = {} },
		indent = { animate = { enabled = false }, only_current = true },
		input = { enable = true },
		toggle = {
			map = vim.keymap.set,
			which_key = true,
			notify = true,
			icon = {
				enabled = " ",
				disabled = " ",
			},
			color = {
				enabled = "green",
				disabled = "yellow",
			},
			wk_desc = {
				enabled = "Disable ",
				disabled = "Enable ",
			},
		},
	},
}
