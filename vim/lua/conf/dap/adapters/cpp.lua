local dap = require("dap")
local dap_ext = require("dap.ext.vscode")
local utils = require("conf.dap.utils")

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
            name = "Launch",
            type = "cppdbg",
            request = "launch",
            cwd = '${workspaceFolder}',
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            stopAtEntry = true,
            targetArchitecture = "x86_64",
            MIMode = "gdb",
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
            miDebuggerServerAddress = 'localhost:6565',
            miDebuggerPath = '/usr/local/bin/gdb',
            cwd = '${workspaceFolder}',
            targetArchitecture = "x86_64",
            MIMode = 'gdb',
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
            processId = require("dap.utils").pick_process,
        },
    }

    local vscode_configs = dap_ext.getconfigs(utils.get_vscode_cfg_path())

    for _, name in ipairs({ "c", "cpp", "rust" }) do
        dap.configurations[name] = dap.configurations[name] or {}
        for _, cfg in ipairs(configurations) do
            local exists = false

            if vscode_configs then
                for _, v in ipairs(vscode_configs) do
                    if v['type'] == 'cppdbg' and v['name'] == cfg['name'] then
                        exists = true
                    end
                end
            end

            if not exists then
                table.insert(dap.configurations[name], cfg)
            end
        end
    end
end


M.vscode = function()
    local need = vim.bo.filetype == "c" or vim.bo.filetype == "cpp" or vim.bo.filetype == "rust"

    if not need then
        return
    end

    local configurations = {
        {
            name = "Launch",
            type = "cppdbg",
            request = "launch",
            cwd = '${workspaceFolder}',
            stopAtEntry = true,
            program = "${input:inputProgram}",
            targetArchitecture = "x86_64",
            MIMode = 'gdb',
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
            miDebuggerServerAddress = 'localhost:6565',
            miDebuggerPath = '/usr/local/bin/gdb',
            cwd = '${workspaceFolder}',
            targetArchitecture = "x86_64",
            MIMode = 'gdb',
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
            processId = "${pick_process}"
        },
    }

    utils.save_launch_json(configurations)
end

return M
