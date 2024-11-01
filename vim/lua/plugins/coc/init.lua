return {
    {
        "neoclide/coc.nvim",
        cond = function()
            return vim.g.usecoc
        end,
        dependencies = {
            -- {
            --     "williamboman/mason.nvim",
            --     config = true,
            -- },
            -- {
            --     "fannheyward/telescope-coc.nvim",
            --     config = function()
            --         require("telescope").setup({
            --             extensions = {
            --                 coc = {
            --                     prefer_locations = false,
            --                     push_cursor_on_edit = true,
            --                     timeout = 3000,
            --                 },
            --             },
            --         })
            --         require("telescope").load_extension("coc")
            --     end,
            -- },
        },
        branch = "release",
        build = "npm ci",
        opts = {},
        config = function()
            require("conf.coc").setup(opts)
        end,
    },
}
