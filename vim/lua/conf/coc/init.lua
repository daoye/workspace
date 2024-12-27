local npairs = require('nvim-autopairs')

local M = {}

function _G.check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

function _G.coc_has_provider(method)
    if method then
        return vim.fn.CocHasProvider(method)
    end
    return true
end

function _G.coc_completion_confirm()
    if vim.fn["coc#pum#visible"]() ~= 0 then
        return vim.fn["coc#pum#confirm"]()
    elseif npairs then
        return npairs.autopairs_cr()
    end
end

local cocAction = vim.fn['CocAction']

-- Use K to show documentation in preview window
local function show_docs()
    local cw = vim.fn.expand("<cword>")
    if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
    elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
    else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
    end
end


local function close_float()
    if vim.api.nvim_eval("coc#float#has_float()") then
        vim.api.nvim_eval("coc#float#close_all()")
    else
        vim.api.nvim_eval("<esc>")
    end
end

local function openLink()
    local res = cocAction("openLink")
    if res then
        return
    end

    local line = vim.fn.getline(".")
    local url = line:match("https?://[^%s%)]+")

    if url then
        vim.fn.system("open " .. url)
    else
        local email = line:match("[A-Za-z0-9_%.%-]+@[A-Za-z0-9_%.%-]+%.[a-z]+")
        if email then
            vim.fn.system("open mailto:" .. email)
        else
            vim.fn.system("open " .. vim.fn.expand("%:p:h"))
        end
    end
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("Error: Could not open link")
    end
end



local keyset = vim.keymap.set

---@param method string|string[]
local function has(buffer, method)
    return true
end

local function augroup(name)
    return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

local function lsp_maps(bufnr)
    local maps = {
        { "gd",                 "<cmd>Telescope coc definitions<cr>",           desc = "Goto Definition",       silent = true,       has = "definition" },
        { "<leader>lr",         "<cmd>Telescope coc references<cr>",            desc = "References" },
        { "<leader>gd",         "<cmd>Telescope coc declarations<cr>",          desc = "Goto Declaration" },
        { "<leader>gd",         "<Plug>(coc-definition)<cr>",                   desc = "Goto Declaration", },
        { "gi",                 "<cmd>Telescope coc implementations<cr>",       desc = "Goto Implementation" },
        { "gy",                 "<cmd>Telescope coc type_definitions<cr>",      desc = "Goto T[y]pe Definition" },
        { "K",                  show_docs,                                      desc = "Hover" },
        { "<esc>",              close_float,                                    desc = "Close popup" },
        { "<leader>fs",         "<Plug>(coc-format)<cr>",                       desc = "Format",                mode = { "n", "x" }, },
        { "<leader>fs",         "<Plug>(coc-format-selected)<cr>",              desc = "ange format",           mode = { "v" }, },
        { "<leader>la",         "<cmd>Telescope coc line_code_actions<cr>",     desc = "Code Action",           mode = { "n", "v" }, silent = true,                    has = "codeAction", },
        { "<leader><leader>la", "<cmd>Telescope coc file_code_actions<cr>",     desc = "Code Action",           mode = { "n", "v" }, silent = true,                    has = "codeAction", },
        { "<leader>ls",         "<cmd>Telescope coc document_symbols<cr>",      mode = { "n", "v" },            silent = true,       desc = "Goto Symbol", },
        { "<leader><leader>ls", "<cmd>Telescope coc workspace_symbols<cr>",     mode = { "n", "v" },            silent = true,       desc = "Goto Symbol (Workspace)", },

        { "<leader>fd",         "<cmd>Telescope coc diagnostics<cr>",           desc = "Document diagnostics" },
        { "<leader><leader>fd", "<cmd>Telescope coc workspace_diagnostics<cr>", desc = "Workspace diagnostics" },

        {
            "<C-u>",
            'coc#float#has_float() ? coc#float#scroll(0) : "<C-u>"',
            silent = true,
            expr = true,
            mode = { "n", "i", "o" },
            desc = "Scroll forward"
        },
        {
            "<C-d>",
            'coc#float#has_float() ? coc#float#scroll(1) : "<C-d>"',
            silent = true,
            expr = true,
            mode = { "n", "i", "o" },
            desc = "Scroll backward"
        },
        { "<leader>o",  openLink,                 silent = true, mode = { "n", },     desc = "Open link under cursor" },

        {
            "<leader>cf",
            "CocAction('fold')",
            -- silent = true,
            expr = true,
            mode = { "n" },
            desc = "Create fold"
        },

        { "<leader>rn", "<Plug>(coc-rename)",     silent = true, desc = "Rename",     has = "rename" },
        { "if",         "<Plug>(coc-funcobj-i)",  silent = true, mode = { "x", "o" }, has = "documentSymbol" },
        { "af",         "<Plug>(coc-funcobj-a)",  silent = true, mode = { "x", "o" }, has = "documentSymbol" },
        { "ic",         "<Plug>(coc-classobj-i)", silent = true, mode = { "x", "o" }, has = "documentSymbol" },
        { "ac",         "<Plug>(coc-classobj-a)", silent = true, mode = { "x", "o" }, has = "documentSymbol" },
    }


    local keyHandler = require("lazy.core.handler.keys")
    local keymaps = keyHandler.resolve(maps)

    for _, keys in pairs(keymaps) do
        local has = not keys.has or has(bufnr, keys.has)
        local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

        if has and cond then
            local opts = keyHandler.opts(keys)
            opts.cond = nil
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.buffer = bufnr

            vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
        end
    end
end

local function super_tab()
    local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

    keyset(
        "i",
        "<TAB>",
        'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
        opts
    )
    keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

    -- Make <CR> to accept selected completion item or notify coc.nvim to format
    -- <C-g>u breaks current undo, please make your own choice
    -- keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
    keyset('i', '<cr>', 'v:lua.coc_completion_confirm()', opts)
    -- Use <c-j> to trigger snippets
    -- keyset("i", "<c-j>", '<Plug>(coc-snippets-expand-jump)', {silent = true, expr=true})
    -- vim.keymap.set("i", "<c-j>", [[<Plug>(coc-snippets-expand-jump)]], opts)
    -- Use <c-space> to trigger completion
    -- keyset("i", "<BS>", "coc#refresh()", { silent = true, expr = true })
end

M.setup = function(opts)
    opts = opts or {}
    vim.g.coc_global_extensions = {
        "coc-highlight",
        "coc-sumneko-lua",
        "coc-snippets",
        "coc-json",
        "coc-tsserver",
        "coc-css",
        "coc-html",
        "coc-html-css-support",
        "coc-flutter",
        "coc-prettier",
        "coc-sh",
        "coc-lists",
        "coc-clangd",
        "@yaegassy/coc-tailwindcss3",
        "@yaegassy/coc-volar",
        "@yaegassy/coc-pylsp"
    }

    vim.api.nvim_create_autocmd("User", {
        pattern = "CocNvimInit",
        group = augroup("cocnviminit"),
        callback = function()
            -- local bufnr = vim.api.nvim_get_current_buf()

            vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })

            lsp_maps(nil)

            vim.api.nvim_create_autocmd("User", {
                pattern = "CocStatusChange",
                group = augroup("cocstatuschange"),
                callback = function()
                    if package.loaded['lualine'] then
                        require('lualine').refresh({ place = { 'statusline' } })
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufReadPost", {
                group = augroup("autofold"),
                callback = function()
                    -- if cocAction('hasProvider', 'foldingRange') then
                    --     cocAction('fold')
                    --     vim.api.nvim_eval("<zR>")
                    -- end
                end,
            })
        end,
    })

    super_tab()
end

return M
