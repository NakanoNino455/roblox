-- // 配置区域 //
local Translations = {
    -- 示例：将 "Main" 替换为 "QWER"
    ["Home"] = "主菜单",
    ["Combat"] = "自瞄与绘制",
    ["NullZen Free || Scp Roleplay || v1.0.2"] = "猫王455 Scp-Roleplay 菜单 V1.1.2 （进阶版）",
    ["Misc"] = "其他",
    ["Anti AFK"] = "挂机防踢",
    ["Full Bright"] = "夜视",
    ["Speed Boost"] = "移速修改",
    ["Show Full Chat"] = "打开原生聊天栏",
    ["Get Radio"] = "获取电台",
    ["Respawn/Reset"] = "重生/重置人物",
    ["Options"] = "选项",
    ["Noclip"] = "穿墙",
    ["Anti Void"] = "防虚空",
    ["Misc"] = "其他",
    ["ESP"] = "透视绘制",
    ["Boxes"] = "绘制",
    ["Names"] = "名称",
    ["Hitbox"] = "命中框",
    ["Head Hitbox Size"] = "头部命中大小",
    ["Body Hitbox Size"] = "身体命中大小",
    ["Aimbot"] = "自瞄",
    ["Aimbot/Silent Aim FOV Size"] = "自瞄圈大小",
    ["Show FOV"] = "自瞄圈",
    ["Server Hop"] = "切换服务器",
    ["Rejoin Current Server"] = "重进当前服务器",
    ["Send Mod Tracker Info to The Discord Server"] = "感谢支持！！",
    ["Disable This Toggle if you care about your account"] = "Scp-Roleplay (进阶版菜单) V1.1.2 版本更新内容\n1.由基础版聊天监控转换->原生聊天栏\n2.新增电台获取功能\n3.优化部分自瞄功能代码\n该版本功能更好于基础版\n感谢大家支持！！！",
}

-- // 翻译核心逻辑 //
local function translateText(text)
    if not text or type(text) ~= "string" then return text end
    
    -- 1. 优先完全匹配 (精准且快)
    if Translations[text] then
        return Translations[text]
    end
    
    -- 2. 模糊匹配/替换 (如果完全匹配失败)
    for en, cn in pairs(Translations) do
        -- 使用 plain=true 防止特殊字符报错，如果需要正则请去掉第三个参数
        if text:find(en, 1, true) then 
            local newText, count = text:gsub(en, cn)
            if count > 0 then
                return newText
            end
        end
    end
    
    return text
end

local function setupTranslationEngine()
    -- 尝试使用元表劫持 (__newindex)
    -- 这会在脚本试图修改文本时直接拦截并替换
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__newindex
        setreadonly(mt, false)
        
        mt.__newindex = newcclosure(function(t, k, v)
            if checkcaller() then -- 防止某些内部报错，通常加上checkcaller更稳
                if (t:IsA("TextLabel") or t:IsA("TextButton") or t:IsA("TextBox")) and k == "Text" then
                    v = translateText(tostring(v))
                end
            end
            return oldIndex(t, k, v)
        end)
        
        setreadonly(mt, true)
        print("文字转换引擎: 元表劫持成功")
    end)
    
    -- 如果元表劫持失败 (某些执行器不支持)，则启动后备方案：循环扫描
    if not success then
        warn("元表劫持失败，切换到循环扫描模式:", err)
       
        local translated = {}
        
        -- 处理单个GUI对象的函数
        local function processGui(gui)
            if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) then
                -- 监听文本变化
                if not translated[gui] then
                    translated[gui] = true
                    -- 初始翻译
                    if gui.Text and gui.Text ~= "" then
                        local newText = translateText(gui.Text)
                        if newText ~= gui.Text then gui.Text = newText end
                    end
                    
                    -- 持续监听
                    gui:GetPropertyChangedSignal("Text"):Connect(function()
                        local currentText = gui.Text
                        local newText = translateText(currentText)
                        if newText ~= currentText then
                            gui.Text = newText
                        end
                    end)
                end
            end
        end
        
        -- 监听新UI添加
        local function setupListener(parent)
            parent.DescendantAdded:Connect(function(descendant)
                task.wait() -- 稍作等待确保属性加载
                processGui(descendant)
            end)
            
            -- 处理现有的UI
            for _, v in ipairs(parent:GetDescendants()) do
                processGui(v)
            end
        end
        
        pcall(function() setupListener(game:GetService("CoreGui")) end)
        
        local Players = game:GetService("Players")
        if Players.LocalPlayer then
            if Players.LocalPlayer:FindFirstChild("PlayerGui") then
                setupListener(Players.LocalPlayer.PlayerGui)
            end
            -- 监听 PlayerGui 何时被添加（例如刚重生）
            Players.LocalPlayer.ChildAdded:Connect(function(child)
                if child.Name == "PlayerGui" then
                    setupListener(child)
                end
            end)
        end
    end
end

-- // 1. 启动翻译引擎 //
setupTranslationEngine()

-- 等待一小会儿确保钩子生效
task.wait(0.5) 

-- // 2. 加载目标脚本 //
print("正在加载脚本...")
local scriptSuccess, scriptErr = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NakanoNino455/roblox/refs/heads/main/111.lua"))()
end)

if scriptSuccess then
    print("脚本加载成功！")
else
    warn("脚本加载失败:", scriptErr)
end
