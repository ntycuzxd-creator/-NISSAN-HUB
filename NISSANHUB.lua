local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

local Window = OrionLib:MakeWindow({
    Name = "🔒 Legend Piece | Single-User Premium Hub v3", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "ระบบเซิร์ฟเวอร์ส่วนตัวเปิดใช้งานแล้ว"
})

-- ตัวแปรระบบหลัก (Settings)
_G.AutoFarm = false
_G.AutoChest = false
_G.AutoStats = false
_G.TargetMob = "Bandit"
_G.StatTarget = "Melee"

local Player = game.Players.LocalPlayer

-- ฟังก์ชันวาร์ปแบบจำกัดความเร็วและสุ่มพิกัดองศา (ปลอดภัยสูงสุด)
local function safeInstantTeleport(targetCFrame)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        local randomOffsetX = (math.random(-40, 40) / 100)
        local randomOffsetZ = (math.random(-40, 40) / 100)
        hrp.CFrame = targetCFrame * CFrame.new(randomOffsetX, 0, randomOffsetZ)
    end
end

-- สร้างแท็บเมนู
local FarmTab = Window:MakeTab({ Name = "⚔️ Auto Farm", Icon = "rbxassetid://4483362458", Premium = false })
local ChestTab = Window:MakeTab({ Name = "💰 Chest Farm", Icon = "rbxassetid://4483362458", Premium = false })
local StatsTab = Window:MakeTab({ Name = "📊 Auto Stats", Icon = "rbxassetid://4483362458", Premium = false })

-- =======================================================
-- [1. ระบบฟาร์มเลือกเป้าหมายตามรูปภาพของคุณ]
-- =======================================================

-- แยกหมวดหมู่มอนสเตอร์ทั่วไป (ตามภาพแถบสีเทา)
FarmTab:AddDropdown({
    Name = "เลือกมอนสเตอร์ทั่วไป (Normal Mobs)",
    Default = "Bandit",
    Options = {
        "Bandit", "Marine", "Trained Marine", "Pirate", "Monkey", 
        "Chef", "Head Chef", "Fishman", "Vagabond", "Strong Marine", 
        "Snow Bandit", "Snowman", "Deserter", "Strong Deserter", 
        "Sky Soldier", "God's Guards", "Knight Monkey", "Mechanic", "Expert Mechanic"
    },
    Callback = function(Value) _G.TargetMob = Value end    
})

-- แยกหมวดหมู่บอสประจำเกาะ (ตามภาพแถบสีม่วง/ชมพู)
FarmTab:AddDropdown({
    Name = "เลือกบอสประจำเกาะ (Island Bosses)",
    Default = "Boss Bandit",
    Options = {
        "Boss Bandit", "Axe Hand", "Clown", "Gorilla King", 
        "Golden Armor", "Shark Man", "Captain Smoker", "Icy Samurai", 
        "Yeti", "Spikey", "Sandy", "Judgement", "God", "Cyborg"
    },
    Callback = function(Value) _G.TargetMob = Value end    
})

-- สวิตช์เปิด-ปิดระบบฟาร์ม
FarmTab:AddToggle({
    Name = "เปิดระบบโจมตีมอนสเตอร์อัตโนมัติ",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        task.spawn(function()
            while _G.AutoFarm do
                task.wait(0.1)
                pcall(function()
                    local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs")
                    if enemies then
                        for _, enemy in pairs(enemies:GetChildren()) do
                            if enemy.Name == _G.TargetMob and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                                if enemyHRP and _G.AutoFarm then
                                    -- วาร์ปไปตำแหน่งปลอดภัยเหนือหัวศัตรู
                                    safeInstantTeleport(enemyHRP.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0))
                                    
                                    -- คำสั่งส่งสัญญาณการโจมตี
                                    if game.ReplicatedStorage:FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("Combat") then
                                        game.ReplicatedStorage.Remotes.Combat:FireServer()
                                    end
                                end
                                break
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- =======================================================
-- [2. ระบบฟาร์มกล่องจำกัดเวลา 1.50 วินาทีตามใจสั่ง]
-- =======================================================
ChestTab:AddToggle({
    Name = "เปิดระบบเก็บกล่องอัตโนมัติ (วาร์ปดีเลย์ 1.50 วิ)",
    Default = false,
    Callback = function(Value)
        _G.AutoChest = Value
        task.spawn(function()
            while _G.AutoChest do
                pcall(function()
                    local chests = workspace:FindFirstChild("Chests") or workspace:FindFirstChild("ChestModels") or workspace
                    local chestFound = false

                    for _, chest in pairs(chests:GetChildren()) do
                        if (chest.Name:match("Chest") or chest.Name:match("กล่อง")) and chest:IsA("Model") then
                            local rootPart = chest:FindFirstChild("HumanoidRootPart") or chest:FindFirstChild("TouchPart") or chest:PrimaryPart
                            
                            if rootPart and _G.AutoChest then
                                chestFound = true
                                safeInstantTeleport(rootPart.CFrame * CFrame.new(0, 1.5, 0))
                                task.wait(1.50) -- [ระบบหน่วงเวลา 1.50 วินาทีตามที่ต้องการ]
                            end
                        end
                    end
                    if not chestFound then task.wait(5) end
                end)
                task.wait(0.1)
            end
        end)
    end
})

-- =======================================================
-- [3. ระบบอัปสเตตัสอัตโนมัติ]
-- =======================================================
StatsTab:AddDropdown({
    Name = "เลือกสายที่จะอัปสเตตัส",
    Default = "Melee",
    Options = {"Melee", "Defense", "Sword", "Devil Fruit"},
    Callback = function(Value) _G.StatTarget = Value end    
})

StatsTab:AddToggle({
    Name = "เปิดระบบ Auto Stats",
    Default = false,
    Callback = function(Value)
        _G.AutoStats = Value
        task.spawn(function()
            while _G.AutoStats do
                task.wait(0.5)
                pcall(function()
                    if game.ReplicatedStorage:FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("UpgradeStat") then
                        game.ReplicatedStorage.Remotes.UpgradeStat:FireServer(_G.StatTarget, 1)
                    end
                end)
            end
        end)
    end
})

-- ระบบ Anti-AFK บิ้วท์อินในตัว
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)

OrionLib:Init()
