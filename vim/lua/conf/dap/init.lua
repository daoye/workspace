local utils = require("utils")

local M = {}


M.setup = function()
    local dap = require("dap")

    dap.set_log_level("TRACE")

    dap.listeners.after.event_initialized["aprilzz"] = function(session)
        dap.repl.open({ height = 10 }, "belowright split")
    end


    dap.listeners.on_config["aprilzz"] = function(config)
        local cfg = vim.fn.deepcopy(config)

        local task = cfg["preLaunchTask"]
        if task then
            utils.run_command(string.gsub(task, '${workspaceFolder}', vim.fn.getcwd()))
        end
        return config
    end

    -- dap signs
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    local kind = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = " ",
        -- Breakpoint = "󰠭 ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
    }

    for name, sign in pairs(kind) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
            "Dap" .. name,
            { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
    end

    -- adapters
    require("conf.dap.adapters.js").setup()
    require("conf.dap.adapters.cs").setup()
    require("conf.dap.adapters.cpp").setup()
    require("conf.dap.adapters.python").setup()

    -- load .vscode/launch.json to override default configurations
    require("conf.dap.adapters.vscode").setup()
end

return M
