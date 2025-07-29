return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour="macchiato"
        })
        vim.cmd.colorscheme("catppuccin")
        local colors = require("catppuccin.palettes").get_palette("macchiato")
        vim.opt.cursorline = true
        vim.api.nvim_set_hl(0, "LineNrAbove", { fg = colors["overlay0"] })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg =  colors["lavender"] })
        vim.api.nvim_set_hl(0, "LineNrBelow", { fg = colors["overlay0"]  })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg =  colors["lavender"] })
    end,
}
