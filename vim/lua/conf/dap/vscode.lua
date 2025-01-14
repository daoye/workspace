local M = {}

M.load_config = function()
    local dir = vim.fn.getcwd() .. ".vscode/launch.json"
    require('dap.ext.vscode').load_launchjs(dir,
        {
            cppdbg = { 'c', 'cpp', 'rust' },
            python = { 'python' },
            coreclr = { 'cs', 'cshtml' },
            ['pwa-node'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
            ['node'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
            ['pwa-chrome'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
            ['pwa-msedge'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
            ['node-terminal'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
            ['pwa-extensionHost'] = {
                'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'
            },
        })
end


return M
