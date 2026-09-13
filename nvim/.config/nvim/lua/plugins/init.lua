-- Each plugin module calls vim.pack.add, which clones/updates over the
-- network on first use -- a single offline machine, DNS hiccup, or
-- GitHub rate-limit throws and would otherwise abort this whole require
-- chain, which in turn means config/keymaps (loaded after "plugins" in
-- init.lua) never load either. pcall isolates one plugin's failure from
-- every other plugin and from options/keymaps still loading normally.
local plugin_modules = {
	"plugins.whichkey",
	"plugins.catppuccin",
	"plugins.treesitter",
	"plugins.outline",
	"plugins.snacks",
	"plugins.completion",
	"plugins.lsp",
	"plugins.conform",
	"plugins.gitsigns",
	"plugins.surround",
	"plugins.todo-comments",
	"plugins.lualine",
	"plugins.markdown",
	"plugins.mistralvibe",
}

for _, mod in ipairs(plugin_modules) do
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify(("Failed to load %s: %s"):format(mod, err), vim.log.levels.ERROR)
	end
end
