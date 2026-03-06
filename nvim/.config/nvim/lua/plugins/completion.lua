 vim.pack.add({
	{
		src = "https://github.com/Saghen/blink.cmp",
		version = "v1.9.1",
	},
	{ 
		src = "https://github.com/windwp/nvim-autopairs" 
	},
})

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = {
		nerd_font_variant = "mono",
	},
})

require("nvim-autopairs").setup({})
