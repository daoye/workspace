local dap = require("dap")
local dap_ext = require("dap.ext.vscode")
local utils = require("conf.dap.utils")
local M = {}

local find_python = function()
    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.

    local cwd = vim.fn.getcwd()
    local command = (os.getenv("VIRTUAL_ENV") or '') .. "/bin/python"

    if vim.fn.executable(command) == 1 then
        return command
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    elseif vim.fn.executable(cwd .. '/.env/bin/python') == 1 then
        return cwd .. '/.env/bin/python'
    else
        return '/usr/bin/python'
    end
end


M.setup = function()
    dap.adapters.python = function(cb, config)
        local command = find_python()

        if config.request == 'attach' then
            ---@diagnostic disable-next-line: undefined-field
            local port = (config.connect or config).port
            ---@diagnostic disable-next-line: undefined-field
            local host = (config.connect or config).host or '127.0.0.1'

            cb({
                type = 'server',
                port = assert(port, '`connect.port` is required for a python `attach` configuration'),
                host = host,
                options = {
                    source_filetype = 'python',
                },
            })
        else
            cb({
                type = 'executable',
                command = command,
                args = { '-m', 'debugpy.adapter' },
                options = {
                    source_filetype = 'python',
                },
            })
        end
    end

    local configurations = {
        {
            -- The first three options are required by nvim-dap
            type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch',
            name = "Launch file",

            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
            program = "${file}",
            python = find_python(),
            args = {},
            cwd = "${workspaceFolder}",
        },
    }

    local vscode_configs = dap_ext.getconfigs(utils.get_vscode_cfg_path())

    local name = 'python'
    dap.configurations[name] = dap.configurations[name] or {}

    for _, cfg in ipairs(configurations) do
        local exists = false

        if vscode_configs then
            for _, v in ipairs(vscode_configs) do
                if v['type'] == 'python' and v['name'] == cfg['name'] then
                    exists = true
                end
            end
        end

        if not exists then
            table.insert(dap.configurations[name], cfg)
        end
    end
end

M.vscode = function()
    local need = vim.bo.filetype == "python"
    if not need then
        return
    end

    local python_path = find_python()

    local configurations = {
        {
            -- The first three options are required by nvim-dap
            type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch',
            name = "Launch file",

            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

            program = "${file}",
            python = python_path,
            args = {},
            cwd = "${workspaceFolder}",
        },
    }

    utils.save_launch_json(configurations)
end

return M
