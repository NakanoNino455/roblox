--[[ 

    SCP Roleplay - Cat King v1.8 (Custom Config Edition)

    UI Library: YC GUI

    配置: 使用用户自定义的 Config 系统

    保留: Team Check, Hitbox Physics/Face Fix, Aimbot Logic

    修改: ESP 与 Name Tags 分离

]]



-- 1. 加载 UI 库

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NakanoNino455/roblox/refs/heads/main/UI.lua"))() 

Library.Config.UIVisible = false -- 启动隐藏



-- 2. 创建主控

local MainControl = Library:CreateMainControl("CatKing SCP v2.4")

local MainWin = Library:CreateChildWindow("Main")

local CombatWin = Library:CreateChildWindow("Aimbot")

local MobileWin = Library:CreateChildWindow("Mobile Aim")

local SCPWin = Library:CreateChildWindow("SCP")

local MiscWin = Library:CreateChildWindow("Other")

local ConfigWin = Library:CreateChildWindow("Config")



-- 3. 绑定窗口

MainControl:BindWindow("Main", true)

MainControl:BindWindow("Aimbot", false)

MainControl:BindWindow("Mobile Aim", false)

MainControl:BindWindow("SCP", false)

MainControl:BindWindow("Other", false)

MainControl:BindWindow("Config", false)



Library:SetupSettings()

MainControl:BindWindow("UI Settings", false)



--------------------------------------------------------------------------------

-- [全局变量]

--------------------------------------------------------------------------------

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera



_G.WallCheckSetting = true

_G.WeaponCheckEnabled = false 

_G.ESPActive = false 

_G.NameTagsActive = false -- [新增]

_G.TeamCheckEnabled = false 

_G.HitboxSize = 9 

_G.HitboxTransparency = 10

_G.HitboxActive = false 

_G.HitboxTeamCheck = false 
_G.SilentAimTeamSettings = {
    ["Class-D"] = true,
    ["Chaos Insurgency"] = true,
    ["Scientific Department"] = true,
    ["Security Department"] = true,
    ["Intelligence Agency"] = true,
    ["Mobile Task Force"] = true,
    ["Rapid Response Team"] = true,
    ["Medical Department"] = true,
    ["Administrative Department"] = true,
    ["Internal Security Department"] = true
}



_G.MobileGlobal = { IsAimbotGuiOn = false, IsFOVOn = false, IsCrossOn = false, AimbotActive = false }



_G.HeadLock = {

    FOVCircle = nil, Crosshair = nil,

    Settings = { FOV=400, MaxDistance=1000, PredictionStrength=0.2, Smoothness=3, WallCheck=true, ShowCrosshair=false, StickyLock=true, TeamCheck=false, LockMode="Instant lock" },

    LockedTarget = nil, RenderConnection = nil

}



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



-- [阵营检测]

local VillainTeams = { ["Class-D"]=true, ["Class - D"]=true, ["Chaos Insurgency"]=true, ["The Chaos Insurgency"]=true }

local HeroTeams = { ["Scientific Department"]=true, ["Security Department"]=true, ["Mobile Task Force"]=true, ["Intelligence Agency"]=true, ["Rapid Response Team"]=true, ["Medical Department"]=true, ["Administrative Department"]=true, ["Internal Security Department"]=true }



local function isEnemy(player)

    if not _G.TeamCheckEnabled then return true end

    if not player or not player.Team or not LocalPlayer.Team then return true end

    local myTeam = LocalPlayer.Team.Name; local theirTeam = player.Team.Name

    if myTeam == theirTeam then return false end

    local amIVillain = VillainTeams[myTeam]; local amIHero = HeroTeams[myTeam]

    local areTheyVillain = VillainTeams[theirTeam]; local areTheyHero = HeroTeams[theirTeam]

    if amIVillain and areTheyHero then return true end

    if amIHero and areTheyVillain then return true end

    return false

end



-- [Wall Check]

local function checkVisible(part)

    if not _G.HeadLock.Settings.WallCheck then return true end

    local origin = Camera.CFrame.Position

    local direction = part.Position - origin

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent, Camera, workspace:FindFirstChild("RaycastIgnore")}

    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    return result == nil

end



local function hasWeapon()

    if not _G.WeaponCheckEnabled then return true end

    if not LocalPlayer.Character then return false end

    local t = LocalPlayer.Character:FindFirstChildOfClass("Tool")

    if not t then return false end

    for _,n in ipairs(weaponsList) do if t.Name==n or string.find(t.Name,n) then return true end end

    return false

end



local function getBestTarget()

    local bT, bS = nil, math.huge

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do

        if p~=LocalPlayer and p.Character and isEnemy(p) then

            local head = p.Character:FindFirstChild("Head")

            local hum = p.Character:FindFirstChild("Humanoid")

            if head and hum and hum.Health > 0 then

                local sPos, onS = Camera:WorldToViewportPoint(head.Position)

                if onS and checkVisible(head) then

                    local d2d = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude

                    if d2d <= _G.HeadLock.Settings.FOV and d2d < bS then bS = d2d; bT = {Head=head, Player=p, Character=p.Character} end

                end

            end

        end

    end

    return bT

end



-- ==================================================================

-- [UI 内容]

-- ==================================================================



-- Main

local NameHideConnection = nil 

local function forceHideName()

    local char = LocalPlayer.Character; if not char then return end

    local hum = char:FindFirstChild("Humanoid"); local head = char:FindFirstChild("Head")

    if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; hum.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff; hum.NameOcclusion=Enum.NameOcclusion.NoOcclusion; hum.NameDisplayDistance=0 end

    if head then for _,c in pairs(head:GetChildren()) do if c:IsA("BillboardGui") or c:IsA("SurfaceGui") then c.Enabled=false end end end

end

MainWin:CreateModule("Hidden Name", function(v)

    if v then if NameHideConnection then NameHideConnection:Disconnect() end NameHideConnection=RunService.RenderStepped:Connect(forceHideName)

    else if NameHideConnection then NameHideConnection:Disconnect(); NameHideConnection=nil end; local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer; c.Humanoid.HealthDisplayType=Enum.HumanoidHealthDisplayType.DisplayWhenDamaged; c.Humanoid.NameDisplayDistance=100 end; if c and c:FindFirstChild("Head") then for _,o in pairs(c.Head:GetChildren()) do if o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=true end end end end

end)



-- [分离后的 ESP 和 Name Tags]

local highlights = {}

local espLabels = {}



-- 颜色定义 (共用)

local TEAM_COLORS = {["Class-D"]=Color3.fromRGB(255,165,0), ["Class - D"]=Color3.fromRGB(255,165,0), ["Scientific Department"]=Color3.fromRGB(0,0,255), ["Security Department"]=Color3.fromRGB(255,255,255), ["Mobile Task Force"]=Color3.fromRGB(0,0,139), ["Intelligence Agency"]=Color3.fromRGB(255,0,0), ["Rapid Response Team"]=Color3.fromRGB(255,50,50), ["Chaos Insurgency"]=Color3.fromRGB(0,0,0), ["Medical Department"]=Color3.fromRGB(0,191,255), ["Administrative Department"]=Color3.fromRGB(0,255,0), ["Internal Security Department"]=Color3.fromRGB(139,0,0), ["Default"]=Color3.fromRGB(200,200,200)}

local function getCol(p) return (p and p.Team and TEAM_COLORS[p.Team.Name]) or (p and p.Team and p.Team.TeamColor.Color) or TEAM_COLORS["Default"] end



-- 1. ESP (仅高亮)

-- 1. ESP (Refactored to Event-Based)
local ESPConnections = {}

local function AddESP(player)
    if player == LocalPlayer then return end
    
    local function ApplyHighlight(char)
        if not char then return end
        -- Avoid duplicates
        if highlights[char] then highlights[char]:Destroy() end

        task.spawn(function()
            local head = char:WaitForChild("Head", 10)
            if not head then return end
            if not _G.ESPActive then return end -- Double check

            local h = Instance.new("Highlight", char)
            h.FillColor = getCol(player)
            h.OutlineColor = Color3.new(1,1,1)
            h.FillTransparency = 0.6
            h.OutlineTransparency = 0.2
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlights[char] = h
        end)
    end

    if player.Character then ApplyHighlight(player.Character) end
    -- Store connection per player to disconnect cleanly later
    ESPConnections[player] = player.CharacterAdded:Connect(ApplyHighlight)
end

local function RemoveESP(player)
    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end
    if player.Character and highlights[player.Character] then
        highlights[player.Character]:Destroy()
        highlights[player.Character] = nil
    end
end

MainWin:CreateModule("ESP", function(Value)
    _G.ESPActive = Value
    if Value then
        -- Apply to existing
        for _, p in ipairs(Players:GetPlayers()) do
            AddESP(p)
        end
        -- Listen for new
        ESPConnections["PlayerAdded"] = Players.PlayerAdded:Connect(AddESP)
        ESPConnections["PlayerRemoving"] = Players.PlayerRemoving:Connect(RemoveESP)
    else
        -- Clean up connections
        if ESPConnections["PlayerAdded"] then ESPConnections["PlayerAdded"]:Disconnect() end
        if ESPConnections["PlayerRemoving"] then ESPConnections["PlayerRemoving"]:Disconnect() end
        for p, conn in pairs(ESPConnections) do
            if typeof(p) == "Instance" and p:IsA("Player") then
                conn:Disconnect()
            end
        end
        table.clear(ESPConnections)

        -- Clean up highlights
        for char, h in pairs(highlights) do
            if h then h:Destroy() end
        end
        table.clear(highlights)
    end
end)



-- 2. Name Tags (仅名字显示)

-- 2. Name Tags (Refactored to Event-Based)
local NameTagConnections = {}

local function AddNameTag(player)
    if player == LocalPlayer then return end

    local function ApplyTag(char)
        if not char then return end
        if espLabels[char] then espLabels[char]:Destroy() end

        task.spawn(function()
            local head = char:WaitForChild("Head", 10)
            if not head then return end
            if not _G.NameTagsActive then return end

            local b = Instance.new("BillboardGui", char)
            b.Name = "NameESP"
            b.AlwaysOnTop = true
            b.Size = UDim2.new(0,100,0,20)
            b.StudsOffset = Vector3.new(0,2.5,0)
            b.MaxDistance = 2000
            b.Adornee = head

            local l = Instance.new("TextLabel", b)
            l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.Text = player.Name
            l.TextColor3 = getCol(player)
            l.TextScaled = true
            l.Font = Enum.Font.SourceSansBold
            l.TextStrokeTransparency = 0.5

            espLabels[char] = b
            l.Parent = b
            b.Parent = char
        end)
    end

    if player.Character then ApplyTag(player.Character) end
    NameTagConnections[player] = player.CharacterAdded:Connect(ApplyTag)
end

local function RemoveNameTag(player)
    if NameTagConnections[player] then
        NameTagConnections[player]:Disconnect()
        NameTagConnections[player] = nil
    end
    if player.Character and espLabels[player.Character] then
        espLabels[player.Character]:Destroy()
        espLabels[player.Character] = nil
    end
end

MainWin:CreateModule("Name Tags", function(Value)
    _G.NameTagsActive = Value
    if Value then
        for _, p in ipairs(Players:GetPlayers()) do
            AddNameTag(p)
        end
        NameTagConnections["PlayerAdded"] = Players.PlayerAdded:Connect(AddNameTag)
        NameTagConnections["PlayerRemoving"] = Players.PlayerRemoving:Connect(RemoveNameTag)
    else
        if NameTagConnections["PlayerAdded"] then NameTagConnections["PlayerAdded"]:Disconnect() end
        if NameTagConnections["PlayerRemoving"] then NameTagConnections["PlayerRemoving"]:Disconnect() end
        for p, conn in pairs(NameTagConnections) do
            if typeof(p) == "Instance" and p:IsA("Player") then
                conn:Disconnect()
            end
        end
        table.clear(NameTagConnections)

        for char, v in pairs(espLabels) do
            if v then v:Destroy() end
        end
        table.clear(espLabels)
    end
end)



MainWin:CreateModule("Full Bright", function(v) local L=game:GetService("Lighting"); if v then _G.OL={Ambient=L.Ambient, Brightness=L.Brightness, GlobalShadows=L.GlobalShadows, OutdoorAmbient=L.OutdoorAmbient, ClockTime=L.ClockTime, FogEnd=L.FogEnd}; L.Ambient=Color3.new(0.7,0.7,0.7); L.Brightness=1.5; L.GlobalShadows=false; L.OutdoorAmbient=Color3.new(0.7,0.7,0.7); L.ClockTime=12; L.FogEnd=100000 else if _G.OL then for k,val in pairs(_G.OL) do L[k]=val end; _G.OL=nil end end end)

MainWin:CreateModule("Noclip", function(v) if v then _G.Noclip=RunService.Stepped:Connect(function() if LocalPlayer.Character then for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=false end end end end) else if _G.Noclip then _G.Noclip:Disconnect(); _G.Noclip=nil end end end)

MainWin:CreateModule("Infinite Jump", function(v) if v then _G.InfJ=UserInputService.JumpRequest:Connect(function() if LocalPlayer.Character then local r=LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X,50,r.AssemblyLinearVelocity.Z) end end end) else if _G.InfJ then _G.InfJ:Disconnect() end end end)

local Spd={En=false, Val=25}; local SpdMod=MainWin:CreateModule("Speed Boost", function(v) Spd.En=v end); SpdMod:CreateSlider("Sprint Speed", 20,40,25, function(v) Spd.Val=v end); RunService.Heartbeat:Connect(function() if Spd.En and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then local r=LocalPlayer.Character.HumanoidRootPart; local v=LocalPlayer.Character.Humanoid.MoveDirection; if v.Magnitude>0 then r.AssemblyLinearVelocity=Vector3.new(v.X*Spd.Val, r.AssemblyLinearVelocity.Y, v.Z*Spd.Val) end end end)

MainWin:CreateModule("Show Chat", function(v) local c=game:GetService("TextChatService"):FindFirstChild("ChatWindowConfiguration"); if c then c.Enabled=v end end)

MainWin:CreateButton("Get Radio", function() local list=Players:GetPlayers(); if #list<=1 then return end; local targets={}; for _,p in ipairs(list) do if p~=LocalPlayer then table.insert(targets,p) end end; local rP=targets[math.random(1,#targets)]; if rP.Character and rP.Backpack:FindFirstChild("Radio") and LocalPlayer.Character and not LocalPlayer.Backpack:FindFirstChild("Radio") then rP.Backpack.Radio:Clone().Parent=LocalPlayer.Backpack; Library:Notify("Success","Radio Copied",true) end end)



-- Aimbot (PC)

local FOVCircle = Drawing.new("Circle"); FOVCircle.Visible=false; FOVCircle.Thickness=2; FOVCircle.Transparency=0.7; FOVCircle.Radius=400; FOVCircle.NumSides=64; FOVCircle.Filled=false; _G.HeadLock.FOVCircle=FOVCircle

local Crosshair = {Horizontal=Drawing.new("Line"), Vertical=Drawing.new("Line")}; for _,l in pairs(Crosshair) do l.Visible=false; l.Color=Color3.fromRGB(255,0,0); l.Thickness=2; l.Transparency=0.8 end; _G.HeadLock.Crosshair=Crosshair



local function lockToHead(targetData)

    if not targetData then return end

    local head, char = targetData.Head, targetData.Character

    local tPos = head.Position

    if _G.HeadLock.Settings.LockMode == "Forecast Lock" then local r = char:FindFirstChild("HumanoidRootPart"); if r then tPos=tPos+(r.AssemblyLinearVelocity*((tPos-Camera.CFrame.Position).Magnitude/1000)*_G.HeadLock.Settings.PredictionStrength) end end

    local goal = CFrame.lookAt(Camera.CFrame.Position, tPos)

    if _G.HeadLock.Settings.LockMode == "Smooth lock" then Camera.CFrame = Camera.CFrame:Lerp(goal, 1/_G.HeadLock.Settings.Smoothness) else Camera.CFrame = goal end

end



local AimMod = CombatWin:CreateModule("Aimbot (PC)", function(v)

    if v then

        _G.HeadLock.RenderConnection = RunService.RenderStepped:Connect(function()

            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

            FOVCircle.Position = center; FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

            if _G.HeadLock.Settings.ShowCrosshair then Crosshair.Horizontal.Visible=true; Crosshair.Vertical.Visible=true; Crosshair.Horizontal.From=Vector2.new(center.X-10,center.Y); Crosshair.Horizontal.To=Vector2.new(center.X+10,center.Y); Crosshair.Vertical.From=Vector2.new(center.X,center.Y-10); Crosshair.Vertical.To=Vector2.new(center.X,center.Y+10) else Crosshair.Horizontal.Visible=false; Crosshair.Vertical.Visible=false end

            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and hasWeapon() then

                if _G.HeadLock.Settings.StickyLock and _G.HeadLock.LockedTarget then

                    local t = _G.HeadLock.LockedTarget

                    if t.Head and t.Head.Parent and t.Character.Humanoid.Health>0 and isEnemy(t.Player) then lockToHead(t) else _G.HeadLock.LockedTarget=getBestTarget() end

                else _G.HeadLock.LockedTarget=getBestTarget(); if _G.HeadLock.LockedTarget then lockToHead(_G.HeadLock.LockedTarget) end end

                if _G.HeadLock.LockedTarget then Crosshair.Horizontal.Color=Color3.new(0,1,0); Crosshair.Vertical.Color=Color3.new(0,1,0) else Crosshair.Horizontal.Color=Color3.new(1,0,0); Crosshair.Vertical.Color=Color3.new(1,0,0) end

            else _G.HeadLock.LockedTarget=nil; Crosshair.Horizontal.Color=Color3.new(1,0,0); Crosshair.Vertical.Color=Color3.new(1,0,0) end

        end)

    else if _G.HeadLock.RenderConnection then _G.HeadLock.RenderConnection:Disconnect() end; FOVCircle.Visible=false; Crosshair.Horizontal.Visible=false; Crosshair.Vertical.Visible=false end

end, true)



AimMod:CreateDropdown("Lock Mode", {"Instant lock", "Smooth lock", "Forecast Lock"}, function(v) _G.HeadLock.Settings.LockMode = v end)

AimMod:CreateSlider("FOV", 50, 800, 80, function(v) _G.HeadLock.Settings.FOV = v; FOVCircle.Radius = v end)

AimMod:CreateSlider("Smoothness", 1, 20, 3, function(v) _G.HeadLock.Settings.Smoothness = v end)

AimMod:CreateSlider("Distance", 50, 3000, 1000, function(v) _G.HeadLock.Settings.MaxDistance = v end)

AimMod:CreateSlider("Prediction", 0, 100, 20, function(v) _G.HeadLock.Settings.PredictionStrength = v/100 end)

AimMod:CreateSwitch("Show FOV", function(v) if _G.HeadLock.RenderConnection then FOVCircle.Visible=v end end, false)

AimMod:CreateSwitch("Show Crosshair", function(v) _G.HeadLock.Settings.ShowCrosshair = v; if not v then Crosshair.Horizontal.Visible=false; Crosshair.Vertical.Visible=false end end, false)

AimMod:CreateSwitch("Wall Check", function(v) _G.HeadLock.Settings.WallCheck = v; _G.WallCheckSetting = v end, true)

AimMod:CreateSwitch("Sticky Lock", function(v) _G.HeadLock.Settings.StickyLock = v end, false)

AimMod:CreateSwitch("Team Check", function(v) _G.TeamCheckEnabled = v; _G.HeadLock.Settings.TeamCheck = v end, false)

CombatWin:CreateModule("Gun Check (PC & Mobile)", function(v) _G.WeaponCheckEnabled = v end)



-- Mobile

local MFOV = Drawing.new("Circle"); MFOV.Visible=false; MFOV.Thickness=2; MFOV.Radius=80; MFOV.Filled=false

local MX = Drawing.new("Line"); local MY = Drawing.new("Line"); MX.Visible=false; MY.Visible=false; MX.Color=Color3.new(1,1,1); MY.Color=Color3.new(1,1,1)

RunService.RenderStepped:Connect(function()

    local c = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    MFOV.Position = c; MFOV.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    MFOV.Visible = _G.MobileGlobal.IsFOVOn

    MX.Visible = _G.MobileGlobal.IsCrossOn; MY.Visible = _G.MobileGlobal.IsCrossOn

    if _G.MobileGlobal.IsCrossOn then MX.From=Vector2.new(c.X-10,c.Y); MX.To=Vector2.new(c.X+10,c.Y); MY.From=Vector2.new(c.X,c.Y-10); MY.To=Vector2.new(c.X,c.Y+10) end

end)

local function ResetCharacter(char) if char and char:FindFirstChild("Head") then char.Head.Size = Vector3.new(1.2,1.2,1.2); char.Head.Transparency = 0; char.Head.CanCollide = true; char.Head.Massless = false; for _,o in pairs(char.Head:GetChildren()) do if o:IsA("Decal") or o:IsA("Texture") then o.Transparency=0 end end end end



-- [修复] 优化后的 Hitbox 模块：状态检测 + 透明度修复 + 视角剔除修复

local HitMod = MobileWin:CreateModule("Enable Silent Aim", function(v)
    _G.HitboxActive = v
    if v then
        _G.HitboxLoop = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    local hum = p.Character:FindFirstChild("Humanoid") -- 获取 Humanoid 以检测生命

                    local isTarget = false

                    if head and hum and hum.Health > 0 then
                        -- 团队检测逻辑
                        local tName = p.Team and p.Team.Name or ""
                        local checkName = tName
                        if tName == "Class - D" then checkName = "Class-D" end -- 兼容 Class - D

                        local teamAllowed = _G.SilentAimTeamSettings[checkName]
                        -- 如果是未知队伍，默认为允许，或者根据需求调整
                        if teamAllowed == nil then teamAllowed = true end
                        
                        -- Global TeamCheck 依然生效
                        local enemyCheck = true
                        if _G.TeamCheckEnabled and not isEnemy(p) then enemyCheck = false end

                        if teamAllowed and enemyCheck then
                            isTarget = true
                        end
                    end
                        
                    if isTarget then
                        -- 计算目标透明度 (将 10 转换为 1.0)
                        local targetTrans = _G.HitboxTransparency / 10
                        
                        -- [核心修复]: 只有当大小不正确 OR 透明度不正确时，才执行写入
                        if head.Size.X ~= _G.HitboxSize or head.Transparency ~= targetTrans then
                            head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                            head.Transparency = targetTrans
                            head.CanCollide = false
                            head.Massless = true
                            -- [新增] 强制设置 LocalTransparencyModifier 防止近距离视角剔除（看不到头）
                            head.LocalTransparencyModifier = 0 
                            
                            for _, o in pairs(head:GetChildren()) do
                                if o:IsA("Decal") or o:IsA("Texture") then 
                                    o.Transparency = targetTrans 
                                end
                            end
                        end
                    else
                        -- 目标无效（死了，或者队伍未勾选），重置
                        if head and head.Size.X > 2 then 
                            ResetCharacter(p.Character) 
                        end
                    end
                end
            end
        end)
    else
        if _G.HitboxLoop then _G.HitboxLoop:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do 
            ResetCharacter(p.Character) 
        end
    end
end)

-- 添加队伍选择勾选框
local teamsList = {
    "Class-D", "Chaos Insurgency", "Scientific Department", "Security Department", 
    "Intelligence Agency", "Mobile Task Force", "Rapid Response Team", 
    "Medical Department", "Administrative Department", "Internal Security Department"
}

for _, teamName in ipairs(teamsList) do
    HitMod:CreateSwitch(teamName, function(v)
        _G.SilentAimTeamSettings[teamName] = v
    end, true) -- 默认 true
end

-- [已修改] 移除了 Hitbox Size 和 Hitbox Trans 的 Slider，默认值已在全局变量中设置



local MobAimMod = MobileWin:CreateModule("Enable Mobile Aimbot", function(v)
    _G.MobileGlobal.IsAimbotGuiOn = v
    if v then
        local g = Instance.new("ScreenGui", game.CoreGui); g.Name="MobAim"; local b = Instance.new("TextButton", g); b.Size=UDim2.new(0,60,0,60); b.Position=UDim2.new(0.85,0,0.6,0); b.Text="AIM"; b.BackgroundColor3=Color3.fromRGB(255,50,50); Instance.new("UICorner",b).CornerRadius=UDim.new(0,30)
        local drag, dStart, sPos; b.InputBegan:Connect(function(i) if i.UserInputType.Name:match("Touch") then drag=true; dStart=i.Position; sPos=b.Position end end); UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType.Name:match("Touch") then local d=i.Position-dStart; b.Position=UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType.Name:match("Touch") then drag=false end end)
        local aimLoop = RunService.RenderStepped:Connect(function() 
            if _G.MobileGlobal.AimbotActive then 
                local bT, bD = nil, math.huge; 
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); 
                for _,p in pairs(Players:GetPlayers()) do 
                    if p~=LocalPlayer and p.Character and isEnemy(p) then 
                        local h = p.Character:FindFirstChild("Head"); 
                        if h then 
                            local sP, oS = Camera:WorldToViewportPoint(h.Position); 
                            if oS then 
                                -- Wall Check Logic
                                if _G.WallCheckSetting and not checkVisible(h) then 
                                    -- skip
                                else
                                    local dist = (Vector2.new(sP.X, sP.Y) - center).Magnitude; 
                                    if dist < 80 and dist < bD then bD=dist; bT=h end 
                                end
                            end 
                        end 
                    end 
                end; 
                if bT then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, bT.Position) end 
            end 
        end)
        b.MouseButton1Click:Connect(function() _G.MobileGlobal.AimbotActive = not _G.MobileGlobal.AimbotActive; b.BackgroundColor3=_G.MobileGlobal.AimbotActive and Color3.new(0,1,0) or Color3.fromRGB(255,50,50) end); _G.MobileRes = g; _G.MobileAimLoop = aimLoop
    else if _G.MobileRes then _G.MobileRes:Destroy() end; if _G.MobileAimLoop then _G.MobileAimLoop:Disconnect() end; _G.MobileGlobal.AimbotActive = false end
end)

MobAimMod:CreateSwitch("Team Check", function(v) _G.TeamCheckEnabled = v end, false)
MobAimMod:CreateSwitch("Wall Check", function(v) _G.WallCheckSetting = v end, true)

MobileWin:CreateModule("Show FOV Circle", function(v) _G.MobileGlobal.IsFOVOn = v end)

MobileWin:CreateModule("Show Crosshair", function(v) _G.MobileGlobal.IsCrossOn = v end)



-- SCP

local scps = {"SCP-016", "SCP-016", "SCP-023", "SCP-299", "SCP-049", "SCP-066", "SCP-079", "SCP-087", "SCP-093", "SCP-096", "SCP-1025", "SCP-1299", "SCP-131", "SCP-173", "SCP-2950", "SCP-316", "SCP-999"}

local function toggleSCP(n, s) local f=workspace:FindFirstChild("SCPs"); if not f then return end; local m=f:FindFirstChild(n); if not m then return end; local h=m:FindFirstChildOfClass("Highlight"); if s then if not h then h=Instance.new("Highlight", m); h.FillColor=Color3.new(1,0,0); h.OutlineColor=Color3.new(1,1,0) end else if h then h:Destroy() end end end

for _,s in ipairs(scps) do SCPWin:CreateModule(s.." ESP", function(v) toggleSCP(s,v) end) end

SCPWin:CreateButton("Enable All", function() for _,s in ipairs(scps) do toggleSCP(s,true) end end)

SCPWin:CreateButton("Disable All", function() for _,s in ipairs(scps) do toggleSCP(s,false) end end)



-- Other

MiscWin:CreateButton("Copy Discord Link", function() setclipboard("https://discord.gg/QtVMrPaM"); Library:Notify("Discord", "Copied!", true) end)

-- [已添加] Anti-AFK 功能

MiscWin:CreateModule("Anti AFK", function(v)

    if v then

        _G.AntiAFKConn = LocalPlayer.Idled:Connect(function()

            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

            task.wait(1)

            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

        end)

    else

        if _G.AntiAFKConn then _G.AntiAFKConn:Disconnect(); _G.AntiAFKConn = nil end

    end

end)



--------------------------------------------------------------------------------

-- [TAB 6: Config System v2 - 完全重构]

--------------------------------------------------------------------------------

local CFG = {

    Folder = "CatKing-Configs",

    Current = "",

    Data = {}

}



-- 初始化文件夹

if not isfolder(CFG.Folder) then makefolder(CFG.Folder) end



-- 保存当前设置到内存

function CFG:Capture()

    self.Data = {

        HitboxSize = _G.HitboxSize,

        HitboxTrans = _G.HitboxTransparency,

        AimbotFOV = _G.HeadLock.Settings.FOV,

        AimbotSmooth = _G.HeadLock.Settings.Smoothness,

        AimbotDist = _G.HeadLock.Settings.MaxDistance,

        AimbotPred = _G.HeadLock.Settings.PredictionStrength,

        LockMode = _G.HeadLock.Settings.LockMode,

        WallCheck = _G.WallCheckSetting,

        TeamCheck = _G.TeamCheckEnabled,

        WeaponCheck = _G.WeaponCheckEnabled

    }

end



-- 应用配置到全局变量

function CFG:Apply()

    if self.Data.HitboxSize then _G.HitboxSize = self.Data.HitboxSize end

    if self.Data.HitboxTrans then _G.HitboxTransparency = self.Data.HitboxTrans end

    if self.Data.AimbotFOV then 

        _G.HeadLock.Settings.FOV = self.Data.AimbotFOV

        _G.HeadLock.FOVCircle.Radius = self.Data.AimbotFOV

    end

    if self.Data.AimbotSmooth then _G.HeadLock.Settings.Smoothness = self.Data.AimbotSmooth end

    if self.Data.AimbotDist then _G.HeadLock.Settings.MaxDistance = self.Data.AimbotDist end

    if self.Data.AimbotPred then _G.HeadLock.Settings.PredictionStrength = self.Data.AimbotPred end

    if self.Data.LockMode then _G.HeadLock.Settings.LockMode = self.Data.LockMode end

    if self.Data.WallCheck ~= nil then 

        _G.WallCheckSetting = self.Data.WallCheck

        _G.HeadLock.Settings.WallCheck = self.Data.WallCheck

    end

    if self.Data.TeamCheck ~= nil then 

        _G.TeamCheckEnabled = self.Data.TeamCheck

        _G.HeadLock.Settings.TeamCheck = self.Data.TeamCheck

    end

    if self.Data.WeaponCheck ~= nil then _G.WeaponCheckEnabled = self.Data.WeaponCheck end

end



-- 保存配置到文件

function CFG:Save(name)

    if not name or name == "" then

        local idx = 1

        while isfile(self.Folder.."/cfg"..idx..".json") do idx = idx + 1 end

        name = "cfg"..idx

    end

    

    self:Capture()

    local ok = pcall(function()

        writefile(self.Folder.."/"..name..".json", HttpService:JSONEncode(self.Data))

    end)

    

    return ok, name

end



-- 加载配置从文件

function CFG:Load(name)

    if not name or name == "" then name = "cfg1" end

    local path = self.Folder.."/"..name..".json"

    

    if not isfile(path) then return false, "Not found" end

    

    local ok, result = pcall(function()

        local raw = readfile(path)

        return HttpService:JSONDecode(raw)

    end)

    

    if not ok then return false, "Parse error" end

    

    self.Data = result

    self:Apply()

    return true, "Loaded"

end



-- 删除配置文件

function CFG:Delete(name)

    if not name or name == "" then return false, "No name" end

    local path = self.Folder.."/"..name..".json"

    

    if not isfile(path) then return false, "Not found" end

    

    local ok = pcall(function() delfile(path) end)

    return ok, ok and "Deleted" or "Failed"

end



-- 列出所有配置

function CFG:List()

    local files = listfiles(self.Folder)

    local names = {}

    for _, fp in ipairs(files) do

        local n = fp:match("([^/\\]+)%.json$")

        if n then table.insert(names, n) end

    end

    return names

end



-- 创建UI (使用正确的 API 方法)

local SaveMod = ConfigWin:CreateModule("💾 Save Config", function(enabled)

    if enabled then

        local ok, name = CFG:Save("")

        Library:Notify("Config", ok and ("✅ Saved: "..name) or "❌ Failed", ok)

        task.wait(0.3)

        SaveMod:Set(false)

    end

end, false)



local LoadMod1 = ConfigWin:CreateModule("📂 Load cfg1", function(enabled)

    if enabled then

        local ok, msg = CFG:Load("cfg1")

        Library:Notify("Config", ok and "✅ Loaded cfg1" or ("❌ "..msg), ok)

        task.wait(0.3)

        LoadMod1:Set(false)

    end

end, false)



local LoadMod2 = ConfigWin:CreateModule("📂 Load cfg2", function(enabled)

    if enabled then

        local ok, msg = CFG:Load("cfg2")

        Library:Notify("Config", ok and "✅ Loaded cfg2" or ("❌ "..msg), ok)

        task.wait(0.3)

        LoadMod2:Set(false)

    end

end, false)



local LoadMod3 = ConfigWin:CreateModule("📂 Load cfg3", function(enabled)

    if enabled then

        local ok, msg = CFG:Load("cfg3")

        Library:Notify("Config", ok and "✅ Loaded cfg3" or ("❌ "..msg), ok)

        task.wait(0.3)

        LoadMod3:Set(false)

    end

end, false)



local DelMod1 = ConfigWin:CreateModule("🗑️ Delete cfg1", function(enabled)

    if enabled then

        local ok, msg = CFG:Delete("cfg1")

        Library:Notify("Config", ok and "✅ Deleted cfg1" or ("❌ "..msg), ok)

        task.wait(0.3)

        DelMod1:Set(false)

    end

end, false)



local DelMod2 = ConfigWin:CreateModule("🗑️ Delete cfg2", function(enabled)

    if enabled then

        local ok, msg = CFG:Delete("cfg2")

        Library:Notify("Config", ok and "✅ Deleted cfg2" or ("❌ "..msg), ok)

        task.wait(0.3)

        DelMod2:Set(false)

    end

end, false)



local ListMod = ConfigWin:CreateModule("📋 List All Configs", function(enabled)

    if enabled then

        local list = CFG:List()

        if #list == 0 then

            Library:Notify("Config", "❌ No configs found", false)

        else

            Library:Notify("Config", "Found "..#list..": "..table.concat(list, ", "), true)

        end

        task.wait(0.3)

        ListMod:Set(false)

    end

end, false)



-- [强制关闭所有UI等待灵动岛点击]

for _, winData in pairs(Library.Globals.Windows) do

    if winData.Main then winData.Main.Visible = false end

end

local back = game.CoreGui:FindFirstChild("YC_GUI_Final") and game.CoreGui.YC_GUI_Final:FindFirstChild("Backdrop")

if back then back.Visible = false end



Library:Notify("Loaded", "Cat King v1.8", true)      
