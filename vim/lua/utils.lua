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


M.json_encode = function(data)
    if type(data) ~= "table" then
        vim.notify("Input data must be a table", vim.log.levels.ERROR)
        return
    end

    local json = vim.fn.json_encode(data)
    if not json then
        vim.notify("Failed to serialize data to JSON", vim.log.levels.ERROR)
        return
    end

    local formatted_json = vim.fn.system("echo " .. vim.fn.shellescape(json) .. " | jq .")
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to format JSON using jq", vim.log.levels.ERROR)
        return
    end

    return formatted_json
end

return M
