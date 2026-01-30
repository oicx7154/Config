s = setmetatable({},{__index=function(t,k)local v=cloneref(game:GetService(k))rawset(t,k,v)return v end,__call=function(_,k)return k and s[k]or game end})

local ConfigLibrary = {}
ConfigLibrary.__index = ConfigLibrary

local HttpService = s.HttpService

function ConfigLibrary.new(folderName, uiLibrary,SystemFileName)
    local self = setmetatable({}, ConfigLibrary)
    
    self.RootFolder = folderName or "MyScriptConfig"
    self.SystemFile = SystemFileName or "SystemData.json"
    self.Registry = {}
    self.UI = uiLibrary
    
    if not isfolder(self.RootFolder) then
        makefolder(self.RootFolder)
    end
    
    return self
end

function ConfigLibrary:Register(name, element)
    if not name or not element then return end
    self.Registry[name] = element
end

function ConfigLibrary:GetFiles()
    local files = {}
    if not isfolder(self.RootFolder) then makefolder(self.RootFolder) end
    
    local list = listfiles(self.RootFolder)
    for _, filepath in ipairs(list) do
        if filepath:sub(-5) == ".json" and not filepath:find(self.SystemFile) then
            local filename = filepath
            local parts = filepath:split("/")
            filename = parts[#parts]
            if filename == filepath then parts = filepath:split("\\") filename = parts[#parts] end
            
            filename = filename:sub(1, -6)
            table.insert(files, filename)
        end
    end
    return files
end

function ConfigLibrary:Save(configName)
    if not configName or configName == "" then 
        self.UI:Notify({Title="错误/Error", Content="请输入配置名称/Please enter a Config name ", Duration=2})
        return false
    end

    local count = 0
    for _ in pairs(self.Registry) do count = count + 1 end
    if count == 0 then
        self.UI:Notify({Title="警告/Warn", Content="没有注册任何功能/No features registered ", Duration=2})
        return false
    end

    local data = {}
    for name, element in pairs(self.Registry) do
        local val = nil
        if element.Value ~= nil then val = element.Value 
        elseif element.State ~= nil then val = element.State end
        
        if val ~= nil then data[name] = val end
    end
    
    local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not success then return false end

    local filePath = self.RootFolder .. "/" .. configName .. ".json"
    writefile(filePath, encoded)
    self.UI:Notify({Title="配置/Config", Content="保存成功!/Saved Successfully !", Duration=2})
    return true
end

function ConfigLibrary:Load(configName)
    if not configName or configName == "" then return end
    local filePath = self.RootFolder .. "/" .. configName .. ".json"
    if not isfile(filePath) then 
        self.UI:Notify({Title="错误/Error", Content="找不到文件/Cannot find the file ", Duration=2})
        return 
    end
    
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
    if not success or not decoded then return end

    for name, value in pairs(decoded) do
        local element = self.Registry[name]
        if element then
            task.spawn(function()
                if element.Set then pcall(function() element:Set(value) end)
                elseif element.SetValue then pcall(function() element:SetValue(value) end)
                end
            end)
        end
    end
    self.UI:Notify({Title="配置/Config", Content="已加载/loaded: " .. configName, Duration=2})
end

function ConfigLibrary:Delete(configName)
    local filePath = self.RootFolder .. "/" .. configName .. ".json"
    if isfile(filePath) then
        delfile(filePath)
        self.UI:Notify({Title="配置/Config", Content="已删除/Deleted", Duration=2})
        return true
    end
    return false
end

function ConfigLibrary:SetAutoLoad(configName, isEnabled)
    local data = { TargetConfig = configName, AutoLoad = isEnabled }
    writefile(self.RootFolder .. "/" .. self.SystemFile, HttpService:JSONEncode(data))
end

function ConfigLibrary:CheckAutoLoad()
    local sysPath = self.RootFolder .. "/" .. self.SystemFile
    if not isfile(sysPath) then return nil end
    
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(sysPath)) end)
    if success and data and data.AutoLoad and data.TargetConfig then
        self.UI:Notify({Title="自动加载/AutoLoad", Content="恢复配置/recovery config: "..data.TargetConfig, Duration=3})
        self:Load(data.TargetConfig)
        return data.TargetConfig
    end
    return nil
end
-- ==========================================================
