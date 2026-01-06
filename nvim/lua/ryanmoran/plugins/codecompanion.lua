return {
	"olimorris/codecompanion.nvim",
	opts = {
		ignore_warnings = true,
		strategies = {
			chat = {
				adapter = "copilot",
				model = "claude-3-7-sonnet",
			},
			inline = {
				adapter = "copilot",
				model = "claude-3-7-sonnet",
			},
			cmd = {
				adapter = "copilot",
				model = "claude-3-7-sonnet",
			},
		},
	},
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
