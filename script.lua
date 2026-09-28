-- ==========================================
-- 🐱 แมวส้ม Script Hub - Complete Edition v6
-- (Discord เปิดได้ทุก Injector + Fallback ครบ)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

if LocalPlayer.PlayerGui:FindFirstChild("AnimeScriptHub") then
    LocalPlayer.PlayerGui.AnimeScriptHub:Destroy()
end

local Config = {
    AimbotEnabled = false, AimPart = "Head", AimSmoothness = 0.15, FOVCircleRadius = 180,
    BulletHomingEnabled = false, BulletSpeed = 300,
    ESP_Enabled = false, ESP_Box = false, ESP_Health = false,
    ESP_LineColor = Color3.fromRGB(255, 0, 255),
    ESP_LineMode = "Bottom",
    SpeedEnabled = false, SpeedValue = 16,
    FlyEnabled = false, FlySpeed = 50, FlyHeight = 10,
    ThemeColor = Color3.fromRGB(130, 80, 255),
    BgColor = Color3.fromRGB(20, 15, 35),
    TextColor = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 160, 190),
    DiscordInvite = "44YNvqhXP"
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeScriptHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Notification
local function SendNotification(title, content, duration)
    duration = duration or 3
    local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
    if not NotifContainer then
        NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "NotifContainer"
        NotifContainer.Size = UDim2.new(0, 260, 1, 0)
        NotifContainer.Position = UDim2.new(1, -275, 0, 10)
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.ZIndex = 20
        NotifContainer.Parent = ScreenGui
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 8)
        layout.Parent = NotifContainer
    end
    local NotifBox = Instance.new("Frame")
    NotifBox.Size = UDim2.new(1, 0, 0, 65)
    NotifBox.BackgroundColor3 = Config.BgColor
    NotifBox.BackgroundTransparency = 0.15
    NotifBox.Position = UDim2.new(1, 50, 0, 0)
    NotifBox.ZIndex = 20
    NotifBox.Parent = NotifContainer
    Instance.new("UICorner", NotifBox).CornerRadius = UDim.new(0, 10)
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Config.ThemeColor
    boxStroke.Thickness = 1.5
    boxStroke.Transparency = 0.3
    boxStroke.Parent = NotifBox
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -50, 0, 20)
    tLabel.Position = UDim2.new(0, 48, 0, 8)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLabel.TextSize = 14
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 20
    tLabel.Parent = NotifBox
    local cLabel = Instance.new("TextLabel")
    cLabel.Size = UDim2.new(1, -50, 0, 25)
    cLabel.Position = UDim2.new(0, 48, 0, 28)
    cLabel.BackgroundTransparency = 1
    cLabel.Text = content
    cLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    cLabel.TextSize = 12
    cLabel.Font = Enum.Font.Gotham
    cLabel.TextXAlignment = Enum.TextXAlignment.Left
    cLabel.TextWrapped = true
    cLabel.ZIndex = 20
    cLabel.Parent = NotifBox
    NotifBox:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.delay(duration, function()
        pcall(function()
            NotifBox:TweenPosition(UDim2.new(1, 50, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
            task.wait(0.3)
            NotifBox:Destroy()
        end)
    end)
end

-- Loading Screen
local LoadingGui = Instance.new("Frame")
LoadingGui.Size = UDim2.new(0, 360, 0, 180)
LoadingGui.Position = UDim2.new(0.5, -180, 0.5, -90)
LoadingGui.BackgroundColor3 = Config.BgColor
LoadingGui.BackgroundTransparency = 0.15
LoadingGui.ZIndex = 15
LoadingGui.Parent = ScreenGui
Instance.new("UICorner", LoadingGui).CornerRadius = UDim.new(0, 12)
local loadStroke = Instance.new("UIStroke")
loadStroke.Color = Config.ThemeColor
loadStroke.Thickness = 2
loadStroke.Transparency = 0.3
loadStroke.Parent = LoadingGui
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 25)
StatusText.Position = UDim2.new(0, 0, 0, 80)
StatusText.BackgroundTransparency = 1
StatusText.Text = "กำลังโหลดระบบ..."
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.GothamBold
StatusText.ZIndex = 16
StatusText.Parent = LoadingGui
local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.8, 0, 0, 12)
BarBg.Position = UDim2.new(0.1, 0, 0, 125)
BarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
BarBg.BackgroundTransparency = 0.5
BarBg.ZIndex = 16
BarBg.Parent = LoadingGui
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Config.ThemeColor
BarFill.ZIndex = 17
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Config.BgColor
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://103628356622817"
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Config.ThemeColor
btnStroke.Thickness = 2
btnStroke.Parent = ToggleButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Config.BgColor
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Config.ThemeColor
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = MainFrame

local MainBg = Instance.new("ImageLabel")
MainBg.Size = UDim2.new(1, 0, 1, 0)
MainBg.BackgroundTransparency = 1
MainBg.Image = "rbxassetid://16255492011"
MainBg.ImageTransparency = 0.6
MainBg.ScaleType = Enum.ScaleType.Crop
MainBg.ZIndex = 0
MainBg.Parent = MainFrame

local MainOverlay = Instance.new("Frame")
MainOverlay.Size = UDim2.new(1, 0, 1, 0)
MainOverlay.BackgroundColor3 = Config.BgColor
MainOverlay.BackgroundTransparency = 0.3
MainOverlay.ZIndex = 1
MainOverlay.Parent = MainFrame

local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, 50)
HeaderBar.BackgroundColor3 = Config.BgColor
HeaderBar.BackgroundTransparency = 0.4
HeaderBar.ZIndex = 2
HeaderBar.Parent = MainFrame
Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 16)
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = Config.BgColor
headerFix.BackgroundTransparency = 0.4
headerFix.ZIndex = 2
headerFix.Parent = HeaderBar
local HeaderIcon = Instance.new("ImageLabel")
HeaderIcon.Size = UDim2.new(0, 35, 0, 35)
HeaderIcon.Position = UDim2.new(0, 15, 0.5, -17.5)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Image = "rbxassetid://103628356622817"
HeaderIcon.ZIndex = 3
HeaderIcon.Parent = HeaderBar
local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -100, 1, 0)
HeaderTitle.Position = UDim2.new(0, 60, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "🐱 แมวส้ม Script Hub"
HeaderTitle.TextColor3 = Config.TextColor
HeaderTitle.TextSize = 18
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 3
HeaderTitle.Parent = HeaderBar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 3
CloseBtn.Parent = HeaderBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local dragging = false
local dragStart, startPos
HeaderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
HeaderBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Config.BgColor
Sidebar.BackgroundTransparency = 0.6
Sidebar.ZIndex = 2
Sidebar.Parent = MainFrame
local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 140, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 2
ContentContainer.Parent = MainFrame

local function CreateSidebarButton(name, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Config.BgColor
    btn.BackgroundTransparency = 0.8
    btn.Text = "   " .. name
    btn.TextColor3 = Config.TextDim
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ZIndex = 3
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = Config.ThemeColor
    indicator.Visible = false
    indicator.ZIndex = 4
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Sidebar:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextColor3 = Config.TextDim
                v.BackgroundTransparency = 0.8
                local ind = v:FindFirstChild("Frame")
                if ind then ind.Visible = false end
            end
        end
        btn.TextColor3 = Config.TextColor
        btn.BackgroundTransparency = 0.5
        indicator.Visible = true
        if callback then callback() end
    end)
    return btn
end

local function CreateToggle(parent, text, flagName, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container
    local currentState = Config[flagName]
    if currentState == nil then currentState = defaultState end
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 45, 0, 24)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -12)
    toggleBtn.BackgroundColor3 = currentState and Config.ThemeColor or Color3.fromRGB(60, 55, 80)
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 3
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = currentState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 4
    knob.Parent = toggleBtn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    toggleBtn.MouseButton1Click:Connect(function()
        currentState = not currentState
        Config[flagName] = currentState
        if currentState then
            toggleBtn.BackgroundColor3 = Config.ThemeColor
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
        if callback then callback(currentState) end
    end)
end

local function CreateSlider(parent, text, min, max, flagName, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 50)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = parent
    local currentValue = Config[flagName]
    if currentValue == nil then currentValue = default end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. currentValue
    label.TextColor3 = Config.TextDim
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 15)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    sliderBg.ZIndex = 3
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Config.ThemeColor
    fill.ZIndex = 4
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 5
    sliderBtn.Parent = sliderBg
    local isDragging = false
    local function updateSlider()
        local mouse = UserInputService:GetMouseLocation()
        local percent = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (percent * (max - min)))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. value
        Config[flagName] = value
        if callback then callback(value) end
    end
    sliderBtn.MouseButton1Down:Connect(function() isDragging = true; updateSlider() end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider() end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Config.ThemeColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
end

local function ClearContent()
    for _, v in pairs(ContentContainer:GetChildren()) do
        if v:IsA("ScrollingFrame") then v:Destroy() end
    end
end

local function CreatePage(title)
    ClearContent()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Config.ThemeColor
    page.ZIndex = 3
    page.Parent = ContentContainer
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = Config.TextColor
    header.TextSize = 18
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.ZIndex = 3
    header.Parent = page
    return page
end

local espDrawings = {}
local currentLockedTarget = nil

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Config.FOVCircleRadius
FOVCircle.Color = Config.ESP_LineColor
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

local TargetSnapLine = Drawing.new("Line")
TargetSnapLine.Color = Color3.fromRGB(255, 0, 0)
TargetSnapLine.Thickness = 2
TargetSnapLine.Transparency = 0.9
TargetSnapLine.Visible = false

local function CreateESP(player)
    if espDrawings[player] then return end
    local line = Drawing.new("Line"); line.Visible = false
    local text = Drawing.new("Text"); text.Size = 14; text.Center = true; text.Outline = true; text.Visible = false
    local box = Drawing.new("Square"); box.Visible = false
    local healthBarBg = Drawing.new("Square"); healthBarBg.Visible = false
    local healthBar = Drawing.new("Square"); healthBar.Visible = false
    espDrawings[player] = {Line = line, Text = text, Box = box, HealthBarBg = healthBarBg, HealthBar = healthBar}
end

local function RemoveESP(player)
    if espDrawings[player] then
        for _, obj in pairs(espDrawings[player]) do pcall(function() obj:Remove() end) end
        espDrawings[player] = nil
    end
end
Players.PlayerRemoving:Connect(RemoveESP)

RunService.Stepped:Connect(function()
    if Config.BulletHomingEnabled and currentLockedTarget and currentLockedTarget.Character then
        local targetPart = currentLockedTarget.Character:FindFirstChild(Config.AimPart)
        if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name == "Bullet" or obj.Name == "Projectile" or obj.Name == "Part" or obj.Name == "Fireball") then
                    if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 100 then
                        obj.CFrame = CFrame.new(obj.Position, targetPart.Position)
                        obj.Velocity = (targetPart.Position - obj.Position).Unit * Config.BulletSpeed
                    end
                end
            end
        end
    end
end)

CreateSidebarButton("🏠 หน้าหลัก", 1, function()
    local page = CreatePage("หน้าหลัก")
    CreateToggle(page, "🎯 ล็อกเป้าหมาย (Aimbot)", "AimbotEnabled", false, function(state)
        FOVCircle.Visible = state
        if not state then TargetSnapLine.Visible = false; currentLockedTarget = nil end
    end)
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, 0, 0, 35)
    modeBtn.BackgroundColor3 = Config.BgColor
    modeBtn.BackgroundTransparency = 0.5
    modeBtn.Text = "โหมดล็อก: " .. Config.AimPart
    modeBtn.TextColor3 = Config.TextColor
    modeBtn.TextSize = 14
    modeBtn.Font = Enum.Font.Gotham
    modeBtn.ZIndex = 3
    modeBtn.Parent = page
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)
    modeBtn.MouseButton1Click:Connect(function()
        Config.AimPart = (Config.AimPart == "Head") and "HumanoidRootPart" or "Head"
        modeBtn.Text = "โหมดล็อก: " .. Config.AimPart
    end)
    CreateSlider(page, "ขนาด FOV กลางจอ", 50, 400, "FOVCircleRadius", 180, function(value) FOVCircle.Radius = value end)
    CreateToggle(page, "🚀 กระสุนติดตามเป้า", "BulletHomingEnabled", false, function(state) end)
    CreateSlider(page, "ความเร็วกระสุน", 100, 1000, "BulletSpeed", 300, function(value) end)
end)

CreateSidebarButton("👤 ผู้เล่น/บิน", 2, function()
    local page = CreatePage("ผู้เล่น & การเคลื่อนที่")
    CreateToggle(page, "วิ่งเร็ว", "SpeedEnabled", false, function(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = state and Config.SpeedValue or 16
        end
    end)
    CreateSlider(page, "ความเร็ววิ่ง", 16, 100, "SpeedValue", 16, function(value)
        if Config.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end)
    CreateSlider(page, "ความเร็วบิน", 10, 200, "FlySpeed", 50, function(value) end)
    CreateSlider(page, "ความสูงบิน", 1, 100, "FlyHeight", 10, function(value) end)
    CreateToggle(page, "🕊️ เปิด/ปิด โหมดบิน", "FlyEnabled", false, function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid then
            if state then
                humanoid.PlatformStand = true
                local bg = Instance.new("BodyGyro", hrp); bg.Name = "MobFlyGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                local bv = Instance.new("BodyVelocity", hrp); bv.Name = "MobFlyVelocity"; bv.velocity = Vector3.new(0, 0, 0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                RunService.RenderStepped:Connect(function()
                    if Config.FlyEnabled and hrp and hrp.Parent then
                        bv.velocity = Camera.CFrame.LookVector * Config.FlySpeed
                        bg.cframe = Camera.CFrame
                    end
                end)
            else
                humanoid.PlatformStand = false
                if hrp:FindFirstChild("MobFlyGyro") then hrp.MobFlyGyro:Destroy() end
                if hrp:FindFirstChild("MobFlyVelocity") then hrp.MobFlyVelocity:Destroy() end
            end
        end
    end)
end)

CreateSidebarButton("👁️ เส้นมอง", 3, function()
    local page = CreatePage("เส้นมอง (ESP)")
    CreateToggle(page, "เปิด/ปิด เส้นมอง (Tracer)", "ESP_Enabled", false, function(state) end)
    CreateToggle(page, "เปิด/ปิด กล่องรอบตัว (Box)", "ESP_Box", false, function(state) end)
    CreateToggle(page, "เปิด/ปิด หลอดเลือด (Health)", "ESP_Health", false, function(state) end)
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, 0, 0, 35)
    modeBtn.BackgroundColor3 = Config.BgColor
    modeBtn.BackgroundTransparency = 0.5
    modeBtn.Text = "📍 ตำแหน่งเส้น: " .. (Config.ESP_LineMode == "Top" and "ด้านบน" or "ด้านล่าง")
    modeBtn.TextColor3 = Config.TextColor
    modeBtn.TextSize = 14
    modeBtn.Font = Enum.Font.Gotham
    modeBtn.ZIndex = 3
    modeBtn.Parent = page
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)
    modeBtn.MouseButton1Click:Connect(function()
        Config.ESP_LineMode = (Config.ESP_LineMode == "Top") and "Bottom" or "Top"
        modeBtn.Text = "📍 ตำแหน่งเส้น: " .. (Config.ESP_LineMode == "Top" and "ด้านบน" or "ด้านล่าง")
        SendNotification("ตำแหน่งเส้น", "เปลี่ยนเป็น: " .. (Config.ESP_LineMode == "Top" and "ด้านบน" or "ด้านล่าง"), 2)
    end)
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(1, 0, 0, 35)
    colorBtn.BackgroundColor3 = Config.ESP_LineColor
    colorBtn.Text = "🎨 เปลี่ยนสีเส้น ESP"
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBtn.TextSize = 14
    colorBtn.Font = Enum.Font.Gotham
    colorBtn.ZIndex = 3
    colorBtn.Parent = page
    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 8)
    colorBtn.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 100, 0)
        }
        local newColor = colors[math.random(1, #colors)]
        Config.ESP_LineColor = newColor
        colorBtn.BackgroundColor3 = newColor
        FOVCircle.Color = newColor
    end)
end)

CreateSidebarButton("⚙️ ตั้งค่า", 4, function()
    local page = CreatePage("ตั้งค่า")
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 50)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "🐱 แมวส้ม Script Hub\nเวอร์ชัน: 6.0"
    infoLabel.TextColor3 = Config.TextDim
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.ZIndex = 3
    infoLabel.Parent = page
    
    -- ✅ ปุ่ม Discord เด้งเข้าแอป (Fallback 5 วิธี)
    CreateButton(page, "💬 เข้าดิสคอร์ด (เด้งเข้าแอป)", function()
        local inviteCode = Config.DiscordInvite
        local inviteUrl = "https://discord.gg/" .. inviteCode
        
        -- คัดลอกลิงก์ไว้เผื่อฉุกเฉิน
        pcall(function() setclipboard(inviteUrl) end)
        
        local opened = false
        
        -- วิธีที่ 1: openUrl ของ Injector (ได้ผลที่สุดบนมือถือ)
        pcall(function()
            if openUrl then
                openUrl(inviteUrl)
                opened = true
            end
        end)
        
        -- วิธีที่ 2: launchApp ของ Injector
        if not opened then
            pcall(function()
                if launchApp then
                    launchApp("discord")
                    opened = true
                end
            end)
        end
        
        -- วิธีที่ 3: Intent URL (Android)
        if not opened then
            pcall(function()
                local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
                if isMobile then
                    local intent = "intent://discord.gg/" .. inviteCode .. "#Intent;scheme=https;package=com.discord;S.browser_fallback_url=" .. inviteUrl .. ";end"
                    if request then
                        request({Url = intent, Method = "GET"})
                        opened = true
                    end
                end
            end)
        end
        
        -- วิธีที่ 4: Discord RPC (PC)
        if not opened then
            pcall(function()
                local req = (syn and syn.request) or (http and http.request) or http_request
                if req then
                    req({
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                            ["Origin"] = "https://discord.com"
                        },
                        Body = HttpService:JSONEncode({
                            cmd = "INVITE_BROWSER",
                            args = { code = inviteCode },
                            nonce = HttpService:GenerateGUID(false)
                        })
                    })
                    opened = true
                end
            end)
        end
        
        -- วิธีที่ 5: Fallback เปิด Browser ในตัว Roblox
        if not opened then
            pcall(function()
                GuiService:OpenBrowserWindow(inviteUrl)
            end)
        end
        
        if opened then
            SendNotification("Discord", "กำลังเปิด Discord...", 3)
        else
            SendNotification("Discord", "คัดลอกลิงก์แล้ว! เปิดแอป Discord เองได้เลย", 4)
        end
    end)
    
    CreateButton(page, "🔍 ค้นหาเซิร์ฟเวอร์ว่าง (1 คน)", function()
        SendNotification("Server Finder", "กำลังค้นหา...", 2)
        local ServerFrame = Instance.new("Frame")
        ServerFrame.Size = UDim2.new(0, 400, 0, 300)
        ServerFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
        ServerFrame.BackgroundColor3 = Config.BgColor
        ServerFrame.BackgroundTransparency = 0.1
        ServerFrame.ZIndex = 30
        ServerFrame.Parent = ScreenGui
        Instance.new("UICorner", ServerFrame).CornerRadius = UDim.new(0, 12)
        local sfStroke = Instance.new("UIStroke")
        sfStroke.Color = Config.ThemeColor
        sfStroke.Thickness = 1.5
        sfStroke.Parent = ServerFrame
        local sfTitle = Instance.new("TextLabel")
        sfTitle.Size = UDim2.new(1, 0, 0, 40)
        sfTitle.BackgroundTransparency = 1
        sfTitle.Text = "Server Finder 💻"
        sfTitle.TextColor3 = Config.TextColor
        sfTitle.TextSize = 18
        sfTitle.Font = Enum.Font.GothamBold
        sfTitle.ZIndex = 31
        sfTitle.Parent = ServerFrame
        local sfClose = Instance.new("TextButton")
        sfClose.Size = UDim2.new(0, 30, 0, 30)
        sfClose.Position = UDim2.new(1, -35, 0, 5)
        sfClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        sfClose.Text = "X"
        sfClose.TextColor3 = Color3.fromRGB(255, 255, 255)
        sfClose.TextSize = 16
        sfClose.Font = Enum.Font.GothamBold
        sfClose.ZIndex = 31
        sfClose.Parent = ServerFrame
        Instance.new("UICorner", sfClose).CornerRadius = UDim.new(0, 6)
        sfClose.MouseButton1Click:Connect(function() ServerFrame:Destroy() end)
        local sfScroll = Instance.new("ScrollingFrame")
        sfScroll.Size = UDim2.new(1, -20, 1, -50)
        sfScroll.Position = UDim2.new(0, 10, 0, 45)
        sfScroll.BackgroundTransparency = 1
        sfScroll.ScrollBarThickness = 3
        sfScroll.ZIndex = 31
        sfScroll.Parent = ServerFrame
        local sfLayout = Instance.new("UIListLayout")
        sfLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sfLayout.Padding = UDim.new(0, 5)
        sfLayout.Parent = sfScroll
        task.spawn(function()
            local cursor = ""
            local found = 0
            while found < 10 do
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
                local success, result = pcall(function() return game:HttpGet(url) end)
                if success then
                    local data = HttpService:JSONDecode(result)
                    for _, server in pairs(data.data) do
                        if server.playing < server.maxPlayers then
                            found = found + 1
                            local serverBtn = Instance.new("TextButton")
                            serverBtn.Size = UDim2.new(1, -10, 0, 40)
                            serverBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
                            serverBtn.Text = "  Server: " .. server.id:sub(1, 8) .. "... | " .. server.playing .. "/" .. server.maxPlayers
                            serverBtn.TextColor3 = Config.TextColor
                            serverBtn.TextSize = 12
                            serverBtn.Font = Enum.Font.Gotham
                            serverBtn.TextXAlignment = Enum.TextXAlignment.Left
                            serverBtn.ZIndex = 32
                            serverBtn.Parent = sfScroll
                            Instance.new("UICorner", serverBtn).CornerRadius = UDim.new(0, 6)
                            local joinBtn = Instance.new("TextButton")
                            joinBtn.Size = UDim2.new(0, 60, 0, 25)
                            joinBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
                            joinBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
                            joinBtn.Text = "Join"
                            joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            joinBtn.TextSize = 12
                            joinBtn.Font = Enum.Font.GothamBold
                            joinBtn.ZIndex = 33
                            joinBtn.Parent = serverBtn
                            Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
                            joinBtn.MouseButton1Click:Connect(function()
                                pcall(function()
                                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                end)
                            end)
                            if found >= 10 then break end
                        end
                    end
                    cursor = data.nextPageCursor or ""
                    if cursor == "" then break end
                else break end
                task.wait(0.5)
            end
            if found == 0 then
                local noServer = Instance.new("TextLabel")
                noServer.Size = UDim2.new(1, 0, 0, 40)
                noServer.BackgroundTransparency = 1
                noServer.Text = "ไม่พบเซิร์ฟเวอร์ว่าง"
                noServer.TextColor3 = Config.TextDim
                noServer.TextSize = 14
                noServer.Font = Enum.Font.Gotham
                noServer.ZIndex = 32
                noServer.Parent = sfScroll
            end
        end)
    end)
    
    CreateButton(page, "🔄 รีจอยเซิร์ฟเวอร์ 1 คน", function()
        SendNotification("Rejoin", "กำลังค้นหา...", 2)
        task.spawn(function()
            local cursor = ""
            while true do
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
                local success, result = pcall(function() return game:HttpGet(url) end)
                if success then
                    local data = HttpService:JSONDecode(result)
                    for _, server in pairs(data.data) do
                        if server.playing == 1 then
                            pcall(function()
                                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            end)
                            return
                        end
                    end
                    cursor = data.nextPageCursor or ""
                    if cursor == "" then break end
                else break end
                task.wait(0.5)
            end
            SendNotification("Rejoin", "ไม่พบเซิร์ฟเวอร์ 1 คน", 3)
        end)
    end)
    
    CreateButton(page, "❌ ทำลาย UI ทั้งหมด", function()
        if FOVCircle then FOVCircle:Remove() end
        if TargetSnapLine then TargetSnapLine:Remove() end
        for _, data in pairs(espDrawings) do
            for _, obj in pairs(data) do pcall(function() obj:Remove() end) end
        end
        ScreenGui:Destroy()
    end)
end)

local firstBtn = Sidebar:GetChildren()[1]
if firstBtn and firstBtn:IsA("TextButton") then firstBtn.MouseButton1Click:Fire() end

RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter

    local closestPlayer = nil
    if Config.AimbotEnabled then
        local shortestDistance = FOVCircle.Radius
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = player.Character:FindFirstChild(Config.AimPart)
                if targetPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        currentLockedTarget = closestPlayer
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(Config.AimPart) then
            local targetPos = closestPlayer.Character[Config.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Config.AimSmoothness)
            local headScreen = Camera:WorldToViewportPoint(closestPlayer.Character[Config.AimPart].Position)
            TargetSnapLine.From = screenCenter
            TargetSnapLine.To = Vector2.new(headScreen.X, headScreen.Y)
            TargetSnapLine.Visible = true
        else
            TargetSnapLine.Visible = false
        end
    else
        TargetSnapLine.Visible = false
        currentLockedTarget = nil
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Config.ESP_Enabled or Config.ESP_Box then
                CreateESP(player)
                local data = espDrawings[player]
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if Config.ESP_Enabled then
                            local originPoint
                            if Config.ESP_LineMode == "Top" then
                                originPoint = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            else
                                originPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            end
                            data.Line.From = originPoint
                            data.Line.To = Vector2.new(screenPoint.X, screenPoint.Y)
                            data.Line.Color = Config.ESP_LineColor
                            data.Line.Visible = true
                            data.Text.Text = player.Name
                            data.Text.Position = Vector2.new(screenPoint.X, screenPoint.Y - 25)
                            data.Text.Visible = true
                        else
                            data.Line.Visible = false
                            data.Text.Visible = false
                        end
                        if Config.ESP_Box then
                            local head = char:FindFirstChild("Head")
                            if head then
                                local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local legScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                local height = math.abs(headScreen.Y - legScreen.Y)
                                local width = height / 2
                                local boxPos = Vector2.new(headScreen.X - width / 2, headScreen.Y)
                                data.Box.Size = Vector2.new(width, height)
                                data.Box.Position = boxPos
                                data.Box.Color = Config.ESP_LineColor
                                data.Box.Visible = true
                                if Config.ESP_Health then
                                    local humanoid = char.Humanoid
                                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                    data.HealthBarBg.Size = Vector2.new(3.5, height)
                                    data.HealthBarBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
                                    data.HealthBarBg.Visible = true
                                    local currentBarHeight = height * healthPercent
                                    data.HealthBar.Size = Vector2.new(2.5, currentBarHeight)
                                    data.HealthBar.Position = Vector2.new(boxPos.X - 5.5, boxPos.Y + (height - currentBarHeight))
                                    data.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                                    data.HealthBar.Visible = true
                                else
                                    data.HealthBar.Visible = false
                                    data.HealthBarBg.Visible = false
                                end
                            end
                        else
                            data.Box.Visible = false
                            data.HealthBar.Visible = false
                            data.HealthBarBg.Visible = false
                        end
                    else
                        data.Line.Visible = false; data.Text.Visible = false; data.Box.Visible = false; data.HealthBar.Visible = false; data.HealthBarBg.Visible = false
                    end
                else
                    data.Line.Visible = false; data.Text.Visible = false; data.Box.Visible = false; data.HealthBar.Visible = false; data.HealthBarBg.Visible = false
                end
            else
                if espDrawings[player] then
                    espDrawings[player].Line.Visible = false; espDrawings[player].Text.Visible = false; espDrawings[player].Box.Visible = false; espDrawings[player].HealthBar.Visible = false; espDrawings[player].HealthBarBg.Visible = false
                end
            end
        end
    end
end)

task.spawn(function()
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1.5, true)
    task.wait(1.5)
    if LoadingGui then LoadingGui:Destroy() end
    ToggleButton.Visible = true
    MainFrame.Visible = true
    SendNotification("ยินดีต้อนรับ", "🐱 แมวส้ม Script Hub พร้อมใช้งาน!", 3)
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
