local M = {}

M.map = function(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    -- do not create the keymap if a lazy keys handler exists
    if not keys.active[keys.parse({ lhs, mode = mode }).id] then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end


M.run_command = function(cmd)
    local done = false
    local co, is_main = coroutine.running()

    vim.fn.jobstart(cmd, {
        cwd = vim.fn.getcwd(),
        stdout_buffered = false,
        stderr_buffered = false,
        on_stdout = function(_, data, _)
            for _, line in ipairs(data) do
                if line ~= "" then
                    vim.api.nvim_echo({ { "[INFO]: " .. line, "None" } }, false, {})
                end
            end
        end,
        on_stderr = function(_, data, _)
            for _, line in ipairs(data) do
                if line ~= "" then
                    vim.api.nvim_echo({ { "[ERROR]: " .. line, "WarningMsg" } }, false, {})
                end
            end
        end,
        on_exit = function(_, code, _)
            -- vim.api.nvim_echo({ { "Command exited with code: " .. code, "None" } }, false, {})
            done = true
            coroutine.resume(co)
        end,
    })

    while not done do
        coroutine.yield()
    end
end

return M
