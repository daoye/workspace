local M = {}

M.setup = function()
    local dir = vim.fn.getcwd() .. ".vscode/launch.json"
    require('dap.ext.vscode').load_launchjs(dir, { cppdbg = { 'c', 'cpp', 'rust' } })
end


return M
