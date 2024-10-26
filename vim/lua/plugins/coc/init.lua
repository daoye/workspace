if not vim.g.usecoc then
    return {}
end

return {
    {
        "neoclide/coc.nvim",
        dependencies = {
            {
                "fannheyward/telescope-coc.nvim",
                config = function()
                    require("telescope").setup({
                        extensions = {
                            coc = {
                                prefer_locations = false,
                                push_cursor_on_edit = true,
                                timeout = 3000,
                            },
                        },
                    })
                    require("telescope").load_extension("coc")
                end,
            },
        },
        branch = "release",
        build = "npm ci",
        opts = {},
        config = function()
            require("conf.coc").setup(opts)
        end,
    },
}
