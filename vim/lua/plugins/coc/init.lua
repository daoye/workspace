return {
    {
        "neoclide/coc.nvim",
        cond = function()
            return vim.g.usecoc
        end,
        dependencies = {
            {
                "Decodetalkers/csharpls-extended-lsp.nvim",
                cond = function()
                    return vim.g.usecoc
                end,
            },
        },
        branch = "release",
        build = "npm ci",
        opts = {},
        config = function(opts)
            require("conf.coc").setup(opts)
        end,
    },
}
