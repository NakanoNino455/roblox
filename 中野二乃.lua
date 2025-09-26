-- 通用汉化引擎（无循环版，合并版）
-- 用法：修改 loadstring 里的链接为目标脚本

-- 翻译表（两份合并）
local Translations = {
    -- 第一份
    ["ESP1"] = "透视",
	["ESP1 Settings"] = "透视设置",
    ["Boxes"] = "透框",
    ["Names"] = "名称",
    ["Health Bars"] = "血量",
	["Welcome to Our Script"] = "欢迎使用我们的脚本",
    ["Thank you for using our script! This tool provides various exploiting eatures to make your game experience better."] =
        "感谢使用我们的脚本！本工具提供多种外挂功能，旨在提升你的游戏体验。",
    ["Thank you for using our script! This tool provides various exploiting features to make your game experience better."] =
        "感谢使用我们的脚本！本工具提供多种外挂功能，旨在提升你的游戏体验。",
    ["Join Our Discord - Click to Copy               the invite"] = "加入我们的 Discord - 点击复制邀请",
    ["Join Our Discord - Click to Copy the invite"] = "加入我们的 Discord - 点击复制邀请",
    ["Main Options"] = "主要选项",
    ["Enable Aimbot"] = "启用自瞄",
    ["FOV Radius"] = "视野半径",
	["Tracers"] = "线条",
	["Movement"] = "移动",
	["Aimbot"] = "自瞄",
	["Camera FOV"] = "视角设置",
	["Show Health Number"] = "显示血量数字",
	["Show Distance"] = "显示距离",
	["Max Distance"] = "最大距离",
	["Team Colors"] = "队伍颜色",
    ["Smoothness"] = "平滑度",
    ["Visual Options"] = "显示选项",
    ["Show FOV Circle"] = "显示视野圈",
    ["FOV Circle Color"] = "视野圈颜色",
    ["FOV Circle Thickness"] = "视野圈粗细",

    -- 第二份
    ["Introduction"] = "介绍",
    ["SCP: Roleplay - Magnesium v1.4"] = "SCP:角色扮演中文菜单 By:中野二乃",
    ["Hitbox Expander"] = "碰撞箱扩展",
    ["Head Size"] = "头部大小",
    ["Body Size"] = "身体大小", 
    ["ChatSpy"] = "聊天监控",
    ["Ragdoll"] = "布偶化",
	["if you rejoin with this button you wont be able to execute the script, this is for rejoining and then playing without cheats"] = "如果你用这个按钮重新加入，你将无法执行脚本，这是用于重新加入，然后在没有作弊的情况下进行游戏",
	["Target Player"] = "目标玩家",
	["name"] = "名字",
	["Enable ESP"] = "打开透视",
	["Send Message"] = "发送信息",
	["Message"] = "信息",
	["Rejoin Current Server"] = "重新加入当前服务器",
    ["Anti-Aim1"] = "反自瞄1",
    ["Anti-Aim2"] = "反自瞄2",
    ["Infinite Yield"] = "无限命令集",
    ["Text Size"] = "文字大小",
    ["Box Thickness"] = "方框粗细",
    ["Tracer Thickness"] = "射线粗细",
    ["ESP Transparency"] = "透视透明度",
    ["ESP FPS"] = "透视刷新率",
    ["ESP FPS Control"] = "透视刷新率控制",
    ["Higher FPS = smoother ESP but more CPU usage"] = "更高帧率 = 更流畅的透视但更占用CPU",
    ["Lower FPS = less CPU usage but choppier ESP"] = "更低帧率 = 更少CPU占用但透视更卡顿",
    ["Default: 60 FPS (recommended)"] = "默认：60帧（推荐）",
    ["ESP Color"] = "透视颜色",
    ["Text Color"] = "文字颜色",
    ["Walkspeed"] = "移动速度",
    ["Walkspeed Speed"] = "移动速度值",
    ["Enable Noclip"] = "穿墙",
    ["Infinite Jump"] = "无限跳跃",
    ["Teleport Walking"] = "瞬移行走",
    ["Fly"] = "飞行",
    ["Explorer mode (notfe)"] = "资源管理器模式 (notfe)",
    ["Advanced Options"] = "高级选项",
    ["Prediction Factor"] = "预测系数",
    ["Team Check"] = "队伍检测",
    ["Misc"] = "杂项",
    ["Deafult is 70 btw"] = "默认是70",
    ["Fake Lag"] = "假延迟",
    ["Auto Jump"] = "自动跳跃",
    ["Anti AFK"] = "防挂机",
    ["Anti Void"] = "防掉虚空",
    ["Fake Chat"] = "假聊天",
    ["Z to send or press button below"] = "按 Z 键发送或点击下方按钮",
    ["Enabled"] = "启用",
    ["Send Notifications"] = "发送通知",
    ["Anti-Moderation & Magnesium"] = "防管理检测 & Magnesium",
    ["FPS Limit"] = "帧率限制",
    ["Full Bright"] = "全亮模式",
    ["Simplify Map"] = "简化地图",
	["Map Modification"] = "地图修改",
    ["Disable All Features"] = "禁用所有功能",
    ["Auto Leave"] = "自动离开",
    ["Notify me when moderator joins the game"] = "当管理员进入游戏时通知我",
    ["Disable everything when moderator joins the game"] = "当管理员进入时禁用所有功能",
    ["Reset character when moderator joins the game"] = "当管理员进入时重置角色",
    ["Magnesium Radio Advertiser"] = "Magnesium 电台广告",
    ["Magnesium Chat Advertiser"] = "Magnesium 聊天广告",
    ["ANTI-MOD INFORMATION"] = "防管理信息",
    ["Some features like Infinite Yield, Camera FOV, and Map Modification cannot be disabled automatically and may remain active when a moderator joins. Use them at your own risk."] =
        "某些功能如 无限命令集、视角FOV、地图修改 无法自动禁用，管理员加入时可能仍然激活，请自行承担风险。",
    ["Auto Leave is effective but risky — instantly leaving when a mod joins can look suspicious."] =
        "自动离开 有效但风险较高——管理员加入时立即离开可能显得可疑。",
    ["Recommended Setup:"] = "推荐设置：",
    ["Ground Detection Modes"] = "地面检测模式",
    ["Ground Only Detection (ON): Only checks downward for ground"] = "仅地面检测(开)：只检测向下的地面",
    ["Enhanced Ground Detection (OFF): Checks all directions for walls/objects"] = "增强地面检测(关)：检测所有方向的墙体/物体",
    ["Beta feature - if you die when flying it means either you are too fast or you started walking for some reason"] = "测试功能 - 如果你飞行时死亡，说明你速度太快或开始行走",
    ["Ignore Walkspeed Slider limit"] = "忽略移动速度滑条限制",
    ["BETA"] = "测试版",
    ["Enhanced Fly"] = "增强飞行",
    ["Fly Speed"] = "飞行速度",
    ["Fly Stabilizer"] = "飞行稳定器",
    ["Enhanced Ground Detection"] = "增强地面检测",
    ["Ground Only Detection"] = "仅地面检测",
    ["Ground Detection Distance"] = "地面检测距离"
}

-- 翻译函数
local function translateText(text)
    if not text or type(text) ~= "string" then return text end
    if Translations[text] then return Translations[text] end
    for en, cn in pairs(Translations) do
        if text:find(en, 1, true) then
            return text:gsub(en, cn)
        end
    end
    return text
end

-- 翻译 GUI 元素
local function translateGui(gui)
    if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
        pcall(function()
            local text = gui.Text
            if text and text ~= "" then
                local newText = translateText(text)
                if newText ~= text then
                    gui.Text = newText
                end
            end
        end)
    end
end

-- 翻译所有已有 GUI
local function scanAll()
    for _, gui in ipairs(game:GetDescendants()) do
        translateGui(gui)
    end
end

-- 监听新增 GUI
local function setupListener(parent)
    parent.DescendantAdded:Connect(function(d)
        task.wait(0.1)
        translateGui(d)
    end)
end

-- 启动翻译引擎
local function setupTranslator()
    scanAll()
    setupListener(game)

    local player = game:GetService("Players").LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        setupListener(player.PlayerGui)
    end
end

-- 先加载外部脚本，再启动汉化
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bodzio21/Magnesium/refs/heads/main/Loader"))()
end)

if not success then
    warn("外部脚本加载失败:", err)
else
    task.delay(2, setupTranslator) -- 延迟执行，确保外部 GUI 先加载
end
