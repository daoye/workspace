local dap = require("dap")
local utils = require("conf.dap.adapters.utils")

local M = {}


M.setup = function()
    dap.adapters['cppdbg'] = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7',
        attach = {
            pidProperty = "processId",
            pidSelect = "ask"
        },
    }

    local configurations = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            cwd = '${workspaceFolder}',
            -- program = "${workspaceFolder}/app.exe",
            -- program = function()
            --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            -- end,
            stopAtEntry = true,
            program = "${input:inputProgram}",
            osx = {
                MIMode = "lldb"
            },
            setupCommands = {
                {
                    text = '-enable-pretty-printing',
                    description = 'enable pretty printing',
                    ignoreFailures = false
                },
            },

        },
        {
            name = 'Attach to gdbserver :6565',
            type = 'cppdbg',
            request = 'launch',
            MIMode = 'gdb',
            miDebuggerServerAddress = 'localhost:6565',
            miDebuggerPath = '/usr/local/bin/gdb',
            cwd = '${workspaceFolder}',
            osx = {
                MIMode = "lldb"
            },
            setupCommands = {
                {
                    text = '-enable-pretty-printing',
                    description = 'enable pretty printing',
                    ignoreFailures = false
                },
            },
            -- processId = "${pick_process}"
            -- processId = require("dap.utils").pick_process,
        },
    }

    -- for _, name in ipairs({ "c", "cpp", "rust" }) do
    --     dap.configurations[name] = configurations
    -- end

    if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
        utils.merge_launch_json(configurations)
    end
end

return M
