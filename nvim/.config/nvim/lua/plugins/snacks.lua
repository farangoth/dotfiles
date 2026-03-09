vim.pack.add({
    "https://github.com/folke/snacks.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

local Snacks = require("snacks")

Snacks.setup({
    explorer = { enabled = true },
    statuscolumn = { enabled = true },
    indent = {
        animate = {
            enabled = false,
        },
        scope = {
            enabled = true,
            only_scope = true,
            only_current = true,
        },
        chunk = {
            enabled = false,
        }
    },
    input = { enabled = true },
    scope = { enabled = true },
    gh = { enabled = true },
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
    { "<leader>b",       function() Snacks.picker.buffers() end,                                                                                   desc = "smart file",           hidden = true },
    { "<leader><space>", function() Snacks.picker.smart() end,                                                                                     desc = "smart file",           hidden = true },
    { "<leader>ff",      function() Snacks.picker.files() end,                                                                                     desc = "files" },
    { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.expand("~/dotfiles/") }) end,                                               desc = "configs" },
    { "<leader>fr",      function() Snacks.picker.recent() end,                                                                                    desc = "recents" },
    { "<leader>fb",      function() Snacks.picker.buffers() end,                                                                                   desc = "buffers" },
    { "<leader>fp",      function() Snacks.picker.projects() end,                                                                                  desc = "projects" },
    { "<leader>e",       function() Snacks.explorer() end,                                                                                         desc = "open explorer" },
    --grep
    { "<leader>sl",      function() Snacks.picker.lines() end,                                                                                     desc = "search buffer lines" },
    { "<leader>sb",      function() Snacks.picker.grep_buffers() end,                                                                              desc = "search buffers" },
    { "<leader>sf",      function() Snacks.picker.grep() end,                                                                                      desc = "search files" },
    -- GoTo
    { "gd",              function() Snacks.picker.lsp_definitions() end,                                                                           desc = "goto definition" },
    { "gD",              function() Snacks.picker.lsp_declarations() end,                                                                          desc = "goto declaration" },
    { "gr",              function() Snacks.picker.lsp_references() end,                                                                            desc = "list references",      nowait = true, },
    { "gI",              function() Snacks.picker.lsp_implementations() end,                                                                       desc = "goto implementations" },
    { "gy",              function() Snacks.picker.lsp_type_definitions() end,                                                                      desc = "goto type definitions" },
    -- lsp
    { "<leader>ld",      function() Snacks.picker.diagnostics_buffer({ layout = "sidebar", }) end,                                                 desc = "buffer diagnostics" },
    { "<leader>lD",      function() Snacks.picker.diagnostics({ layout = "sidebar" }) end,                                                         desc = "workspace diagnostics" },
    { "<leader>ls",      function() Snacks.picker.lsp_symbols({ layout = "sidebar", auto_close = false, jump = { close = false } }) end,           desc = "buffer symbols" },
    { "<leader>lS",      function() Snacks.picker.lsp_workspace_symbols({ layout = "sidebar", auto_close = false, jump = { close = false } }) end, desc = "workspace symbols" },
    { "<leader>lC",      function() Snacks.picker.lsp_config() end,                                                                                desc = "configs" },
    -- git
    { "<leader>gg",      function() Snacks.lazygit() end,                                                                                          desc = "lazygit" },
    { "<leader>gb",      function() Snacks.picker.git_branches() end,                                                                              desc = "branches" },
    { "<leader>gs",      function() Snacks.picker.git_status() end,                                                                                desc = "status" },
    { "<leader>gd",      function() Snacks.picker.git_diff() end,                                                                                  desc = "diff" },
    { "<leader>gl",      function() Snacks.picker.git_log() end,                                                                                   desc = "log" },
    { "<leader>gL",      function() Snacks.git.blame_line() end,                                                                                   desc = "blame line" },
    { "<leader>gO",      function() Snacks.gitbrowse.open() end,                                                                                   desc = "open repo" },
    --github
    { "<leader>ghi",     function() Snacks.picker.gh_issue() end,                                                                                  desc = "opened issues" },
    { "<leader>ghI",     function() Snacks.picker.gh_issue({ state = "all" }) end,                                                                 desc = "all issues" },
    { "<leader>ghp",     function() Snacks.picker.gh_pr() end,                                                                                     desc = "opened PR" },
    { "<leader>ghP",     function() Snacks.picker.gh_pr({ state = "all" }) end,                                                                    desc = "all PR" },
    -- toggle
    { "<leader>tz",      function() Snacks.zen() end,                                                                                              desc = "zen mode" },
    { "<leader>ti",      function() Snacks.toggle.indent() end,                                                                                    desc = "indent" },
    -- helpers
    { "<leader>hh",      function() Snacks.picker.help() end,                                                                                      desc = "help" },
    { "<leader>hm",      function() Snacks.picker.man() end,                                                                                       desc = "man" },
    { "<leader>hk",      function() Snacks.picker.keymaps() end,                                                                                   desc = "keymaps" },
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
