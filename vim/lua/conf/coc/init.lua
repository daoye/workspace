local navic = require("nvim-navic")
local utils = require("utils")

local M = {}

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

function _G.check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

local keyset = vim.keymap.set
local keymap = vim.api.nvim_set_keymap

---@param method string|string[]
local function has(buffer, method)
    return true
end

local function lsp_maps()
    local maps = {
        { "gd",         "<cmd>Telescope coc definitions<cr>",  desc = "Goto Definition", has = "definition" },
        { "<leader>lr", "<cmd>Telescope coc references<cr>",   desc = "References" },
        { "<leader>gd", "<cmd>Telescope coc declarations<cr>", desc = "Goto Declaration" },
        {
            "<leader>gd",
            "<Plug>(coc-definition)<cr>",
            silent = true,
            desc = "Goto Declaration",
        },
        { "gi", "<cmd>Telescope coc implementations<cr>",  desc = "Goto Implementation" },
        { "gy", "<cmd>Telescope coc type_definitions<cr>", desc = "Goto T[y]pe Definition" },
        { "K",  show_docs,                                 silent = true,                  desc = "Hover" },
        {
            "<c-k>",
            "<Plug>CocActionAsync('showSignatureHelp')<cr>",
            mode = "i",
            desc = "Signature Help",
            has = "signatureHelp",
        },
        {
            "<leader>fs",
            "<Plug>(coc-format-selected)<cr>",
            desc = "Format / Range format",
            mode = { "n", "v" },
        },
        {
            "la",
            "<cmd>Telescope coc line_code_actions<cr>",
            desc = "Code Action",
            mode = { "n", "v" },
            has = "codeAction",
        },
        {
            "<leader>la",
            "<cmd>Telescope coc file_code_actions<cr>",
            desc = "Code Action",
            mode = { "n", "v" },
            has = "codeAction",
        },
        { "<leader>rn", "<Plug>(coc-rename)", desc = "Rename", has = "rename" },
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

local function complition_maps()
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
    keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

    -- Use <c-j> to trigger snippets
    keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
    -- Use <c-space> to trigger completion
    -- keyset("i", "<BS>", "coc#refresh()", { silent = true, expr = true })

    -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
    keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
    keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
    keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
    keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
    keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
    keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
    keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
    keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)

    -- Remap <C-f> and <C-b> to scroll float windows/popups
    ---@diagnostic disable-next-line: redefined-local
    local opts = { silent = true, nowait = true, expr = true }
    keyset("n", "<C-u>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-u>"', opts)
    keyset("n", "<C-d>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-d>"', opts)
    keyset("i", "<C-u>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
    keyset("i", "<C-d>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
    keyset("v", "<C-u>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-u>"', opts)
    keyset("v", "<C-d>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-d>"', opts)
end

local function autocmd()
    -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
    vim.api.nvim_create_augroup("CocGroup", {})
    vim.api.nvim_create_autocmd("CursorHold", {
        group = "CocGroup",
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor on CursorHold",
    })

    -- Setup formatexpr specified filetype(s)
    -- vim.api.nvim_create_autocmd("FileType", {
    --     group = "CocGroup",
    --     pattern = "typescript,reacttypescript,json",
    --     command = "setl formatexpr=CocAction('formatSelected')",
    --     desc = "Setup formatexpr specified filetype(s).",
    -- })

    -- Update signature help on jump placeholder
    vim.api.nvim_create_autocmd("User", {
        group = "CocGroup",
        pattern = "CocJumpPlaceholder",
        command = "call CocActionAsync('showSignatureHelp')",
        desc = "Update signature help on jump placeholder",
    })
end

M.setup = function(opts)
    opts = opts or {}
    vim.g.coc_global_extensions = {
        "coc-json",
        "coc-tsserver",
    }

    autocmd()

    lsp_maps()

    complition_maps()
end

return M
