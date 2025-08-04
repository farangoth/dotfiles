vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinLeave" }, {
    pattern = "/home/farangoth/git/gitjournal/*",
    callback = function()
        vim.fn.jobstart({ "bash", "/home/farangoth/bin/push_commit.sh" })
    end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "/home/farangoth/dotfiles/qtile/.config/qtile/config.py",
    callback = function()
        vim.fn.jobstart({ "qtile cmd-obj -o cmd -f reload_config" })
    end,
})
