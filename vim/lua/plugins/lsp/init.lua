return {
    {
        "williamboman/mason-lspconfig.nvim",
        cond = function()
            return not vim.g.usecoc
        end,
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = true,
    },
    {
        "neovim/nvim-lspconfig",
        cond = function()
            return not vim.g.usecoc
        end,
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            -- add any global capabilities here
            capabilities = {
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    },
                },
            },
        },
        init = function() end,
        config = function(_, opts)
            require("conf.lsp").setup(opts)
        end,
    },
    -- auto completion
    {
        'hrsh7th/nvim-cmp',
        cond = function()
            return not vim.g.usecoc
        end,
        dependencies = {
            {
                'hrsh7th/cmp-nvim-lsp',
            },
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',

            -- autocomplete snip source
            'saadparwaiz1/cmp_luasnip',
            {
                'L3MON4D3/LuaSnip',
                dependencies = { "rafamadriz/friendly-snippets" },
                init = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end
            },

            -- extend sources
            'hrsh7th/cmp-nvim-lsp-signature-help',

            -- spell
            'f3fora/cmp-spell',
            -- dap
            "rcarriga/cmp-dap",
        },
        config = function(_, opts)
            require("conf.cmp").setup(opts)
        end,
        init = function()
            require("conf.cmp").initialize()
        end
    },

    -- formater, lints
    {
        "nvimtools/none-ls.nvim",
        cond = function()
            return not vim.g.usecoc
        end,
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.black,

                    null_ls.builtins.code_actions.refactoring,

                    -- null_ls.builtins.completion.spell,
                },
            })
        end,
    },

    -- csharp
    {
        "Decodetalkers/csharpls-extended-lsp.nvim",
        cond = function()
            return not vim.g.usecoc
        end,
    },

    -- lua
    {
        "folke/lazydev.nvim",
        cond = function()
            return not vim.g.usecoc
        end,
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "Bilal2453/luvit-meta",

        cond = function()
            return not vim.g.usecoc
        end,
        lazy = true
    }, -- optional `vim.uv` typings

}
