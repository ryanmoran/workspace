return {
    "ray-x/navigator.lua",
    dependencies = {
        {"hrsh7th/nvim-cmp"}, {"nvim-treesitter/nvim-treesitter"},
        {"ray-x/guihua.lua", run = "cd lua/fzy && make"}, {
            "ray-x/go.nvim",
            event = {"CmdlineEnter"},
            ft = {"go", "gomod"},
            build = ':lua require("go.install").update_all_sync()'
        }, {
            "ray-x/lsp_signature.nvim", -- Show function signature when you type
            event = "VeryLazy",
            config = function() require("lsp_signature").setup() end
        }
    },
    config = function()
        require("go").setup()
        require("navigator").setup({
            lsp_signature_help = true, -- enable ray-x/lsp_signature
            lsp = {format_on_save = true}
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {"go"},
            callback = function(ev)
                -- CTRL/control keymaps
                vim.api .nvim_buf_set_keymap(0, "n", "<C-i>", ":GoImport<CR>", {})
                vim.api.nvim_buf_set_keymap(0, "n", "<C-b>", ":GoBuild %:h<CR>", {})
                vim.api.nvim_buf_set_keymap(0, "n", "<C-t>", ":GoTestPkg<CR>", {})
                vim.api.nvim_buf_set_keymap(0, "n", "<C-c>", ":GoCoverage -p<CR>", {})

                -- Opens test files
                vim.api.nvim_buf_set_keymap(0, "n", "tt", ":lua require('go.alternate').switch(true, '')<CR>", {}) -- Test
                vim.api.nvim_buf_set_keymap(0, "n", "tv", ":lua require('go.alternate').switch(true, 'vsplit')<CR>", {}) -- Test Vertical
                vim.api.nvim_buf_set_keymap(0, "n", "ts", ":lua require('go.alternate').switch(true, 'split')<CR>", {}) -- Test Split
            end,
            group = vim.api.nvim_create_augroup("go_autocommands", {clear = true})
        })

        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
               require('go.format').goimports()
            end,
            group = format_sync_grp,
        })

    end
}

