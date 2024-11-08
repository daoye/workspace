local M = {}

M.opts = {
    -- border = "rounded",
    border = { "+", "-", "+", "|", "+", "-", "+", "|" },
    width_ratio = 0.8,
    height_ratio = 0.5,
    empty_message = "No messages found.",
    show_timestamp = true,
    intercept_levels = {
        ERROR = true,
        WARN = true,
        INFO = false
    },
    colors = {
        ERROR = "ErrorMsg",
        WARN = "WarningMsg",
        INFO = "MoreMsg"
    },
    icons = {
        ERROR = "E ",
        WARN = "W ",
        INFO = "I "
    }
}

function M.setup(user_config)
    M.opts = vim.tbl_extend("force", M.opts, user_config or {})
end

local messages = { ERROR = {}, WARN = {}, INFO = {} }

local clear = function()
    messages = { ERROR = {}, WARN = {}, INFO = {} }
end



-- local original_notify = vim.notify
-- vim.notify = function(msg, level, opts)
--     print(1111)
--     local level_str = vim.log.levels[level] == vim.log.levels.ERROR and "ERROR" or
--         vim.log.levels[level] == vim.log.levels.WARN and "WARN" or "INFO"

--     local timestamp = os.date("%Y-%m-%d %H:%M:%S")
--     table.insert(messages[level_str], { msg = msg, time = timestamp })

--     if package.loaded['lualine'] then
--         require('lualine').refresh({ place = { 'statusline' } })
--     end

--     if not M.opts.intercept_levels[level_str] then
--         original_notify(msg, level, opts)
--     end
-- end

function M.get_status_summary()
    local status = ""
    for level, msgs in pairs(messages) do
        local count = #msgs
        if count > 0 then
            status = status .. (M.opts.icons[level] or "") .. count .. " "
        end
    end
    return status
end

function M.open_message_float()
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.ceil(vim.o.columns * M.opts.width_ratio)
    local height = math.ceil(vim.o.lines * M.opts.height_ratio)
    local separator = string.rep("-", width)

    local lines = {}
    if not (next(messages.ERROR) or next(messages.WARN) or next(messages.INFO)) then
        for _ = 1, math.floor((height - 1) / 2) do
            table.insert(lines, "")
        end
        table.insert(lines, string.rep(" ", math.floor((width - #M.opts.empty_message) / 2)) .. M.opts.empty_message)
    else
        for level, msgs in pairs(messages) do
            if M.opts.intercept_levels[level] then
                for _, msg_info in ipairs(msgs) do
                    if M.opts.show_timestamp then
                        table.insert(lines, string.format("Time: %s", msg_info.time))
                    end

                    local message_lines = vim.split(msg_info.msg, "\n", true)
                    for _, line in ipairs(message_lines) do
                        table.insert(lines, string.format("[%s] %s", level, line))
                    end
                    table.insert(lines, separator)
                end
            end
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        border = M.opts.border,
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    for i, line in ipairs(lines) do
        if line:find("%[ERROR%]") then
            vim.api.nvim_buf_add_highlight(buf, -1, M.opts.colors.ERROR, i - 1, 0, -1)
        elseif line:find("%[WARN%]") then
            vim.api.nvim_buf_add_highlight(buf, -1, M.opts.colors.WARN, i - 1, 0, -1)
        elseif line:find("%[INFO%]") then
            vim.api.nvim_buf_add_highlight(buf, -1, M.opts.colors.INFO, i - 1, 0, -1)
        end
    end

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", ":close<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buf, "n", "cc", clear, { noremap = true, silent = true })
end

return M
