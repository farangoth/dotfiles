return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = {
			function()
				local parsers = {
					"bash",
					"c",
					"cpp",
                    "diff",
					"gitcommit",
					"gitignore",
					"haskell",
					"html",
					"htmldjango",
					"jq",
					"json",
					"latex",
					"lua",
					"make",
					"markdown",
					"ngimx",
					"python",
					"sql",
					"ssh_config",
					"vim",
					"vimdoc",
					"yaml",
					"requirements",
				}
				require("nvim-treesitter").install(parsers)
                require("nvim-treesitter").update()
			end,
		},
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local filetype = args.match
                    local lang = vim.treesitter.language.get_lang(filetype)
                    if vim.treesitter.language.add(lang) then
                        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        vim.treesitter.start()
                    end
                end
            })
        end
	},
}
