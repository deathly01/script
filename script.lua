-- ==========================================
-- 🐱 แมวส้ม Script Hub - Complete Edition v35
-- (Steal Egg + Anti-Drop + Speed 0-500 + 4K Ground)
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
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local hasHook = (hookmetamethod ~= nil) and (hookfunction ~= nil)
local hasGetNamecall = (getnamecallmethod ~= nil)

if LocalPlayer.PlayerGui:FindFirstChild("AnimeScriptHub") then
    LocalPlayer.PlayerGui.AnimeScriptHub:Destroy()
end

-- ==========================================
-- Config
-- ==========================================
local Config = {
    AimbotEnabled = false, AimPart = "Head", FOVCircleRadius = 250,
    LockStrength = 90, WallCheck = true,
    BulletHomingEnabled = false, BulletSpeed = 500,
    ESP_Enabled = false, ESP_Box = false, ESP_Health = false,
    ESP_LineColor = Color3.fromRGB(255, 0, 255), ESP_LineMode = "Bottom",
    SpeedEnabled = false, SpeedValue = 100, SpeedBypass = true,
    FlyEnabled = false, FlySpeed = 50, FlyHeight = 10,
    SpinEnabled = false, SpinSpeed = 5,
    AntiLagEnabled = false, Ground4KEnabled = false,
    AFKEnabled = false,
    AutoCollectEnabled = false, CollectRadius = 30,
    AntiDropEnabled = false,
    FPSEnabled = false, FPSRGB = false, FPSColor = Color3.fromRGB(0, 255, 0), FPSPosition = "TopRight",
    ThemeColor = Color3.fromRGB(130, 80, 255),
    BgColor = Color3.fromRGB(20, 15, 35),
    TextColor = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 160, 190)
}

local currentLockedTarget = nil
local espDrawings = {}

-- ==========================================
-- ScreenGui
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeScriptHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true

-- Drawing API
local FOVCircle, TargetSnapLine
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = Config.FOVCircleRadius
    FOVCircle.Color = Config.ESP_LineColor
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    TargetSnapLine = Drawing.new("Line")
    TargetSnapLine.Color = Color3.fromRGB(255, 0, 0)
    TargetSnapLine.Thickness = 2
    TargetSnapLine.Transparency = 0.9
    TargetSnapLine.Visible = false
end)

-- ==========================================
-- SendNotification
-- ==========================================
local function SendNotification(title, content, duration)
    duration = duration or 3
    pcall(function()
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Instance.new("Frame")
            NotifContainer.Name = "NotifContainer"
            NotifContainer.Size = UDim2.new(0, 260, 1, 0)
            NotifContainer.Position = UDim2.new(1, -275, 0, 10)
            NotifContainer.BackgroundTransparency = 1
            NotifContainer.ZIndex = 200
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
        NotifBox.ZIndex = 200
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
        tLabel.ZIndex = 200
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
        cLabel.ZIndex = 200
        cLabel.Parent = NotifBox
        NotifBox:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        task.delay(duration, function()
            pcall(function()
                NotifBox:TweenPosition(UDim2.new(1, 50, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
                task.wait(0.3)
                NotifBox:Destroy()
            end)
        end)
    end)
end

-- ==========================================
-- ฟังก์ชันช่วย
-- ==========================================
local function GetTargetPart(character)
    if not character then return nil end
    local partNames = {Config.AimPart, "Head", "UpperTorso", "Torso", "HumanoidRootPart"}
    for _, name in ipairs(partNames) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return nil
end

local function HasLineOfSight(targetPart)
    if not Config.WallCheck then return true end
    if not targetPart then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end
    local origin = char.Head.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, params)
    if not result then return true end
    if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return false
end

local function UnlockMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.AutoRotate = true
        humanoid.Sit = false
    end
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
                pcall(function() v:Destroy() end)
            end
        end
    end
end

local function IsTargetInFOV()
    if not Config.BulletHomingEnabled then return false end
    if not currentLockedTarget or not currentLockedTarget.Character then return false end
    local targetPart = GetTargetPart(currentLockedTarget.Character)
    if not targetPart then return false end
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
    if FOVCircle and distanceFromCenter > FOVCircle.Radius then return false end
    if not HasLineOfSight(targetPart) then return false end
    return true, targetPart
end

-- ==========================================
-- ✅ ระบบขโมยไข่ (กดวิเดี่ยว)
-- ==========================================
local Stealing = false

local function FindNearestEgg()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local nearest = nil
    local shortest = Config.CollectRadius
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and part ~= hrp then
                local name = string.lower(obj.Name)
                if string.find(name, "egg") or string.find(name, "steal") or string.find(name, "pet") then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        nearest = part
                    end
                end
            end
        end
    end
    return nearest
end

-- ✅ ฟังก์ชันขโมยไข่แบบกดวิเดี่ยว
local function StealEggOnce()
    if Stealing then
        SendNotification("ขโมยไข่", "กำลังขโมยอยู่...", 2)
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        SendNotification("ขโมยไข่", "ไม่พบตัวละคร", 2)
        return
    end
    
    local hrp = char.HumanoidRootPart
    local originalCFrame = hrp.CFrame
    
    -- หาไข่ที่ใกล้สุด
    local egg = FindNearestEgg()
    if not egg then
        SendNotification("ขโมยไข่", "ไม่พบไข่ในระยะ " .. Config.CollectRadius, 2)
        return
    end
    
    Stealing = true
    SendNotification("ขโมยไข่", "วาปไปเก็บ: " .. egg.Name, 2)
    
    -- วาปไปที่ไข่
    pcall(function()
        hrp.CFrame = CFrame.new(egg.Position)
    end)
    
    -- รอ 0.15 วิ (ให้ Server บันทึกการเก็บ)
    task.wait(0.15)
    
    -- วาปกลับ
    pcall(function()
        hrp.CFrame = originalCFrame
    end)
    
    task.wait(0.1)
    Stealing = false
    SendNotification("ขโมยไข่", "เก็บไข่สำเร็จ!", 2)
end

-- ✅ ระบบกันไข่ตกจากมือ
local AntiDropConnection = nil

local function EnableAntiDrop()
    AntiDropConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiDropEnabled then
            if AntiDropConnection then AntiDropConnection:Disconnect() end
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        -- ตรวจสอบ Tool ในมือ
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local name = string.lower(tool.Name)
            if string.find(name, "egg") or string.find(name, "steal") or string.find(name, "pet") then
                -- กันไม่ให้ Tool ถูก Unequip
                pcall(function()
                    if tool.Parent ~= char then
                        tool.Parent = char
                    end
                end)
                -- ล็อกตำแหน่ง
                pcall(function()
                    if tool:FindFirstChild("Handle") then
                        tool.Handle.CanCollide = false
                    end
                end)
            end
        end
        
        -- ตรวจสอบของที่ถือ (ติดตัว)
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then
                local name = string.lower(v.Name)
                if string.find(name, "egg") or string.find(name, "steal") or string.find(name, "pet") then
                    pcall(function()
                        if v.Parent ~= char then
                            v.Parent = char
                        end
                    end)
                end
            end
        end
    end)
end

local function DisableAntiDrop()
    if AntiDropConnection then AntiDropConnection:Disconnect(); AntiDropConnection = nil end
end

-- ==========================================
-- FPS Counter RGB
-- ==========================================
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 120, 0, 30)
FPSLabel.Position = UDim2.new(1, -130, 0, 10)
FPSLabel.BackgroundColor3 = Config.BgColor
FPSLabel.BackgroundTransparency = 0.3
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Config.FPSColor
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Visible = false
FPSLabel.ZIndex = 150
FPSLabel.Parent = ScreenGui
Instance.new("UICorner", FPSLabel).CornerRadius = UDim.new(0, 6)
local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = Config.ThemeColor
fpsStroke.Thickness = 1.5
fpsStroke.Transparency = 0.3
fpsStroke.Parent = FPSLabel

local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    return Color3.new(r, g, b)
end

local function UpdateFPSPosition(pos)
    Config.FPSPosition = pos
    if pos == "TopLeft" then FPSLabel.Position = UDim2.new(0, 10, 0, 10)
    elseif pos == "TopRight" then FPSLabel.Position = UDim2.new(1, -130, 0, 10)
    elseif pos == "BottomLeft" then FPSLabel.Position = UDim2.new(0, 10, 1, -40)
    elseif pos == "BottomRight" then FPSLabel.Position = UDim2.new(1, -130, 1, -40) end
end

task.spawn(function()
    local frameCount = 0
    local lastTime = tick()
    local hue = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            if Config.FPSEnabled then 
                FPSLabel.Text = "FPS: " .. frameCount
                FPSLabel.TextColor3 = Config.FPSRGB and HSVtoRGB(hue, 1, 1) or Config.FPSColor
            end
            frameCount = 0
            lastTime = now
        end
        if Config.FPSRGB and Config.FPSEnabled then
            hue = (hue + 0.003) % 1
        end
    end)
end)

-- ==========================================
-- Loading Screen
-- ==========================================
local LoadingGui = Instance.new("Frame")
LoadingGui.Size = UDim2.new(0, 360, 0, 180)
LoadingGui.Position = UDim2.new(0.5, -180, 0.5, -90)
LoadingGui.BackgroundColor3 = Config.BgColor
LoadingGui.BackgroundTransparency = 0.15
LoadingGui.ZIndex = 100
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
StatusText.ZIndex = 101
StatusText.Parent = LoadingGui
local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.8, 0, 0, 12)
BarBg.Position = UDim2.new(0.1, 0, 0, 125)
BarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
BarBg.BackgroundTransparency = 0.5
BarBg.ZIndex = 101
BarBg.Parent = LoadingGui
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Config.ThemeColor
BarFill.ZIndex = 102
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- ==========================================
-- Main Frame
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Config.BgColor
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Active = true
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

-- Header
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
CloseBtn.ZIndex = 5
CloseBtn.Active = true
CloseBtn.Parent = HeaderBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Drag
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

-- Sidebar
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

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Config.BgColor
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://103628356622817"
ToggleButton.Visible = false
ToggleButton.Active = true
ToggleButton.AutoButtonColor = false
ToggleButton.ZIndex = 100
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Config.ThemeColor
btnStroke.Thickness = 2
btnStroke.Parent = ToggleButton

local btnDragging = false
local btnDragStart, btnStartPos
local btnMoved = false

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnMoved = false
        btnDragStart = input.Position
        btnStartPos = ToggleButton.Position
    end
end)
ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false
        if not btnMoved then MainFrame.Visible = not MainFrame.Visible end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        if math.abs(delta.X) > 10 or math.abs(delta.Y) > 10 then btnMoved = true end
        ToggleButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- UI Components
-- ==========================================
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
    btn.Active = true
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
    toggleBtn.ZIndex = 6
    toggleBtn.Active = true
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = currentState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 7
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
    sliderBtn.Active = true
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

-- ✅ TextBox Slider (ใส่ตัวเลขเอง)
local function CreateTextBox(parent, text, flagName, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = container
    local currentValue = Config[flagName] or default
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, 0, 1, 0)
    box.Position = UDim2.new(0.6, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    box.Text = tostring(currentValue)
    box.TextColor3 = Config.TextColor
    box.PlaceholderText = "0-500"
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ZIndex = 6
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            val = math.clamp(val, 0, 500)
            Config[flagName] = val
            box.Text = tostring(val)
            if callback then callback(val) end
        else
            box.Text = tostring(currentValue)
        end
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
    btn.ZIndex = 6
    btn.Active = true
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
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

-- ==========================================
-- Anti-Lag / AFK
-- ==========================================
local AntiLagConnection = nil
local AFKConnection = nil

local function EnableAntiLag()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
    end)
    AntiLagConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiLagEnabled then
            if AntiLagConnection then AntiLagConnection:Disconnect() end
            return
        end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                pcall(function() v.Enabled = false end)
            end
        end
    end)
end

local function DisableAntiLag()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
    end)
    if AntiLagConnection then AntiLagConnection:Disconnect(); AntiLagConnection = nil end
end

local function EnableAFK()
    AFKConnection = RunService.Heartbeat:Connect(function()
        if not Config.AFKEnabled then
            if AFKConnection then AFKConnection:Disconnect() end
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid:GetState() == Enum.HumanoidStateType.Seated then return end
            pcall(function() humanoid.Jump = true end)
        end
    end)
end

local function DisableAFK()
    if AFKConnection then AFKConnection:Disconnect(); AFKConnection = nil end
end

-- ==========================================
-- ✅ ระบบพื้น 4K
-- ==========================================
local Ground4KEffects = {}

local function Enable4KGround()
    pcall(function()
        -- เพิ่มความละเอียดของ Texture
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        settings().Rendering.EditQualityLevel = 21
    end)
    
    pcall(function()
        -- เพิ่มความละเอียดให้พื้น
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("ground") or obj.Name:lower():find("floor") or obj.Name:lower():find("terrain") then
                pcall(function()
                    obj.Material = Enum.Material.Grass
                    obj.Reflectance = 0.1
                end)
            end
        end
    end)
    
    -- เพิ่ม Effect ให้ภาพสวยขึ้น
    pcall(function()
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "4K_CC"
        cc.Brightness = 0.05
        cc.Contrast = 0.2
        cc.Saturation = 0.35
        cc.TintColor = Color3.fromRGB(255, 250, 245)
        cc.Parent = Lighting
        table.insert(Ground4KEffects, cc)
        
        local bloom = Instance.new("BloomEffect")
        bloom.Name = "4K_Bloom"
        bloom.Intensity = 1.5
        bloom.Size = 28
        bloom.Threshold = 0.85
        bloom.Parent = Lighting
        table.insert(Ground4KEffects, bloom)
        
        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Name = "4K_SunRays"
        sunRays.Intensity = 0.15
        sunRays.Spread = 1
        sunRays.Parent = Lighting
        table.insert(Ground4KEffects, sunRays)
        
        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "4K_Atmosphere"
        atmosphere.Density = 0.3
        atmosphere.Offset = 0.25
        atmosphere.Color = Color3.fromRGB(199, 199, 199)
        atmosphere.Decay = Color3.fromRGB(106, 112, 125)
        atmosphere.Glare = 0.5
        atmosphere.Haze = 1.5
        atmosphere.Parent = Lighting
        table.insert(Ground4KEffects, atmosphere)
        
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2.5
        Lighting.Ambient = Color3.fromRGB(75, 75, 75)
        Lighting.OutdoorAmbient = Color3.fromRGB(135, 135, 135)
        Lighting.EnvironmentDiffuseScale = 0.6
        Lighting.EnvironmentSpecularScale = 0.6
        Lighting.ShadowSoftness = 0.4
    end)
    
    SendNotification("4K Ground", "เปิดแล้ว - พื้นสวย 4K!", 3)
end

local function Disable4KGround()
    for _, effect in pairs(Ground4KEffects) do
        pcall(function() effect:Destroy() end)
    end
    Ground4KEffects = {}
    SendNotification("4K Ground", "ปิดโหมดพื้น 4K", 2)
end

-- ==========================================
-- Silent Aim Hooks
-- ==========================================
if hasHook and hasGetNamecall then
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local ok, inFOV, targetPart = pcall(IsTargetInFOV)
            if ok and inFOV and targetPart then
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local args = {...}
                    local modified = false
                    for i, arg in pairs(args) do
                        if typeof(arg) == "CFrame" then args[i] = CFrame.new(arg.Position, targetPart.Position); modified = true
                        elseif typeof(arg) == "Vector3" then args[i] = targetPart.Position; modified = true
                        end
                    end
                    if modified then return oldNamecall(self, unpack(args)) end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- ==========================================
-- เมนู: หน้าหลัก
-- ==========================================
CreateSidebarButton("🏠 หน้าหลัก", 1, function()
    local page = CreatePage("หน้าหลัก")
    
    CreateToggle(page, "🎯 ล็อกเป้าหมาย (Aimbot)", "AimbotEnabled", false, function(state)
        if FOVCircle then FOVCircle.Visible = state end
        if not state then 
            if TargetSnapLine then TargetSnapLine.Visible = false end
            currentLockedTarget = nil 
        end
    end)
    
    local aimModeBtn = Instance.new("TextButton")
    aimModeBtn.Size = UDim2.new(1, 0, 0, 35)
    aimModeBtn.BackgroundColor3 = Config.ThemeColor
    aimModeBtn.Text = "🎯 โหมดล็อก: " .. (Config.AimPart == "Head" and "หัว" or "ตัว")
    aimModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimModeBtn.TextSize = 14
    aimModeBtn.Font = Enum.Font.GothamBold
    aimModeBtn.ZIndex = 6
    aimModeBtn.Active = true
    aimModeBtn.Parent = page
    Instance.new("UICorner", aimModeBtn).CornerRadius = UDim.new(0, 8)
    aimModeBtn.MouseButton1Click:Connect(function()
        Config.AimPart = (Config.AimPart == "Head") and "HumanoidRootPart" or "Head"
        aimModeBtn.Text = "🎯 โหมดล็อก: " .. (Config.AimPart == "Head" and "หัว" or "ตัว")
    end)
    
    CreateSlider(page, "📡 ขนาด FOV กลางจอ", 50, 500, "FOVCircleRadius", 250, function(value)
        if FOVCircle then FOVCircle.Radius = value end
    end)
    
    CreateSlider(page, "🔒 ความแรงล็อก (0=นุ่ม, 100=Snap)", 0, 100, "LockStrength", 90, function(value)
        Config.LockStrength = value
    end)
    
    CreateToggle(page, "🧱 ไม่ล็อกผ่านกำแพง (Wall Check)", "WallCheck", true, function(state) end)
    CreateToggle(page, "🚀 กระสุนติดตามเป้า (Silent Aim)", "BulletHomingEnabled", false, function(state)
        if FOVCircle then FOVCircle.Visible = state end
    end)
    CreateSlider(page, "⚡ ความเร็วกระสุน", 100, 1500, "BulletSpeed", 500, function(value) end)
end)

-- ==========================================
-- ✅ เมนู: ขโมยไข่ (กดวิเดี่ยว)
-- ==========================================
CreateSidebarButton("🥚 ขโมยไข่", 2, function()
    local page = CreatePage("ขโมยไข่ (Steal Egg)")
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60)
    info.BackgroundTransparency = 1
    info.Text = "ระบบขโมยไข่ (กดวิเดี่ยว)\nกดปุ่ม → วาปไปเก็บไข่ → วาปกลับทันที"
    info.TextColor3 = Config.TextDim
    info.TextSize = 12
    info.Font = Enum.Font.Gotham
    info.TextWrapped = true
    info.ZIndex = 3
    info.Parent = page
    
    -- ✅ ปุ่มกดขโมยไข่
    local stealBtn = Instance.new("TextButton")
    stealBtn.Size = UDim2.new(1, 0, 0, 55)
    stealBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    stealBtn.Text = "🥚 ขโมยไข่ (กด)"
    stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stealBtn.TextSize = 16
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.ZIndex = 6
    stealBtn.Active = true
    stealBtn.Parent = page
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)
    stealBtn.MouseButton1Click:Connect(function()
        StealEggOnce()
    end)
    
    CreateSlider(page, "📦 รัศมีขโมยไข่", 10, 200, "CollectRadius", 30, function(value)
        Config.CollectRadius = value
    end)
    
    -- ✅ ระบบกันไข่ตกจากมือ
    CreateToggle(page, "🛡️ กันไข่ตกจากมือ (Anti-Drop)", "AntiDropEnabled", false, function(state)
        if state then 
            EnableAntiDrop()
            SendNotification("Anti-Drop", "เปิด - ไข่จะไม่ตกจากมือ!", 3)
        else 
            DisableAntiDrop()
            SendNotification("Anti-Drop", "ปิด", 2)
        end
    end)
    
    local info2 = Instance.new("TextLabel")
    info2.Size = UDim2.new(1, 0, 0, 40)
    info2.BackgroundTransparency = 1
    info2.Text = "หมายเหตุ: Anti-Drop จะล็อกไข่ที่ขโมยมาไว้ในมือ"
    info2.TextColor3 = Color3.fromRGB(255, 200, 100)
    info2.TextSize = 11
    info2.Font = Enum.Font.Gotham
    info2.TextWrapped = true
    info2.ZIndex = 3
    info2.Parent = page
end)

-- ==========================================
-- เมนู: ผู้เล่น
-- ==========================================
CreateSidebarButton("👥 ผู้เล่น", 3, function()
    local page = CreatePage("รายชื่อผู้เล่น & วาป")
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 35)
    refreshBtn.BackgroundColor3 = Config.ThemeColor
    refreshBtn.Text = "🔄 รีเฟรชรายชื่อผู้เล่น"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.TextSize = 14
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.ZIndex = 6
    refreshBtn.Active = true
    refreshBtn.Parent = page
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)
    
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, 0, 0, 350)
    playerListFrame.BackgroundColor3 = Config.BgColor
    playerListFrame.BackgroundTransparency = 0.7
    playerListFrame.ZIndex = 3
    playerListFrame.Parent = page
    Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 8)
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = playerListFrame
    
    local function RefreshPlayerList()
        for _, v in pairs(playerListFrame:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -10, 0, 40)
                row.Position = UDim2.new(0, 5, 0, 0)
                row.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
                row.ZIndex = 4
                row.Parent = playerListFrame
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
                nameLabel.Position = UDim2.new(0, 5, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Config.TextColor
                nameLabel.TextSize = 12
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 5
                nameLabel.Parent = row
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0, 50, 0, 28)
                tpBtn.Position = UDim2.new(0.55, 0, 0.5, -14)
                tpBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
                tpBtn.Text = "วาป"
                tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                tpBtn.TextSize = 12
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.ZIndex = 5
                tpBtn.Active = true
                tpBtn.Parent = row
                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
                tpBtn.MouseButton1Click:Connect(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 3)
                    end
                end)
                local resetBtn = Instance.new("TextButton")
                resetBtn.Size = UDim2.new(0, 50, 0, 28)
                resetBtn.Position = UDim2.new(0.75, 0, 0.5, -14)
                resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                resetBtn.Text = "รี"
                resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                resetBtn.TextSize = 12
                resetBtn.Font = Enum.Font.GothamBold
                resetBtn.ZIndex = 5
                resetBtn.Active = true
                resetBtn.Parent = row
                Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
                resetBtn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                        player.Character:FindFirstChildOfClass("Humanoid").Health = 0
                    end
                end)
            end
        end
    end
    refreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
    Players.PlayerAdded:Connect(function() task.wait(0.5); RefreshPlayerList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5); RefreshPlayerList() end)
    task.wait(0.1)
    RefreshPlayerList()
end)

-- ==========================================
-- ✅ เมนู: ผู้เล่น/บิน (Speed 0-500 + Bypass)
-- ==========================================
CreateSidebarButton("👤 ผู้เล่น/บิน", 4, function()
    local page = CreatePage("ผู้เล่น & การเคลื่อนที่")
    
    -- ✅ Speed ใส่ตัวเลข 0-500
    CreateTextBox(page, "⚡ ความเร็ววิ่ง (0-500)", "SpeedValue", 100, function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end)
    
    CreateToggle(page, "🏃 วิ่งเร็ว", "SpeedEnabled", false, function(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = state and Config.SpeedValue or 16
        end
    end)
    
    CreateToggle(page, "🛡️ Bypass Anti-Cheat (ทุกแมพ)", "SpeedBypass", true, function(state) end)
    
    -- Fly
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
                UnlockMovement()
            end
        end
    end)
    
    CreateToggle(page, "🌀 หมุนตัว (Spin)", "SpinEnabled", false, function(state) end)
    CreateSlider(page, "ความเร็วหมุน", 1, 30, "SpinSpeed", 5, function(value) end)
    CreateButton(page, "🔓 ปลดล็อกการเคลื่อนที่", function()
        UnlockMovement()
    end)
end)

-- ==========================================
-- เมนู: เส้นมอง
-- ==========================================
CreateSidebarButton("👁️ เส้นมอง", 5, function()
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
    modeBtn.ZIndex = 6
    modeBtn.Active = true
    modeBtn.Parent = page
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)
    modeBtn.MouseButton1Click:Connect(function()
        Config.ESP_LineMode = (Config.ESP_LineMode == "Top") and "Bottom" or "Top"
        modeBtn.Text = "📍 ตำแหน่งเส้น: " .. (Config.ESP_LineMode == "Top" and "ด้านบน" or "ด้านล่าง")
    end)
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(1, 0, 0, 35)
    colorBtn.BackgroundColor3 = Config.ESP_LineColor
    colorBtn.Text = "🎨 เปลี่ยนสีเส้น ESP"
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBtn.TextSize = 14
    colorBtn.Font = Enum.Font.Gotham
    colorBtn.ZIndex = 6
    colorBtn.Active = true
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
        if FOVCircle then FOVCircle.Color = newColor end
    end)
end)

-- ==========================================
-- ✅ เมนู: ตั้งค่า (เพิ่ม 4K Ground)
-- ==========================================
CreateSidebarButton("⚙️ ตั้งค่า", 6, function()
    local page = CreatePage("ตั้งค่า")
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 60)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "🐱 แมวส้ม Script Hub\nเวอร์ชัน: 35.0\nHook: " .. (hasHook and "✅ รองรับ" or "❌ ไม่รองรับ")
    infoLabel.TextColor3 = Config.TextDim
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.ZIndex = 3
    infoLabel.Parent = page
    
    -- ✅ 4K Ground
    CreateToggle(page, "🎨 พื้นสวยขึ้น 4K (4K Ground)", "Ground4KEnabled", false, function(state)
        if state then Enable4KGround() else Disable4KGround() end
    end)
    
    CreateButton(page, "🔍 ค้นหาเซิร์ฟเวอร์ว่าง (1 คน)", function()
        SendNotification("Server Finder", "กำลังค้นหา...", 2)
        local ServerFrame = Instance.new("Frame")
        ServerFrame.Size = UDim2.new(0, 400, 0, 300)
        ServerFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
        ServerFrame.BackgroundColor3 = Config.BgColor
        ServerFrame.BackgroundTransparency = 0.1
        ServerFrame.ZIndex = 50
        ServerFrame.Parent = ScreenGui
        Instance.new("UICorner", ServerFrame).CornerRadius = UDim.new(0, 12)
        local sfTitle = Instance.new("TextLabel")
        sfTitle.Size = UDim2.new(1, 0, 0, 40)
        sfTitle.BackgroundTransparency = 1
        sfTitle.Text = "Server Finder 💻"
        sfTitle.TextColor3 = Config.TextColor
        sfTitle.TextSize = 18
        sfTitle.Font = Enum.Font.GothamBold
        sfTitle.ZIndex = 51
        sfTitle.Parent = ServerFrame
        local sfClose = Instance.new("TextButton")
        sfClose.Size = UDim2.new(0, 30, 0, 30)
        sfClose.Position = UDim2.new(1, -35, 0, 5)
        sfClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        sfClose.Text = "X"
        sfClose.TextColor3 = Color3.fromRGB(255, 255, 255)
        sfClose.ZIndex = 51
        sfClose.Parent = ServerFrame
        Instance.new("UICorner", sfClose).CornerRadius = UDim.new(0, 6)
        sfClose.MouseButton1Click:Connect(function() ServerFrame:Destroy() end)
        local sfScroll = Instance.new("ScrollingFrame")
        sfScroll.Size = UDim2.new(1, -20, 1, -50)
        sfScroll.Position = UDim2.new(0, 10, 0, 45)
        sfScroll.BackgroundTransparency = 1
        sfScroll.ZIndex = 51
        sfScroll.Parent = ServerFrame
        local sfLayout = Instance.new("UIListLayout")
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
                            serverBtn.ZIndex = 52
                            serverBtn.Parent = sfScroll
                            Instance.new("UICorner", serverBtn).CornerRadius = UDim.new(0, 6)
                            local joinBtn = Instance.new("TextButton")
                            joinBtn.Size = UDim2.new(0, 60, 0, 25)
                            joinBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
                            joinBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
                            joinBtn.Text = "Join"
                            joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            joinBtn.Font = Enum.Font.GothamBold
                            joinBtn.ZIndex = 53
                            joinBtn.Parent = serverBtn
                            Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
                            joinBtn.MouseButton1Click:Connect(function()
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
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
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
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
    
    CreateToggle(page, "⚡ แก้กระตุก (Anti-Lag)", "AntiLagEnabled", false, function(state)
        if state then EnableAntiLag() else DisableAntiLag() end
    end)
    
    CreateToggle(page, "💤 AFK (กันเตะ)", "AFKEnabled", false, function(state)
        if state then EnableAFK() else DisableAFK() end
    end)
    
    CreateToggle(page, "📊 แสดง FPS", "FPSEnabled", false, function(state)
        FPSLabel.Visible = state
    end)
    
    CreateToggle(page, "🌈 FPS สี RGB", "FPSRGB", false, function(state) end)
    
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

-- ==========================================
-- Main Loop (Speed Bypass)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.SpeedEnabled and Config.SpeedBypass then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                pcall(function()
                    char:FindFirstChildOfClass("Humanoid").WalkSpeed = Config.SpeedValue
                end)
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if FOVCircle then FOVCircle.Position = screenCenter end

    local closestPlayer = nil
    if Config.AimbotEnabled then
        local shortestDistance = FOVCircle and FOVCircle.Radius or 250
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = GetTargetPart(player.Character)
                if targetPart and HasLineOfSight(targetPart) then
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
        
        if closestPlayer and closestPlayer.Character then
            local targetPart = GetTargetPart(closestPlayer.Character)
            if targetPart then
                local targetPos = targetPart.Position
                if Config.LockStrength >= 99 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                else
                    local lockSmoothness = 1 - (Config.LockStrength / 100)
                    local aimSpeed = math.clamp(1 - lockSmoothness, 0.05, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSpeed)
                end
                if TargetSnapLine then
                    local headScreen = Camera:WorldToViewportPoint(targetPos)
                    TargetSnapLine.From = screenCenter
                    TargetSnapLine.To = Vector2.new(headScreen.X, headScreen.Y)
                    TargetSnapLine.Visible = true
                end
            else
                if TargetSnapLine then TargetSnapLine.Visible = false end
            end
        else
            if TargetSnapLine then TargetSnapLine.Visible = false end
        end
    else
        if TargetSnapLine then TargetSnapLine.Visible = false end
        currentLockedTarget = nil
    end

    -- ESP Loop
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

-- ==========================================
-- โหลดเสร็จ
-- ==========================================
task.spawn(function()
    task.wait(0.5)
    if BarFill then
        BarFill:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, true)
    end
    task.wait(1)
    if LoadingGui then LoadingGui:Destroy() end
    if ToggleButton then ToggleButton.Visible = true end
    if MainFrame then MainFrame.Visible = true end
    SendNotification("ยินดีต้อนรับ", "🐱 แมวส้ม Script Hub v35 พร้อมใช้งาน!", 3)
end)
