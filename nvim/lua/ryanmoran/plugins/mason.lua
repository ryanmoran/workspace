return {
	"williamboman/mason.nvim",
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	},
	config = function()
		local mason = require("mason")
		local lspconfig = require("mason-lspconfig")
		local installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		lspconfig.setup({
			ensure_installed = { "ts_ls" },
		})

		installer.setup({
			ensure_installed = {
				"eslint_d",
				"goimports",
				"golangci-lint",
				"gopls",
				"jsonlint",
				"luacheck",
				"markdownlint",
				"prettier",
				"shellcheck",
				"shfmt",
				"stylelint",
				"stylua",
				"typescript-language-server",
				"yamllint",
			},
		})
	end,
}
