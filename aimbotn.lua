local Rayfield = loadstring            if type(k) == "string" and k:match("^OishiConfig_") then
                table.insert(list, k:gsub("^OishiConfig_", ""))
            end
        end
    end
    table.sort(list)
    return list
end

local function saveConfig(name)
    if not name or name == "" then name = "Default" end
    local config = {}
    for flag, data in pairs(flagRegistry) do
        config[flag] = data.currentValue
    end
    local json = HttpService:JSONEncode(config)
    
    if isfolder and makefolder and isfile and writefile then
        if not isfolder(configFolder) then makefolder(configFolder) end
        local filePath = configFolder .. "/" .. name .. ".json"
        writefile(filePath, json)
        if isfolder("OishiHub") then
            writefile(lastConfigFile, name)
        end
        print("[Config] Saved: " .. name)
        return true
    else
        _G["OishiConfig_" .. name] = json
        _G["OishiHub_lastConfig"] = name
        print("[Config] Saved to _G: " .. name)
        return true
    end
end

local function loadConfig(name)
    if not name or name == "" then return false end
    local json = nil
    
    if isfile and readfile then
        local filePath = configFolder .. "/" .. name .. ".json"
        if isfile(filePath) then
            json = readfile(filePath)
            print("[Config] Loaded: " .. name)
        end
    else
        if _G["OishiConfig_" .. name] then
            json = _G["OishiConfig_" .. name]
            print("[Config] Loaded from _G: " .. name)
        end
    end
    
    if not json then
        print("[Config] Config not found: " .. name)
        return false
