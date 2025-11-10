Config = {
    api = "01a80aef-4f89-447c-8b68-a594f0eb2a34", 
    service = "密钥2",
    provider = "key"

}
local function main()
loadstring(game:HttpGet("https://raw.githubusercontent.com/NakanoNino455/roblox/refs/heads/main/fisch.lua"))()
print("script loaded uerd was here")
end

if getgenv().RedExecutorKeySys then return end
getgenv().RedExecutorKeySys = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

-- Configuration
local KeySystemData = {
    Name = "enter title here",
    Colors = {
        Background = Color3.fromRGB(245, 250, 255),
        BackgroundAlt = Color3.fromRGB(255, 255, 255),
        Title = Color3.fromRGB(60, 120, 255),
        AccentA = Color3.fromRGB(120, 180, 255),
        AccentB = Color3.fromRGB(90, 200, 255),
        InputField = Color3.fromRGB(255, 255, 255),
        InputFieldBorder = Color3.fromRGB(140, 170, 255),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(240, 246, 255),
        Error = Color3.fromRGB(235, 84, 84),
        Success = Color3.fromRGB(58, 196, 138),
        Discord = Color3.fromRGB(88, 101, 242)
    },
    Service = "redexecutor",
    SilentMode = false,
    DiscordInvite = "",
    WebsiteURL = "https://yourwebsite.com/", -- leave like that
    FileName = "redexecutor/key.txt"
}

local function CreateObject(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props) do 
        if prop ~= "Parent" then
            obj[prop] = value
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function SmoothTween(obj, time, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local ScreenGui = CreateObject("ScreenGui", {
    Name = "RedExecutorKeySystem", 
    Parent = CoreGui, 
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
})

-- Disable global Lighting blur: keep frosted effect on panel instead
local Blur = nil

-- Remove animated background layer for a cleaner light theme

-- Soft drop shadow behind the main window
local Shadow = CreateObject("ImageLabel", {
    Name = "Shadow",
    Parent = ScreenGui,
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 1,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 370, 0, 270),
    ZIndex = 0
})

local MainFrame = CreateObject("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = KeySystemData.Colors.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 350, 0, 250),
    ClipsDescendants = true,
    BackgroundTransparency = 0.6
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
-- Ensure the subtle shadow follows the window by parenting inside MainFrame and matching size
Shadow.Parent = MainFrame
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
CreateObject("UIStroke", {
    Parent = MainFrame,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.fromRGB(120, 170, 255),
    Thickness = 1,
    Transparency = 0.3
})
-- animate border color gently
task.spawn(function()
    local hue = 0
    while MainFrame and MainFrame.Parent do
        hue = (hue + 0.005) % 1
        local c = Color3.fromHSV(hue, 0.2, 1)
        local stroke = MainFrame:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = c end
        task.wait(0.05)
    end
end)
CreateObject("UIGradient", {
    Parent = MainFrame,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 245, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 230, 255))
    })
})
-- glass sheen animated overlay
local Sheen = CreateObject("Frame", {
    Name = "Sheen",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 2
})
local SheenGradient = CreateObject("UIGradient", {
    Parent = Sheen,
    Rotation = 25,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1),
        NumberSequenceKeypoint.new(0.45, 0.85),
        NumberSequenceKeypoint.new(0.50, 0.6),
        NumberSequenceKeypoint.new(0.55, 0.85),
        NumberSequenceKeypoint.new(1.00, 1)
    }),
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
})
task.spawn(function()
    while Sheen and Sheen.Parent do
        for r = -20, 60, 2 do
            SheenGradient.Rotation = r
            task.wait(0.03)
        end
        task.wait(1.2)
    end
end)

local TitleBar = CreateObject("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Background,
    Size = UDim2.new(1, 0, 0, 30),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0)
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8, 0, 0), Parent = TitleBar})
local TitleGradient = CreateObject("UIGradient", {
    Parent = TitleBar,
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, KeySystemData.Colors.AccentB or KeySystemData.Colors.Title),
        ColorSequenceKeypoint.new(1, KeySystemData.Colors.AccentA or KeySystemData.Colors.Title)
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 1)
    })
})
-- animate title gradient subtle sweep
task.spawn(function()
    while TitleGradient and TitleGradient.Parent do
        for r = -15, 15, 3 do
            TitleGradient.Rotation = r
            task.wait(0.05)
        end
        for r = 15, -15, -3 do
            TitleGradient.Rotation = r
            task.wait(0.05)
        end
        task.wait(0.6)
    end
end)

local Title = CreateObject("TextLabel", {
    Name = "Title",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Text = "脚本密钥系统",
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 200, 0, 20),
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(70, 110, 255),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Center,
    AnchorPoint = Vector2.new(0.5, 0.5)
})

local KeyInput = CreateObject("TextBox", {
    Name = "KeyInput",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.InputField,
    Text = "",
    PlaceholderText = "在这里输入你的密钥",
    Position = UDim2.new(0.5, 0, 0.3, 0),
    Size = UDim2.new(0, 280, 0, 35),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(40, 60, 100),
    PlaceholderColor3 = Color3.fromRGB(140, 160, 200),
    TextXAlignment = Enum.TextXAlignment.Left,
    AnchorPoint = Vector2.new(0.5, 0),
    ClipsDescendants = true,
    ClearTextOnFocus = false
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeyInput})
CreateObject("UIStroke", {
    Parent = KeyInput,
    Color = KeySystemData.Colors.InputFieldBorder,
    Thickness = 1,
    Transparency = 0.8
})
CreateObject("UIPadding", {
    Parent = KeyInput,
    PaddingLeft = UDim.new(0, 10)
})
local KeyGradient = CreateObject("UIGradient", {
    Parent = KeyInput,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 248, 255))
    })
})

local SubmitButton = CreateObject("TextButton", {
    Name = "ValidateButton",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Button,
    BorderColor3 = KeySystemData.Colors.InputFieldBorder,
    BorderSizePixel = 1,
    Position = UDim2.new(0.5, 0, 0.55, 0),
    Size = UDim2.new(0, 110, 0, 32),
    Text = "验证密钥系统",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(120, 200, 230),
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0)
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SubmitButton})
local SubmitStroke = CreateObject("UIStroke", { Parent = SubmitButton, Color = Color3.fromRGB(90, 120, 255), Thickness = 1, Transparency = 0.3 })
local SubmitGradient = CreateObject("UIGradient", {
    Parent = SubmitButton,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 240, 255))
    })
})
local SubmitScale = CreateObject("UIScale", { Parent = SubmitButton, Scale = 1 })
-- glow effect
local SubmitGlow = CreateObject("ImageLabel", {
    Name = "Glow",
    Parent = SubmitButton,
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(140, 170, 255),
    ImageTransparency = 0.9,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 10, 1, 10),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 0
})

local GetKeyButton = CreateObject("TextButton", {
    Name = "GetKeyButton",
    Parent = MainFrame,
    Visible = false,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0)
})
-- GetKey removed visually
local GetKeyGlow = CreateObject("ImageLabel", {
    Name = "Glow",
    Parent = GetKeyButton,
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(255, 160, 190),
    ImageTransparency = 0.9,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 10, 1, 10),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 0
})

local DiscordButton = CreateObject("TextButton", {
    Name = "DiscordButton",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Discord,
    Position = UDim2.new(0.5, 0, 0.75, 0),
    Size = UDim2.new(0, 220, 0, 32),
    Text = "免费领取Robux",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(245, 248, 255),
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0)
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DiscordButton})
local DiscordGradient = CreateObject("UIGradient", {
    Parent = DiscordButton,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0.62, 0.8, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(0.60, 0.8, 0.95))
    })
})
local DiscordStroke = CreateObject("UIStroke", { Parent = DiscordButton, Color = Color3.fromRGB(180, 190, 255), Thickness = 1, Transparency = 0.4 })
local DiscordScale = CreateObject("UIScale", { Parent = DiscordButton, Scale = 1 })
local DiscordGlow = CreateObject("ImageLabel", {
    Name = "Glow",
    Parent = DiscordButton,
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(150, 160, 255),
    ImageTransparency = 0.9,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 12, 1, 12),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 0
})

local StatusLabel = CreateObject("TextLabel", {
    Name = "StatusLabel",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.9, 0),
    Size = UDim2.new(0, 280, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "",
    TextColor3 = KeySystemData.Colors.Error,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Center,
    AnchorPoint = Vector2.new(0.5, 0),
    TextTransparency = 1
})

local function ShowStatusMessage(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
    StatusLabel.TextTransparency = 0
    SmoothTween(StatusLabel, 0.3, {TextTransparency = 0})
    
    task.spawn(function()
        task.wait(3)
        if StatusLabel.Text == text then
            SmoothTween(StatusLabel, 0.5, {TextTransparency = 1})
        end
    end)
end

local function AddHoverEffect(button)
    local scaleObject = button:FindFirstChildOfClass("UIScale")
    local strokeObject = button:FindFirstChildOfClass("UIStroke")

    button.MouseEnter:Connect(function()
        if scaleObject then SmoothTween(scaleObject, 0.18, { Scale = 1.05 }) end
        if strokeObject then SmoothTween(strokeObject, 0.18, { Transparency = 0.15 }) end
    end)
    
    button.MouseLeave:Connect(function()
        if scaleObject then SmoothTween(scaleObject, 0.18, { Scale = 1 }) end
        if strokeObject then SmoothTween(strokeObject, 0.18, { Transparency = 0.3 }) end
    end)
end

AddHoverEffect(SubmitButton)
-- GetKey removed

KeyInput.Focused:Connect(function()
    SmoothTween(KeyInput.UIStroke, 0.2, {
        Color = KeySystemData.Colors.Title, 
        Transparency = 0.3
    })
end)

KeyInput.FocusLost:Connect(function()
    SmoothTween(KeyInput.UIStroke, 0.2, {
        Color = KeySystemData.Colors.InputFieldBorder, 
        Transparency = 0.8
    })
end)

-- Button ripple click effect
local function AttachRipple(button)
    button.MouseButton1Click:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundTransparency = 0.6
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.ZIndex = (button.ZIndex or 1) + 1
        ripple.Parent = button
        CreateObject("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.6
        TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }):Play()

        task.delay(0.45, function()
            if ripple then ripple:Destroy() end
        end)
    end)
end

local function openGetKey()
    local JunkieKeySystem = loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    
    local API_KEY = Config.api
    local PROVIDER = Config.provider
    local SERVICE = Config.service
    
    local link = JunkieKeySystem.getLink(API_KEY, PROVIDER, SERVICE)
    if link then
        if setclipboard then
            setclipboard(link)
            ShowStatusMessage("Verification link copied!", KeySystemData.Colors.Success)
        else
            ShowStatusMessage("Link: " .. link, KeySystemData.Colors.Success)
        end
    else
        ShowStatusMessage("Failed to generate link", KeySystemData.Colors.Error)
    end
end

local function validateKey()
    local userKey = KeyInput.Text:gsub("%s+", "")
    if not userKey or userKey == "" then
        ShowStatusMessage("Please enter a key.", KeySystemData.Colors.Error)
        return
    end

    ShowStatusMessage("Validating key...", Color3.fromRGB(255, 165, 0))
    
    local JunkieKeySystem = loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    
    local API_KEY = Config.api
    local SERVICE = Config.service
    
    local isValid = JunkieKeySystem.verifyKey(API_KEY, userKey, SERVICE)
    if isValid then
        ShowStatusMessage("Key valid! Loading executor...", KeySystemData.Colors.Success)
        
        -- Welcome overlay
        local Overlay = CreateObject("Frame", {
            Name = "WelcomeOverlay",
            Parent = ScreenGui,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 999
        })
        local OverlayGradient = CreateObject("UIGradient", {
            Parent = Overlay,
            Rotation = 0,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(230, 245, 255)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 240, 250)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(240, 255, 245))
            })
        })
        local player = Players and Players.LocalPlayer
        local displayName = (player and (player.DisplayName ~= "" and player.DisplayName or player.Name)) or "用户"
        local Welcome = CreateObject("TextLabel", {
            Name = "WelcomeText",
            Parent = Overlay,
            BackgroundTransparency = 1,
            Text = "欢迎尊贵的 " .. displayName .. " 使用！",
            Font = Enum.Font.GothamBlack,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 42,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            TextTransparency = 1
        })
        CreateObject("UIStroke", { Parent = Welcome, Color = Color3.fromRGB(120, 140, 255), Thickness = 1, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual })
        local WelcomeGlow = CreateObject("ImageLabel", {
            Name = "WelcomeGlow",
            Parent = Welcome,
            BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084",
            ImageColor3 = Color3.fromRGB(180, 200, 255),
            ImageTransparency = 0.88,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276),
            Size = UDim2.new(1, 60, 1, 60),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 998
        })
        -- rainbow text color animation
        task.spawn(function()
            local t = 0
            while Welcome and Welcome.Parent do
                t = t + 0.02
                local hue = (t * 0.15) % 1
                Welcome.TextColor3 = Color3.fromHSV(hue, 0.7, 1)
                task.wait(0.02)
            end
        end)
        SmoothTween(Welcome, 0.4, { TextTransparency = 0 })

        SmoothTween(MainFrame, 0.5, {
            Position = UDim2.new(0.5, 0, -0.5, 0),
            BackgroundTransparency = 1
        })
        SmoothTween(Shadow, 0.5, { ImageTransparency = 1 })
        
        task.wait(2.4)
        SmoothTween(Welcome, 0.8, { TextTransparency = 1 })
        task.wait(0.5)
        if Overlay then Overlay:Destroy() end
        
        task.wait(0.2)
        if Blur and Blur.Parent then Blur:Destroy() end
        ScreenGui:Destroy()
        
        main()
    else
        ShowStatusMessage("Invalid key. Try again!", KeySystemData.Colors.Error)
    end
end

SubmitButton.MouseButton1Click:Connect(validateKey)
-- GetKey removed
AttachRipple(SubmitButton)
-- GetKey removed
AttachRipple(DiscordButton)

local dragging, dragInput, dragStart, startPos
local function onInputChanged(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(onInputChanged)

-- Open external link helper (best-effort in exploit environments)
local function openInBrowser(url)
    local cleaned = tostring(url):gsub("^@+", "")
    local ok = false
    -- always copy first for reliability
    if setclipboard then pcall(setclipboard, cleaned) end
    -- Xeno-specific handlers (best guess across common builds)
    if getgenv and getgenv().Xeno and type(getgenv().Xeno) == "table" then
        if getgenv().Xeno.open_url then ok = pcall(getgenv().Xeno.open_url, cleaned) or ok end
        if getgenv().Xeno.OpenURL then ok = pcall(getgenv().Xeno.OpenURL, cleaned) or ok end
    end
    if _G and _G.Xeno and type(_G.Xeno) == "table" then
        if _G.Xeno.open_url then ok = pcall(_G.Xeno.open_url, cleaned) or ok end
        if _G.Xeno.OpenURL then ok = pcall(_G.Xeno.OpenURL, cleaned) or ok end
    end
    if xeno and type(xeno) == "table" then
        if xeno.open_url then ok = pcall(xeno.open_url, cleaned) or ok end
        if xeno.OpenURL then ok = pcall(xeno.OpenURL, cleaned) or ok end
    end
    if syn and syn.open_url then ok = pcall(syn.open_url, cleaned) or ok end
    if http and http.open_url then ok = pcall(http.open_url, cleaned) or ok end
    if openurl then ok = pcall(openurl, cleaned) or ok end
    if getgenv and getgenv().open_url then ok = pcall(getgenv().open_url, cleaned) or ok end
    if http_request then ok = pcall(http_request, { Url = cleaned, Method = "GET" }) or ok end
    if request then ok = pcall(request, { Url = cleaned, Method = "GET" }) or ok end
    if syn and syn.request then ok = pcall(syn.request, { Url = cleaned, Method = "GET" }) or ok end
    if not ok and setclipboard then pcall(setclipboard, cleaned) end
    return ok
end

-- Rainbow text for the Robux button
task.spawn(function()
    local t = 0
    while DiscordButton and DiscordButton.Parent do
        t = t + 0.02
        local hue = (t * 0.12) % 1
        DiscordButton.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        task.wait(0.02)
    end
end)

DiscordButton.MouseButton1Click:Connect(function()
    local robuxUrl = "@https://shorturl.at/a24NF"
    ShowStatusMessage("正在打开链接...", Color3.fromRGB(220, 60, 60))
    -- copy immediately for user certainty
    if setclipboard then pcall(setclipboard, robuxUrl:gsub("^@+", "")) end
    task.spawn(function()
        local opened = openInBrowser(robuxUrl)
        if opened then
            ShowStatusMessage("已打开/复制：免费领取链接", Color3.fromRGB(220, 60, 60))
        else
            ShowStatusMessage("无法自动打开，已复制链接", Color3.fromRGB(220, 60, 60))
        end
    end)
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateKey()
    end
end)

MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1

SmoothTween(MainFrame, 0.5, {
    Size = UDim2.new(0, 350, 0, 250), 
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0
})
SmoothTween(Shadow, 0.5, { ImageTransparency = 0.3 })
