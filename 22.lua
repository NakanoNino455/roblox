local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SCP-Roleplay by Cat King v1.5",
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

-- Mobile 模式开关
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
               
               -- ================== Mobile 模式输入检测 ==================
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

-- 聊天显示开关 (Replaces Chat Monitor)
local ShowChatToggle = MiscTab:CreateToggle({
    Name = "show chat",
    CurrentValue = false,
    Flag = "ShowChat",
    Callback = function(Value)
        local TextChatService = game:GetService("TextChatService")
        local chatWindowConfig = TextChatService:FindFirstChild("ChatWindowConfiguration")

        if chatWindowConfig then
            chatWindowConfig.Enabled = Value
            if Value then
                print("已强制开启聊天记录窗口")
            end
        end
    end,
})

-- 添加说明
MiscTab:CreateParagraph({
    Title = "Menu description",
    Content = "This script will be provided free of charge forever.\nIf you paid for it\nYou Got SCAM \nI will continue to update and optimize the features.\nThank you for your support!\n \n \nUpdate v 1.5 \n1.Added Mobile Mode (Aimbot)\n2.Replaced Chat Monitor with system Show Chat\n3.Optimize scripts and fix bugs"
})
