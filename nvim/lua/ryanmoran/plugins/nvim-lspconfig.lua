return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.config.clangd = {
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "hpp" },
		}
	end,
}
