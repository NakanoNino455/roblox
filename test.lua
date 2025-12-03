local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Cat-King Hub | By Cat King v2.6", -- 版本号微调以示区别
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Naramo-Nuclear-Plant-V2",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Cat-King Hub",
      FileName = "CatKing_Configs"
   },
   KeySystem = false, 
})

-- 服务引用
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- [UI 系统: 锁定提示 & CatKing 功能列表]
--------------------------------------------------------------------
if CoreGui:FindFirstChild("NaramoOverlay") then
    CoreGui.NaramoOverlay:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NaramoOverlay"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false 

-- 1. 锁定提示文本 (LOCKED)
local LockLabel = Instance.new("TextLabel")
LockLabel.Name = "LockIndicator"
LockLabel.Parent = ScreenGui
LockLabel.BackgroundTransparency = 1
LockLabel.Size = UDim2.new(0, 100, 0, 30)
LockLabel.Font = Enum.Font.GothamBlack
LockLabel.Text = "[ LOCKED ]"
LockLabel.TextColor3 = Color3.fromRGB(255, 50, 50) 
LockLabel.TextSize = 18
LockLabel.TextStrokeTransparency = 0
LockLabel.Visible = false
LockLabel.Position = UDim2.new(0.5, 30, 0.5, 30)

-- 2. 功能列表框架
local ListFrame = Instance.new("Frame")
ListFrame.Name = "FeatureList"
ListFrame.Parent = ScreenGui
ListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ListFrame.BackgroundTransparency = 0.6
ListFrame.BorderSizePixel = 0
ListFrame.Position = UDim2.new(0.85, 0, 0.3, 0) 
ListFrame.Size = UDim2.new(0, 180, 0, 50) 
ListFrame.Visible = false
ListFrame.Active = true
ListFrame.Draggable = true 

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = ListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ListFrame
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 2)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ListPadding = Instance.new("UIPadding")
ListPadding.Parent = ListFrame
ListPadding.PaddingTop = UDim.new(0, 10)
ListPadding.PaddingBottom = UDim.new(0, 10)

-- 功能状态追踪表
local ActiveFeatures = {
    Aimbot = false,
    MobileAimbot = false,
    ESP = false,
    Tracers = false,
    Noclip = false,
    InfiniteJump = false,
    FullBright = false,
    InfiniteAmmo = false,
    VehicleMod = false 
}

-- 更新列表函数
local function UpdateFeatureList()
    for _, child in pairs(ListFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "MainTitle"
    TitleLabel.Parent = ListFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Font = Enum.Font.FredokaOne 
    TitleLabel.Text = "CatKing v3"
    TitleLabel.TextSize = 26
    TitleLabel.LayoutOrder = 0 
    TitleLabel.TextStrokeTransparency = 0.8
     
    local Spacer = Instance.new("TextLabel")
    Spacer.Parent = ListFrame
    Spacer.Text = "----------------"
    Spacer.BackgroundTransparency = 1
    Spacer.Size = UDim2.new(1, 0, 0, 10)
    Spacer.TextColor3 = Color3.fromRGB(100, 100, 100)
    Spacer.LayoutOrder = 1
    Spacer.TextSize = 10

    local count = 0
    for featureName, isEnabled in pairs(ActiveFeatures) do
        if isEnabled then
            local label = Instance.new("TextLabel")
            label.Parent = ListFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -20, 0, 22)
            label.Font = Enum.Font.GothamBold
            label.Text = string.upper(featureName)
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextSize = 16
            label.LayoutOrder = count + 2 
            label.TextStrokeTransparency = 1
            count = count + 1
        end
    end
     
    local totalHeight = 35 + 10 + (count * 24) + 20
    ListFrame.Size = UDim2.new(0, 180, 0, totalHeight)
end

-- 全局彩虹特效 (修复版：强制更新颜色)
task.spawn(function()
    while task.wait(0.05) do 
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)

        -- 列表颜色更新
        if ListFrame.Visible then
            for _, child in pairs(ListFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = color
                    if child.Name == "MainTitle" then
                        child.TextStrokeColor3 = Color3.fromHSV(hue, 0.5, 0.5)
                    end
                end
            end
        end

        -- FOV圈颜色更新 (此处移除Visible判断，确保开启瞬间就有颜色)
        FOVCircle.Color = color
        
        MobileFOVCircle.Color = color
        MobileBtnFrame.BackgroundColor3 = color 
    end
end)

--------------------------------------------------------------------
-- [Mobile Movable Button Setup] - 修复触摸拖动
--------------------------------------------------------------------
local MobileBtnFrame = Instance.new("Frame")
MobileBtnFrame.Name = "MobileTriggerFrame"
MobileBtnFrame.Parent = ScreenGui
MobileBtnFrame.Size = UDim2.new(0, 60, 0, 60)
MobileBtnFrame.Position = UDim2.new(0.8, 0, 0.6, 0)
MobileBtnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MobileBtnFrame.BackgroundTransparency = 0.5
MobileBtnFrame.BorderSizePixel = 0
MobileBtnFrame.Visible = false
MobileBtnFrame.Active = true

local MobileBtnCorner = Instance.new("UICorner")
MobileBtnCorner.CornerRadius = UDim.new(1, 0)
MobileBtnCorner.Parent = MobileBtnFrame

local MobileBtn = Instance.new("TextButton")
MobileBtn.Parent = MobileBtnFrame
MobileBtn.Size = UDim2.new(1, 0, 1, 0)
MobileBtn.BackgroundTransparency = 1
MobileBtn.Text = "AIM"
MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileBtn.Font = Enum.Font.GothamBlack
MobileBtn.TextSize = 14

--------------------------------------------------------------------
-- [Mobile Button Drag System] - 新增触摸拖动支持
--------------------------------------------------------------------
local MobileDragging = false
local MobileDragInput = nil
local MobileDragStart = nil
local MobileStartPos = nil

local function UpdateMobileDrag(input)
    local delta = input.Position - MobileDragStart
    MobileBtnFrame.Position = UDim2.new(
        MobileStartPos.X.Scale, 
        MobileStartPos.X.Offset + delta.X, 
        MobileStartPos.Y.Scale, 
        MobileStartPos.Y.Offset + delta.Y
    )
end

MobileBtnFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MobileDragging = true
        MobileDragStart = input.Position
        MobileStartPos = MobileBtnFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                MobileDragging = false
            end
        end)
    end
end)

MobileBtnFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        MobileDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == MobileDragInput and MobileDragging then
        UpdateMobileDrag(input)
    end
end)

--------------------------------------------------------------------
-- [核心变量]
--------------------------------------------------------------------
_G.InfiniteAmmoEnabled = false
_G.VehicleModEnabled = false
_G.VehicleSpeedMult = 1.5
_G.VehicleTurnSpeed = 0.02

-- [UPDATED] 添加了偏移量变量
local MobileSettings = {
    Enabled = false,
    Active = false,
    FOV = 120,
    Target = nil,
    OffsetX = 0, -- 新增 X轴偏移
    OffsetY = 0  -- 新增 Y轴偏移
}

local AimbotSettings = {
    Enabled = false,
    BypassCheck = false, 
    FOV = 150,
    WallCheck = true, 
    LockedTarget = nil
}

local VisualSettings = {
    Enabled = false,
    ShowTracers = false,
    ShowHealth = false,
    ShowDistance = false,
    RenderDistance = 2000, 
    ESP_Storage = {},
    TeamCache = {}
}

_G.InfiniteJumpEnabled = false
_G.NoclipConnection = nil

local WeaponKeywords = {
    "BR", "18", "M19", 
    "M4", "AK", "P90", "MP5", "Shotgun", "Pistol", "Glock", 
    "Rifle", "Sniper", "SMG", "Gun", "Blaster", "Deagle", 
    "USP", "Scar", "Vector", "Awp", "M249", "P250", "HK",
    "Weapon", "Firearm"
}

-- 创建标签页
local MainTab = Window:CreateTab("Main", nil)
local AimbotTab = Window:CreateTab("Aimbot", nil)
local VisualTab = Window:CreateTab("Visual", nil)
local VehicleTab = Window:CreateTab("Vehicle", nil)
local OtherTab = Window:CreateTab("Other", nil)

--------------------------------------------------------------------
-- [Main Tab]
--------------------------------------------------------------------
local MainSection = MainTab:CreateSection("Main")

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
       _G.InfiniteJumpEnabled = Value
       ActiveFeatures.InfiniteJump = Value
       UpdateFeatureList()
   end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJumpEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
       ActiveFeatures.Noclip = Value
       UpdateFeatureList()
       
       if Value then
           _G.NoclipConnection = RunService.Stepped:Connect(function()
               if LocalPlayer.Character then
                   for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                        if v:IsA("BasePart") and v.CanCollide == true then
                            v.CanCollide = false
                        end
                   end
               end
           end)
       else
           if _G.NoclipConnection then
               _G.NoclipConnection:Disconnect()
               _G.NoclipConnection = nil
           end
       end
   end,
})

MainTab:CreateToggle({
   Name = "Show Chat",
   CurrentValue = false,
   Flag = "ForceChat",
   Callback = function(Value)
        local chatWindowConfig = TextChatService:FindFirstChild("ChatWindowConfiguration")
        if chatWindowConfig then
            chatWindowConfig.Enabled = Value
        end
        pcall(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, Value)
        end)
   end,
})

local EnvSection = MainTab:CreateSection("Environment settings")

MainTab:CreateToggle({
   Name = "Full Bright",
   CurrentValue = false,
   Flag = "FullBright",
   Callback = function(Value)
       ActiveFeatures.FullBright = Value
       UpdateFeatureList()

       if Value then
           _G.OldBrightness = Lighting.Brightness
           _G.OldAmbient = Lighting.Ambient
           _G.OldGlobalShadows = Lighting.GlobalShadows
           Lighting.Brightness = 2
           Lighting.Ambient = Color3.fromRGB(255, 255, 255)
           Lighting.GlobalShadows = false
       else
           Lighting.Brightness = _G.OldBrightness or 1
           Lighting.Ambient = _G.OldAmbient or Color3.fromRGB(0,0,0)
           Lighting.GlobalShadows = _G.OldGlobalShadows or true
       end
   end,
})

--------------------------------------------------------------------
-- [Aimbot Tab]
--------------------------------------------------------------------
local AimbotSection = AimbotTab:CreateSection("PC Aimbot")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.Radius = AimbotSettings.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Mobile Visuals
local MobileFOVCircle = Drawing.new("Circle")
MobileFOVCircle.Thickness = 3
MobileFOVCircle.NumSides = 32
MobileFOVCircle.Filled = false
MobileFOVCircle.Transparency = 1
MobileFOVCircle.Visible = false
MobileFOVCircle.Radius = MobileSettings.FOV
MobileFOVCircle.Color = Color3.fromRGB(255, 255, 255)

local MobileCrosshairH = Drawing.new("Line")
MobileCrosshairH.Thickness = 2
MobileCrosshairH.Color = Color3.fromRGB(255, 0, 0)
MobileCrosshairH.Visible = false

local MobileCrosshairV = Drawing.new("Line")
MobileCrosshairV.Thickness = 2
MobileCrosshairV.Color = Color3.fromRGB(255, 0, 0)
MobileCrosshairV.Visible = false

-- (注：彩虹循环已移至上方，并移除了 Visible 检查)

local function IsHoldingWeapon()
    if AimbotSettings.BypassCheck then return true end
    local character = LocalPlayer.Character
    if not character then return false end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local toolName = tool.Name:lower() 
    for _, keyword in pairs(WeaponKeywords) do
        if string.find(toolName, keyword:lower()) then return true end
    end
    return false
end

local function IsVisible(targetPart)
    if not AimbotSettings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestPlayer(fovLimit)
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    -- [UPDATED] 计算中心点：如果是手机模式，则应用偏移量
    local centerScreen
    if MobileSettings.Active then
        centerScreen = Vector2.new((Camera.ViewportSize.X / 2) + MobileSettings.OffsetX, (Camera.ViewportSize.Y / 2) + MobileSettings.OffsetY)
    else
        centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
    
    local checkFOV = fovLimit or AimbotSettings.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health <= 0 then continue end
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end

            local head = player.Character.Head
            local vector, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local distance = (Vector2.new(vector.X, vector.Y) - centerScreen).Magnitude
                if distance < shortestDistance and distance <= checkFOV then
                    if IsVisible(head) then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

AimbotTab:CreateToggle({
   Name = "Aimbot (PC Right Click)",
   CurrentValue = false,
   Flag = "AimbotEnabled",
   Callback = function(Value)
       AimbotSettings.Enabled = Value
       ActiveFeatures.Aimbot = Value
       UpdateFeatureList()
   end,
})

AimbotTab:CreateToggle({
   Name = "⚠️Always Aimbot (No Gun Check)",
   CurrentValue = false,
   Flag = "BypassCheck",
   Callback = function(Value)
       AimbotSettings.BypassCheck = Value
   end,
})

AimbotTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Flag = "WallCheck",
   Callback = function(Value)
       AimbotSettings.WallCheck = Value
   end,
})

AimbotTab:CreateSlider({
   Name = "FOV",
   Range = {50, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Flag = "FOVRadius",
   Callback = function(Value)
       AimbotSettings.FOV = Value
       FOVCircle.Radius = Value
   end,
})

-- [Mobile Aimbot Section]
local MobileSection = AimbotTab:CreateSection("Mobile Aimbot")

AimbotTab:CreateToggle({
   Name = "Enable Mobile Aimbot Button",
   CurrentValue = false,
   Flag = "MobileAimbotEnabled",
   Callback = function(Value)
       MobileSettings.Enabled = Value
       MobileBtnFrame.Visible = Value
       ActiveFeatures.MobileAimbot = Value
       UpdateFeatureList()
       
       if not Value then
           MobileSettings.Active = false
           MobileBtn.Text = "AIM"
           MobileFOVCircle.Visible = false
           MobileCrosshairH.Visible = false
           MobileCrosshairV.Visible = false
       end
   end,
})

AimbotTab:CreateSlider({
   Name = "Mobile FOV",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 120,
   Callback = function(Value)
       MobileSettings.FOV = Value
       MobileFOVCircle.Radius = Value
   end,
})

-- [新增] 准心位置 X 调节
AimbotTab:CreateSlider({
   Name = "Crosshair Pos X (Left/Right)",
   Range = {-500, 500},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 0,
   Callback = function(Value)
       MobileSettings.OffsetX = Value
   end,
})

-- [新增] 准心位置 Y 调节
AimbotTab:CreateSlider({
   Name = "Crosshair Pos Y (Up/Down)",
   Range = {-500, 500},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 0,
   Callback = function(Value)
       MobileSettings.OffsetY = Value
   end,
})

MobileBtn.MouseButton1Click:Connect(function()
    MobileSettings.Active = not MobileSettings.Active
    if MobileSettings.Active then
        MobileBtn.Text = "ON"
    else
        MobileBtn.Text = "AIM"
    end
end)


local WeaponModsSection = AimbotTab:CreateSection("Weapon Mods")

AimbotTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfiniteAmmo",
    Callback = function(Value)
        _G.InfiniteAmmoEnabled = Value
        ActiveFeatures.InfiniteAmmo = Value
        UpdateFeatureList()
    end,
})

local DebugLabel = AimbotTab:CreateLabel("Debugging information: Waiting for Checking...")

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    local hasWeapon = IsHoldingWeapon()
    local currentToolName = "No/Empty hands"
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        currentToolName = LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
    end

    -- Debug Info
    if AimbotSettings.BypassCheck then
          DebugLabel:Set("Status: ⚠️ Always Aimbot (Using: " .. currentToolName .. ")")
    elseif hasWeapon then
          DebugLabel:Set("Status: ✅ Match successful (Using: " .. currentToolName .. ")")
    else
          DebugLabel:Set("Status: ❌ No weapon (Using: " .. currentToolName .. ")")
    end

    -- [UPDATED] 基础中心点
    local baseCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- MOBILE AIMBOT LOGIC
    if MobileSettings.Enabled and MobileSettings.Active then
        -- [UPDATED] 应用偏移量到 Mobile Center
        local mobileCenter = Vector2.new(baseCenter.X + MobileSettings.OffsetX, baseCenter.Y + MobileSettings.OffsetY)

        MobileFOVCircle.Visible = true
        MobileFOVCircle.Position = mobileCenter
        
        MobileCrosshairH.Visible = true
        MobileCrosshairH.From = Vector2.new(mobileCenter.X - 10, mobileCenter.Y)
        MobileCrosshairH.To = Vector2.new(mobileCenter.X + 10, mobileCenter.Y)
        
        MobileCrosshairV.Visible = true
        MobileCrosshairV.From = Vector2.new(mobileCenter.X, mobileCenter.Y - 10)
        MobileCrosshairV.To = Vector2.new(mobileCenter.X, mobileCenter.Y + 10)

        MobileSettings.Target = GetClosestPlayer(MobileSettings.FOV)
        if MobileSettings.Target and MobileSettings.Target.Character and MobileSettings.Target.Character:FindFirstChild("Head") then
            local targetHead = MobileSettings.Target.Character.Head
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetHead.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
            
            LockLabel.Visible = true
            LockLabel.Text = "[ M-LOCKED ]"
        else
            LockLabel.Visible = false
        end
    else
        MobileFOVCircle.Visible = false
        MobileCrosshairH.Visible = false
        MobileCrosshairV.Visible = false
        if not AimbotSettings.Enabled then LockLabel.Visible = false end
    end

    -- PC AIMBOT LOGIC
    if AimbotSettings.Enabled and hasWeapon then
        FOVCircle.Visible = true
        FOVCircle.Position = baseCenter -- PC Aimbot 保持在屏幕正中心
    else
        FOVCircle.Visible = false
        AimbotSettings.LockedTarget = nil
        if not MobileSettings.Active then LockLabel.Visible = false end
        if not MobileSettings.Enabled then return end
    end

    local isTriggerPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    if isTriggerPressed and AimbotSettings.Enabled then
        if not AimbotSettings.LockedTarget 
           or not AimbotSettings.LockedTarget.Character 
           or not AimbotSettings.LockedTarget.Character:FindFirstChild("Humanoid")
           or AimbotSettings.LockedTarget.Character.Humanoid.Health <= 0 then
            
            AimbotSettings.LockedTarget = GetClosestPlayer(AimbotSettings.FOV)
        end

        if AimbotSettings.LockedTarget and AimbotSettings.LockedTarget.Character and AimbotSettings.LockedTarget.Character:FindFirstChild("Head") then
            local targetHead = AimbotSettings.LockedTarget.Character.Head
            
            if IsVisible(targetHead) then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetHead.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
                LockLabel.Visible = true
                LockLabel.Text = "[ LOCKED ]"
            else
                LockLabel.Visible = false
                if AimbotSettings.WallCheck then
                    AimbotSettings.LockedTarget = nil
                end
            end
        else
            AimbotSettings.LockedTarget = nil
            if not MobileSettings.Active then LockLabel.Visible = false end
        end
    elseif not MobileSettings.Active then
        AimbotSettings.LockedTarget = nil
        LockLabel.Visible = false
    end
end)

--------------------------------------------------------------------
-- [Visual Tab] - 修复ESP系统
--------------------------------------------------------------------
local VisualSection = VisualTab:CreateSection("ESP")

-- 清理ESP函数（优化版）
local function ClearVisual(player)
    if VisualSettings.ESP_Storage[player] then
        pcall(function()
            if VisualSettings.ESP_Storage[player].Tracer then
                VisualSettings.ESP_Storage[player].Tracer.Visible = false
                VisualSettings.ESP_Storage[player].Tracer:Remove()
            end
        end)
        pcall(function()
            if VisualSettings.ESP_Storage[player].Highlight then
                VisualSettings.ESP_Storage[player].Highlight:Destroy()
            end
        end)
        pcall(function()
            if VisualSettings.ESP_Storage[player].Billboard then
                VisualSettings.ESP_Storage[player].Billboard:Destroy()
            end
        end)
        VisualSettings.ESP_Storage[player] = nil
        VisualSettings.TeamCache[player] = nil
    end
end

-- 获取玩家颜色（带缓存检测）
local function GetPlayerColor(player)
    if player.TeamColor then return player.TeamColor.Color end
    if player.Team and player.Team.TeamColor then return player.Team.TeamColor.Color end
    return Color3.fromRGB(255, 255, 255)
end

-- 获取玩家当前队伍标识
local function GetTeamIdentifier(player)
    if player.Team then
        return player.Team.Name
    elseif player.TeamColor then
        return tostring(player.TeamColor)
    end
    return "NoTeam"
end

-- 创建ESP函数（新增）
local function CreateESP(player)
    if player == LocalPlayer then return end
    if VisualSettings.ESP_Storage[player] then return end
    
    VisualSettings.ESP_Storage[player] = {
        Tracer = Drawing.new("Line"),
        Highlight = Instance.new("Highlight"),
        Billboard = Instance.new("BillboardGui"),
        NameLabel = Instance.new("TextLabel"),
        InfoLabel = Instance.new("TextLabel")
    }
    
    local hl = VisualSettings.ESP_Storage[player].Highlight
    hl.Name = "RayfieldHighlight"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    
    local bg = VisualSettings.ESP_Storage[player].Billboard
    bg.Name = "RayfieldBillboard"
    bg.Size = UDim2.new(0, 200, 0, 60)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    
    local nameLbl = VisualSettings.ESP_Storage[player].NameLabel
    nameLbl.Parent = bg
    nameLbl.Size = UDim2.new(1, 0, 0, 20)
    nameLbl.Position = UDim2.new(0,0,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextStrokeTransparency = 0.5
    nameLbl.TextSize = 14
    nameLbl.Font = Enum.Font.SourceSansBold
    
    local infoLbl = VisualSettings.ESP_Storage[player].InfoLabel
    infoLbl.Parent = bg
    infoLbl.Size = UDim2.new(1, 0, 0, 30)
    infoLbl.Position = UDim2.new(0,0,0.4,0)
    infoLbl.BackgroundTransparency = 1
    infoLbl.TextStrokeTransparency = 0.5
    infoLbl.TextSize = 12
    infoLbl.Font = Enum.Font.SourceSans
    infoLbl.TextColor3 = Color3.new(1,1,1)
    
    -- 缓存当前队伍
    VisualSettings.TeamCache[player] = GetTeamIdentifier(player)
end

-- 刷新单个玩家ESP（用于队伍变化）
local function RefreshPlayerESP(player)
    ClearVisual(player)
    if VisualSettings.Enabled then
        task.defer(function()
            CreateESP(player)
        end)
    end
end

VisualTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = function(Value)
       VisualSettings.Enabled = Value
       ActiveFeatures.ESP = Value
       UpdateFeatureList()
    
       if Value then
           -- 立即为所有现有玩家创建ESP
           for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer then
                   CreateESP(player)
               end
           end
       else
           for _, player in pairs(Players:GetPlayers()) do
               ClearVisual(player)
           end
       end
   end,
})

local VisualDetailSection = VisualTab:CreateSection("Show")

VisualTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Flag = "ShowTracers",
   Callback = function(Value)
       VisualSettings.ShowTracers = Value
       ActiveFeatures.Tracers = Value
       UpdateFeatureList()
   end,
})

VisualTab:CreateToggle({
   Name = "Health",
   CurrentValue = false,
   Flag = "ShowHealth",
   Callback = function(Value)
       VisualSettings.ShowHealth = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Distance",
   CurrentValue = false,
   Flag = "ShowDistance",
   Callback = function(Value)
       VisualSettings.ShowDistance = Value
   end,
})

--------------------------------------------------------------------
-- [ESP事件处理] - 新增：处理新玩家加入
--------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
    if VisualSettings.Enabled then
        task.defer(function()
            CreateESP(player)
        end)
    end
     
    -- 监听角色加载
    player.CharacterAdded:Connect(function(char)
        if VisualSettings.Enabled and VisualSettings.ESP_Storage[player] then
            task.defer(function()
                local espObj = VisualSettings.ESP_Storage[player]
                if espObj and espObj.Highlight then
                    espObj.Highlight.Parent = char
                end
                if espObj and espObj.Billboard and char:FindFirstChild("Head") then
                    espObj.Billboard.Adornee = char.Head
                    espObj.Billboard.Parent = char
                end
            end)
        end
    end)
end)

-- 为现有玩家添加角色监听
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            if VisualSettings.Enabled and VisualSettings.ESP_Storage[player] then
                task.defer(function()
                    local espObj = VisualSettings.ESP_Storage[player]
                    if espObj and espObj.Highlight then
                        espObj.Highlight.Parent = char
                    end
                    if espObj and espObj.Billboard and char:FindFirstChild("Head") then
                        espObj.Billboard.Adornee = char.Head
                        espObj.Billboard.Parent = char
                    end
                end)
            end
        end)
    end
end

Players.PlayerRemoving:Connect(function(player)
    ClearVisual(player)
end)

-- 队伍变化检测循环（低频）
task.spawn(function()
    while task.wait(1) do
        if VisualSettings.Enabled then
            for player, _ in pairs(VisualSettings.ESP_Storage) do
                if player and player.Parent then
                    local currentTeam = GetTeamIdentifier(player)
                    if VisualSettings.TeamCache[player] ~= currentTeam then
                        -- 队伍发生变化，刷新ESP颜色
                        VisualSettings.TeamCache[player] = currentTeam
                        if VisualSettings.ESP_Storage[player] then
                            local color = GetPlayerColor(player)
                            pcall(function()
                                VisualSettings.ESP_Storage[player].Highlight.FillColor = color
                                VisualSettings.ESP_Storage[player].NameLabel.TextColor3 = color
                                VisualSettings.ESP_Storage[player].Tracer.Color = color
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 清理无效ESP对象（低频）
task.spawn(function()
    while task.wait(5) do
        if VisualSettings.Enabled then
            local toRemove = {}
            for player, espObj in pairs(VisualSettings.ESP_Storage) do
                if not player or not player.Parent then
                    table.insert(toRemove, player)
                end
            end
            for _, player in pairs(toRemove) do
                ClearVisual(player)
            end
        end
    end
end)

--------------------------------------------------------------------
-- [ESP渲染循环] - 优化性能
--------------------------------------------------------------------
local ESPUpdateCounter = 0
RunService.RenderStepped:Connect(function()
    if not VisualSettings.Enabled then return end
    
    ESPUpdateCounter = ESPUpdateCounter + 1
    local fullUpdate = (ESPUpdateCounter % 3 == 0) -- 每3帧进行一次完整更新

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local viewportCenter = Camera.ViewportSize

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then
            if VisualSettings.ESP_Storage[player] then
                pcall(function()
                    VisualSettings.ESP_Storage[player].Tracer.Visible = false
                    VisualSettings.ESP_Storage[player].Highlight.Enabled = false
                    VisualSettings.ESP_Storage[player].Billboard.Enabled = false
                end)
            end
            continue
        end
        
        local head = char.Head
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        
        -- 距离检测
        local dist = 0
        if myRoot then
            dist = (myRoot.Position - root.Position).Magnitude
            if dist > VisualSettings.RenderDistance then
                if VisualSettings.ESP_Storage[player] then
                    pcall(function()
                        VisualSettings.ESP_Storage[player].Tracer.Visible = false
                        VisualSettings.ESP_Storage[player].Highlight.Enabled = false
                        VisualSettings.ESP_Storage[player].Billboard.Enabled = false
                    end)
                end
                continue
            end
        end

        -- 确保ESP已创建
        if not VisualSettings.ESP_Storage[player] then
            CreateESP(player)
        end

        local espObj = VisualSettings.ESP_Storage[player]
        if not espObj then continue end
        
        local color = GetPlayerColor(player)

        -- 启用组件
        pcall(function()
            espObj.Highlight.Enabled = true
            espObj.Billboard.Enabled = true
        end)

        -- 完整更新（每3帧）
        if fullUpdate then
            pcall(function()
                if espObj.Highlight.Parent ~= char then
                    espObj.Highlight.Parent = char
                end
                espObj.Highlight.FillColor = color
                espObj.Highlight.OutlineColor = Color3.new(1,1,1)

                if espObj.Billboard.Adornee ~= head then
                    espObj.Billboard.Adornee = head
                    espObj.Billboard.Parent = char
                end
                
                espObj.NameLabel.Text = player.Name
                espObj.NameLabel.TextColor3 = color

                local infoText = ""
                if VisualSettings.ShowHealth and hum then
                    local hp = math.floor(hum.Health)
                    infoText = infoText .. "[HP: " .. hp .. "] "
                end
                
                if myRoot and VisualSettings.ShowDistance then
                    infoText = infoText .. "[" .. math.floor(dist) .. "m]"
                end
                espObj.InfoLabel.Text = infoText
            end)
        end

        -- Tracer更新（每帧，因为位置变化快）
        local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if VisualSettings.ShowTracers and onScreen then
            pcall(function()
                espObj.Tracer.Visible = true
                espObj.Tracer.Color = color
                espObj.Tracer.Thickness = 1
                espObj.Tracer.From = Vector2.new(viewportCenter.X / 2, viewportCenter.Y)
                espObj.Tracer.To = Vector2.new(vec.X, vec.Y)
            end)
        else
            pcall(function()
                espObj.Tracer.Visible = false
            end)
        end
    end
end)

--------------------------------------------------------------------
-- [Vehicle Tab]
--------------------------------------------------------------------
local VehicleSection = VehicleTab:CreateSection("Modification")

VehicleTab:CreateToggle({
   Name = "Enable Speed & Stabilizer",
   CurrentValue = false,
   Flag = "VehicleMod",
   Callback = function(Value)
       _G.VehicleModEnabled = Value
       ActiveFeatures.VehicleMod = Value
       UpdateFeatureList()
   end,
})

VehicleTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {0.1, 5},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1.5,
   Callback = function(Value)
       _G.VehicleSpeedMult = Value
   end,
})

VehicleTab:CreateSlider({
   Name = "Turn Sensitivity",
   Range = {0.01, 0.1},
   Increment = 0.01,
   Suffix = "",
   CurrentValue = 0.02,
   Callback = function(Value)
       _G.VehicleTurnSpeed = Value
   end,
})

-- 载具物理循环
RunService.Heartbeat:Connect(function()
    if not _G.VehicleModEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local vehicleModel = seat.Parent
        local primaryPart = vehicleModel.PrimaryPart or vehicleModel:FindFirstChild("Body") or vehicleModel:FindFirstChild("Hull")
        
        if primaryPart then
            local currentPivot = vehicleModel:GetPivot()
            local newPivot = currentPivot
            
            -- 1. 直线加速
            if seat.Throttle ~= 0 then
                local moveVector = currentPivot.LookVector * (seat.Throttle * _G.VehicleSpeedMult)
                newPivot = newPivot + moveVector
            end
            
            -- 2. 转向修正
            if seat.Steer ~= 0 then
                local rotateStep = -seat.Steer * _G.VehicleTurnSpeed
                newPivot = newPivot * CFrame.Angles(0, rotateStep, 0)
            end
            
            -- 3. 应用位移
            if seat.Throttle ~= 0 or seat.Steer ~= 0 then
                vehicleModel:PivotTo(newPivot)
            end
            
            -- 4. 强制稳定 (防止翻车)
            primaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

--------------------------------------------------------------------
-- [Other Tab] (Config System & Tools) - 完美修复版
--------------------------------------------------------------------
local OtherSection = OtherTab:CreateSection("UI Setting")

OtherTab:CreateToggle({
   Name = "Show Feature List",
   CurrentValue = false,
   Flag = "ShowList",
   Callback = function(Value)
       ListFrame.Visible = Value
       UpdateFeatureList()
   end,
})

local ConfigSection = OtherTab:CreateSection("Configuration System")

local ConfigNameInput = ""
local ConfigFolder = "CatKing_Configs" -- 确保文件夹名称正确

-- 1. 确保文件夹存在
pcall(function()
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
end)

OtherTab:CreateInput({
   Name = "Config Name",
   PlaceholderText = "Enter name...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       ConfigNameInput = Text
   end,
})

OtherTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        local name = ConfigNameInput
        if name == "" or name == nil then
            -- 自动命名逻辑
            local count = 0
            pcall(function()
                local files = listfiles(ConfigFolder)
                count = #files + 1
            end)
            name = "Config " .. count
        end
        
        local SaveData = {
            Aimbot = AimbotSettings,
            Visual = VisualSettings,
            Features = ActiveFeatures,
            Mobile = MobileSettings,
            Vehicle = {Speed = _G.VehicleSpeedMult, Turn = _G.VehicleTurnSpeed}
        }
        
        local json = HttpService:JSONEncode(SaveData)
        writefile(ConfigFolder .. "/" .. name .. ".json", json)
        
        Rayfield:Notify({
            Title = "Configuration Saved",
            Content = "Saved as: " .. name,
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- 2. 修复：安全的配置文件获取函数 (兼容所有手机注入器)
local function GetConfigs()
    local names = {}
    pcall(function()
        if isfolder(ConfigFolder) then
            local files = listfiles(ConfigFolder)
            for _, path in pairs(files) do
                -- 使用 match 提取文件名，无论路径是 /storage/... 还是 workspace/...
                local file = path:match("([^/]+)$")
                if file then
                     -- 移除 .json 后缀
                    if file:sub(-5) == ".json" then
                        file = file:sub(1, -6)
                    end
                    table.insert(names, file)
                end
            end
        end
    end)
    return names
end

local ConfigList = GetConfigs()
if #ConfigList == 0 then table.insert(ConfigList, "None") end

local SelectedConfigToLoad = ConfigList[1]

local LoadDropdown = OtherTab:CreateDropdown({
   Name = "Select Config",
   Options = ConfigList,
   CurrentOption = SelectedConfigToLoad, 
   Flag = "ConfigLoader",
   Callback = function(Option)
       if Option and Option[1] then
           SelectedConfigToLoad = Option[1]
       end
   end,
})

OtherTab:CreateButton({
    Name = "Load Selected Config",
    Callback = function()
        if not SelectedConfigToLoad or SelectedConfigToLoad == "None" then
             Rayfield:Notify({Title = "Error", Content = "Please select a valid config.", Duration = 2})
             return 
        end
        
        local success, content = pcall(function() 
             return readfile(ConfigFolder .. "/" .. SelectedConfigToLoad .. ".json")
        end)
        
        if not success then 
            Rayfield:Notify({Title = "Error", Content = "Failed to read file.", Duration = 2})
            return 
        end
 
        local data = HttpService:JSONDecode(content)
        
        -- 恢复设置
        if data.Aimbot then 
            for k,v in pairs(data.Aimbot) do AimbotSettings[k] = v end
            if AimbotSettings.FOV then FOVCircle.Radius = AimbotSettings.FOV end
        end
        
        if data.Visual then 
             VisualSettings.Enabled = data.Visual.Enabled
             VisualSettings.ShowTracers = data.Visual.ShowTracers
             VisualSettings.ShowHealth = data.Visual.ShowHealth
             VisualSettings.ShowDistance = data.Visual.ShowDistance
        end
        
        if data.Mobile then
             MobileSettings.FOV = data.Mobile.FOV
             MobileFOVCircle.Radius = MobileSettings.FOV
             -- 恢复偏移量
             if data.Mobile.OffsetX then MobileSettings.OffsetX = data.Mobile.OffsetX end
             if data.Mobile.OffsetY then MobileSettings.OffsetY = data.Mobile.OffsetY end
        end
 
        Rayfield:Notify({
            Title = "Configuration Loaded",
            Content = "Settings loaded from: " .. SelectedConfigToLoad,
            Duration = 3,
            Image = 4483362458,
         })
    end,
})

-- [新增] 删除配置功能
OtherTab:CreateButton({
    Name = "Delete Selected Config",
    Callback = function()
        if not SelectedConfigToLoad or SelectedConfigToLoad == "None" then
             Rayfield:Notify({Title = "Error", Content = "Please select a config to delete.", Duration = 2})
             return 
        end

        local filePath = ConfigFolder .. "/" .. SelectedConfigToLoad .. ".json"
        
        local success, err = pcall(function()
            if isfile(filePath) then
                delfile(filePath)
            end
        end)
        
        if success then
            Rayfield:Notify({
                Title = "Config Deleted", 
                Content = "Deleted: " .. SelectedConfigToLoad, 
                Duration = 2,
                Image = 4483362458
            })
            
            -- 自动刷新列表
            local newlist = GetConfigs()
            if #newlist == 0 then 
                table.insert(newlist, "None")
                SelectedConfigToLoad = "None"
            else
                SelectedConfigToLoad = newlist[1]
            end
            LoadDropdown:Refresh(newlist)
        else
            Rayfield:Notify({Title = "Error", Content = "Failed to delete file.", Duration = 2})
        end
    end,
})

OtherTab:CreateButton({
   Name = "Refresh Config List",
   Callback = function()
       local newlist = GetConfigs()
       local msg = "Found " .. #newlist .. " configs."
       
       if #newlist == 0 then 
           table.insert(newlist, "None") 
           msg = "No configs found in folder."
       end
       
       LoadDropdown:Refresh(newlist)
       Rayfield:Notify({Title = "Refreshed", Content = msg, Duration = 2})
   end,
})

local UtilSection = OtherTab:CreateSection("Tools")

OtherTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.Health = 0
       end
   end,
})

OtherTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
       game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
   end,
})

-- 无限子弹循环 (低频优化)
task.spawn(function()
    while task.wait(0.5) do 
        if _G.InfiniteAmmoEnabled then
             local Character = LocalPlayer.Character
             if Character then
                 local Tool = Character:FindFirstChildWhichIsA("Tool")
                 if Tool then
                     local LocalAmmoFolder = Tool:FindFirstChild("LocalTAmmo")
                     if LocalAmmoFolder then
                         for _, folder in pairs(LocalAmmoFolder:GetChildren()) do
                             if folder:FindFirstChild("Ammo") then
                                 if folder.Ammo.MaxValue < 9999 then
                                     folder.Ammo.MaxValue = 9999
                                 end
                                 folder.Ammo.Value = 9999
                             end
                             if folder:FindFirstChild("Stored") then
                                  folder.Stored.MaxValue = 9999
                                  folder.Stored.Value = 9999
                             end
                          end
                      end
                  end
             end
        end
    end
end)

Rayfield:Notify({
   Title = "System Loaded",
   Content = "Mobile Aimbot & Config System Ready.",
   Duration = 5,
   Image = 4483362458,
})
