local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "猫王455专属脚本(SCP)",
   LoadingTitle = "猫王455专属脚本",
   LoadingSubtitle = "by 猫王455",
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

local MainTab = Window:CreateTab("主菜单", nil)
local MainSection = MainTab:CreateSection("主菜单")

-- 在外部定义连接表，确保在回调函数中可用
local connections = {}

local Toggle = MainTab:CreateToggle({
   Name = "全员透视",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       -- 使用pcall包装整个回调函数，防止错误传播
       local success, errorMsg = pcall(function()
           if Value then
               -- 启用全员透视
               local Players = game:GetService("Players")
               
               -- 团队颜色映射
               local TEAM_COLORS = {
                   ["Class-D"] = Color3.fromRGB(255, 165, 0),           -- 橙色
                   ["Scientific Department"] = Color3.fromRGB(0, 0, 255), -- 蓝色
                   ["Security Department"] = Color3.fromRGB(255, 255, 255), -- 白色
                   ["Mobile Task Force"] = Color3.fromRGB(0, 0, 139),   -- 深蓝色
                   ["Intelligence Agency"] = Color3.fromRGB(255, 0, 0), -- 红色
                   ["Rapid Response Team"] = Color3.fromRGB(255, 50, 50), -- 亮红色
                   ["Chaos Insurgency"] = Color3.fromRGB(0, 0, 0),      -- 黑色
                   ["Medical Department"] = Color3.fromRGB(0, 191, 255), -- 亮蓝色
                   ["Administrative Department"] = Color3.fromRGB(0, 255, 0), -- 绿色
                   ["Default"] = Color3.fromRGB(200, 200, 200),        -- 默认灰色
               }
               
               -- 获取玩家颜色
               local function getPlayerColor(player)
                   if player and player.Team then
                       local teamName = player.Team.Name
                       
                       -- 1. 精确匹配
                       if TEAM_COLORS[teamName] then
                           return TEAM_COLORS[teamName]
                       end
                       
                       -- 2. 不区分大小写匹配
                       teamName = teamName:lower()
                       for name, color in pairs(TEAM_COLORS) do
                           if name:lower() == teamName then
                               return color
                           end
                       end
                       
                       -- 3. 部分匹配
                       for name, color in pairs(TEAM_COLORS) do
                           if teamName:find(name:lower(), 1, true) or name:lower():find(teamName, 1, true) then
                               return color
                           end
                       end
                       
                       -- 4. 使用团队默认颜色
                       if player.Team.TeamColor then
                           return player.Team.TeamColor.Color
                       end
                   end
                   
                   -- 5. 回退到默认颜色
                   return TEAM_COLORS["Default"]
               end
               
               -- 创建小型名称标签（无背景，小尺寸）
               local function createSmallNameLabel(character, player)
                   -- 移除现有标签
                   local existingLabel = character:FindFirstChild("SmallNameLabel")
                   if existingLabel then
                       existingLabel:Destroy()
                   end
                   
                   local color = getPlayerColor(player)
                   
                   -- 为黑色团队调整文本颜色
                   local textColor = color
                   if player.Team and (player.Team.Name:lower():find("chaos") or color == TEAM_COLORS["Chaos Insurgency"]) then
                       textColor = Color3.new(1, 1, 1) -- 白色文本
                   end
                   
                   -- 创建小型BillboardGui
                   local billboard = Instance.new("BillboardGui")
                   billboard.Name = "SmallNameLabel"
                   billboard.AlwaysOnTop = true
                   billboard.Size = UDim2.new(0, 100, 0, 20)  -- 小尺寸
                   billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                   billboard.MaxDistance = 0  -- 全图可见
                   billboard.Adornee = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
                   
                   if not billboard.Adornee then
                       billboard:Destroy()
                       return
                   end
                   
                   -- 直接创建文本标签，无背景
                   local nameLabel = Instance.new("TextLabel")
                   nameLabel.Size = UDim2.new(1, 0, 1, 0)
                   nameLabel.BackgroundTransparency = 1  -- 完全透明背景
                   nameLabel.Text = player.Name
                   nameLabel.TextColor3 = textColor
                   nameLabel.TextScaled = true
                   nameLabel.TextSize = 12  -- 小字体
                   nameLabel.Font = Enum.Font.GothamBold
                   nameLabel.TextStrokeTransparency = 0.3  -- 文字描边
                   nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                   nameLabel.Parent = billboard
                   
                   billboard.Parent = character
                   return billboard
               end
               
               -- 为玩家添加高亮效果
               local function addPlayerHighlight(character, player)
                   -- 移除现有高亮
                   local existingHighlight = character:FindFirstChildOfClass("Highlight")
                   if existingHighlight then
                       existingHighlight:Destroy()
                   end
                   
                   local color = getPlayerColor(player)
                   
                   -- 添加高亮效果
                   local highlight = Instance.new("Highlight")
                   highlight.Name = "PlayerHighlight"
                   highlight.FillColor = color
                   highlight.OutlineColor = Color3.new(1, 1, 1)
                   highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                   highlight.FillTransparency = 0.4
                   highlight.OutlineTransparency = 0
                   highlight.Parent = character
                   
                   return highlight
               end
               
               -- 为玩家角色添加高亮和标签
               local function setupPlayerEffects(character, player)
                   -- 等待角色完全加载
                   if not character:FindFirstChild("Humanoid") then
                       local humanoid = character:WaitForChild("Humanoid", 5)
                       if not humanoid then
                           return
                       end
                   end
                   
                   if not character.Parent then
                       return
                   end
                   
                   -- 添加高亮效果
                   addPlayerHighlight(character, player)
                   
                   -- 添加小型名称标签
                   createSmallNameLabel(character, player)
                   
                   local teamName = player.Team and player.Team.Name or "无团队"
                   print("已为 " .. player.Name .. " 添加高亮和名称标签，团队: " .. teamName)
               end
               
               -- 清理单个角色的所有效果
               local function cleanupCharacter(character)
                   if character and character.Parent then
                       pcall(function()
                           -- 移除高亮
                           local highlight = character:FindFirstChildOfClass("Highlight")
                           if highlight then 
                               highlight:Destroy()
                           end
                           
                           -- 移除标签
                           local label = character:FindFirstChild("SmallNameLabel")
                           if label then 
                               label:Destroy()
                           end
                       end)
                   end
               end
               
               -- 处理玩家加入
               local function onPlayerAdded(player)
                   -- 监听玩家角色移除（重置或死亡时）
                   local charRemovingConn = player.CharacterRemoving:Connect(function(character)
                       cleanupCharacter(character)
                   end)
                   
                   -- 监听玩家角色生成
                   local charConn = player.CharacterAdded:Connect(function(character)
                       -- 先清理旧效果
                       cleanupCharacter(character)
                       wait(0.5) -- 等待角色完全加载
                       if character and character.Parent then
                           setupPlayerEffects(character, player)
                       end
                   end)
                   
                   -- 监听团队变化
                   local teamConn = player:GetPropertyChangedSignal("Team"):Connect(function()
                       if player.Character and player.Character.Parent then
                           -- 先清理旧效果
                           cleanupCharacter(player.Character)
                           wait(0.5)
                           setupPlayerEffects(player.Character, player)
                       end
                   end)
                   
                   -- 存储连接
                   connections[player] = {
                       character = charConn,
                       characterRemoving = charRemovingConn,
                       team = teamConn
                   }
                   
                   -- 如果玩家已经有角色，立即应用效果
                   if player.Character then
                       spawn(function()
                           cleanupCharacter(player.Character)
                           wait(1)
                           if player.Character and player.Character.Parent then
                               setupPlayerEffects(player.Character, player)
                           end
                       end)
                   end
               end
               
               -- 为所有玩家应用高亮
               local function setupAllPlayers()
                   for _, player in ipairs(Players:GetPlayers()) do
                       onPlayerAdded(player)
                   end
               end
               
               -- 初始化 - 监听新玩家加入
               local playerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
               connections.playerAdded = playerAddedConn
               
               setupAllPlayers()
               
               print("全员透视已启用！")
           else
               -- 禁用全员透视
               local Players = game:GetService("Players")
               
               -- 断开所有事件连接
               for key, conn in pairs(connections) do
                   if type(conn) == "table" then
                       if conn.character then
                           pcall(function() conn.character:Disconnect() end)
                       end
                       if conn.characterRemoving then
                           pcall(function() conn.characterRemoving:Disconnect() end)
                       end
                       if conn.team then
                           pcall(function() conn.team:Disconnect() end)
                       end
                   else
                       pcall(function() conn:Disconnect() end)
                   end
               end
               
               -- 清空连接表
               connections = {}
               
               -- 移除所有效果
               for _, player in ipairs(Players:GetPlayers()) do
                   if player.Character and player.Character.Parent then
                       pcall(function()
                           local character = player.Character
                           
                           -- 移除高亮
                           local highlight = character:FindFirstChildOfClass("Highlight")
                           if highlight then 
                               highlight:Destroy()
                               print("移除 " .. player.Name .. " 的高亮效果")
                           end
                           
                           -- 移除标签
                           local label = character:FindFirstChild("SmallNameLabel")
                           if label then 
                               label:Destroy()
                               print("移除 " .. player.Name .. " 的名称标签")
                           end
                       end)
                   end
               end
               
               print("全员透视已禁用！")
           end
       end)
       
       -- 如果发生错误，打印错误信息但不传播
       if not success then
           warn("全员透视回调错误: " .. tostring(errorMsg))
       end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "地图全亮",
   CurrentValue = false,
   Flag = "MapBrightnessAdjustable",
   Callback = function(Value)
       if Value then
           -- 启用可调亮度地图全亮
           local Lighting = game:GetService("Lighting")
           
           -- 存储原始设置
           local originalSettings = {
               Ambient = Lighting.Ambient,
               Brightness = Lighting.Brightness,
               GlobalShadows = Lighting.GlobalShadows,
               OutdoorAmbient = Lighting.OutdoorAmbient,
               ClockTime = Lighting.ClockTime,
               FogEnd = Lighting.FogEnd
           }
           
           -- 应用全亮设置
           Lighting.Ambient = Color3.new(1, 1, 1)
           Lighting.Brightness = 2.5
           Lighting.GlobalShadows = false
           Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
           Lighting.ClockTime = 12
           Lighting.FogEnd = 100000
           
           -- 存储数据
           _G.MapBrightnessAdjustableData = {
               OriginalSettings = originalSettings,
               Lighting = Lighting
           }
           
           print("地图全亮已启用！")
       else
           -- 禁用可调亮度地图全亮
           if _G.MapBrightnessAdjustableData then
               local data = _G.MapBrightnessAdjustableData
               
               -- 恢复原始光照设置
               if data.OriginalSettings then
                   data.Lighting.Ambient = data.OriginalSettings.Ambient
                   data.Lighting.Brightness = data.OriginalSettings.Brightness
                   data.Lighting.GlobalShadows = data.OriginalSettings.GlobalShadows
                   data.Lighting.OutdoorAmbient = data.OriginalSettings.OutdoorAmbient
                   data.Lighting.ClockTime = data.OriginalSettings.ClockTime
                   data.Lighting.FogEnd = data.OriginalSettings.FogEnd
               end
               
               -- 清空数据
               _G.MapBrightnessAdjustableData = nil
               
               print("地图全亮已禁用！")
           end
       end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "穿墙模式",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       local success, errorMsg = pcall(function()
           if Value then
               -- 启用穿墙模式
               local Players = game:GetService("Players")
               local RunService = game:GetService("RunService")
               local LocalPlayer = Players.LocalPlayer
               
               -- 存储原始碰撞设置
               local originalCollisions = {}
               local noclipConnections = {}
               
               -- 穿墙功能
               local function enableNoclip(character)
                   if not character then return end
                   
                   -- 移除角色的碰撞
                   local function removeCollisions(part)
                       if part:IsA("BasePart") then
                           originalCollisions[part] = part.CanCollide
                           part.CanCollide = false
                       end
                   end
                   
                   -- 移除角色所有部件的碰撞
                   for _, part in ipairs(character:GetDescendants()) do
                       removeCollisions(part)
                   end
                   
                   -- 监听新添加的部件
                   local descendantAdded
                   descendantAdded = character.DescendantAdded:Connect(function(part)
                       removeCollisions(part)
                   end)
                   
                   -- 存储连接
                   noclipConnections[character] = descendantAdded
                   
                   print("已为 " .. LocalPlayer.Name .. " 启用穿墙模式")
               end
               
               -- 自动穿墙功能（防止被卡住）
               local autoNoclipConnection
               autoNoclipConnection = RunService.Stepped:Connect(function()
                   if LocalPlayer.Character then
                       local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                       if humanoid then
                           -- 检测是否被卡住
                           local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                           if rootPart then
                               -- 轻微推动角色防止被卡住
                               rootPart.Velocity = rootPart.Velocity * 0.95
                           end
                       end
                   end
               end)
               
               -- 为当前角色启用穿墙
               if LocalPlayer.Character then
                   enableNoclip(LocalPlayer.Character)
               end
               
               -- 监听角色生成
               local characterConnection
               characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                   wait(0.5) -- 等待角色完全加载
                   enableNoclip(character)
               end)
               
               -- 存储所有连接和数据
               _G.NoclipData = {
                   OriginalCollisions = originalCollisions,
                   Connections = noclipConnections,
                   AutoNoclip = autoNoclipConnection,
                   CharacterConnection = characterConnection,
                   Player = LocalPlayer
               }
               
               print("穿墙模式已启用！")
           else
               -- 禁用穿墙模式
               if _G.NoclipData then
                   local data = _G.NoclipData
                   
                   -- 禁用自动穿墙
                   if data.AutoNoclip then
                       pcall(function() data.AutoNoclip:Disconnect() end)
                   end
                   
                   -- 断开角色连接
                   if data.CharacterConnection then
                       pcall(function() data.CharacterConnection:Disconnect() end)
                   end
                   
                   -- 恢复所有存储的碰撞
                   if data.OriginalCollisions then
                       for part, canCollide in pairs(data.OriginalCollisions) do
                           if part and part.Parent then
                               pcall(function()
                                   part.CanCollide = canCollide
                               end)
                           end
                       end
                   end
                   
                   -- 断开所有部件连接
                   if data.Connections then
                       for _, connection in pairs(data.Connections) do
                           if connection then
                               pcall(function() connection:Disconnect() end)
                           end
                       end
                   end
                   
                   -- 清空数据
                   _G.NoclipData = nil
                   
                   print("穿墙模式已禁用！")
               end
           end
       end)
       
       if not success then
           warn("穿墙模式回调错误: " .. tostring(errorMsg))
       end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "无限跳跃",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
       local success, errorMsg = pcall(function()
           if Value then
               -- 启用无限跳跃
               local UserInputService = game:GetService("UserInputService")
               local Players = game:GetService("Players")
               local LocalPlayer = Players.LocalPlayer
               
               local jumpConnection
               jumpConnection = UserInputService.JumpRequest:Connect(function()
                   if LocalPlayer.Character then
                       local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                       if humanoid then
                           humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                       end
                   end
               end)
               
               _G.InfiniteJumpData = {
                   Connection = jumpConnection
               }
               
               print("无限跳跃已启用！")
           else
               -- 禁用无限跳跃
               if _G.InfiniteJumpData and _G.InfiniteJumpData.Connection then
                   pcall(function()
                       _G.InfiniteJumpData.Connection:Disconnect()
                   end)
                   _G.InfiniteJumpData = nil
                   print("无限跳跃已禁用！")
               end
           end
       end)
       
       if not success then
           warn("无限跳跃回调错误: " .. tostring(errorMsg))
       end
   end,
})



-- 攻击类Tab
local CombatTab = Window:CreateTab("攻击类", nil)
local CombatSection = CombatTab:CreateSection("瞄准功能")

-- FOV圆圈滑块
local FOVSlider = CombatTab:CreateSlider({
   Name = "FOV大小",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Flag = "fovsize",
   Callback = function(Value)
       if _G.AimbotData and _G.AimbotData.FOVCircle then
           _G.AimbotData.FOVCircle.Radius = Value
       end
   end,
})

-- 墙体检测开关
local WallCheckToggle = CombatTab:CreateToggle({
   Name = "墙体检测",
   CurrentValue = true,
   Flag = "WallCheckToggle",
   Callback = function(Value)
       if _G.AimbotData then
           _G.AimbotData.WallCheck = Value
           print("墙体检测已" .. (Value and "启用" or "禁用"))
       end
   end,
})

-- 队伍检测开关
local TeamCheckToggle = CombatTab:CreateToggle({
   Name = "队伍检测",
   CurrentValue = true,
   Flag = "TeamCheckToggle",
   Callback = function(Value)
       if _G.AimbotData then
           _G.AimbotData.TeamCheck = Value
           print("队伍检测已" .. (Value and "启用" or "禁用"))
       end
   end,
})

-- 自瞄功能
local AimbotToggle = CombatTab:CreateToggle({
   Name = "锁头",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
       local success, errorMsg = pcall(function()
           if Value then
               -- 启用自瞄
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
               FOVCircle.Transparency = 1
               FOVCircle.Radius = 150
               FOVCircle.NumSides = 64
               FOVCircle.Filled = false
               
               -- 检测墙体遮挡
               local function isVisibleThroughWalls(targetPosition)
                   if not _G.AimbotData or not _G.AimbotData.WallCheck then
                       return true
                   end
                   
                   local character = LocalPlayer.Character
                   if not character then return false end
                   
                   local head = character:FindFirstChild("Head")
                   if not head then return false end
                   
                   local ray = Ray.new(head.Position, (targetPosition - head.Position).Unit * 500)
                   local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character})
                   
                   if hit then
                       local distance = (position - head.Position).Magnitude
                       local targetDistance = (targetPosition - head.Position).Magnitude
                       return distance >= targetDistance - 1
                   end
                   
                   return true
               end
               
               -- 检测是否为队友
               local function isTeammate(player)
                   if not _G.AimbotData or not _G.AimbotData.TeamCheck then
                       return false
                   end
                   
                   if not LocalPlayer.Team or not player.Team then
                       return false
                   end
                   
                   return LocalPlayer.Team == player.Team
               end
               
               -- 获取最近的敌人
               local function getClosestEnemy()
                   local closestPlayer = nil
                   local shortestDistance = math.huge
                   local mousePos = UserInputService:GetMouseLocation()
                   
                   for _, player in ipairs(Players:GetPlayers()) do
                       if player ~= LocalPlayer and player.Character and not isTeammate(player) then
                           local head = player.Character:FindFirstChild("Head")
                           local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                           local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                           
                           if head and humanoid and humanoid.Health > 0 and rootPart then
                               -- 检测距离是否在500米以内
                               local myRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                               if myRootPart then
                                   local distance3D = (rootPart.Position - myRootPart.Position).Magnitude
                                   
                                   if distance3D <= 500 then
                                       local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                                       
                                       if onScreen and isVisibleThroughWalls(head.Position) then
                                           local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                                           
                                           if distance < FOVCircle.Radius and distance < shortestDistance then
                                               closestPlayer = player
                                               shortestDistance = distance
                                           end
                                       end
                                   end
                               end
                           end
                       end
                   end
                   
                   return closestPlayer
               end
               
               -- 瞄准目标
               local function aimAtTarget(target)
                   if target and target.Character then
                       local head = target.Character:FindFirstChild("Head")
                       if head then
                           Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                       end
                   end
               end
               
               -- 更新FOV圆圈位置
               local renderConnection
               renderConnection = RunService.RenderStepped:Connect(function()
                   local mousePos = UserInputService:GetMouseLocation()
                   FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                   
                   -- 如果按住右键，执行自瞄
                   if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                       local target = getClosestEnemy()
                       if target then
                           aimAtTarget(target)
                       end
                   end
               end)
               
               -- 存储数据
               _G.AimbotData = {
                   FOVCircle = FOVCircle,
                   RenderConnection = renderConnection,
                   WallCheck = true,
                   TeamCheck = true
               }
               
               print("自动瞄准已启用！按住右键瞄准最近的敌人（500米内）")
           else
               -- 禁用自瞄
               if _G.AimbotData then
                   -- 移除FOV圆圈
                   if _G.AimbotData.FOVCircle then
                       pcall(function()
                           _G.AimbotData.FOVCircle:Remove()
                       end)
                   end
                   
                   -- 断开渲染连接
                   if _G.AimbotData.RenderConnection then
                       pcall(function()
                           _G.AimbotData.RenderConnection:Disconnect()
                       end)
                   end
                   
                   _G.AimbotData = nil
                   print("自动瞄准已禁用！")
               end
           end
       end)
       
       if not success then
           warn("自动瞄准回调错误: " .. tostring(errorMsg))
       end
   end,
})

-- SCP Tab
local SCPTab = Window:CreateTab("SCP", nil)
local SCPSection = SCPTab:CreateSection("SCP高亮")

-- SCP列表
local scpList = {
    "SCP-023",
    "SCP-049",
    "SCP-066",
    "SCP-079",
    "SCP-087",
    "SCP-093",
    "SCP-1025",
    "SCP-1299",
    "SCP-131",
    "SCP-173",
    "SCP-2950",
    "SCP-316",
    "SCP-999"
}

-- 存储SCP高亮状态
_G.SCPHighlights = _G.SCPHighlights or {}

-- 为SCP添加高亮
local function addSCPHighlight(scpModel, scpName)
    if not scpModel then return end
    
    -- 移除现有高亮
    local existingHighlight = scpModel:FindFirstChildOfClass("Highlight")
    if existingHighlight then
        existingHighlight:Destroy()
    end
    
    -- 创建新高亮
    local highlight = Instance.new("Highlight")
    highlight.Name = "SCPHighlight_" .. scpName
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = scpModel
    
    return highlight
end

-- 移除SCP高亮
local function removeSCPHighlight(scpModel)
    if not scpModel then return end
    
    local highlight = scpModel:FindFirstChildOfClass("Highlight")
    if highlight and highlight.Name:find("SCPHighlight_") then
        highlight:Destroy()
    end
end

-- 为每个SCP创建开关
for _, scpName in ipairs(scpList) do
    local scpToggle = SCPTab:CreateToggle({
        Name = scpName .. " 高亮",
        CurrentValue = false,
        Flag = "SCP_" .. scpName:gsub("-", "_"),
        Callback = function(Value)
            local success, errorMsg = pcall(function()
                local scpsFolder = workspace:FindFirstChild("SCPs")
                if not scpsFolder then
                    warn("未找到SCPs文件夹")
                    return
                end
                
                local scpModel = scpsFolder:FindFirstChild(scpName)
                if not scpModel then
                    warn("未找到 " .. scpName)
                    return
                end
                
                if Value then
                    -- 启用高亮
                    addSCPHighlight(scpModel, scpName)
                    _G.SCPHighlights[scpName] = true
                    print(scpName .. " 高亮已启用！")
                else
                    -- 禁用高亮
                    removeSCPHighlight(scpModel)
                    _G.SCPHighlights[scpName] = false
                    print(scpName .. " 高亮已禁用！")
                end
            end)
            
            if not success then
                warn(scpName .. " 高亮回调错误: " .. tostring(errorMsg))
            end
        end,
    })
end

-- 全部启用按钮
local EnableAllSCPButton = SCPTab:CreateButton({
    Name = "全部启用",
    Callback = function()
        local scpsFolder = workspace:FindFirstChild("SCPs")
        if not scpsFolder then
            warn("未找到SCPs文件夹")
            return
        end
        
        for _, scpName in ipairs(scpList) do
            local scpModel = scpsFolder:FindFirstChild(scpName)
            if scpModel then
                addSCPHighlight(scpModel, scpName)
                _G.SCPHighlights[scpName] = true
            end
        end
        
        print("所有SCP高亮已启用！")
    end,
})

-- 全部禁用按钮
local DisableAllSCPButton = SCPTab:CreateButton({
    Name = "全部禁用",
    Callback = function()
        local scpsFolder = workspace:FindFirstChild("SCPs")
        if not scpsFolder then
            warn("未找到SCPs文件夹")
            return
        end
        
        for _, scpName in ipairs(scpList) do
            local scpModel = scpsFolder:FindFirstChild(scpName)
            if scpModel then
                removeSCPHighlight(scpModel)
                _G.SCPHighlights[scpName] = false
            end
        end
        
        print("所有SCP高亮已禁用！")
    end,
})
