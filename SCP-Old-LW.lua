local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SCP-Roleplay by Cat King v1.8", -- 更新版本号
   LoadingTitle = "Cat King",
   LoadingSubtitle = "by Cat King ",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Cat-King-Config"
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

-- ==================================================================
-- [Hidden Name]
-- ==================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local NameHideConnection = nil 

local function forceHideName()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")

    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
        humanoid.NameDisplayDistance = 0 
    end

    if head then
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                child.Enabled = false
            end
        end
    end
end

local function restoreName()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")

    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
        humanoid.NameDisplayDistance = 100
    end

    if head then
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                child.Enabled = true
            end
        end
    end
end

MainTab:CreateToggle({
   Name = "Hidden Name ",
   CurrentValue = false,
   Flag = "NameHiderToggle",
   Callback = function(Value)
       if Value then
           if NameHideConnection then NameHideConnection:Disconnect() end
           NameHideConnection = RunService.RenderStepped:Connect(forceHideName)
       else
           if NameHideConnection then 
               NameHideConnection:Disconnect()
               NameHideConnection = nil
           end
           restoreName()
       end
   end,
})
-- ==================================================================


-- 优化内存管理
local connections = setmetatable({}, {__mode = "k"})
local highlights = setmetatable({}, {__mode = "k"})
local espLabels = setmetatable({}, {__mode = "k"})

-- 全局变量
_G.WallCheckSetting = _G.WallCheckSetting ~= nil and _G.WallCheckSetting or true
_G.WeaponCheckEnabled = false 
_G.ESPActive = false 

-- ==================================================================
-- [武器列表]
-- ==================================================================
local weaponsList = {
    "M4", "M16A4", "SMG25", "BP-556", "M416", "SW-762", "KV-12", "AUG A3", 
    "ACR", "BR-762", "ARX-200", "AK-47", "AKS-74U", "Laser Rifle", "M110",
    "SMG46", "SMG416", "P DW-28", "Honey Badger",
    "UMP-45", "MP5", "Kriss Vector", "EVO 3 Micro", "SMG9X", "P90", "MP7",
    "AAC Honey Badger", "APC556 PDW",
    "Spas - 12", "AA-12", "Burning Fang",
    "XM250", "Minigun",
    "M9", "Pistol", "Golden Hawk", "Laser Pistol"
}

-- [ESP 模块 - 修复版]
local Toggle = MainTab:CreateToggle({
   Name = "ESP ",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       _G.ESPActive = Value
       
       if Value then
           local Players = game:GetService("Players")
           
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
               if not character then return end
               if not character:IsDescendantOf(workspace) then return end
               
               local head = character:FindFirstChild("Head")
               if not head then
                   head = character:WaitForChild("Head", 10) 
               end
               
               if not head then return end
               
               if highlights[character] and highlights[character].Parent == character then return end

               cleanupESP(character)
               
               local highlight = Instance.new("Highlight")
               highlight.Name = "PlayerESP"
               highlight.FillColor = getPlayerColor(player)
               highlight.OutlineColor = Color3.new(1, 1, 1)
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.FillTransparency = 0.6
               highlight.OutlineTransparency = 0.2
               highlight.Parent = character
               
               highlights[character] = highlight
               
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
               
               local charAddedConn = player.CharacterAdded:Connect(function(character)
                   task.wait(1) 
                   createESP(character, player)
               end)
               
               local charRemovingConn = player.CharacterRemoving:Connect(function(character)
                   cleanupESP(character)
               end)
               
               local teamChangedConn = player:GetPropertyChangedSignal("Team"):Connect(function()
                   if player.Character then
                       task.wait(0.1)
                       cleanupESP(player.Character)
                       createESP(player.Character, player)
                   end
               end)
               
               connections[player] = {
                   charAdded = charAddedConn,
                   charRemoving = charRemovingConn,
                   teamChanged = teamChangedConn
               }
               
               if player.Character then
                   task.spawn(function()
                       task.wait(0.5)
                       createESP(player.Character, player)
                   end)
               end
           end
           
           local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
               if connections[player] then
                   for _, conn in pairs(connections[player]) do
                       pcall(function() conn:Disconnect() end) -- 安全断开
                   end
                   connections[player] = nil
               end
               if player.Character then
                   cleanupESP(player.Character)
               end
           end)
           connections.playerRemoving = playerRemovingConn
           
           for _, player in ipairs(Players:GetPlayers()) do
               onPlayerAdded(player)
           end
           
           connections.playerAdded = Players.PlayerAdded:Connect(onPlayerAdded)
           
           task.spawn(function()
               while _G.ESPActive do
                   for _, player in ipairs(Players:GetPlayers()) do
                       if player ~= Players.LocalPlayer and player.Character then
                           local head = player.Character:FindFirstChild("Head")
                           if head then
                               if not highlights[player.Character] or not highlights[player.Character].Parent then
                                   createESP(player.Character, player)
                               end
                           end
                       end
                   end
                   task.wait(3)
               end
           end)
       else
           -- [修复核心] 安全关闭逻辑
           _G.ESPActive = false
           
           -- 定义一个安全断开的辅助函数，防止 nil 报错
           local function safeDisconnect(c)
               if c and typeof(c) == "RBXScriptConnection" then
                   pcall(function() c:Disconnect() end)
               end
           end

           -- 1. 优先断开全局监听器
           if connections.playerAdded then
               safeDisconnect(connections.playerAdded)
               connections.playerAdded = nil
           end
           if connections.playerRemoving then
               safeDisconnect(connections.playerRemoving)
               connections.playerRemoving = nil
           end
           
           -- 2. 遍历断开玩家的连接
           for key, val in pairs(connections) do
               if type(val) == "table" then
                   -- 如果是玩家的连接表
                   for _, conn in pairs(val) do
                       safeDisconnect(conn)
                   end
               else
                   -- 如果是其他单独连接
                   safeDisconnect(val)
               end
               connections[key] = nil
           end
           
           -- 3. 安全清理视觉效果 (防止 destroy nil 报错)
           for _, highlight in pairs(highlights) do
               if highlight then pcall(function() highlight:Destroy() end) end
           end
           
           for _, label in pairs(espLabels) do
               if label then pcall(function() label:Destroy() end) end
           end
           
           -- 4. 彻底清空表
           table.clear(connections)
           table.clear(highlights)
           table.clear(espLabels)
           
       end
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

-- 【已替换：无限跳跃 (Velocity Bypass)】
local Toggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
       local UserInputService = game:GetService("UserInputService")
       local Players = game:GetService("Players")
       local LocalPlayer = Players.LocalPlayer

       if Value then
           if _G.InfJumpConnection then _G.InfJumpConnection:Disconnect() end

           _G.InfJumpConnection = UserInputService.JumpRequest:Connect(function()
               if LocalPlayer.Character then
                   local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                   local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   
                   if hum and root and hum.Health > 0 then
                       local currentVel = root.AssemblyLinearVelocity
                       root.AssemblyLinearVelocity = Vector3.new(currentVel.X, 50, currentVel.Z)
                   end
               end
           end)
           
           print("无限跳跃 (Velocity Bypass) 已启用")
       else
           if _G.InfJumpConnection then
               _G.InfJumpConnection:Disconnect()
               _G.InfJumpConnection = nil
           end
           print("无限跳跃已禁用")
       end
   end,
})

-- =========================================================
-- [Sprint Boost]
-- =========================================================
local SpeedSettings = {
    Enabled = false,
    TargetSpeed = 25
}

MainTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SprintEnabled",
   Callback = function(Value)
       SpeedSettings.Enabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Sprint Speed",
   Range = {20, 40},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 25,
   Flag = "SprintValue",
   Callback = function(Value)
       SpeedSettings.TargetSpeed = Value
   end,
})

game:GetService("RunService").Heartbeat:Connect(function()
    if not SpeedSettings.Enabled then return end
    
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum and root and hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
        
        local isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        
        if isSprinting then
            local moveDir = hum.MoveDirection
            local newVelocity = Vector3.new(
                moveDir.X * SpeedSettings.TargetSpeed,
                root.AssemblyLinearVelocity.Y,
                moveDir.Z * SpeedSettings.TargetSpeed
            )
            root.AssemblyLinearVelocity = newVelocity
        end
    end
end)

-- =========================================================
-- [Show Chat]
-- =========================================================
MainTab:CreateToggle({
   Name = "Show Chat",
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

-- ========== Radio复制 ==========
local RadioButton = MainTab:CreateButton({
    Name = "Get Radio",
    Callback = function()
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local allPlayers = Players:GetPlayers()
        
        if #allPlayers <= 1 then return end
        
        local otherPlayers = {}
        for _, player in ipairs(allPlayers) do
            if player ~= localPlayer then
                table.insert(otherPlayers, player)
            end
        end
        
        if #otherPlayers == 0 then return end
        
        local randomPlayer = otherPlayers[math.random(1, #otherPlayers)]
        
        if randomPlayer.Character and randomPlayer:FindFirstChild("Backpack") then
            local radio = randomPlayer.Backpack:FindFirstChild("Radio")
            if radio then
                if localPlayer.Character and localPlayer:FindFirstChild("Backpack") then
                    if not localPlayer.Backpack:FindFirstChild("Radio") then
                        local radioCopy = radio:Clone()
                        radioCopy.Parent = localPlayer.Backpack
                    end
                end
            end
        end
    end,
})

-- 攻击类Tab
local CombatTab = Window:CreateTab("Aimbot", nil)
local CombatSection = CombatTab:CreateSection("PC Aimbot (Right Click)")

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

local FOVSlider = CombatTab:CreateSlider({
   Name = "FOV",
   Range = {50, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 80,
   Flag = "fovsize",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.FOV = Value
           if _G.HeadLock.FOVCircle then
               _G.HeadLock.FOVCircle.Radius = Value
           end
       end
       if _G.MobileAimSettings then _G.MobileAimSettings.FOV = Value end
   end,
})

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

local WallCheckToggle = CombatTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = _G.WallCheckSetting,
   Flag = "WallCheck",
   Callback = function(Value)
       _G.WallCheckSetting = Value 
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.WallCheck = Value
       end
   end,
})

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

local TeamCheckToggle = CombatTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
       if _G.HeadLock and _G.HeadLock.Settings then
           _G.HeadLock.Settings.TeamCheck = Value
       end
       _G.HitboxTeamCheck = Value 
   end,
})

local WeaponCheckToggle = CombatTab:CreateToggle({
    Name = "Gun Check (PC & Mobile)",
    CurrentValue = false,
    Flag = "WeaponCheck",
    Callback = function(Value)
        _G.WeaponCheckEnabled = Value
        if Value then
            print("持枪检测已启用！")
        else
            print("持枪检测已禁用！")
        end
    end,
})

local WeaponStatusLabel = CombatTab:CreateLabel("Weapon status: Not detected")

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

local HeadLockToggle = CombatTab:CreateToggle({
   Name = "Aimbot (PC)",
   CurrentValue = false,
   Flag = "HeadLock",
   Callback = function(Value)
       if Value then
           local Players = game:GetService("Players")
           local RunService = game:GetService("RunService")
           local UserInputService = game:GetService("UserInputService")
           local Camera = workspace.CurrentCamera
           local LocalPlayer = Players.LocalPlayer
           
           local FOVCircle = Drawing.new("Circle")
           FOVCircle.Visible = true
           FOVCircle.Thickness = 2
           FOVCircle.Color = Color3.fromRGB(255, 255, 255)
           FOVCircle.Transparency = 0.7
           FOVCircle.Radius = 400
           FOVCircle.NumSides = 64
           FOVCircle.Filled = false
           
           local Crosshair = {
               Horizontal = Drawing.new("Line"),
               Vertical = Drawing.new("Line")
           }
           
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
                   WallCheck = _G.WallCheckSetting,
                   ShowCrosshair = true,
                   StickyLock = true,
                   TeamCheck = true,
                   LockMode = "即时锁定"
               },
               LockedTarget = nil,
           }
           
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
           
           local function isEnemy(player)
               if not _G.HeadLock.Settings.TeamCheck then return true end
               if not LocalPlayer.Team or not player.Team then return true end
               local myTeam = LocalPlayer.Team.Name
               local theirTeam = player.Team.Name
               if myTeam == theirTeam then return false end
               local isMyTeamVillain = (myTeam == "Class-D" or myTeam == "Chaos Insurgency")
               local isTheirTeamVillain = (theirTeam == "Class-D" or theirTeam == "Chaos Insurgency")
               if isMyTeamVillain and isTheirTeamVillain then return false end
               if isMyTeamVillain ~= isTheirTeamVillain then return true end
               local heroTeams = {"Scientific Department", "Security Department", "Mobile Task Force", "Intelligence Agency", "Rapid Response Team", "Medical Department", "Administrative Department"}
               local isMyTeamHero = false
               local isTheirTeamHero = false
               for _, team in ipairs(heroTeams) do
                   if myTeam == team then isMyTeamHero = true end
                   if theirTeam == team then isTheirTeamHero = true end
               end
               if isMyTeamHero and isTheirTeamHero then return false end
               return true
           end
           
           local function checkVisible(part)
               if not _G.HeadLock.Settings.WallCheck then return true end
               local origin = Camera.CFrame.Position
               local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
               local params = RaycastParams.new()
               params.FilterType = Enum.RaycastFilterType.Blacklist
               params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
               local result = workspace:Raycast(origin, direction, params)
               return result == nil
           end
           
           local function getBestTarget()
               local bestTarget = nil
               local bestScore = math.huge
               local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
               
               for _, player in ipairs(Players:GetPlayers()) do
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
                                           local score = distance2D + (distance3D * 0.05)
                                           if score < bestScore then
                                               bestScore = score
                                               bestTarget = {Head = head, Player = player, Character = character}
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
           
           local function getPredictedPosition(head, character)
               if _G.HeadLock.Settings.LockMode ~= "预测锁定" then return head.Position end
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
           
           local function lockToHead(targetData)
               if not targetData then return end
               local head = targetData.Head
               local character = targetData.Character
               local targetPos = getPredictedPosition(head, character)
               if _G.HeadLock.Settings.LockMode == "即时锁定" then
                   Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
               elseif _G.HeadLock.Settings.LockMode == "平滑锁定" then
                   local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                   Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / _G.HeadLock.Settings.Smoothness)
               else
                   Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
               end
           end
           
           _G.HeadLock.RenderConnection = RunService.RenderStepped:Connect(function()
               local screenSize = Camera.ViewportSize
               local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
               FOVCircle.Position = centerPos
               local hue = tick() % 5 / 5
               FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
               
               local weaponEquipped = hasWeapon()
               if not weaponEquipped and _G.WeaponCheckEnabled then
                   for _, line in pairs(Crosshair) do line.Color = Color3.fromRGB(128, 128, 128) end
               end
               
               if _G.HeadLock.Settings.ShowCrosshair then
                   Crosshair.Horizontal.From = Vector2.new(centerPos.X - 10, centerPos.Y)
                   Crosshair.Horizontal.To = Vector2.new(centerPos.X + 10, centerPos.Y)
                   Crosshair.Vertical.From = Vector2.new(centerPos.X, centerPos.Y - 10)
                   Crosshair.Vertical.To = Vector2.new(centerPos.X, centerPos.Y + 10)
               end
               
               if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and weaponEquipped then
                   if _G.HeadLock.Settings.StickyLock and _G.HeadLock.LockedTarget then
                       local target = _G.HeadLock.LockedTarget
                       local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                       if target.Head and target.Head.Parent and humanoid and humanoid.Health > 0 and isEnemy(target.Player) then
                           lockToHead(target)
                       else
                           _G.HeadLock.LockedTarget = getBestTarget()
                           if _G.HeadLock.LockedTarget then lockToHead(_G.HeadLock.LockedTarget) end
                       end
                   else
                       local target = getBestTarget()
                       if target then _G.HeadLock.LockedTarget = target; lockToHead(target) end
                   end
                   
                   if weaponEquipped and _G.HeadLock.LockedTarget then
                       for _, line in pairs(Crosshair) do line.Color = Color3.fromRGB(0, 255, 0) end
                   elseif weaponEquipped then
                       for _, line in pairs(Crosshair) do line.Color = Color3.fromRGB(255, 0, 0) end
                   end
               else
                   _G.HeadLock.LockedTarget = nil
                   if weaponEquipped then for _, line in pairs(Crosshair) do line.Color = Color3.fromRGB(255, 0, 0) end end
               end
           end)
           print("即时锁头已启用！")
       else
           if _G.HeadLock then
               if _G.HeadLock.FOVCircle then _G.HeadLock.FOVCircle:Remove() end
               if _G.HeadLock.Crosshair then for _, line in pairs(_G.HeadLock.Crosshair) do line:Remove() end end
               if _G.HeadLock.RenderConnection then _G.HeadLock.RenderConnection:Disconnect() end
               _G.HeadLock = nil
           end
           print("即时锁头已禁用！")
       end
   end,
})

-- ==========================================================================================
-- [MOBILE AIM & HITBOX]
-- ==========================================================================================
local MobileTab = Window:CreateTab("Mobile Aim", nil)
local MobileSection = MobileTab:CreateSection("Lock & Silent")

_G.MobileGlobal = {
    IsAimbotGuiOn = false, 
    IsFOVOn = false,       
    IsCrossOn = false,     
    AimbotActive = false   
}

_G.HitboxSize = 6 
_G.HitboxTransparency = 1 
_G.HitboxActive = false 
_G.HitboxTeamCheck = true

local function ResetCharacter(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if head then
        head.Size = Vector3.new(1.2, 1.2, 1.2)
        head.Transparency = 0
        head.CanCollide = true
        
        local face = head:FindFirstChild("face")
        if face and face:IsA("Decal") then
            face.Transparency = 0
        end
    end
    
    if head and hrp then
        for _, descendant in pairs(head:GetChildren()) do
            if descendant:IsA("BillboardGui") then
                 descendant.Adornee = head
                 descendant.StudsOffset = Vector3.new(0, 2, 0)
            end
        end
    end
end

local function ApplyHitboxLogic()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if head and hum and hrp and hum.Health > 0 then
                if _G.HitboxTeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
                     if head.Size.X > 1.5 then ResetCharacter(char) end
                     continue
                end
                
                head.CanCollide = false 
                head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                head.Transparency = _G.HitboxTransparency
                
                local face = head:FindFirstChild("face")
                if face and face:IsA("Decal") then
                    face.Transparency = _G.HitboxTransparency
                end
                
                for _, child in ipairs(head:GetChildren()) do
                    if child:IsA("BillboardGui") then
                        if child.Adornee ~= hrp then child.Adornee = hrp end
                        if child.StudsOffset.Y ~= 3.5 then child.StudsOffset = Vector3.new(0, 3.5, 0) end
                    end
                end
                
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("BillboardGui") then
                         if child.Adornee ~= hrp then child.Adornee = hrp end
                        if child.StudsOffset.Y ~= 3.5 then child.StudsOffset = Vector3.new(0, 3.5, 0) end
                    end
                end
            end
        end
    end
end

local function ResetAllPlayers()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then ResetCharacter(player.Character) end
    end
end

local MobileFOV = Drawing.new("Circle")
local CrosshairX = Drawing.new("Line")
local CrosshairY = Drawing.new("Line")

MobileFOV.Visible = false
MobileFOV.Thickness = 2
MobileFOV.Transparency = 1
MobileFOV.Radius = 80 
MobileFOV.NumSides = 64
MobileFOV.Filled = false

CrosshairX.Visible = false; CrosshairY.Visible = false
CrosshairX.Color = Color3.new(1,1,1); CrosshairY.Color = Color3.new(1,1,1)
CrosshairX.Thickness = 1; CrosshairY.Thickness = 1

game:GetService("RunService").RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    MobileFOV.Position = center
    MobileFOV.Radius = 80
    
    local hue = tick() % 5 / 5
    MobileFOV.Color = Color3.fromHSV(hue, 1, 1)

    local showFOV = _G.MobileGlobal.IsFOVOn or _G.MobileGlobal.IsAimbotGuiOn
    local showCross = _G.MobileGlobal.IsCrossOn or _G.MobileGlobal.IsAimbotGuiOn
    
    MobileFOV.Visible = showFOV
    CrosshairX.Visible = showCross
    CrosshairY.Visible = showCross
    
    CrosshairX.From = Vector2.new(center.X - 10, center.Y)
    CrosshairX.To = Vector2.new(center.X + 10, center.Y)
    CrosshairY.From = Vector2.new(center.X, center.Y - 10)
    CrosshairY.To = Vector2.new(center.X, center.Y + 10)
    
    if _G.WeaponCheckEnabled then
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local hasGun = false
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, weaponName in ipairs(weaponsList) do
                    if tool.Name == weaponName or string.find(tool.Name, weaponName) then
                        hasGun = true
                        break
                    end
                end
            end
        else
            hasGun = true
        end
        
        if hasGun then
            CrosshairX.Color = Color3.new(1,1,1)
            CrosshairY.Color = Color3.new(1,1,1)
        else
            CrosshairX.Color = Color3.fromRGB(100, 100, 100)
            CrosshairY.Color = Color3.fromRGB(100, 100, 100)
        end
    else
        CrosshairX.Color = Color3.new(1,1,1)
        CrosshairY.Color = Color3.new(1,1,1)
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not _G.MobileGlobal.AimbotActive then return end
    
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    if _G.WeaponCheckEnabled and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local hasGun = false
        if tool then
            for _, weaponName in ipairs(weaponsList) do
                if tool.Name == weaponName or string.find(tool.Name, weaponName) then
                    hasGun = true
                    break
                end
            end
        end
        if not hasGun then return end
    end
    
    local closest = nil
    local maxDist = math.huge
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            local isTeammate = false
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then isTeammate = true end
            
            if not isTeammate then
                local head = player.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < 80 and dist < maxDist then
                        
                        local visible = true
                        if _G.WallCheckSetting then
                            local origin = Camera.CFrame.Position
                            local dest = head.Position
                            local direction = (dest - origin)
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                            params.IgnoreWater = true
                            
                            local result = workspace:Raycast(origin, direction, params)
                            if result then
                                if result.Instance:IsDescendantOf(player.Character) then
                                    visible = true
                                else
                                    visible = false
                                end
                            end
                        end
                        
                        if visible then
                            maxDist = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    
    if closest then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closest.Position)
    end
end)

MobileTab:CreateToggle({
   Name = "Enable Mobile Aimbot",
   CurrentValue = false,
   Flag = "MobileAimbot",
   Callback = function(Value)
       _G.MobileGlobal.IsAimbotGuiOn = Value
       local CoreGui = game:GetService("CoreGui")
       
       if Value then
           local ScreenGui = Instance.new("ScreenGui")
           ScreenGui.Name = "MobileAimGui"
           ScreenGui.Parent = CoreGui
           
           local AimBtn = Instance.new("TextButton")
           AimBtn.Name = "AimButton"
           AimBtn.Size = UDim2.new(0, 60, 0, 60)
           AimBtn.Position = UDim2.new(0.85, 0, 0.6, 0)
           AimBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
           AimBtn.Text = "AIM"
           AimBtn.TextColor3 = Color3.new(1,1,1)
           AimBtn.Font = Enum.Font.GothamBold
           AimBtn.TextSize = 16
           AimBtn.Parent = ScreenGui
           
           local Corner = Instance.new("UICorner")
           Corner.CornerRadius = UDim.new(0, 30)
           Corner.Parent = AimBtn
           
           local dragging, dragInput, dragStart, startPos
           AimBtn.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                   dragging = true
                   dragStart = input.Position
                   startPos = AimBtn.Position
                   input.Changed:Connect(function()
                       if input.UserInputState == Enum.UserInputState.End then dragging = false end
                   end)
               end
           end)
           AimBtn.InputChanged:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                   dragInput = input
               end
           end)
           game:GetService("UserInputService").InputChanged:Connect(function(input)
               if input == dragInput and dragging then
                   local delta = input.Position - dragStart
                   AimBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
               end
           end)
           
           AimBtn.MouseButton1Click:Connect(function()
               _G.MobileGlobal.AimbotActive = not _G.MobileGlobal.AimbotActive
               if _G.MobileGlobal.AimbotActive then
                   AimBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                   AimBtn.Text = "ON"
               else
                   AimBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                   AimBtn.Text = "AIM"
               end
           end)
           
           _G.MobileResources = ScreenGui
       else
           _G.MobileGlobal.AimbotActive = false
           if _G.MobileResources then _G.MobileResources:Destroy() end
           _G.MobileResources = nil
       end
   end,
})

MobileTab:CreateToggle({
   Name = "Enable Silent Aim",
   CurrentValue = false,
   Flag = "ShowHitboxBtn",
   Callback = function(Value)
       local CoreGui = game:GetService("CoreGui")
       
       if Value then
           local ScreenGui = Instance.new("ScreenGui")
           ScreenGui.Name = "HitboxButtonGui"
           ScreenGui.Parent = CoreGui
           
           local HitBtn = Instance.new("TextButton")
           HitBtn.Name = "HitboxBtn"
           HitBtn.Size = UDim2.new(0, 70, 0, 70)
           HitBtn.Position = UDim2.new(0.85, 0, 0.45, 0)
           HitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
           HitBtn.Text = "HITBOX"
           HitBtn.TextColor3 = Color3.new(1,1,1)
           HitBtn.Font = Enum.Font.GothamBold
           HitBtn.TextSize = 14
           HitBtn.Parent = ScreenGui
           
           local Corner = Instance.new("UICorner")
           Corner.CornerRadius = UDim.new(0, 35)
           Corner.Parent = HitBtn
           
           local dragging, dragInput, dragStart, startPos
           HitBtn.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                   dragging = true
                   dragStart = input.Position
                   startPos = HitBtn.Position
                   input.Changed:Connect(function()
                       if input.UserInputState == Enum.UserInputState.End then dragging = false end
                   end)
               end
           end)
           HitBtn.InputChanged:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                   dragInput = input
               end
           end)
           game:GetService("UserInputService").InputChanged:Connect(function(input)
               if input == dragInput and dragging then
                   local delta = input.Position - dragStart
                   HitBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
               end
           end)
           
           HitBtn.MouseButton1Click:Connect(function()
               _G.HitboxActive = not _G.HitboxActive
               if _G.HitboxActive then
                   HitBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                   HitBtn.Text = "ON"
               else
                   HitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                   HitBtn.Text = "HITBOX"
                   ResetAllPlayers()
               end
           end)
           
           _G.HitboxGui = ScreenGui
           
           _G.HitboxLoop = game:GetService("RunService").Heartbeat:Connect(function()
               if _G.HitboxActive then
                   ApplyHitboxLogic()
               end
           end)
           
       else
           _G.HitboxActive = false
           ResetAllPlayers()
           
           if _G.HitboxGui then _G.HitboxGui:Destroy() end
           if _G.HitboxLoop then _G.HitboxLoop:Disconnect() end
           _G.HitboxGui = nil
           _G.HitboxLoop = nil
       end
   end,
})

MobileTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "MobileShowFOV",
    Callback = function(Value)
        _G.MobileGlobal.IsFOVOn = Value
    end,
})

MobileTab:CreateToggle({
    Name = "Show Crosshair",
    CurrentValue = false,
    Flag = "MobileShowCrosshair",
    Callback = function(Value)
        _G.MobileGlobal.IsCrossOn = Value
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

MiscTab:CreateParagraph({
   Title = "Menu description",
   Content = "This script will be provided free of charge forever.\nIf you paid for it\nYou Got SCAM \nI will continue to update and optimize the features.\nThank you for your support!\n此脚本完全免费\n如果你是第三方渠道购买的那么你被骗了\n请立刻申请退款\n \n \nUpdate v 1.8 \n1. Fixed ESP \n2. Added Hidden Name\n3. Added Config Save"
})

MiscTab:CreateButton({
   Name = "Copy Discord Link",
   Callback = function()
       local inviteLink = "https://discord.gg/QtVMrPaM"
       setclipboard(inviteLink)
       Rayfield:Notify({
           Title = "Success",
           Content = "Discord Link Copied to Clipboard!",
           Duration = 3,
           Image = 4483362458,
       })
   end,
})

-- ==================================================================
-- [CONFIG SYSTEM]
-- ==================================================================
local ConfigTab = Window:CreateTab("Config", nil)
local ConfigSection = ConfigTab:CreateSection("Configuration System")

local ConfigFolder = "Cat-King-Config"
local HttpService = game:GetService("HttpService")
local InputConfigName = ""
local SelectedConfig = nil
local ConfigDropdown = nil

if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

local function GetConfigFileList()
    local files = listfiles(ConfigFolder)
    local names = {}
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(names, name)
        end
    end
    return names
end

ConfigTab:CreateInput({
    Name = "Custom Config Name",
    PlaceholderText = "Input name here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        InputConfigName = Text
    end,
})

ConfigDropdown = ConfigTab:CreateDropdown({
    Name = "Select Config",
    Options = GetConfigFileList(),
    CurrentOption = "",
    Flag = "ConfigDropdown",
    Callback = function(Option)
        SelectedConfig = Option
    end,
})

ConfigTab:CreateButton({
    Name = "Refresh List",
    Callback = function()
        local newOptions = GetConfigFileList()
        ConfigDropdown:Refresh(newOptions)
        Rayfield:Notify({
            Title = "Config",
            Content = "List Refreshed!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        local name = InputConfigName
        
        if name == "" then
            local count = 1
            while isfile(ConfigFolder .. "/config" .. count .. ".json") do
                count = count + 1
            end
            name = "config" .. count
        end
        
        local data = {}
        for flag, info in pairs(Rayfield.Flags) do
            if info then
                if type(info) == "table" and info.CurrentValue ~= nil then
                     data[flag] = info.CurrentValue
                elseif type(info) ~= "table" then
                     data[flag] = info
                end
            end
        end
        
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        
        local newOptions = GetConfigFileList()
        ConfigDropdown:Refresh(newOptions)
        
        Rayfield:Notify({
            Title = "Config Saved",
            Content = "Saved as: " .. name,
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        if not SelectedConfig or SelectedConfig == "" then
             Rayfield:Notify({Title = "Error", Content = "Please select a config first!", Duration = 3, Image = 4483362458})
             return
        end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        if isfile(path) then
            local content = readfile(path)
            local data = HttpService:JSONDecode(content)
            
            for flag, value in pairs(data) do
                if Rayfield.Flags[flag] then
                    pcall(function()
                        Rayfield.Flags[flag]:Set(value)
                    end)
                end
            end
            
            Rayfield:Notify({
                Title = "Config Loaded",
                Content = "Loaded: " .. SelectedConfig,
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        if not SelectedConfig or SelectedConfig == "" then
             Rayfield:Notify({Title = "Error", Content = "Please select a config first!", Duration = 3, Image = 4483362458})
             return
        end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        if isfile(path) then
            delfile(path)
            
            local newOptions = GetConfigFileList()
            ConfigDropdown:Refresh(newOptions)
            SelectedConfig = nil 
            
            Rayfield:Notify({
                Title = "Config Deleted",
                Content = "Deleted: " .. SelectedConfig,
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})
