return {
  "RRethy/base16-nvim",
  enabled = true,
  config = function()
    require("base16-colorscheme").setup()
    vim.cmd('colorscheme base16-tomorrow-night-eighties')
  end
}

