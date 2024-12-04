local dap = require("dap")
local M = {}

M.setup = function()
    for _, name in ipairs({ "node", "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
        dap.adapters[name] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "js-debug-adapter",
                args = { "${port}" },
            },
        }
    end

    for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch",
                program = "${file}",
                cwd = "${workspaceFolder}",
            },
            {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
            },
        }
    end
end

return M
