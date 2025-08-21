return {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
        dashboard = {
            width = 60,
            row = nil,
            col = nil,
            pane_gap = 4,
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
                        icon = " ",
                        key = "g",
                        desc = "open lazygit",
                        action = ":lua Snacks.lazygit()",
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
                    { section = "header", indent = 60,          padding = 2 },
                    { pane = 2,           section = "terminal", cmd = "",   height = 6, padding = 2, indent = 2 },
                },
                {
                { section = "keys", gap = 1, padding = 1 },
                { section = "startup", indent = 60 },
            },
            {
                { pane = 2, icon = " ", title = "projects", section = "projects", indent = 2, padding = 1 },
                { pane = 2, icon = " ", title = "recent files", section = "recent_files", indent = 2, padding = 1 },
            },
            },
        },
    },
}
