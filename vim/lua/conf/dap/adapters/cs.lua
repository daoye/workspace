local dap = require('dap')
local uv = vim.uv;

local put = function(text)
    if not text then
        return
    end

    vim.schedule(function()
        dap.repl.append(text)
    end)
end

local function find_project_root()
    local root_patterns = { '.sln', '.git' }
    local root = vim.fs.find(root_patterns, { upward = true })[1]
    if root then
        return vim.fs.dirname(root)
    else
        return uv.cwd() -- Default to current working directory if no project root is found
    end
end

local function find_csproj_files(root)
    return vim.fs.find(function(name, _)
        return name:match('.*%.csproj$')
    end, { limit = math.huge, type = 'file', path = root })
end

-- find framework version
local function get_target_framework(csproj)
    local file = io.open(csproj, 'r')
    if not file then return nil end
    local content = file:read('*a')
    file:close()

    return content:match('<TargetFramework>(.-)</TargetFramework>')
end

-- find entry dll
local function find_dll_path(csproj)
    local target_framework = get_target_framework(csproj) or 'net8.0'

    local csproj_dir = vim.fs.dirname(csproj)
    local dll_name = vim.fs.basename(csproj):match("(.+)%..+") .. '.dll'

    return uv.fs_realpath(csproj_dir) .. '/bin/Debug/' .. target_framework .. '/' .. dll_name
end

-- async run system command and redirect stdout into dap repl
local function system_output_to_repl(cmd, args, callback)
    local handle
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)

    handle = uv.spawn(cmd, {
        args = args,
        stdio = { nil, stdout, stderr },
    }, function(code, signal)
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        handle:close()

        if callback then
            vim.schedule(function()
                callback(code, signal)
            end)
        end
    end)

    uv.read_start(stdout, function(err, data)
        put(err)
        put(data)
    end)

    uv.read_start(stderr, function(err, data)
        put(err)
        put(data)
    end)
end

-- build project before start debug
local function build_project(csproj, callback)
    local build_cmd = 'dotnet'
    local build_args = { 'build', csproj or '' }
    put('Running: ' .. build_cmd .. ' ' .. table.concat(build_args, ' ') .. '\n')
    system_output_to_repl(build_cmd, build_args, function(code, signal)
        if code == 0 then
            callback(true)
        else
            put('Build failed with code ' .. code .. ' and signal ' .. signal .. '\n')
            callback(false)
        end
    end)
end

local entry_dll = nil

local function start_debugging()
    dap.run(dap.configurations.cs[1])
end

local function setup_debugging()
    dap.terminate(nil, nil, function()
        dap.repl.open({ height = 10 }, "belowright split")
        dap.repl.clear()

        local co = coroutine.wrap(function()
            local root = find_project_root()
            local csproj_files = find_csproj_files(root)

            if #csproj_files == 0 then
                put("No .csproj files found in the project.\n")
            elseif #csproj_files == 1 then
                dap.configurations.cs[1].cwd = vim.fs.dirname(csproj_files[1])
                build_project(csproj_files[1], function(success)
                    if success then
                        entry_dll = find_dll_path(csproj_files[1])
                        start_debugging()
                    end
                end)
            else
                local proj = require("dap.utils").pick_file({
                    executables = false,
                    filter = function(filepath)
                        return filepath and vim.endswith(filepath, ".csproj")
                    end,
                })
                if proj then
                    dap.configurations.cs[1].cwd = vim.fs.dirname(proj)
                    build_project(proj, function(success)
                        if success then
                            entry_dll = find_dll_path(proj)
                            start_debugging()
                        end
                    end)
                end
            end
        end)

        co()
    end)
end

local M = {}

M.setup = function()
    vim.api.nvim_create_augroup('CsDebugMappings', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = 'CsDebugMappings',
        pattern = { 'cs', 'cshtml', 'csproj' },
        callback = function()
            vim.keymap.set('n', '<F5>',
                function()
                    if dap.session() then
                        dap.continue()
                    else
                        setup_debugging()
                    end
                end,
                { noremap = true, silent = true, buffer = true, desc = 'Launch(DAP)' })

            vim.keymap.set('n', '<C-F5>', function()
                dap.terminate(nil, nil, function() dap.run(dap.configurations.cs[2]) end)
            end, { noremap = true, silent = true, buffer = true, desc = 'Attach to process(DAP)' })
        end,
    })

    dap.adapters.coreclr = {
        type = 'executable',
        command = 'netcoredbg',
        args = { '--interpreter=vscode' },
    }

    dap.configurations.cs = {
        {
            type = "coreclr",
            name = "Launch",
            request = "launch",
            cwd = "${workspaceFolder}",
            env = {
                ASPNETCORE_ENVIRONMENT = "Development"
            },
            program = function()
                return entry_dll or vim.ui.input({ promot = "Input entry dll full path" })
            end,
        },
        {
            type = "coreclr",
            request = "attach",
            name = "Attach",
            cwd = "${workspaceFolder}",
            env = {
                ASPNETCORE_ENVIRONMENT = "Development"
            },
            processId = function()
                return require('dap.utils').pick_process({
                    filter = function(proc)
                        local pname = vim.fs.basename(vim.fn.getcwd())
                        return string.find(proc.name, pname) and string.find(proc.name, "net")
                    end
                })
            end,
        }
    }
end

return M
