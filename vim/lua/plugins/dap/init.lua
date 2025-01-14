return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
        },
        -- event = { "VeryLazy" },
        opts = {},
        keys = {
            { "<F5>",   function() require("dap").continue() end,                                             desc = "(DAP)Continue with picked configuration" },
            { "<S-F5>", function() require("dap").terminate() end,                                            desc = "(DAP)Terminate" },
            { "<C-F5>", function() require("dap").restart() end,                                              desc = "(DAP)Restart" },
            { "<A-F5>", function() require("dap").continue() end,                                             desc = "(DAP)Continue" },
            { "<F6>",   function() require("dap").run_to_cursor() end,                                        desc = "(DAP)Run to Cursor" },
            { "<F9>",   function() require("dap").toggle_breakpoint() end,                                    desc = "(DAP)Toggle Breakpoint" },
            { "<C-F9>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "(DAP)Breakpoint with condition" },
            { "<S-F9>", function() require("dap").clear_breakpoints() end,                                    desc = "(DAP)Clear breakpoints" },
            {
                "<A-F9>",
                function()
                    require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
                end,
                desc = "(DAP)Breakpoint with log"
            },
            { "<F10>",                    function() require("dap").step_over() end,                  desc = "(DAP)Step Over" },
            { "<S-F10>",                  function() require("dap").step_out() end,                   desc = "(DAP)Step Out" },
            { "<F11>",                    function() require("dap").step_into() end,                  desc = "(DAP)Step Into" },
            { "<F1>",                     function() require("dap.repl").toggle({ height = 10 }) end, desc = "(DAP)Toggle repl buffer" },
            { "<leader>dg",               function() require("dap").goto_() end,                      desc = "(DAP)Go to line (no execute)" },
            { "<leader>dj",               function() require("dap").down() end,                       desc = "(DAP)Down" },
            { "<leader>dk",               function() require("dap").up() end,                         desc = "(DAP)Up" },
            { "<leader>dl",               function() require("dap").run_last() end,                   desc = "(DAP)Run Last" },
            { "<leader>dp",               function() require("dap").pause() end,                      desc = "(DAP)Pause" },
            { "<leader>ds",               function() require("dap").session() end,                    desc = "(DAP)Session" },
            { "<leader><leader><leader>", function() require("conf.dap").vscode() end,                desc = "(DAP)Update .vscode/launch.json and load" },
        },
        config = function()
            require("conf.dap").setup()
        end,
    },
    {

        "nvim-telescope/telescope-dap.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap",
        },
        config = function()
            require('telescope').load_extension('dap')
        end,
        keys = {
            { "<leader>dc", function() require 'telescope'.extensions.dap.commands {} end,         desc = "Dap commands" },
            { "<leader>do", function() require 'telescope'.extensions.dap.configurations {} end,   desc = "Dap configurations" },
            { "<leader>db", function() require 'telescope'.extensions.dap.list_breakpoints {} end, desc = "Dap list breakpoints" },
            { "<leader>dv", function() require 'telescope'.extensions.dap.variables {} end,        desc = "Dap variables" },
            { "<leader>df", function() require 'telescope'.extensions.dap.frames {} end,           desc = "Dap frames" },
        },
    }
}
