return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects" }, -- Syntax aware text-objects
		{
			"nvim-treesitter/nvim-treesitter-context", -- Show code context
			opts = { enable = true, mode = "topline", line_numbers = true },
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown" },
			callback = function(_)
				-- treesitter-context is buggy with Markdown files
				require("treesitter-context").disable()
			end,
		})

		local treesitter = require("nvim-treesitter.configs")
		treesitter.setup({
			ensure_installed = {
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
				"python",
				"rust",
				"sql",
				"toml",
				"typescript",
				"tsx",
				"yaml",
			},
			indent = { enable = true },
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				disable = { "csv" }, -- preferring chrisbra/csv.vim
			},
			textobjects = { select = { enable = true, lookahead = true } },
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
