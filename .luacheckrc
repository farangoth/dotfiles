-- luacheck config for the nvim stow package.
-- `vim` is a Neovim-injected global, not defined anywhere in this repo, and
-- config code constantly assigns into it (vim.o.*, vim.g.*, ...), so it must
-- be a writable global rather than read_globals.
globals = { "vim" }
std = "lua51"

max_line_length = false
