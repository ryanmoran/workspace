return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			css = { "stylelint" },
			go = { "golangcilint" },
			html = { "tidy" },
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			json = { "jsonlint" },
			lua = { "luacheck" },
			markdown = { "markdownlint" },
			sh = { "shellcheck" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			yaml = { "yamllint" },
		}

		lint.linters.shellcheck.args = {
			"-x",
		}

		lint.linters.luacheck = {
			cmd = "luacheck",
			stdin = true,
			args = {
				"--globals",
				"vim",
			},
			stream = "stdout",
			ignore_exitcode = true,
		}

		lint.linters.yamllint.args = {
			"-c",
			"~/.config/nvim/.yamllint",
		}

		lint.linters.markdownlint.args = {
			"--stdin",
			"--disable",
			"MD024",
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
