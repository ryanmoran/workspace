return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				css = { "prettier" },
				go = { "goimports" },
				proto = { "buf" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				markdown = { "rumdl" },
				sh = { "shfmt" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "yamlfmt" },
			},
			format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
		})
	end,
}
