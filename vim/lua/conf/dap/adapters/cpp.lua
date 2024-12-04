local dap = require("dap")
local utils = require("conf.dap.adapters.utils")

local M = {}


M.setup = function()
    dap.adapters['cppdbg'] = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7'
    }

    local configurations = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            cwd = '${workspaceFolder}',
            -- program = function()
            --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            -- end,
            stopAtEntry = true,
            program = "${input:inputProgram}",
        },
        {
            name = 'Attach to gdbserver :6565',
            type = 'cppdbg',
            request = 'launch',
            MIMode = 'gdb',
            miDebuggerServerAddress = 'localhost:6565',
            miDebuggerPath = '/usr/local/bin/gdb',
            cwd = '${workspaceFolder}',
            processId = "${pick_process}"
            -- processId = require("dap.utils").pick_process,
        },
    }

    utils.merge_launch_json(configurations)
end

return M
