local utils = require("utils")

local M = {}


M.get_vscode_cfg_path = function()
    return vim.fn.getcwd() .. "/.vscode/launch.json"
end

M.save_launch_json = function(configurations)
    local launch_json_path = vim.fn.getcwd() .. "/.vscode/launch.json"

    -- make directory
    local vscode_dir = vim.fn.getcwd() .. "/.vscode"
    if vim.fn.isdirectory(vscode_dir) == 0 then
        vim.fn.mkdir(vscode_dir, "p")
    end

    -- load launch.json
    local existing_config = {}
    local file = io.open(launch_json_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and #content > 0 then
            local parsed_config, _, err = vim.fn.json_decode(content)
            if parsed_config then
                existing_config = parsed_config
            elseif err then
                print("Error decoding existing launch.json: " .. err)
                return
            end
        end
    end


    if not existing_config.version then
        existing_config.version = "0.2.0"
    end

    local function configuration_exists(config)
        for _, existing in ipairs(existing_config.configurations) do
            -- if existing.name == config.name then
            if existing.type == config.type and existing.name == config.name then
                return true
            end
        end
        return false
    end

    local function input_exists(config)
        for _, existing in ipairs(existing_config.inputs) do
            if existing.id == config.id then
                return true
            end
        end
        return false
    end


    local changed = false

    -- merge configurations
    existing_config.configurations = existing_config.configurations or {}
    local new_configurations = configurations or {}
    for _, new_config in ipairs(new_configurations) do
        if not configuration_exists(new_config) then
            table.insert(existing_config.configurations, new_config)
            changed = true
        end
    end


    local inputs = {
        {
            id = "inputProgram",
            type = "pickString",
            description = "Launch Program: ",
            default = "foobar"
        }
    }
    existing_config.inputs = existing_config.inputs or {}
    for _, new_config in ipairs(inputs) do
        if not input_exists(new_config) then
            table.insert(existing_config.inputs, new_config)
            changed = true
        end
    end


    if not changed then
        return
    end


    -- save to launch.json
    local updated_content = utils.json_encode(existing_config)
    local write_file = io.open(launch_json_path, "w")
    if write_file and updated_content then
        write_file:write(updated_content)
        write_file:close()
        print("launch.json updated at " .. launch_json_path)
    else
        print("Failed to write launch.json to " .. launch_json_path)
    end
end


return M
