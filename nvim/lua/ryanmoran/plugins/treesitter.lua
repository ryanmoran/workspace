return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" }, -- Syntax aware text-objects
		{
			"nvim-treesitter/nvim-treesitter-context", -- Show code context
			opts = { enable = true, mode = "topline", line_numbers = true },
		},
	},
	config = function()
		require("nvim-treesitter").install({
			"bash",
			"c",
			"cpp",
			"css",
			"csv",
			"dot",
			"gitignore",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"html",
			"javascript",
			"json",
			"lua",
			"make",
			"markdown",
			"proto",
			"python",
			"rust",
			"sql",
			"toml",
			"tsx",
			"typescript",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				if vim.bo.filetype == "csv" then -- preferring chrisbra/csv.vim
					return
				end
				local ok = pcall(vim.treesitter.start)
				if ok then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown" },
			callback = function(_)
				-- treesitter-context is buggy with Markdown files
				require("treesitter-context").disable()
			end,
		})

		local opts = { noremap = true, silent = true }

		local function quickfix()
			vim.lsp.buf.code_action({})
		end

		local function showerror()
			vim.diagnostic.open_float()
		end

		vim.keymap.set("n", "<leader>qf", quickfix, opts)
		vim.keymap.set("n", "<space>e", showerror, opts)
	end,
}
