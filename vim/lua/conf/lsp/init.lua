local lspconfig = require("lspconfig")
local navic = require("nvim-navic")
local telescope = require("telescope.builtin")

local M = {}

local function get()
    if M._keys then
        return M._keys
    end

    M._keys = {
        {
            "gd",
            function()
                if vim.bo.filetype == "cs" then
                    -- There has some problem for csharp_ls with telescope
                    vim.lsp.buf.definition()
                else
                    vim.cmd("Telescope lsp_definitions")
                end
            end,
            desc = "Goto Definition",
            has = "definition",
        },
        { "<leader>lr", "<cmd>Telescope lsp_references<cr>",       desc = "References" },
        { "<leader>gd", vim.lsp.buf.declaration,                   desc = "Goto Declaration" },
        { "gi",         "<cmd>Telescope lsp_implementations<cr>",  desc = "Goto Implementation" },
        { "gy",         "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto T[y]pe Definition" },
        { "K",          vim.lsp.buf.hover,                         desc = "Hover" },
        {
            "<c-k>",
            vim.lsp.buf.signature_help,
            mode = "i",
            desc = "Signature Help",
            has = "signatureHelp",
        },
        -- {
        --     "<leader>fs",
        --     function(...)
        --         return require("conform").format(...)
        --     end,
        --     desc = "Format Document",
        --     has = "documentFormatting",
        -- },
        { "<leader>fs", vim.lsp.buf.format, desc = "Format / Range format", mode = { "n", "v" } },
        -- {
        --     "<leader>fs",
        --     function()
        --         require("conform").format(nil, function(err)
        --             if not err then
        --                 local mode = vim.api.nvim_get_mode().mode
        --                 if vim.startswith(string.lower(mode), "v") then
        --                     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        --                 end
        --             end
        --         end)
        --     end,
        --     desc = "Format Range",
        --     mode = { "n", "v" },
        -- },
        {
            "<leader>la",
            vim.lsp.buf.code_action,
            desc = "Code Action",
            mode = { "n", "v" },
            has = "codeAction",
        },
        { "<leader>rn", vim.lsp.buf.rename, desc = "Rename",                has = "rename" },
        {
            "<leader>ls",
            telescope["lsp_document_symbols"]({
                symbols = {
                    "Class",
                    "Function",
                    "Method",
                    "Constructor",
                    "Interface",
                    "Module",
                    "Struct",
                    "Trait",
                    "Field",
                    "Property",
                },
            }),
            desc = "Goto Symbol",
        },
        {
            "<leader><leader>ls",
            telescope["lsp_dynamic_workspace_symbols"]({
                symbols = {
                    "Class",
                    "Function",
                    "Method",
                    "Constructor",
                    "Interface",
                    "Module",
                    "Struct",
                    "Trait",
                    "Field",
                    "Property",
                },
            }),
            desc = "Goto Symbol (Workspace)",
        },
        { "<leader>fd",         "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
        { "<leader><leader>fd", "<cmd>Telescope diagnostics<cr>",         desc = "Workspace diagnostics" },
    }

    return M._keys
end

---@param method string|string[]
local function has(buffer, method)
    if type(method) == "table" then
        for _, m in ipairs(method) do
            if has(buffer, m) then
                return true
            end
        end
        return false
    end

    method = method:find("/") and method or "textDocument/" .. method
    local clients = vim.lsp.get_clients({ bufnr = buffer })
    for _, client in ipairs(clients) do
        if client.name == "csharp_ls" then
            return true
        end

        if client.supports_method(method) then
            return true
        end
    end

    return false
end

M.setup = function(opts)
    opts = opts or {}
    opts.capabilities =
        vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), opts.capabilities or {})

    require("mason-lspconfig").setup_handlers({
        function(server_name)
            if server_name == "volar" then
                -- vue integrate with ts_ls, this ignore
                return
            end

            local ok, mod = pcall(function()
                return require("conf.lsp." .. server_name)
            end)

            if ok then
                mod.setup(opts)
            else
                lspconfig[server_name].setup(opts or {})
            end
        end,
    })
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        local keyHandler = require("lazy.core.handler.keys")
        local maps = get()
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

        -- for navic in lualine
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end,
})

return M
