return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end
				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					gs.next_hunk()
				end, { expr = true, desc = "Next Hunk" })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					gs.prev_hunk()
				end, { expr = true, desc = "Prev Hunk" })
				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage Selected Hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset Selected Hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "Blame Line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "Diff This (HEAD)" })
				map("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
				map("n", "<leader>hP", gs.toggle_deleted, { desc = "Toggle Deleted Lines" })
			end,
		})
	end,
}
