vim.g.mapleader = ","

vim.opt.encoding = "utf-8"

vim.opt.compatible = false
vim.opt.hlsearch = true
vim.opt.laststatus = 2
vim.opt.vb = true
vim.opt.ruler = true
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.autoindent = true
vim.opt.colorcolumn = "120"
vim.opt.textwidth = 120
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamed"
vim.opt.scrollbind = false
vim.opt.wildmenu = true

-- Setting Spacing and Indent (plus line no)
vim.opt.nu = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.ts = 2
vim.opt.wrap = false
vim.opt.directory = "/tmp"

-- Hidden characters
vim.opt.listchars = { tab = '  ', trail = '█' }
vim.opt.list = true

local map = vim.api.nvim_set_keymap

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
map("n", "n", "nzzzv", { noremap = true })
map("n", "N", "Nzzzv", { noremap = true })
map("n", "<space>", ":noh<CR>", { noremap = true }) -- hit the space bar to remove search highlights

-- Yank to system clipboard
map("v", "<leader>y", "\"*y", { noremap = true })
map("n", "<leader>y", "\"*y", { noremap = true })

-- Maintain undo history between sessions
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

-- filetype related
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"gitcommit"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 72, {scope = "local"})
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"markdown"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 0, {scope = "local"})
        vim.api.nvim_set_option_value("wrapmargin", 0, {scope = "local"})
        vim.api.nvim_set_option_value("linebreak", false, {scope = "local"})
    end
})
