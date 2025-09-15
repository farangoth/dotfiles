return {
	"folke/snacks.nvim",
	lazy = false,
	opts = {
		picker = {
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
				},
				files = {
					hidden = true,
					ignored = false,
				},
				smart = {
					hidden = true,
					ignored = false,
				},
				grep = {
					hidden = true,
					ignored = false,
				},
			},
		},
	},
	keys = {
		{
			"<leader><leader>",
			function()
				Snacks.picker.smart()
			end,
			desc = "smart find files",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "find files",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers({ layout = "select" })
			end,
			desc = "find buffers",
		},
		{
			"<leader>fp",
			function()
                Snacks.picker.projects({})
			end,
			desc = "find projects",
		},
		{
			"<leader>fe",
			function()
				Snacks.picker.explorer()
			end,
			desc = "open files explorer",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "grep text",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols({ layout = { preset = "left" } })
			end,
			desc = "open symbols explorer (buffer)",
		},
		{
			"<leader>fS",
			function()
				Snacks.picker.lsp_workspace_symbols({ layout = { preset = "left" } })
			end,
			desc = "open symbols explorer (workspace)",
		},
		{
			"<leader>fD",
			function()
				Snacks.picker.diagnostics({ layout = { preset = "left" } })
			end,
			desc = "open diagnostics explorer (workspace)",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics_buffer({ layout = { preset = "left" } })
			end,
			desc = "open diagnostics explorer (buffer)",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "find help",
		},
		{
			"<leader>fu",
			function()
				Snacks.picker.undo()
			end,
			desc = "explore undo",
		},
		{
			'<leader>"',
			function()
				Snacks.picker.registers()
			end,
			desc = "find registers",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.lsp_definitions({ layout = { preset = "left" } })
			end,
			desc = "(GoTo) definition",
		},
		{
			"<leader>gD",
			function()
				Snacks.picker.lsp_implementations({ layout = { preset = "left" } })
			end,
			desc = "(GoTo) implementations",
		},
		{
			"<leader>gr",
			function()
				Snacks.picker.lsp_references({ layout = { preset = "left" } })
			end,
			desc = "(GoTo) references",
		},
	},
}
