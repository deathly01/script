-- ==========================================
-- Robot Script Hub | Chili UI Version (Android)
-- ==========================================

-- โหลดไลบรารี Chili UI (ใช้ลิงก์ไลบรารีจริงเพื่อให้ UI ทำงานได้ถูกต้อง)
local Chili = loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

-- สร้างหน้าต่างหลักของ Chili
local Window = Chili:CreateWindow("🐱 แมวส้ม Script Hub")

-- สร้างแท็บต่างๆ
local MainTab = Window:CreateTab("ฟังก์ชันหลัก")
local CombatTab = Window:CreateTab("ล็อกเป้า & กระสุน")
local EspTab = Window:CreateTab("ระบบ ESP")
local MiscTab = Window:CreateTab("เคลื่อนที่ & บิน")

----------------------------------------------------------------
-- ตัวแปรสถานะ
----------------------------------------------------------------
local AutoFarmEnabled = false
local WalkSpeedValue = 16
local SafeSpeedEnabled = false

-- ตัวแปรระบบบิน
local flying = false
local flySpeed = 50
local flyConnection = nil
local mobileFlyGui = nil
local moveDir = Vector3.new(0, 0, 0)

-- ตัวแปร Aimbot & กระสุนติดตาม
local AimbotEnabled = false
local BulletHomingEnabled = false
local AimPart = "Head"
local currentLockedTarget = nil
local AimSmoothness = 0.15

-- ตัวแปร ESP & สีของเส้น
local ESPEnabled = false
local BoxESPEnabled = false
local espDrawings = {}
local LineColor = Color3.fromRGB(255, 255, 255)
local TargetLineColor = Color3.fromRGB(255, 0, 0)
local TracerPosition = "ด้านล่าง"

-- เส้นตรงชี้เป้า (Target Snap Line)
local TargetSnapLine = Drawing.new("Line")
TargetSnapLine.Color = TargetLineColor
TargetSnapLine.Thickness = 2
TargetSnapLine.Transparency = 0.9
TargetSnapLine.Visible = false

-- วงกลม FOV ตรงกลางจอ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = 180
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

----------------------------------------------------------------
-- 1. แท็บฟังก์ชันหลัก
----------------------------------------------------------------
MainTab:CreateToggle("เปิด/ปิด ออโต้ฟาร์มเงิน", false, function(Value)
    AutoFarmEnabled = Value
    spawn(function()
        while AutoFarmEnabled do
            task.wait(1)
            print("กำลังฟาร์มเงิน...")
        end
    end)
end)

MainTab:CreateButton("รีเซ็ตตัวละคร", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
    end
end)

----------------------------------------------------------------
-- 2. แท็บกระสุนติดตาม & ล็อกหัว
----------------------------------------------------------------
CombatTab:CreateToggle("🎯 เปิด/ปิด ล็อกเป้า (Aimbot)", false, function(Value)
    AimbotEnabled = Value
    FOVCircle.Visible = Value
    if not Value then
        TargetSnapLine.Visible = false
        currentLockedTarget = nil
    end
end)

CombatTab:CreateToggle("🚀 เปิด/ปิด กระสุนเลี้ยวโค้ง (Bullet Homing)", false, function(Value)
    BulletHomingEnabled = Value
end)

CombatTab:CreateSlider("📏 ขนาดวงกลมล็อกเป้า FOV", 50, 400, 180, function(Value)
    FOVCircle.Radius = Value
end)

CombatTab:CreateSlider("⚡ ความเร็วในการเล็งตามเป้า", 1, 50, 15, function(Value)
    AimSmoothness = Value / 100
end)

----------------------------------------------------------------
-- 3. แท็บระบบ ESP
----------------------------------------------------------------
EspTab:CreateToggle("👁️ เปิด/ปิด เส้นมอง (Tracer) และชื่อ", false, function(Value)
    ESPEnabled = Value
    if not ESPEnabled then
        for _, data in pairs(espDrawings) do
            if data.Line then data.Line:Remove() end
            if data.Text then data.Text:Remove() end
            if data.Box then data.Box:Remove() end
            if data.HealthBar then data.HealthBar:Remove() end
            if data.HealthBarBg then data.HealthBarBg:Remove() end
        end
        espDrawings = {}
    end
end)

EspTab:CreateToggle("📦 เปิด/ปิด กล่องครอบตัว & หลอดเลือด", false, function(Value)
    BoxESPEnabled = Value
end)

EspTab:CreateDropdown("📍 ตำแหน่งเส้น Tracer", {"ด้านล่าง", "ด้านบน"}, function(Option)
    if type(Option) == "table" then
        TracerPosition = Option[1] or "ด้านล่าง"
    else
        TracerPosition = tostring(Option)
    end
end)

local function CreateESP(player)
    if espDrawings[player] then return end
    
    local line = Drawing.new("Line")
    line.Color = LineColor
    line.Thickness = 1.5
    line.Transparency = 0.8
    line.Visible = false

    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Visible = false

    local box = Drawing.new("Square")
    box.Color = LineColor
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = 0.8
    box.Visible = false

    local healthBarBg = Drawing.new("Square")
    healthBarBg.Color = Color3.fromRGB(0, 0, 0)
    healthBarBg.Thickness = 1
    healthBarBg.Filled = true
    healthBarBg.Transparency = 0.7
    healthBarBg.Visible = false

    local healthBar = Drawing.new("Square")
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 1
    healthBar.Visible = false

    espDrawings[player] = {
        Line = line, 
        Text = text, 
        Box = box, 
        HealthBarBg = healthBarBg, 
        HealthBar = healthBar
    }
end

local function RemoveESP(player)
    if espDrawings[player] then
        if espDrawings[player].Line then espDrawings[player].Line:Remove() end
        if espDrawings[player].Text then espDrawings[player].Text:Remove() end
        if espDrawings[player].Box then espDrawings[player].Box:Remove() end
        if espDrawings[player].HealthBar then espDrawings[player].HealthBar:Remove() end
        if espDrawings[player].HealthBarBg then espDrawings[player].HealthBarBg:Remove() end
        espDrawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

----------------------------------------------------------------
-- ระบบกระสุนติดตามเป้าหมาย (Bullet Homing Hook)
----------------------------------------------------------------
RunService.Stepped:Connect(function()
    if BulletHomingEnabled and currentLockedTarget and currentLockedTarget.Character then
        local targetPart = currentLockedTarget.Character:FindFirstChild(AimPart)
        if targetPart then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name == "Bullet" or obj.Name == "Projectile" or obj.Name == "Part" or obj.Name == "Fireball") then
                    if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                        obj.CFrame = CFrame.new(obj.Position, targetPart.Position)
                        obj.Velocity = (targetPart.Position - obj.Position).Unit * 300
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- ลูปการทำงานหลัก (RenderStepped)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter

    -- 1. Aimbot Logic
    local closestPlayer = nil
    if AimbotEnabled then
        local shortestDistance = FOVCircle.Radius

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = player.Character:FindFirstChild(AimPart)
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

        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(AimPart) then
            local targetPos = closestPlayer.Character[AimPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)

            local headScreen = Camera:WorldToViewportPoint(closestPlayer.Character[AimPart].Position)
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

    -- 2. ESP Logic
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPEnabled or BoxESPEnabled then
                CreateESP(player)
                local data = espDrawings[player]
                local char = player.Character
                
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    
                    if onScreen then
                        if ESPEnabled then
                            local originPoint
                            if TracerPosition == "ด้านบน" then
                                originPoint = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            else
                                originPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            end

                            data.Line.From = originPoint
                            data.Line.To = Vector2.new(screenPoint.X, screenPoint.Y)
                            data.Line.Visible = true

                            data.Text.Text = player.Name
                            data.Text.Position = Vector2.new(screenPoint.X, screenPoint.Y - 25)
                            data.Text.Visible = true
                        else
                            data.Line.Visible = false
                            data.Text.Visible = false
                        end

                        if BoxESPEnabled then
                            local head = char:FindFirstChild("Head")
                            if head then
                                local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local legScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                local height = math.abs(headScreen.Y - legScreen.Y)
                                local width = height / 2

                                local boxPos = Vector2.new(headScreen.X - width / 2, headScreen.Y)
                                data.Box.Size = Vector2.new(width, height)
                                data.Box.Position = boxPos
                                data.Box.Visible = true

                                local humanoid = char.Humanoid
                                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                
                                local barHeight = height
                                local barWidth = 3.5
                                local barX = boxPos.X - 6
                                local barY = boxPos.Y

                                data.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
                                data.HealthBarBg.Position = Vector2.new(barX, barY)
                                data.HealthBarBg.Visible = true

                                local currentBarHeight = barHeight * healthPercent
                                data.HealthBar.Size = Vector2.new(barWidth - 1, currentBarHeight)
                                data.HealthBar.Position = Vector2.new(barX + 0.5, barY + (barHeight - currentBarHeight))
                                data.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                                data.HealthBar.Visible = true
                            else
                                data.Box.Visible = false
                                data.HealthBar.Visible = false
                                data.HealthBarBg.Visible = false
                            end
                        else
                            data.Box.Visible = false
                            data.HealthBar.Visible = false
                            data.HealthBarBg.Visible = false
                        end
                    else
                        data.Line.Visible = false
                        data.Text.Visible = false
                        data.Box.Visible = false
                        data.HealthBar.Visible = false
                        data.HealthBarBg.Visible = false
                    end
                else
                    data.Line.Visible = false
                    data.Text.Visible = false
                    data.Box.Visible = false
                    data.HealthBar.Visible = false
                    data.HealthBarBg.Visible = false
                end
            else
                if espDrawings[player] then
                    espDrawings[player].Line.Visible = false
                    espDrawings[player].Text.Visible = false
                    espDrawings[player].Box.Visible = false
                    espDrawings[player].HealthBar.Visible = false
                    espDrawings[player].HealthBarBg.Visible = false
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- 4. แท็บเคลื่อนที่ & บิน
----------------------------------------------------------------
MiscTab:CreateToggle("🛡️ วิ่งเร็วปลอดภัย (Anti-Ban)", false, function(Value)
    SafeSpeedEnabled = Value
    if not SafeSpeedEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end)

MiscTab:CreateSlider("⚡ ปรับความเร็ว (Speed)", 16, 60, 16, function(Value)
    WalkSpeedValue = Value
end)

spawn(function()
    while true do
        task.wait(0.2)
        if SafeSpeedEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = WalkSpeedValue
            end
        end
    end
end)

local function CreateMobileFlyUI()
    if mobileFlyGui then mobileFlyGui:Destroy() end
    
    mobileFlyGui = Instance.new("ScreenGui")
    mobileFlyGui.Name = "MobileFlyGui"
    mobileFlyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    mobileFlyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local FlyFrame = Instance.new("Frame")
    FlyFrame.Size = UDim2.new(0, 150, 0, 150)
    FlyFrame.Position = UDim2.new(0.8, -75, 0.6, 0)
    FlyFrame.BackgroundTransparency = 1
    FlyFrame.Parent = mobileFlyGui

    local btnUp = Instance.new("TextButton")
    btnUp.Size = UDim2.new(0, 60, 0, 60)
    btnUp.Position = UDim2.new(0.5, -30, 0, 0)
    btnUp.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    btnUp.Text = "⬆️ ขึ้น"
    btnUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnUp.Parent = FlyFrame
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)

    local btnDown = Instance.new("TextButton")
    btnDown.Size = UDim2.new(0, 60, 0, 60)
    btnDown.Position = UDim2.new(0.5, -30, 0, 90)
    btnDown.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    btnDown.Text = "⬇️ ลง"
    btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnDown.Parent = FlyFrame
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)

    btnUp.MouseButton1Down:Connect(function() moveDir = Vector3.new(0, 1, 0) end)
    btnUp.MouseButton1Up:Connect(function() moveDir = Vector3.new(0, 0, 0) end)
    btnDown.MouseButton1Down:Connect(function() moveDir = Vector3.new(0, -1, 0) end)
    btnDown.MouseButton1Up:Connect(function() moveDir = Vector3.new(0, 0, 0) end)
end

MiscTab:CreateToggle("🕊️ เปิด/ปิด โหมดบิน", false, function(Value)
    flying = Value
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and humanoid then
        if flying then
            humanoid.PlatformStand = true
            CreateMobileFlyUI()

            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "MobFlyGyro"
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)

            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "MobFlyVelocity"
            bv.velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

            flyConnection = RunService.RenderStepped:Connect(function()
                if flying then
                    local camVector = Camera.CFrame.LookVector
                    bv.velocity = (camVector * flySpeed) + (moveDir * flySpeed)
                    bg.cframe = Camera.CFrame
                end
            end)
        else
            humanoid.PlatformStand = false
            if flyConnection then flyConnection:Disconnect() end
            if mobileFlyGui then mobileFlyGui:Destroy() end
            if hrp:FindFirstChild("MobFlyGyro") then hrp.MobFlyGyro:Destroy() end
            if hrp:FindFirstChild("MobFlyVelocity") then hrp.MobFlyVelocity:Destroy() end
            moveDir = Vector3.new(0, 0, 0)
        end
    end
end)
