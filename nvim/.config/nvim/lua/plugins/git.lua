return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
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
				end, { expr = true, desc = "next Hunk" })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					gs.prev_hunk()
				end, { expr = true, desc = "prev Hunk" })
				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, { desc = "stage Hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "reset Hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "stage selected hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "reset selected hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "stage buffer" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "reset buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "preview hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "blame line (hint)" })
				map("n", "<leader>hd", gs.diffthis, { desc = "diff this" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "diff this (HEAD)" })
				map("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "toggle current line blame" })
				map("n", "<leader>hP", gs.toggle_deleted, { desc = "toggle deleted lines" })
			end,
		})
	end,
}
