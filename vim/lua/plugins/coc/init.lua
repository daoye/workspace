return {
    {
        "neoclide/coc.nvim",
        cond = function()
            return vim.g.usecoc
        end,
        dependencies = {
        },
        branch = "release",
        build = "npm ci",
        opts = {},
        config = function(opts)
            require("conf.coc").setup(opts)
        end,
    },
}
