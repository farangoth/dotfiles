vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter"
})

require("nvim-treesitter").install({"lua", "python", "bash", "c", "css", "csv", "gitignore", "html", "htmldjango", "json", "kitty", "latex", "markdown", "toml", "vim", "zsh"})
