local cmp = require("blink.cmp")

local M = {}

M.processing = false
M.spinner_index = 1

local spinner_symbols = {
    "⠋",
    "⠙",
    "⠹",
    "⠸",
    "⠼",
    "⠴",
    "⠦",
    "⠧",
    "⠇",
    "⠏",
}

local function augroup(name)
    return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end


local map_blink = function(buf)
    vim.keymap.set('i', '<TAB>', function()
        return cmp.select_next()
    end, { noremap = true, silent = true, buffer = buf })

    vim.keymap.set('i', '<S-TAB>', function()
        return cmp.select_prev()
    end, { noremap = true, silent = true, buffer = buf })

    vim.keymap.set('i', '<CR>', function()
        if cmp.is_menu_visible() then
            cmp.select_and_accept()
            return nil
        end

        return "<cr>"
    end, { noremap = true, silent = true, expr = true, buffer = buf })
end

-- need use blink.cmp in AI chat
vim.api.nvim_create_autocmd({ "BufNew", "BufEnter", "BufAdd", "BufCreate" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if vim.tbl_contains({ "codecompanion" }, vim.bo.filetype) then
            vim.cmd("CocDisable")

            map_blink(event.buf)
        else
            vim.cmd("CocEnable")
        end
    end,
})


vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = augroup("CodeCompanionHooks"),
    callback = function(request)
        if request.match == "CodeCompanionRequestStarted" then
            M.processing = true
        elseif request.match == "CodeCompanionRequestFinished" then
            M.processing = false
        end

        if package.loaded['lualine'] then
            require('lualine').refresh({ place = { 'statusline' } })
        end
    end,
})

M.get_status = function()
    if M.processing then
        M.spinner_index = (M.spinner_index % #spinner_symbols) + 1
        return "🤔 " .. spinner_symbols[M.spinner_index]
    else
        return ''
    end
end

M.setup = function(opts)
    require("codecompanion").setup(vim.tbl_deep_extend("force", opts or {}, {
        strategies = {
            chat = {
                adapter = "copilot",
            },
            inline = {
                adapter = "copilot",
            },
        },
        display = {
            action_palette = {
                provider = "telescope",                 -- default|telescope|mini_pick
                opts = {
                    show_default_actions = true,        -- Show the default actions in the action palette?
                    show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                },
            },
        },
    }))
end

return M
