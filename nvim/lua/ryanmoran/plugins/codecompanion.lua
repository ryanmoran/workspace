return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"zbirenbaum/copilot.lua",
			config = function()
				require("copilot").setup({})
			end,
		},
	},
}
