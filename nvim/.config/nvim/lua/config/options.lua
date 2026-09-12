vim.o.number = true
vim.o.cursorline = true
vim.o.winborder = "none"
vim.o.scrolloff = 10
vim.o.title = true

local function get_title()
    if vim.bo.filetype == "codecompanion" then
        return "CodeCompanion"
    end
    if vim.bo.buftype ~= "" then
        return "nvim"
    end
    local path = vim.fn.expand("%:p") -- Full absolute path
    if path == "" then
        return "nvim"
    end

    -- Try to find git root
    local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
    if git_dir ~= "" then
        -- Get the absolute path to the .git directory
        local git_root = vim.fn.fnamemodify(git_dir, ":p:h")
        -- If the path ends in .git, go up one more level to get the project root
        if git_root:match("%.git$") then
            git_root = vim.fn.fnamemodify(git_root, ":h")
        end

        local project_root_path = git_root
        local project_root_name = vim.fn.fnamemodify(project_root_path, ":t")
        local rel_path = path:sub(#project_root_path + 2)

        if rel_path == "" then
            return "[ " .. project_root_name .. " ]"
        end
        return "[ " .. project_root_name .. "] " .. rel_path
    else
        -- If not in git, show full path
        return "" .. path
    end
end

-- Update title on relevant events
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
    callback = function()
        vim.opt.titlestring = get_title()
    end,
})

-- indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = false

-- clipboard (shares yanks/pastes with foot/tmux via wl-clipboard + cliphist)
vim.o.clipboard = "unnamedplus"

-- visual
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.showmatch = true
vim.o.showmode = false

--perf
vim.o.synmaxcol = 300
vim.o.updatetime = 300

-- files handling
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.autoread = true
vim.o.autowrite = true

-- undo
-- `undodir` is left at its built-in default (under stdpath("state"),
-- auto-created) rather than hardcoded to ~/.vim/undodir -- that path
-- ignores XDG_STATE_HOME/a non-default HOME and needlessly reimplements
-- what undofile=true already gets for free.
vim.o.undofile = true
vim.o.undolevels = 10000

vim.g.autoformat = true
