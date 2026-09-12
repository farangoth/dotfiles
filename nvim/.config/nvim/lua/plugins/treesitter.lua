vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter"
})

local parsers = {"lua", "python", "bash", "c", "css", "csv", "gitignore", "html", "htmldjango", "json", "kitty", "latex", "markdown", "toml", "vim", "yaml", "zsh"}

require("nvim-treesitter").install(parsers)

-- The rewritten main-branch nvim-treesitter no longer auto-attaches
-- highlighting the way the old `configs.setup{highlight=...}` API did --
-- `install()` alone only fetches parsers. This is what actually turns
-- highlighting (and indent) on for the installed languages.
--
-- Neovim's `filetype` mostly matches the parser name above, except LaTeX
-- (parser "latex", filetype "tex") -- mapped explicitly below. "csv" and
-- "kitty" have no corresponding built-in Neovim filetype, so their
-- autocmd simply never fires; same no-highlight status quo as before this
-- fix, not a regression.
local filetypes = vim.deepcopy(parsers)
for i, lang in ipairs(filetypes) do
	if lang == "latex" then
		filetypes[i] = "tex"
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function()
		-- pcall: install() above may still be downloading/compiling a
		-- parser the first time a matching file is opened (it's async),
		-- and vim.treesitter.start() errors outright if the parser isn't
		-- ready yet -- silently skip highlighting for that one buffer
		-- instead of erroring on startup.
		pcall(vim.treesitter.start)
	end,
})
