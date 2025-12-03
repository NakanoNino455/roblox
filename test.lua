local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Cat-King Hub | V3.0 Ultimate Fix", 
   LoadingTitle = "Loading Core...",
   LoadingSubtitle = "BRM5 Tactical Solution",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CatKing_Configs",
      FileName = "CatKing_V3"
   },
   KeySystem = false, 
})

-- 服务引用
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- [全局变量设置]
--------------------------------------------------------------------
_G.AimOffsetX = 0      -- X轴偏移 (左右修正)
_G.AimOffsetY = 0      -- Y轴偏移 (上下修正)
_G.Prediction = 0.13   -- 预判系数 (BRM5建议 0.12 - 0.15)
_G.Smoothness = 0.3    -- 平滑度 (越小越顺滑，越大越锁死)

local MobileSettings = {
    Enabled = false,
    Active = false,
    FOV = 120,
    Target = nil
}

-- 绘制圆形和准星
local MobileFOVCircle = Drawing.new("Circle")
MobileFOVCircle.Thickness = 2
MobileFOVCircle.NumSides = 40
MobileFOVCircle.Filled = false
MobileFOVCircle.Transparency = 0.8
MobileFOVCircle.Visible = false
MobileFOVCircle.Radius = MobileSettings.FOV
MobileFOVCircle.Color = Color3.fromRGB(0, 255, 0) -- 绿色更显眼

local OffsetCrosshairH = Drawing.new("Line") -- 横线
OffsetCrosshairH.Thickness = 2
OffsetCrosshairH.Color = Color3.fromRGB(255, 0, 0)
OffsetCrosshairH.Visible = false

local OffsetCrosshairV = Drawing.new("Line") -- 竖线
OffsetCrosshairV.Thickness = 2
OffsetCrosshairV.Color = Color3.fromRGB(255, 0, 0)
OffsetCrosshairV.Visible = false

-- 颜色循环
task.spawn(function()
    while task.wait(0.1) do
        if MobileSettings.Enabled then
             -- 呼吸灯效果
             local t = tick() % 1
             MobileFOVCircle.Color = Color3.fromHSV(0.35, 1, 0.5 + 0.5*t) 
        end
    end
end)

--------------------------------------------------------------------
-- [UI Setup - 手机按钮 & 菜单]
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimAssistOverlay"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- 手机拖拽按钮
local MobileBtnFrame = Instance.new("Frame")
MobileBtnFrame.Name = "TriggerFrame"
MobileBtnFrame.Parent = ScreenGui
MobileBtnFrame.Size = UDim2.new(0, 65, 0, 65)
MobileBtnFrame.Position = UDim2.new(0.85, 0, 0.55, 0)
MobileBtnFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileBtnFrame.BackgroundTransparency = 0.3
MobileBtnFrame.BorderSizePixel = 2
MobileBtnFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
MobileBtnFrame.Visible = false
MobileBtnFrame.Active = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = MobileBtnFrame

local MobileBtn = Instance.new("TextButton")
MobileBtn.Parent = MobileBtnFrame
MobileBtn.Size = UDim2.new(1, 0, 1, 0)
MobileBtn.BackgroundTransparency = 1
MobileBtn.Text = "AIM"
MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileBtn.Font = Enum.Font.GothamBlack
MobileBtn.TextSize = 18

-- 锁定状态提示
local LockLabel = Instance.new("TextLabel")
LockLabel.Parent = ScreenGui
LockLabel.Size = UDim2.new(0, 200, 0, 50)
LockLabel.Position = UDim2.new(0.5, -100, 0.8, 0)
LockLabel.BackgroundTransparency = 1
LockLabel.Font = Enum.Font.GothamBold
LockLabel.Text = "LOCKED"
LockLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
LockLabel.TextSize = 24
LockLabel.Visible = false

-- 按钮拖动逻辑
local dragging, dragInput, dragStart, startPos
MobileBtnFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MobileBtnFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MobileBtnFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MobileBtnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--------------------------------------------------------------------
-- [Rayfield Tabs]
--------------------------------------------------------------------
local MainTab = Window:CreateTab("Combat", nil)

local AimSection = MainTab:CreateSection("Mobile Aimbot V3")

MainTab:CreateToggle({
   Name = "Enable Aimbot Button",
   CurrentValue = false,
   Flag = "MobileEnable",
   Callback = function(Value)
       MobileSettings.Enabled = Value
       MobileBtnFrame.Visible = Value
       if not Value then
           MobileSettings.Active = false
           MobileBtn.Text = "AIM"
           MobileFOVCircle.Visible = false
           OffsetCrosshairH.Visible = false
           OffsetCrosshairV.Visible = false
           LockLabel.Visible = false
       end
   end,
})

MainTab:CreateSlider({
   Name = "Target FOV (Range)",
   Range = {50, 600},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value)
       MobileSettings.FOV = Value
       MobileFOVCircle.Radius = Value
   end,
})

local TuningSection = MainTab:CreateSection("Fine Tuning (Important!)")

MainTab:CreateSlider({
   Name = "Prediction (Bullet Lead)",
   Range = {0, 1},
   Increment = 0.01,
   CurrentValue = 0.13,
   Suffix = "s",
   Callback = function(Value)
       _G.Prediction = Value
   end,
})

MainTab:CreateSlider({
   Name = "Smoothness (Low = Fast)",
   Range = {0.1, 1},
   Increment = 0.1,
   CurrentValue = 0.3,
   Callback = function(Value)
       _G.Smoothness = Value
   end,
})

local OffsetSection = MainTab:CreateSection("Offset Fix (Fix TPS Aim)")

MainTab:CreateSlider({
   Name = "Offset X (Left/Right)",
   Range = {-400, 400},
   Increment = 2,
   CurrentValue = 0,
   Suffix = "px",
   Callback = function(Value)
       _G.AimOffsetX = Value
   end,
})

MainTab:CreateSlider({
   Name = "Offset Y (Up/Down)",
   Range = {-400, 400},
   Increment = 2,
   CurrentValue = 0,
   Suffix = "px",
   Callback = function(Value)
       _G.AimOffsetY = Value
   end,
})

--------------------------------------------------------------------
-- [核心算法逻辑]
--------------------------------------------------------------------

MobileBtn.MouseButton1Click:Connect(function()
    MobileSettings.Active = not MobileSettings.Active
    if MobileSettings.Active then
        MobileBtn.Text = "ON"
        MobileBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        MobileBtn.Text = "AIM"
        MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        LockLabel.Visible = false
    end
end)

-- 检测可见性
local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    return workspace:Raycast(origin, direction, params) == nil
end

-- 获取最近敌人（带偏移计算）
local function GetClosestTarget(centerPos)
    local bestTarget = nil
    local bestDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            -- 排除队友
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end
            if player.Character.Humanoid.Health <= 0 then continue end
            
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                -- 计算距离准星（偏移后）的距离
                local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                
                if distToCrosshair < bestDist and distToCrosshair <= MobileSettings.FOV then
                    if IsVisible(head) then
                        bestDist = distToCrosshair
                        bestTarget = player
                    end
                end
            end
        end
    end
    return bestTarget
end

-- 渲染循环
RunService.RenderStepped:Connect(function()
    -- 1. 计算偏移后的中心点 (这就是你真实的准星位置)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local realCrosshairPos = screenCenter + Vector2.new(_G.AimOffsetX, _G.AimOffsetY)

    -- 2. 绘制 UI
    if MobileSettings.Enabled then
        MobileFOVCircle.Visible = true
        MobileFOVCircle.Position = realCrosshairPos -- 圆圈跟随偏移
        
        -- 绘制红色十字准星，帮助你对齐游戏准星
        OffsetCrosshairH.Visible = true
        OffsetCrosshairH.From = Vector2.new(realCrosshairPos.X - 15, realCrosshairPos.Y)
        OffsetCrosshairH.To = Vector2.new(realCrosshairPos.X + 15, realCrosshairPos.Y)
        
        OffsetCrosshairV.Visible = true
        OffsetCrosshairV.From = Vector2.new(realCrosshairPos.X, realCrosshairPos.Y - 15)
        OffsetCrosshairV.To = Vector2.new(realCrosshairPos.X, realCrosshairPos.Y + 15)
    else
        MobileFOVCircle.Visible = false
        OffsetCrosshairH.Visible = false
        OffsetCrosshairV.Visible = false
    end

    -- 3. 自瞄逻辑
    if MobileSettings.Active and MobileSettings.Enabled then
        local target = GetClosestTarget(realCrosshairPos)
        
        if target and target.Character and target.Character:FindFirstChild("Head") then
            LockLabel.Visible = true
            LockLabel.Text = "LOCKED: " .. target.Name
            
            local head = target.Character.Head
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            
            -- [预判算法]
            local targetPos = head.Position
            if root then
                -- 根据敌人速度添加预判量
                targetPos = targetPos + (root.Velocity * _G.Prediction)
            end

            -- [TPS 视角修正算法 V3]
            -- 计算从相机到目标的方向
            local currentCFrame = Camera.CFrame
            local lookAtCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
            
            -- 将像素偏移转换为旋转角度 (Sensitivity)
            -- 这个数值越小，偏移调节越精细
            local pixelToAngle = 0.0012 
            
            -- 反向补偿：为了让敌人出现在屏幕右边，相机必须向左看
            local x_Correction = -(_G.AimOffsetX * pixelToAngle)
            local y_Correction = -(_G.AimOffsetY * pixelToAngle)
            
            local finalCFrame = lookAtCFrame * CFrame.Angles(y_Correction, x_Correction, 0)
            
            -- [平滑算法] 使用 Smoothness 控制 Lerp 速度
            -- 值越小越滑，值越大越硬
            Camera.CFrame = currentCFrame:Lerp(finalCFrame, _G.Smoothness)
        else
            LockLabel.Visible = false
        end
    else
        LockLabel.Visible = false
    end
end)

Rayfield:Notify({
   Title = "Ultimate Fix Loaded",
   Content = "Align the RED crosshair with the WHITE game crosshair!",
   Duration = 5,
   Image = 4483362458,
})
