-- tmux's own C-hjkl bindings (tmux.conf) only forward the key INTO nvim
-- when nvim is the focused pane -- they never get a chance to fire on the
-- way back OUT, since nvim itself consumes the key first. `:wincmd` alone
-- is a dead end at the edge of nvim's own window layout (e.g. a single,
-- unsplit nvim pane): it silently no-ops instead of moving to the tmux
-- pane beside it. Falling back to `tmux select-pane` when `:wincmd`
-- didn't actually change the current window closes that other half of
-- the handoff, without needing the vim-tmux-navigator plugin.
local function move_win_or_pane(wincmd_dir, tmux_dir)
    return function()
        local win_before = vim.api.nvim_get_current_win()
        vim.cmd("wincmd " .. wincmd_dir)
        if vim.api.nvim_get_current_win() == win_before and vim.env.TMUX then
            vim.fn.system("tmux select-pane -" .. tmux_dir)
        end
    end
end

local keymaps = {
    { "<leader>la", function() vim.lsp.buf.code_action() end, desc = "code actions" },
    { "H",          ":bprevious<CR>",                         desc = "prev buffer",       silent = true },
    { "L",          ":bnext<CR>",                             desc = "next buffer",       silent = true },
    { "<leader>v",  ":vsplit<CR>",                            desc = "split vertical",    silent = true },
    { "<leader>c",  ":split<CR>",                             desc = "split horizontal",  silent = true },
    { "<C-h>",      move_win_or_pane("h", "L"),                 desc = "move to left win/pane",  silent = true },
    { "<C-j>",      move_win_or_pane("j", "D"),                 desc = "move to down win/pane",  silent = true },
    { "<C-k>",      move_win_or_pane("k", "U"),                 desc = "move to up win/pane",    silent = true },
    { "<C-l>",      move_win_or_pane("l", "R"),                 desc = "move to right win/pane", silent = true },
    { "<leader>w",  ":w<CR>",                                 desc = "write files",       silent = true },
    { "<leader>lr", function() vim.lsp.buf.rename() end,      desc = "rename symbol" },
    { "<leader>pu", function() vim.pack.update() end,         desc = "update package" },
    {
        "<leader>pc",
        function() vim.cmd.edit(vim.fn.stdpath("config") .. "/lua/plugins/") end,
        desc = "config plugins",
    },
    { "<leader>pm", ":MasonUpdate<CR>",                       desc = "update LSPs" },
}

for _, map in ipairs(keymaps) do
    local lhs = map[1]
    local rhs = map[2]

    local opts = vim.deepcopy(map)
    opts[1] = nil
    opts[2] = nil

    local mode = opts.mode or "n"
    opts.mode = nil
    opts.noremap = opts.noremap ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
end
