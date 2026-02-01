更新/Update
修复Dropdown无法获取value的问题/Fix Dropdown can't get value

使用这个Config库/Use this Config Lib First
```lua
local ConfigLibrary =loadstring(game:HttpGet("https://raw.githubusercontent.com/oicx7154/Config/refs/heads/main/Config.luau"))()
```
```lua
-- 1. 初始化
local ConfigSystem = ConfigLibrary.new("FY_Script_Config", WindUI)

-- 2. 创建 UI 并注册
local SpeedSlider = Section:Slider({
    Title = "移动速度",
    Min = 16, Max = 100, Default = 16,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})
ConfigSystem:Register("WalkSpeed", SpeedSlider) -- 注册！

-- 3. 绑定配置按钮
Section:Button({
    Title = "保存配置",
    Callback = function()
        ConfigSystem:Save("我的配置1")
    end
})

Section:Button({
    Title = "加载配置",
    Callback = function()
        ConfigSystem:Load("我的配置1")
    end
})

-- 4. 启动自动加载 (放在脚本最后)
task.spawn(function()
    task.wait(1) -- 等待UI渲染
    ConfigSystem:CheckAutoLoad()
end)
```
```lua
local ConfigSystem = ConfigLibrary.new("FY_Script_Config", WindUI)

-- 1. Create & Register
local SpeedSlider = Section:Slider({
    Title = "WalkSpeed",
    Min = 16, Max = 100, Default = 16,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})
ConfigSystem:Register("WalkSpeed_Value", SpeedSlider)

-- 2. Save Button
Section:Button({
    Title = "Save Config",
    Callback = function() ConfigSystem:Save("LegitSettings") end
})

-- 3. Auto Load Logic (At the very end of script)
task.spawn(function()
    task.wait(1) -- Wait for UI to render
    ConfigSystem:CheckAutoLoad()
end)
```

