vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

local Snacks = require("snacks")

Snacks.setup({
	explorer = { enabled = true },
	statuscolumn = { enabled = true },
	indent = { enabled = true, only_scope = true, only_current = true },
	input = { enabled = true },
	scope = { enable = true },
	-- lazygit = { enabled = true }
	zen = {
		toggles = {
			line_number = false,
			signcolumn = "no",
			dim = true,
			diagnostics = false,
			indent = false,
		},
	},
	picker = {
		sources = {
			files = {
				hidden = true,
				ignored = true,
				win = {
					input = {
						keys = {
							["<S-h>"] = "toggle_hidden",
							["<S-i>"] = "toggle_ignored",
							["<S-f>"] = "toggle_follow",
						},
					},
				},
				exclude = {
					"**/.git/*",
				},
			},
			grep = {
				hidden = true,
				ignored = true,
				win = {
					input = {
						keys = {
							["<S-h>"] = "toggle_hidden",
							["<S-i>"] = "toggle_ignored",
							["<S-f>"] = "toggle_follow",
						},
					},
				},
				exclude = {
					"**/.git/*",
				},
			},
			explorer = {
				hidden = true,
				ignored = true,
				support_live = true,
				auto_close = true,
				diagnostics = true,
				diagnostics_open = true,
				focus = "list",
				follow_file = true,
				git_status = true,
				git_status_open = false,
				git_untracked = true,
				jump = { close = true },
				tree = true,
				watch = true,
				exclude = {
					".git",
					".venv",
				},
			},
		},
	},
})

local keymaps = {
	-- finders
	{ "<leader><space>", function() Snacks.picker.smart() end, desc = "smart file finder" },
	{ "<leader>ff", function() Snacks.picker.files() end, desc = "files finder" },
	{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "config file finder" }, -- change to dotfiles once setup
	{ "<leader>fr", function() Snacks.picker.recent() end, desc = "recents finder" },
	{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "buffers finder" },
	{ "<leader>e", function() Snacks.explorer() end, desc = "open explorer" },
	--grep
	{ "<leader>sb", function() Snacks.picker.lines() end, desc = "search buffer lines" },
	{ "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "search buffers" },
	{ "<leader>sf", function() Snacks.picker.grep() end, desc = "search files" },
	-- toggle
	{ "<leader>z", function() Snacks.zen() end, desc = "toggle zen mode" },
}

for _, map in ipairs(keymaps) do
	local opts = { desc = map.desc }
	if map.silent ~= nil then
		opts.silent = map.silent
	end
	if map.noremap ~= nil then
		opts.noremap = map.noremap
	else
		opts.noremap = true
	end
	if map.expr ~= nil then
		opts.expr = map.expr
	end

	local mode = map.mode or "n"
	vim.keymap.set(mode, map[1], map[2], opts)
end
