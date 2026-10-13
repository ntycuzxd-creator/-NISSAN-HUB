-- =======================================================
-- 🔒 NISSAN HUB v27.0 | Advanced Name-Radar Dynamic Navigation Engine
-- =======================================================

-- ป้องกันหน้าต่างซ้อน ลบหน้าต่างเก่าออกทันทีก่อนเริ่มรันใหม่
if game:GetService("CoreGui"):FindFirstChild("NISSAN_WORLD_MATRIX") then
    game:GetService("CoreGui"):FindFirstChild("NISSAN_WORLD_MATRIX"):Destroy()
end

-- [[ 1. วาดระบบหน้าต่าง GUI แผงปุ่มตรง สไตล์ Mac Matrix กางแผงปุ่มตรง ]]
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local FrameCorner = Instance.new("UICorner")
local FrameStroke = Instance.new("UIStroke")
local TitleLabel = Instance.new("TextLabel")
local SubTitle = Instance.new("TextLabel")
local ButtonGrid = Instance.new("ScrollingFrame")
local UIGridLayout = Instance.new("UIGridLayout")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "NISSAN_WORLD_MATRIX"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.20, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 310)
MainFrame.Active = true
MainFrame.Draggable = true -- ใช้เมาส์คลิกคากรอบลากย้ายได้อิสระบนจอ PC

FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(0, 255, 127) -- ขอบเรืองแสงสีเขียวนีออน
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FrameStroke.Parent = MainFrame

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TitleLabel.BorderSizePixel = 0
TitleLabel.Size = UDim2.new(1, 0, 0, 38)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "  🍏 NISSAN HUB v27.0 | Advanced Radar Matrix"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 42)
SubTitle.Size = UDim2.new(1, 0, 0, 15)
SubTitle.Font = Enum.Font.SourceSansItalic
SubTitle.Text = "Click Same Island Twice to STOP | Press 'Right Ctrl' to Hide UI"
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130)
SubTitle.TextSize = 11

ButtonGrid.Parent = MainFrame
ButtonGrid.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
ButtonGrid.BorderSizePixel = 0
ButtonGrid.Position = UDim2.new(0.03, 0, 0.20, 0)
ButtonGrid.Size = UDim2.new(0.94, 0, 0, 210)
ButtonGrid.ScrollBarThickness = 6
ButtonGrid.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
ButtonGrid.CanvasSize = UDim2.new(0, 0, 0, 420)

UIGridLayout.Parent = ButtonGrid
UIGridLayout.CellSize = UDim2.new(0, 142, 0, 32)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 285)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Radar Standby"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 2. คลังข้อมูลรายชื่อโมเดลเกาะทั้งหมด 17 เกาะ (สแกนหาวัตถุจริง ไม่ใช้พิกัดหลอก) ]]
local TargetIslands = {
    "Starter Island", "Marine Island", "Pirate Island", "Jungle Island", 
    "Floating Restaurant", "Shark Park", "Legend Town", "Snow Island", 
    "Desert Island", "Sky Island", "Fountain City",
    "Skull Island", "Sea Beast Island", "Mysterious Tower", 
    "Lonely Island", "Rock Island", "Dark Castle"
}

_G.IsTweening = false
_G.CurrentIslandTarget = "" -- ตัวแปรเก็บประวัติชื่อเกาะที่บอทกำลังมุ่งหน้าไป ณ ตอนนี้
local TravelSpeed = 350

local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CurrentActiveTween = nil
local FlyConnection = nil

-- ฟังก์ชันบังคับเบรกหยุดบินแช่แข็งตัวละครฉุกเฉินกลางเวหา
local function forceStopFlight()
    if CurrentActiveTween then CurrentActiveTween:Cancel() CurrentActiveTween = nil end
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    _G.IsTweening = false
    _G.CurrentIslandTarget = ""
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        hrp.Anchored = true task.wait(0.04) hrp.Anchored = false
    end
    StatusLabel.Text = "Status: 🛑 Emergency Brake (Flight Stopped)"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
end

-- [[ 3. ⚡ ระบบเรดาร์ขั้นสูง: สลับเกาะกลางคันได้ทันที + ดักจับระบบกดซ้ำเพื่อหยุดบิน ⚡ ]]
local function radarFlyToIsland(islandName)
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- [[ 🌟 กฎเหล็กข้อที่ 1: ถ้ากดคลิกปุ่มเกาะเดิมซ้ำเป็นครั้งที่ 2 ในขณะที่บินอยู่ สั่งหยุดทันที! 🌟 ]]
    if _G.IsTweening and _G.CurrentIslandTarget == islandName then
        forceStopFlight()
        return
    end
    
    -- [[ 🌟 กฎเหล็กข้อที่ 2: หากกำลังบินอยู่แล้วกดปุ่มเกาะใหม่ สั่งล้างทริปเก่าทิ้งเพื่อหักพวงมาลัยเปลี่ยนทิศทันที 🌟 ]]
    if CurrentActiveTween then CurrentActiveTween:Cancel() CurrentActiveTween = nil end
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    
    _G.IsTweening = true
    _G.CurrentIslandTarget = islandName
    StatusLabel.Text = "Status: 🔍 Radar Scanning for " .. islandName .. "..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- ค้นหาตัววัตถุโมเดลเกาะแท้ในระบบโครงสร้าง Workspace
    local targetIslandObject = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") then
            if obj.Name == islandName or obj.Name:match(islandName) or obj.Name:lower() == islandName:lower() then
                targetIslandObject = obj
                break
            end
        end
    end
    
    local targetPart = targetIslandObject and (targetIslandObject:IsA("BasePart") and targetIslandObject or targetIslandObject:FindFirstChildWhichIsA("BasePart") or targetIslandObject.PrimaryPart)
    
    if targetPart then
        StatusLabel.Text = "Status: ✈️ Flying to " .. islandName .. " (Click again to Stop)"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        -- บินล็อกระดับความสูงคงที่ + เหนือน่านฟ้าเพื่อแก้บั๊กตัวสั่นพั่บ ๆๆๆ
        local targetCFrame = CFrame.new(targetPart.Position.X, targetPart.Position.Y + 45, targetPart.Position.Z)
        local distance = (hrp.Position - targetPart.Position).Magnitude
        local duration = distance / TravelSpeed
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if _G.IsTweening and hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                -- เปิด Noclip ทะลุวัตถุกันดีดสั่นสะเทือนตลอดการบิน
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        CurrentActiveTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        CurrentActiveTween:Play()
        
        -- ตรวจสอบจุดจอดเสร็จสมบูรณ์ปลายทาง
        task.spawn(function()
            local currentTweenToCheck = CurrentActiveTween
            currentTweenToCheck.Completed:Wait()
            
            if CurrentActiveTween == currentTweenToCheck then
                if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
                CurrentActiveTween = nil
                _G.IsTweening = false
                _G.CurrentIslandTarget = ""
                StatusLabel.Text = "Status: 🟢 Safely Landed at " .. islandName
                StatusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
            end
        end)
    else
        _G.IsTweening = false
        _G.CurrentIslandTarget = ""
        StatusLabel.Text = "Status: ❌ Error: " .. islandName .. " not found in server!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    end
end

-- กางแผงปุ่มเกาะทั้งหมด 17 เกาะออกโชว์ตรง ๆ บนหน้าต่าง GUI
for _, islandName in pairs(TargetIslands) do
    local IslandBtn = Instance.new("TextButton")
    IslandBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    IslandBtn.BorderSizePixel = 0
    IslandBtn.Font = Enum.Font.SourceSansBold
    IslandBtn.Text = islandName
    IslandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    IslandBtn.TextSize = 13
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = IslandBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(50, 50, 55)
    btnStroke.Thickness = 1
    btnStroke.Parent = IslandBtn
    
    IslandBtn.MouseButton1Click:Connect(function()
        radarFlyToIsland(islandName)
    end)
    
    IslandBtn.Parent = ButtonGrid
end

-- [[ 4. ⌨️ ปุ่มลัดคีย์บอร์ด PC: กดปุ่ม Ctrl ขวา เพื่อซ่อน/แสดงหน้าต่างเมนู ]]
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
end)

-- ระบบเปิดโหมด Noclip ทะลุสิ่งกีดขวางถาวร 100% กันตัวติดบั๊ก
