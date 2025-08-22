return {
	"folke/snacks.nvim",
	lazy = false,
	opts = {
		dashboard = {
			width = 60,
			row = nil,
			col = nil,
			pane_gap = 6,
			autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
			preset = {
				pick = nil,
				keys = {
					{
						icon = " ",
						key = "e",
						desc = "new file",
						action = ":ene",
					},
					{
						icon = " ",
						key = "t",
						desc = "browse cwd",
						action = ":lua Snacks.dashboard.pick('explorer')",
					},
					{
						icon = " ",
						key = "n",
						desc = "edit notes",
						action = ":e ~/git/gitjournal/",
					},
					{
						icon = " ",
						key = "r",
						desc = "browse code",
						action = ":e ~/code/",
					},
					{
						icon = " ",
						key = "c",
						desc = "browse config",
						action = ":lua Snacks.dashboard.pick('files', {cwd='~/dotfiles'})",
					},
					{
						icon = " ",
						key = "p",
						desc = "browse plugins (lazy)",
						action = ":Lazy",
					},
				},
				header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
			},
			sections = {
				{
					{
						section = "header",
						indent = 60,
						padding = 2,
					},
					{
						pane = 2,
						section = "terminal",
						cmd = "",
						height = 6,
						padding = 2,
					},
				},
				{
					function()
						local is_git = Snacks.git.get_root() ~= nil
						return {
							{
								-- if git repo
								{
									{
										enabled = is_git,
										section = "terminal",
										cmd = "git config --get remote.origin.url",
										action = function()
											Snacks.gitbrowse()
										end,
										key = "b",
										padding = 1,
										height = 1,
									},
								},
								{
									{
										enabled = is_git,
										section = "terminal",
										cmd = "",
										icon = " ",
										title = "open explorer",
										action = function()
											Snacks.picker.explorer()
										end,
										key = "e",
										padding = 0,
										height = 1,
									},
									{
										enabled = is_git,
										section = "terminal",
										cmd = "",
										icon = " ",
										title = "find files",
										action = function()
											Snacks.dashboard.pick("files")
										end,
										key = "f",
										padding = 0,
										height = 1,
									},
									{
										enabled = is_git,
										section = "terminal",
										cmd = "",
										icon = " ",
										title = "grep text",
										action = function()
											Snacks.picker.grep()
										end,
										key = "g",
										padding = 0,
										height = 1,
									},
									{
										enabled = is_git,
										section = "terminal",
										cmd = "",
										icon = "󰊢 ",
										title = "open lazygit",
										action = function()
											Snacks.lazygit()
										end,
										key = "G",
										padding = 0,
										height = 1,
									},

									{
										enabled = is_git,
										section = "recent_files",
										icon = " ",
										title = "recent files",
										padding = 1,
										indent = 2,
										height = 10,
									},
								},
								{
									{
										enabled = is_git,
										pane = 2,
										section = "terminal",
										cmd = "gh issue list -L 5",
										icon = " ",
										title = "GitHub issues",
										action = function()
											vim.fn.jobstart("gh issue list --web", { detach = true })
										end,
										key = "I",
										padding = 1,
										indent = 2,
										height = 10,
									},
									{
										enabled = is_git,
										pane = 2,
										section = "terminal",
										cmd = "git --no-pager diff --stat -B -M -C",
										icon = " ",
										title = "git status",
										action = function()
											Snacks.picker.git_log()
										end,
										key = "h",
										padding = 1,
										height = 10,
									},
								},
							},
							{
								-- if not git repo
								{
									enabled = not is_git,
									section = "keys",
									gap = 1,
									padding = 1,
								},

								{
									{
										enabled = not is_git,
										pane = 2,
										icon = " ",
										title = "projects",
										section = "projects",
										indent = 2,
										padding = 1,
									},
									{
										enabled = not is_git,
										pane = 2,
										icon = " ",
										title = "recent files",
										section = "recent_files",
										indent = 2,
										padding = 1,
									},
								},
							},
						}
					end,
				},
			},
		},
	},
}
