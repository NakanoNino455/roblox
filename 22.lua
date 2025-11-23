local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SCP-Roleplay by Cat King v1.4 (Mobile Support)",
   LoadingTitle = "Cat King",
   LoadingSubtitle = "by Cat King",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Example Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Key | Youtube Hub",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "YoutubeHubKey1",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/AtgzSPWK"}
   }
})

local MainTab = Window:CreateTab("Main", nil)
local MainSection = MainTab:CreateSection("Main")

-- 优化内存管理
local connections = setmetatable({}, {__mode = "k"})
local highlights = setmetatable({}, {__mode = "k"})
local espLabels = setmetatable({}, {__mode = "k"})

-- 【修复】添加全局变量保存墙壁检测状态
_G.WallCheckSetting = _G.WallCheckSetting ~= nil and _G.WallCheckSetting or true

-- 优化的全员透视（增强版）
local Toggle = MainTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       task.spawn(function()
           if Value then
               local Players = game:GetService("Players")
               local RunService = game:GetService("RunService")
               
               local TEAM_COLORS = {
                   ["Class-D"] = Color3.fromRGB(255, 165, 0),
                   ["Scientific Department"] = Color3.fromRGB(0, 0, 255),
                   ["Security Department"] = Color3.fromRGB(255, 255, 255),
                   ["Mobile Task Force"] = Color3.fromRGB(0, 0, 139),
                   ["Intelligence Agency"] = Color3.fromRGB(255, 0, 0),
                   ["Rapid Response Team"] = Color3.fromRGB(255, 50, 50),
                   ["Chaos Insurgency"] = Color3.fromRGB(0, 0, 0),
                   ["Medical Department"] = Color3.fromRGB(0, 191, 255),
                   ["Administrative Department"] = Color3.fromRGB(0, 255, 0),
                   ["Default"] = Color3.fromRGB(200, 200, 200),
               }
               
               local function getPlayerColor(player)
                   if player and player.Team then
                       return TEAM_COLORS[player.Team.Name] or 
                              (player.Team.TeamColor and player.Team.TeamColor.Color) or 
                              TEAM_COLORS["Default"]
                   end
                   return TEAM_COLORS["Default"]
               end
               
               local function cleanupESP(character)
                   if not character then return end
                   
                   local highlight = highlights[character]
                   if highlight then
                       highlight:Destroy()
                       highlights[character] = nil
                   end
                   
                   local label = espLabels[character]
                   if label then
                       label:Destroy()
                       espLabels[character] = nil
                   end
                   
                   local esp = character:FindFirstChild("PlayerESP")
                   if esp then esp:Destroy() end
                   
                   local nameEsp = character:FindFirstChild("NameESP")
                   if nameEsp then nameEsp:Destroy() end
               end
               
               local function createESP(character, player)
                   if not character or not character.Parent then return end
                   
                   -- 先清理旧的ESP
                   cleanupESP(character)
                   
                   task.wait(0.1)
                   
                   local head = character:WaitForChild("Head", 5)
                   if not head then return end
                   
                   -- 创建高亮
                   local highlight = Instance.new("Highlight")
                   highlight.Name = "PlayerESP"
                   highlight.FillColor = getPlayerColor(player)
                   highlight.OutlineColor = Color3.new(1, 1, 1)
                   highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                   highlight.FillTransparency = 0.6
                   highlight.OutlineTransparency = 0.2
                   highlight.Parent = character
                   
                   highlights[character] = highlight
                   
                   -- 创建名称标签
                   local billboard = Instance.new("BillboardGui")
                   billboard.Name = "NameESP"
                   billboard.AlwaysOnTop = true
                   billboard.Size = UDim2.new(0, 100, 0, 20)
                   billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                   billboard.MaxDistance = 2000
                   billboard.Adornee = head
                   
                   local label = Instance.new("TextLabel")
                   label.Size = UDim2.new(1, 0, 1, 0)
                   label.BackgroundTransparency = 1
                   label.Text = player.Name
                   label.TextColor3 = getPlayerColor(player)
                   label.TextScaled = true
                   label.Font = Enum.Font.SourceSans
                   label.TextStrokeTransparency = 0.5
                   label.TextStrokeColor3 = Color3.new(0, 0, 0)
                   label.Parent = billboard
                   
                   billboard.Parent = character
                   espLabels[character] = billboard
               end
               
               local function onPlayerAdded(player)
                   if player == Players.LocalPlayer then return end
                   
                   -- 监听角色添加
                   local charAddedConn = player.CharacterAdded:Connect(function(character)
                       task.wait(0.5)
                       createESP(character, player)
                   end)
                   
                   -- 监听角色移除
                   local charRemovingConn = player.CharacterRemoving:Connect(function(character)
                       cleanupESP(character)
                   end)
                   
                   -- 监听团队变化
                   local teamChangedConn = player:GetPropertyChangedSignal("Team"):Connect(function()
                       if player.Character then
                           task.wait(0.1)
                           createESP(player.Character, player)
                       end
                   end)
                   
                   connections[player] = {
                       charAdded = charAddedConn,
                       charRemoving = charRemovingConn,
                       teamChanged = teamChangedConn
                   }
                   
                   -- 如果玩家已有角色，立即创建ESP
                   if player.Character then
                       task.spawn(function()
                           createESP(player.Character, player)
                       end)
                   end
               end
               
               -- 监听玩家移除
               local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
                   if connections[player] then
                       for _, conn in pairs(connections[player]) do
                           conn:Disconnect()
                       end
                       connections[player] = nil
                   end
                   
                   if player.Character then
                       cleanupESP(player.Character)
                   end
               end)
               
               connections.playerRemoving = playerRemovingConn
               
               -- 为所有现有玩家创建ESP
               for _, player in ipairs(Players:GetPlayers()) do
                   onPlayerAdded(player)
               end
               
               -- 监听新玩家加入
               connections.playerAdded = Players.PlayerAdded:Connect(onPlayerAdded)
               
               print("全员透视已启用（增强版）！")
               
           else
               -- 清理所有连接和ESP
               for _, connData in pairs(connections) do
                   if type(connData) == "table" then
                       for _, conn in pairs(connData) do
                           if typeof(conn) == "RBXScriptConnection" then
                               conn:Disconnect()
                           end
                       end
                   elseif typeof(connData) == "RBXScriptConnection" then
                       connData:Disconnect()
                   end
               end
               
               -- 清理所有高亮和标签
               for character, highlight in pairs(highlights) do
                   if highlight and highlight.Parent then
                       highlight:Destroy()
                   end
               end
               
               for character, label in pairs(espLabels) do
                   if label and label.Parent then
                       label:Destroy()
                   end
               end
               
               local Players = game:GetService("Players")
               for _, player in ipairs(Players:GetPlayers()) do
                   if player.Character then
                       cleanupESP(player.Character)
                   end
               end
               
               table.clear(connections)
               table.clear(highlights)
               table.clear(espLabels)
               
               print("全员透视已禁用！")
           end
       end)
   end,
})

-- 优化的地图全亮
local Toggle = MainTab:CreateToggle({
   Name = "Full Bright",
   CurrentValue = false,
   Flag = "MapBrightnessAdjustable",
   Callback = function(Value)
       local Lighting = game:GetService("Lighting")
       
       if Value then
           _G.OriginalLighting = {
               Ambient = Lighting.Ambient,
               Brightness = Lighting.Brightness,
               GlobalShadows = Lighting.GlobalShadows,
               OutdoorAmbient = Lighting.OutdoorAmbient,
               ClockTime = Lighting.ClockTime,
               FogEnd = Lighting.FogEnd
           }
           
           Lighting.Ambient = Color3.new(0.7, 0.7, 0.7)
           Lighting.Brightness = 1.5
           Lighting.GlobalShadows = false
           Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
           Lighting.ClockTime = 12
           Lighting.FogEnd = 100000
       else
           if _G.OriginalLighting then
               for prop, value in pairs(_G.OriginalLighting) do
                   Lighting[prop] = value
               end
               _G.OriginalLighting = nil
           end
       end
   end,
})

-- 优化的穿墙模式
local Toggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")
       local LocalPlayer = Players.LocalPlayer
       
       if Value then
           _G.NoclipConnection = RunService.Stepped:Connect(function()
               if LocalPlayer.Character then
                   for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.CanCollide = false
                       end
                   end
               end
           end)
       else
           if _G.NoclipConnection then
               _G.NoclipConnection:Disconnect()
               _G.NoclipConnection = nil
               
               if LocalPlayer.Character then
                   for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                           part.CanCollide = true
                       end
                   end
               end
           end
       end
   end,
})

-- 【优化的无限跳跃 - 持续按空格持续跳】
local Toggle = MainTab:CreateToggle({
   Name = " Air Fly（Hold Space)",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
       local UserInputService = game:GetService("UserInputService")
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")
       
       if Value then
           -- 使用更高效的连接方式
           _G.InfiniteJump = RunService.Heartbeat:Connect(function()
               local character = Players.LocalPlayer.Character
               if character then
                   local humanoid = character:FindFirstChildOfClass("Humanoid")
                   if humanoid then
                       -- 检测空格键是否被按住
                       if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                           humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                       end
                   end
               end
           end)
           print("无限跳跃已启用 - 按住空格键持续跳跃")
       else
           if _G.InfiniteJump then
               _G.InfiniteJump:Disconnect()
               _G.InfiniteJump = nil
           end
           print("无限跳跃已禁用")
       end
   end,
})

-- ========== Radio复制功能部分 ==========
-- 复制Radio按钮（无提示版本）
local RadioButton = MainTab:CreateButton({
    Name = "Get Radio",
    Callback = function()
        -- 获取服务
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        
        -- 获取所有玩家列表
        local allPlayers = Players:GetPlayers()
        
        -- 检查是否有其他玩家
        if #allPlayers <= 1 then
            return
        end
        
        -- 创建其他玩家列表（排除自己）
        local otherPlayers = {}
        for _, player in ipairs(allPlayers) do
            if player ~= localPlayer then
                table.insert(otherPlayers, player)
            end
        end
        
        -- 检查是否有其他玩家
        if #otherPlayers == 0 then
            return
        end
        
        -- 随机选择一个玩家
        local randomPlayer = otherPlayers[math.random(1, #otherPlayers)]
        
        -- 检查随机玩家是否有背包和Radio
        if randomPlayer.Character and randomPlayer:FindFirstChild("Backpack") then
            local radio = randomPlayer.Backpack:FindFirstChild("Radio")
            
            if radio then
                -- 确保当前玩家有背包
                if localPlayer.Character and localPlayer:FindFirstChild("Backpack") then
                    -- 检查当前玩家是否已经有Radio
                    if not localPlayer.Backpack:FindFirstChild("Radio") then
                        -- 复制Radio
                        local radioCopy = radio:Clone()
                        radioCopy.Parent = localPlayer.Backpack
                    end
                end
            end
        end
    end,
})
-- ========== Radio功能结束 ==========

-- 攻击类Tab - 即时锁头系统
local CombatTab = Window:CreateTab("Aimbot", nil)
local CombatSection = CombatTab:CreateSection("Instant lock")

-- 锁定模式
local LockModeDropdown = CombatTab:CreateDropdown({
   Name = "lock mode",
   Options = {"Instant lock", "Smooth lock", "Forecast Lock"},
   CurrentOption = "Instant lock",
   Flag = "LockMode",
   Callback = function(Option)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.LockMode = Option
       end
   end,
})

-- Mobile 模式开关 (新添加)
local MobileModeToggle = CombatTab:CreateToggle({
   Name = "Mobile Mode (Aim on Fire)",
   CurrentValue = false,
   Flag = "MobileMode",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.MobileMode = Value
       else
           -- 如果Aimbot还没开启，先保存设置
           _G.MobileModeSetting = Value
       end
   end,
})

-- FOV圆圈滑块
local FOVSlider = CombatTab:CreateSlider({
   Name = "FOV",
   Range = {50, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 400,
   Flag = "fovsize",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.FOV = Value
           if _G.HeadLock.FOVCircle then
               _G.HeadLock.FOVCircle.Radius = Value
           end
       end
   end,
})

-- 平滑度滑块（仅平滑模式使用）
local SmoothSlider = CombatTab:CreateSlider({
   Name = "Smoothness",
   Range = {1, 20},
   Increment = 1,
   Suffix = "",
   CurrentValue = 3,
   Flag = "smooth",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.Smoothness = Value
       end
   end,
})

-- 锁定距离滑块
local DistanceSlider = CombatTab:CreateSlider({
   Name = "Distance",
   Range = {50, 3000},
   Increment = 50,
   Suffix = "m",
   CurrentValue = 1000,
   Flag = "lockdistance",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.MaxDistance = Value
       end
   end,
})

-- 预测强度滑块
local PredictionSlider = CombatTab:CreateSlider({
   Name = "Prediction strength",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = 0.2,
   Flag = "prediction",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.PredictionStrength = Value
       end
   end,
})

-- 显示FOV圆圈
local ShowFOVToggle = CombatTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOV",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.FOVCircle then
           _G.HeadLock.FOVCircle.Visible = Value
       end
   end,
})

-- 显示准星
local ShowCrosshairToggle = CombatTab:CreateToggle({
   Name = "Show crosshair",
   CurrentValue = false,
   Flag = "ShowCrosshair",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.ShowCrosshair = Value
           if _G.HeadLock.Crosshair then
               for _, line in pairs(_G.HeadLock.Crosshair) do
                   line.Visible = Value
               end
           end
       end
   end,
})

-- 【修复】墙壁检测 - 使用全局变量保存状态
local WallCheckToggle = CombatTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = _G.WallCheckSetting,
   Flag = "WallCheck",
   Callback = function(Value)
       _G.WallCheckSetting = Value  -- 保存到全局变量
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.WallCheck = Value
       end
   end,
})

-- 持续锁定开关
local StickyLockToggle = CombatTab:CreateToggle({
   Name = "Sticky Lock",
   CurrentValue = false,
   Flag = "StickyLock",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.StickyLock = Value
       end
   end,
})

-- 队伍检测开关
local TeamCheckToggle = CombatTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.TeamCheck = Value
       end
   end,
})

-- 枪械列表
local weaponsList = {
    -- 步枪类
    "M4", "M16A4", "SMG25", "BP-556", "M416", "SW-762", "KV-12", "AUG A3", 
    "ACR", "BR-762", "ARX-200", "AK-47", "AKS-74U", "Laser Rifle", "M110",
    "SMG46", "SMG416", "P DW-28", "Honey Badger",
    -- 冲锋枪类
    "UMP-45", "MP5", "Kriss Vector", "EVO 3 Micro", "SMG9X", "P90", "MP7",
    -- PDW类
    "AAC Honey Badger", "APC556 PDW",
    -- 霰弹枪类
    "Spas - 12", "AA-12", "Burning Fang",
    -- 重型武器
    "XM250", "Minigun",
    -- 手枪类
    "M9", "Pistol", "Golden Hawk", "Laser Pistol"
}

-- 创建持枪检测开关
local WeaponCheckToggle = CombatTab:CreateToggle({
    Name = "Gun Check",
    CurrentValue = false,
    Flag = "WeaponCheck",
    Callback = function(Value)
        _G.WeaponCheckEnabled = Value
        
        if Value then
            print("持枪检测已启用！")
            print("只有手持指定枪械时才能触发锁头")
        else
            print("持枪检测已禁用！")
        end
    end,
})

-- 添加武器状态显示标签
local WeaponStatusLabel = CombatTab:CreateLabel("Weapon status: Not detected")

-- 创建状态更新循环
task.spawn(function()
    while task.wait(0.1) do
        if _G.WeaponCheckEnabled then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local isWeapon = false
                    for _, weaponName in ipairs(weaponsList) do
                        if tool.Name == weaponName or string.find(tool.Name, weaponName) then
                            isWeapon = true
                            WeaponStatusLabel:Set("Weapon status: 🔫 " .. tool.Name .. " [Support]")
                            break
                        end
                    end
                    
                    if not isWeapon then
                        WeaponStatusLabel:Set("Weapon status: ❌ " .. tool.Name .. " [No Support]")
                    end
                else
                    WeaponStatusLabel:Set("Weapon status: ✋ Empty handed [No Support]")
                end
            else
                WeaponStatusLabel:Set("Weapon status: Not detected")
            end
        else
            WeaponStatusLabel:Set("Weapon status: Off")
        end
    end
end)


-- 即时锁头主开关
local HeadLockToggle = CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "HeadLock",
   Callback = function(Value)
       if Value then
           local Players = game:GetService("Players")
           local RunService = game:GetService("RunService")
           local UserInputService = game:GetService("UserInputService")
           local Camera = workspace.CurrentCamera
           local LocalPlayer = Players.LocalPlayer
           
           -- 创建FOV圆圈
           local FOVCircle = Drawing.new("Circle")
           FOVCircle.Visible = true
           FOVCircle.Thickness = 2
           FOVCircle.Color = Color3.fromRGB(255, 255, 255)
           FOVCircle.Transparency = 0.7
           FOVCircle.Radius = 400
           FOVCircle.NumSides = 64
           FOVCircle.Filled = false
           
           -- 创建准星
           local Crosshair = {
               Horizontal = Drawing.new("Line"),
               Vertical = Drawing.new("Line")
           }
           
           -- 设置准星属性
           for _, line in pairs(Crosshair) do
               line.Visible = true
               line.Color = Color3.fromRGB(255, 0, 0)
               line.Thickness = 2
               line.Transparency = 0.8
           end
           
           _G.HeadLock = {
               FOVCircle = FOVCircle,
               Crosshair = Crosshair,
               Settings = {
                   FOV = 400,
                   MaxDistance = 1000,
                   PredictionStrength = 0.2,
                   Smoothness = 3,
                   WallCheck = _G.WallCheckSetting,  -- 【修复】使用保存的全局变量值
                   ShowCrosshair = true,
                   StickyLock = true,
                   TeamCheck = true,
                   LockMode = "Instant lock",
                   MobileMode = _G.MobileModeSetting or false -- 初始化Mobile Mode
               },
               LockedTarget = nil,
               OriginalCFrame = nil
           }
           
           -- 检测是否持有武器的函数
           local function hasWeapon()
               if not _G.WeaponCheckEnabled then return true end
               if not LocalPlayer.Character then return false end
               
               local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
               if not tool then return false end
               
               local toolName = tool.Name
               for _, weaponName in ipairs(weaponsList) do
                   if toolName == weaponName or string.find(toolName, weaponName) then
                       return true
                   end
               end
               
               return false
           end
           
           -- 完善的团队检测系统
           local function isEnemy(player)
               -- 如果关闭了队伍检测，所有人都是敌人
               if not _G.HeadLock.Settings.TeamCheck then
                   return true
               end
               
               -- 如果没有队伍信息，视为敌人
               if not LocalPlayer.Team or not player.Team then
                   return true
               end
               
               local myTeam = LocalPlayer.Team.Name
               local theirTeam = player.Team.Name
               
               -- 同一队伍的是队友，不锁定
               if myTeam == theirTeam then
                   return false
               end
               
               -- Class-D 和 Chaos Insurgency 互为盟友（反派阵营）
               local isMyTeamVillain = (myTeam == "Class-D" or myTeam == "Chaos Insurgency")
               local isTheirTeamVillain = (theirTeam == "Class-D" or theirTeam == "Chaos Insurgency")
               
               -- 如果双方都是反派阵营，不互相锁定
               if isMyTeamVillain and isTheirTeamVillain then
                   return false
               end
               
               -- 如果一方是反派，另一方不是，则互为敌人
               if isMyTeamVillain ~= isTheirTeamVillain then
                   return true
               end
               
               -- 正派阵营之间的特殊规则
               local heroTeams = {
                   "Scientific Department",
                   "Security Department", 
                   "Mobile Task Force",
                   "Intelligence Agency",
                   "Rapid Response Team",
                   "Medical Department",
                   "Administrative Department"
               }
               
               local isMyTeamHero = false
               local isTheirTeamHero = false
               
               for _, team in ipairs(heroTeams) do
                   if myTeam == team then isMyTeamHero = true end
                   if theirTeam == team then isTheirTeamHero = true end
               end
               
               -- 如果双方都是正派阵营，不互相锁定
               if isMyTeamHero and isTheirTeamHero then
                   return false
               end
               
               -- 其他情况视为敌人
               return true
           end
           
           -- 【优化的墙壁检测函数】
           local function checkVisible(part)
               -- 如果关闭了墙壁检测，则所有目标都可见
               if not _G.HeadLock.Settings.WallCheck then
                   return true
               end
               
               -- 开启墙壁检测，检查是否有墙壁阻挡
               local origin = Camera.CFrame.Position
               local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
               
               local params = RaycastParams.new()
               params.FilterType = Enum.RaycastFilterType.Blacklist
               params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
               
               local result = workspace:Raycast(origin, direction, params)
               -- 如果没有碰撞结果，说明视线无阻挡
               return result == nil
           end
           
           -- 获取最佳目标
           local function getBestTarget()
               local bestTarget = nil
               local bestScore = math.huge
               local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
               
               for _, player in ipairs(Players:GetPlayers()) do
                   -- 跳过自己和友军
                   if player ~= LocalPlayer and player.Character and isEnemy(player) then
                       local character = player.Character
                       local humanoid = character:FindFirstChildOfClass("Humanoid")
                       local head = character:FindFirstChild("Head")
                       local rootPart = character:FindFirstChild("HumanoidRootPart")
                       
                       if head and humanoid and humanoid.Health > 0 and rootPart then
                           local myRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                           
                           if myRootPart then
                               local distance3D = (rootPart.Position - myRootPart.Position).Magnitude
                               
                               if distance3D <= _G.HeadLock.Settings.MaxDistance then
                                   local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                                   
                                   if onScreen and checkVisible(head) then
                                       local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                       
                                       if distance2D <= _G.HeadLock.Settings.FOV then
                                           -- 综合评分：屏幕距离 + 3D距离权重
                                           local score = distance2D + (distance3D * 0.05)
                                           
                                           if score < bestScore then
                                               bestScore = score
                                               bestTarget = {
                                                   Head = head,
                                                   Player = player,
                                                   Character = character
                                               }
                                           end
                                       end
                                   end
                               end
                           end
                       end
                   end
               end
               
               return bestTarget
           end
           
           -- 获取预测位置
           local function getPredictedPosition(head, character)
               if _G.HeadLock.Settings.LockMode ~= "Forecast Lock" then
                   return head.Position
               end
               
               local rootPart = character:FindFirstChild("HumanoidRootPart")
               if not rootPart then return head.Position end
               
               local velocity = rootPart.AssemblyLinearVelocity
               if velocity.Magnitude > 0 then
                   local distance = (head.Position - Camera.CFrame.Position).Magnitude
                   local timeToHit = distance / 1000
                   return head.Position + (velocity * timeToHit * _G.HeadLock.Settings.PredictionStrength)
               end
               
               return head.Position
           end
           
           -- 锁定到头部
           local function lockToHead(targetData)
               if not targetData then return end
               
               local head = targetData.Head
               local character = targetData.Character
               
               -- 获取目标位置
               local targetPos = getPredictedPosition(head, character)
               
               -- 根据模式应用锁定
               if _G.HeadLock.Settings.LockMode == "Instant lock" then
                   -- 即时锁定 - 直接设置相机朝向
                   Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
               elseif _G.HeadLock.Settings.LockMode == "Smooth lock" then
                   -- 平滑锁定 - 使用插值
                   local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                   Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / _G.HeadLock.Settings.Smoothness)
               else -- 预测锁定
                   -- 预测锁定已经在getPredictedPosition中处理
                   Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
               end
           end
           
           -- 主循环
           _G.HeadLock.RenderConnection = RunService.RenderStepped:Connect(function()
               -- 更新FOV圆圈和准星
               local screenSize = Camera.ViewportSize
               local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
               
               FOVCircle.Position = centerPos
               
               -- 检查是否持有武器
               local weaponEquipped = hasWeapon()
               
               -- 根据武器状态改变颜色
               if not weaponEquipped and _G.WeaponCheckEnabled then
                   FOVCircle.Color = Color3.fromRGB(255, 100, 100) -- 红色表示未持枪
                   for _, line in pairs(Crosshair) do
                       line.Color = Color3.fromRGB(128, 128, 128) -- 灰色表示未持枪
                   end
               else
                   FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- 白色表示可用
               end
               
               -- 更新准星
               if _G.HeadLock.Settings.ShowCrosshair then
                   Crosshair.Horizontal.From = Vector2.new(centerPos.X - 10, centerPos.Y)
                   Crosshair.Horizontal.To = Vector2.new(centerPos.X + 10, centerPos.Y)
                   Crosshair.Vertical.From = Vector2.new(centerPos.X, centerPos.Y - 10)
                   Crosshair.Vertical.To = Vector2.new(centerPos.X, centerPos.Y + 10)
               end
               
               -- ================== Mobile 模式输入检测修改 ==================
               local isAiming = false
               if _G.HeadLock.Settings.MobileMode then
                   -- Mobile模式：检测左键（开火键）
                   isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
               else
                   -- PC默认模式：检测右键（瞄准键）
                   isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
               end
               
               -- 检测输入状态（需要持有武器或未启用武器检测）
               if isAiming and weaponEquipped then
                   -- 持续锁定逻辑
                   if _G.HeadLock.Settings.StickyLock and _G.HeadLock.LockedTarget then
                       local target = _G.HeadLock.LockedTarget
                       local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                       
                       -- 验证目标是否有效（包括重新检查是否为敌人）
                       if target.Head and target.Head.Parent and humanoid and humanoid.Health > 0 and isEnemy(target.Player) then
                           lockToHead(target)
                       else
                           -- 目标无效或变成友军，寻找新目标
                           _G.HeadLock.LockedTarget = getBestTarget()
                           if _G.HeadLock.LockedTarget then
                               lockToHead(_G.HeadLock.LockedTarget)
                           end
                       end
                   else
                       -- 实时寻找最佳目标
                       local target = getBestTarget()
                       if target then
                           _G.HeadLock.LockedTarget = target
                           lockToHead(target)
                       end
                   end
                   
                   -- 改变准星颜色表示锁定状态（只有持枪时才变色）
                   if weaponEquipped and _G.HeadLock.LockedTarget then
                       for _, line in pairs(Crosshair) do
                           line.Color = Color3.fromRGB(0, 255, 0) -- 绿色表示锁定
                       end
                   elseif weaponEquipped then
                       for _, line in pairs(Crosshair) do
                           line.Color = Color3.fromRGB(255, 0, 0) -- 红色表示未锁定
                       end
                   end
               else
                   -- 松开按键，清除锁定
                   _G.HeadLock.LockedTarget = nil
                   
                   -- 恢复准星颜色
                   if weaponEquipped then
                       for _, line in pairs(Crosshair) do
                           line.Color = Color3.fromRGB(255, 0, 0)
                       end
                   end
               end
           end)
           
           print("即时锁头已启用！")
           print("当前模式: " .. (_G.HeadLock.Settings.MobileMode and "Mobile (Aim on Fire)" or "PC (Right Click)"))
           print("团队检测: " .. (_G.HeadLock.Settings.TeamCheck and "开启" or "关闭"))
           
       else
           if _G.HeadLock then
               if _G.HeadLock.FOVCircle then
                   _G.HeadLock.FOVCircle:Remove()
               end
               if _G.HeadLock.Crosshair then
                   for _, line in pairs(_G.HeadLock.Crosshair) do
                       line:Remove()
                   end
               end
               if _G.HeadLock.RenderConnection then
                   _G.HeadLock.RenderConnection:Disconnect()
               end
               _G.HeadLock = nil
           end
           print("即时锁头已禁用！")
       end
   end,
})

-- SCP Tab
local SCPTab = Window:CreateTab("SCP", nil)
local SCPSection = SCPTab:CreateSection("SCP ESP")

local scpList = {
    "SCP-023", "SCP-049", "SCP-066", "SCP-079", "SCP-087",
    "SCP-093", "SCP-1025", "SCP-1299", "SCP-131", "SCP-173",
    "SCP-2950", "SCP-316", "SCP-999"
}

_G.SCPHighlights = _G.SCPHighlights or {}

local function toggleSCPHighlight(scpName, enable)
    local scpsFolder = workspace:FindFirstChild("SCPs")
    if not scpsFolder then return end
    
    local scpModel = scpsFolder:FindFirstChild(scpName)
    if not scpModel then return end
    
    local highlight = scpModel:FindFirstChildOfClass("Highlight")
    
    if enable then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.Parent = scpModel
        end
    else
        if highlight then
            highlight:Destroy()
        end
    end
    
    _G.SCPHighlights[scpName] = enable
end

for _, scpName in ipairs(scpList) do
    SCPTab:CreateToggle({
        Name = scpName .. " ESP",
        CurrentValue = false,
        Flag = "SCP_" .. scpName:gsub("-", "_"),
        Callback = function(Value)
            toggleSCPHighlight(scpName, Value)
        end,
    })
end

SCPTab:CreateButton({
    Name = "Enable all",
    Callback = function()
        for _, scpName in ipairs(scpList) do
            toggleSCPHighlight(scpName, true)
        end
    end,
})

SCPTab:CreateButton({
    Name = "Disable all",
    Callback = function()
        for _, scpName in ipairs(scpList) do
            toggleSCPHighlight(scpName, false)
        end
    end,
})

-- 杂项Tab
local MiscTab = Window:CreateTab("Other", nil)
local MiscSection = MiscTab:CreateSection("Practical functions")

-- 聊天监控开关
local ChatMonitorToggle = MiscTab:CreateToggle({
    Name = "Chat Monitor",
    CurrentValue = false,
    Flag = "ChatMonitor",
    Callback = function(Value)
        if Value then
            -- 聊天监控代码
            local Players = game:GetService("Players")
            local CoreGui = game:GetService("CoreGui")
            local LocalPlayer = Players.LocalPlayer
            local Teams = game:GetService("Teams")
            
            -- 检查是否已存在，避免重复创建
            if CoreGui:FindFirstChild("ChatMonitorGui") then
                CoreGui:FindFirstChild("ChatMonitorGui"):Destroy()
            end
            
            -- 创建主GUI (使用CoreGui避免被检测)
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ChatMonitorGui"
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.Parent = CoreGui
            
            -- 保存到全局变量以便关闭
            _G.ChatMonitorGui = screenGui
            
            -- 创建主框架
            local mainFrame = Instance.new("Frame")
            mainFrame.Name = "MainFrame"
            mainFrame.Size = UDim2.new(0, 450, 0, 500)
            mainFrame.Position = UDim2.new(1, -470, 0.5, -250)
            mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            mainFrame.BorderSizePixel = 0
            mainFrame.Active = true
            mainFrame.Draggable = true
            mainFrame.Parent = screenGui
            
            -- 创建标题栏
            local titleBar = Instance.new("Frame")
            titleBar.Name = "TitleBar"
            titleBar.Size = UDim2.new(1, 0, 0, 30)
            titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            titleBar.BorderSizePixel = 0
            titleBar.Parent = mainFrame
            
            -- 标题文本
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -60, 1, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = "Chating"
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextScaled = true
            titleLabel.Font = Enum.Font.SourceSansBold
            titleLabel.Parent = titleBar
            
            -- 最小化按钮
            local minimizeButton = Instance.new("TextButton")
            minimizeButton.Name = "MinimizeButton"
            minimizeButton.Size = UDim2.new(0, 30, 0, 30)
            minimizeButton.Position = UDim2.new(1, -60, 0, 0)
            minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
            minimizeButton.Text = "_"
            minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            minimizeButton.TextScaled = true
            minimizeButton.Font = Enum.Font.SourceSansBold
            minimizeButton.Parent = titleBar
            
            -- 关闭按钮
            local closeButton = Instance.new("TextButton")
            closeButton.Name = "CloseButton"
            closeButton.Size = UDim2.new(0, 30, 0, 30)
            closeButton.Position = UDim2.new(1, -30, 0, 0)
            closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            closeButton.Text = "X"
            closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeButton.TextScaled = true
            closeButton.Font = Enum.Font.SourceSansBold
            closeButton.Parent = titleBar
            
            -- 创建滚动框架
            local scrollingFrame = Instance.new("ScrollingFrame")
            scrollingFrame.Name = "ChatLogFrame"
            scrollingFrame.Size = UDim2.new(1, -10, 1, -70)
            scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
            scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            scrollingFrame.BorderSizePixel = 0
            scrollingFrame.ScrollBarThickness = 8
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
            scrollingFrame.Parent = mainFrame
            
            -- 创建UIListLayout用于自动排列
            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 5)
            listLayout.Parent = scrollingFrame
            
            -- 添加圆角
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 10)
            uiCorner.Parent = mainFrame
            
            -- 控制面板
            local controlPanel = Instance.new("Frame")
            controlPanel.Name = "ControlPanel"
            controlPanel.Size = UDim2.new(1, -10, 0, 30)
            controlPanel.Position = UDim2.new(0, 5, 1, -35)
            controlPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            controlPanel.BorderSizePixel = 0
            controlPanel.Parent = mainFrame
            
            local controlCorner = Instance.new("UICorner")
            controlCorner.CornerRadius = UDim.new(0, 5)
            controlCorner.Parent = controlPanel
            
            -- 清空按钮
            local clearButton = Instance.new("TextButton")
            clearButton.Name = "ClearButton"
            clearButton.Size = UDim2.new(0, 80, 0, 25)
            clearButton.Position = UDim2.new(0, 5, 0, 2.5)
            clearButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            clearButton.Text = "Clear"
            clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            clearButton.TextScaled = true
            clearButton.Font = Enum.Font.SourceSans
            clearButton.Parent = controlPanel
            
            local clearCorner = Instance.new("UICorner")
            clearCorner.CornerRadius = UDim.new(0, 5)
            clearCorner.Parent = clearButton
            
            -- 复制最后消息按钮
            local copyButton = Instance.new("TextButton")
            copyButton.Name = "CopyButton"
            copyButton.Size = UDim2.new(0, 80, 0, 25)
            copyButton.Position = UDim2.new(0, 90, 0, 2.5)
            copyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            copyButton.Text = "Copy"
            copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyButton.TextScaled = true
            copyButton.Font = Enum.Font.SourceSans
            copyButton.Parent = controlPanel
            
            local copyCorner = Instance.new("UICorner")
            copyCorner.CornerRadius = UDim.new(0, 5)
            copyCorner.Parent = copyButton
            
            -- 自动滚动切换
            local autoScrollButton = Instance.new("TextButton")
            autoScrollButton.Name = "AutoScrollButton"
            autoScrollButton.Size = UDim2.new(0, 80, 0, 25)
            autoScrollButton.Position = UDim2.new(0, 175, 0, 2.5)
            autoScrollButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            autoScrollButton.Text = "Auto scrolling: On"
            autoScrollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            autoScrollButton.TextScaled = true
            autoScrollButton.Font = Enum.Font.SourceSans
            autoScrollButton.Parent = controlPanel
            
            local autoScrollCorner = Instance.new("UICorner")
            autoScrollCorner.CornerRadius = UDim.new(0, 5)
            autoScrollCorner.Parent = autoScrollButton
            
            -- 消息计数标签
            local countLabel = Instance.new("TextLabel")
            countLabel.Size = UDim2.new(0, 100, 1, 0)
            countLabel.Position = UDim2.new(1, -105, 0, 0)
            countLabel.BackgroundTransparency = 1
            countLabel.Text = "Message: 0"
            countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            countLabel.TextXAlignment = Enum.TextXAlignment.Right
            countLabel.Font = Enum.Font.SourceSans
            countLabel.TextSize = 14
            countLabel.Parent = controlPanel
            
            -- 变量
            local messageCount = 0
            local lastMessage = ""
            local connections = {}
            local autoScroll = true
            
            -- 保存连接到全局变量以便关闭
            _G.ChatMonitorConnections = connections
            
            -- 获取队伍信息函数
            local function getTeamInfo(player)
                local teamName = "无队伍"
                local teamColor = Color3.fromRGB(150, 150, 150)
                
                if player.Team then
                    teamName = player.Team.Name
                    teamColor = player.Team.TeamColor.Color
                end
                
                return teamName, teamColor
            end
            
            -- 创建聊天消息函数
            local function createChatMessage(playerName, message, player)
                local messageFrame = Instance.new("Frame")
                messageFrame.Name = "MessageFrame"
                messageFrame.Size = UDim2.new(1, -10, 0, 70)
                messageFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                messageFrame.BorderSizePixel = 0
                
                -- 添加悬停效果
                messageFrame.MouseEnter:Connect(function()
                    messageFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end)
                
                messageFrame.MouseLeave:Connect(function()
                    messageFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                -- 添加圆角
                local msgCorner = Instance.new("UICorner")
                msgCorner.CornerRadius = UDim.new(0, 8)
                msgCorner.Parent = messageFrame
                
                -- 获取队伍信息
                local teamName, teamColor = "System", Color3.fromRGB(255, 200, 0)
                if player and player:IsA("Player") then
                    teamName, teamColor = getTeamInfo(player)
                end
                
                -- 队伍标签
                local teamLabel = Instance.new("TextLabel")
                teamLabel.Size = UDim2.new(0, 100, 0, 18)
                teamLabel.Position = UDim2.new(0, 5, 0, 3)
                teamLabel.BackgroundColor3 = teamColor
                teamLabel.BackgroundTransparency = 0.3
                teamLabel.Text = " " .. teamName .. " "
                teamLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                teamLabel.TextXAlignment = Enum.TextXAlignment.Center
                teamLabel.Font = Enum.Font.SourceSans
                teamLabel.TextSize = 11
                teamLabel.Parent = messageFrame
                
                local teamCorner = Instance.new("UICorner")
                teamCorner.CornerRadius = UDim.new(0, 4)
                teamCorner.Parent = teamLabel
                
                -- 玩家名称标签
                local playerLabel = Instance.new("TextLabel")
                playerLabel.Size = UDim2.new(1, -120, 0, 20)
                playerLabel.Position = UDim2.new(0, 110, 0, 2)
                playerLabel.BackgroundTransparency = 1
                playerLabel.Text = "👤 " .. playerName
                playerLabel.TextColor3 = teamColor
                playerLabel.TextXAlignment = Enum.TextXAlignment.Left
                playerLabel.Font = Enum.Font.SourceSansBold
                playerLabel.TextSize = 14
                playerLabel.Parent = messageFrame
                
                -- 消息内容标签
                local messageLabel = Instance.new("TextLabel")
                messageLabel.Size = UDim2.new(1, -10, 0, 35)
                messageLabel.Position = UDim2.new(0, 5, 0, 25)
                messageLabel.BackgroundTransparency = 1
                messageLabel.Text = "💬 " .. message
                messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                messageLabel.TextXAlignment = Enum.TextXAlignment.Left
                messageLabel.TextWrapped = true
                messageLabel.Font = Enum.Font.SourceSans
                messageLabel.TextSize = 13
                messageLabel.Parent = messageFrame
                
                -- 时间戳
                local timeLabel = Instance.new("TextLabel")
                timeLabel.Size = UDim2.new(0, 60, 0, 15)
                timeLabel.Position = UDim2.new(1, -65, 0, 5)
                timeLabel.BackgroundTransparency = 1
                timeLabel.Text = os.date("%H:%M:%S")
                timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                timeLabel.TextXAlignment = Enum.TextXAlignment.Right
                timeLabel.Font = Enum.Font.SourceSans
                timeLabel.TextSize = 10
                timeLabel.Parent = messageFrame
                
                -- 点击复制消息
                local clickButton = Instance.new("TextButton")
                clickButton.Size = UDim2.new(1, 0, 1, 0)
                clickButton.BackgroundTransparency = 1
                clickButton.Text = ""
                clickButton.Parent = messageFrame
                
                clickButton.MouseButton1Click:Connect(function()
                    local fullMessage = string.format("[%s] [%s] %s: %s", 
                        os.date("%H:%M:%S"), 
                        teamName, 
                        playerName, 
                        message
                    )
                    setclipboard(fullMessage)
                    
                    -- 创建临时提示
                    local copyTip = Instance.new("TextLabel")
                    copyTip.Size = UDim2.new(0, 60, 0, 20)
                    copyTip.Position = UDim2.new(0.5, -30, 0.5, -10)
                    copyTip.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    copyTip.Text = "已复制!"
                    copyTip.TextColor3 = Color3.fromRGB(255, 255, 255)
                    copyTip.Font = Enum.Font.SourceSansBold
                    copyTip.TextSize = 12
                    copyTip.Parent = messageFrame
                    
                    local tipCorner = Instance.new("UICorner")
                    tipCorner.CornerRadius = UDim.new(0, 4)
                    tipCorner.Parent = copyTip
                    
                    task.wait(1)
                    copyTip:Destroy()
                end)
                
                messageCount = messageCount + 1
                messageFrame.LayoutOrder = messageCount
                messageFrame.Parent = scrollingFrame
                
                -- 更新计数
                countLabel.Text = "Message: " .. tostring(messageCount)
                
                -- 保存最后一条消息
                if player and player:IsA("Player") then
                    lastMessage = string.format("[%s] %s: %s", teamName, playerName, message)
                else
                    lastMessage = playerName .. ": " .. message
                end
                
                -- 自动调整画布大小
                scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                
                -- 自动滚动到底部
                if autoScroll then
                    task.wait()
                    scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y)
                end
            end
            
            -- 监听聊天函数
            local function connectPlayer(player)
                if player ~= LocalPlayer then
                    local connection = player.Chatted:Connect(function(message)
                        createChatMessage(player.Name, message, player)
                    end)
                    table.insert(connections, connection)
                end
            end
            
            -- 监听所有现有玩家
            for _, player in pairs(Players:GetPlayers()) do
                connectPlayer(player)
            end
            
            -- 监听新加入的玩家
            local playerAddedConnection = Players.PlayerAdded:Connect(connectPlayer)
            table.insert(connections, playerAddedConnection)
            
            -- 清空按钮功能
            clearButton.MouseButton1Click:Connect(function()
                for _, child in pairs(scrollingFrame:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                messageCount = 0
                countLabel.Text = "消息数: 0"
                scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            end)
            
            -- 复制最后消息按钮
            copyButton.MouseButton1Click:Connect(function()
                if lastMessage ~= "" then
                    setclipboard(lastMessage)
                    copyButton.Text = "已复制!"
                    copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
                    task.wait(1)
                    copyButton.Text = "复制最后"
                    copyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end)
            
            -- 自动滚动切换
            autoScrollButton.MouseButton1Click:Connect(function()
                autoScroll = not autoScroll
                if autoScroll then
                    autoScrollButton.Text = "自动滚动:开"
                    autoScrollButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
                else
                    autoScrollButton.Text = "自动滚动:关"
                    autoScrollButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
                end
            end)
            
            -- 最小化按钮功能
            local isMinimized = false
            minimizeButton.MouseButton1Click:Connect(function()
                isMinimized = not isMinimized
                if isMinimized then
                    scrollingFrame.Visible = false
                    controlPanel.Visible = false
                    mainFrame.Size = UDim2.new(0, 450, 0, 30)
                    minimizeButton.Text = "□"
                else
                    scrollingFrame.Visible = true
                    controlPanel.Visible = true
                    mainFrame.Size = UDim2.new(0, 450, 0, 500)
                    minimizeButton.Text = "_"
                end
            end)
            
            -- 关闭按钮功能
            closeButton.MouseButton1Click:Connect(function()
                -- 断开所有连接
                for _, connection in pairs(connections) do
                    connection:Disconnect()
                end
                -- 销毁GUI
                screenGui:Destroy()
                print("聊天监控器已关闭")
            end)
            
            -- 添加快捷键切换显示/隐藏 (按 F9)
            local UserInputService = game:GetService("UserInputService")
            local keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed then
                    if input.KeyCode == Enum.KeyCode.F9 then
                        mainFrame.Visible = not mainFrame.Visible
                    elseif input.KeyCode == Enum.KeyCode.F8 then
                        -- F8清空记录
                        for _, child in pairs(scrollingFrame:GetChildren()) do
                            if child:IsA("Frame") then
                                child:Destroy()
                            end
                        end
                        messageCount = 0
                        countLabel.Text = "消息数: 0"
                    end
                end
            end)
            table.insert(connections, keyConnection)
            
            -- 启动提示
            createChatMessage("system", "Chat monitoring is now active!", nil)
            createChatMessage("Notice", "Press F9 to toggle the display/hide status, F8 to clear the save data", nil)
            createChatMessage("Notice", "Click on the message to copy the complete content (including team information)", nil)
            
            print("聊天监控器 v3.0 加载成功！")
            print("快捷键: F9-显示/隐藏  F8-清空记录")
            
        else
            -- 关闭聊天监控
            if _G.ChatMonitorGui then
                _G.ChatMonitorGui:Destroy()
                _G.ChatMonitorGui = nil
            end
            
            if _G.ChatMonitorConnections then
                for _, connection in pairs(_G.ChatMonitorConnections) do
                    connection:Disconnect()
                end
                _G.ChatMonitorConnections = nil
            end
            
            print("聊天监控器已关闭")
        end
    end,
})

-- 添加说明
MiscTab:CreateParagraph({
    Title = "Menu description",
    Content = "This script will be provided free of charge forever.\nIf you paid for it\nYou Got SCAM \nI will continue to update and optimize the features.\nThank you for your support!\n \n \nUpdate v 1.4 \n1.Added Mobile Mode (Aimbot)\n2.Fixed Aimbot Bug\n3.Optimize scripts and fix bugs"
})
