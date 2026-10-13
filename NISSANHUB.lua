-- [[ 1. โหลด Kavo UI Library ตัวที่เสถียรที่สุดสำหรับ Delta และ Real ]]
local Library = loadstring(game:HttpGet("https://githubusercontent.com"))()
local Window = Library.CreateLib("🔒 NISSAN HUB v1 | Legend Piece", "DarkTheme")

-- [[ 2. ตั้งค่าตัวแปรระบบ ]]
_G.AutoFarm = false
_G.AutoChest = false
_G.AutoStats = false
_G.TargetMob = "Bandit"
_G.StatTarget = "Melee"

local Player = game.Players.LocalPlayer

-- [[ 3. ฟังก์ชันพิกัดปลอดภัยสุ่มองศา ป้องกันการโดนแบน ]]
local function safeInstantTeleport(targetCFrame)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        local randomOffsetX = (math.random(-40, 40) / 100)
        local randomOffsetZ = (math.random(-40, 40) / 100)
        hrp.CFrame = targetCFrame * CFrame.new(randomOffsetX, 0, randomOffsetZ)
    end
end

-- [[ 4. สร้างหน้าต่างเมนูตามสไตล์ Kavo UI ]]
local MainTab = Window:NewTab("⚔️ Auto Farm")
local ChestTab = Window:NewTab("💰 Chest Farm")
local StatsTab = Window:NewTab("📊 Auto Stats")

local FarmSection = MainTab:NewSection("ระบบฟาร์มมอนสเตอร์และบอส")
local ChestSection = ChestTab:NewSection("ระบบฟาร์มกล่องสมบัติ AFK")
local StatsSection = StatsTab:NewSection("ระบบอัปแต้มพลังอัตโนมัติ")

-- [[ 5. ตัวเลือกมอนสเตอร์ทั่วไป (อ้างอิงจากรูปภาพของคุณ) ]]
FarmSection:NewDropdown("เลือกมอนสเตอร์ทั่วไป (Mobs)", "เลือกมอนเพื่อปล่อยบอท", {
    "Bandit", "Marine", "Trained Marine", "Pirate", "Monkey", 
    "Chef", "Head Chef", "Fishman", "Vagabond", "Strong Marine", 
    "Snow Bandit", "Snowman", "Deserter", "Strong Deserter", 
    "Sky Soldier", "God's Guards", "Knight Monkey", "Mechanic", "Expert Mechanic"
}, function(Value)
    _G.TargetMob = Value
end)

-- [[ 6. ตัวเลือกบอสประจำเกาะ (อ้างอิงจากรูปภาพของคุณ) ]]
FarmSection:NewDropdown("เลือกบอสประจำเกาะ (Bosses)", "เลือกบอสเพื่อฟาร์มของดรอป", {
    "Boss Bandit", "Axe Hand", "Clown", "Gorilla King", 
    "Golden Armor", "Shark Man", "Captain Smoker", "Icy Samurai", 
    "Yeti", "Spikey", "Sandy", "Judgement", "God", "Cyborg"
}, function(Value)
    _G.TargetMob = Value
end)

-- [[ 7. ปุ่มสวิตช์เปิด-ปิดการฟาร์ม ]]
FarmSection:NewToggle("เปิดระบบโจมตีอัตโนมัติ", "ฟาร์มมอนสเตอร์ที่เลือกข้ามคืน", function(state)
    _G.AutoFarm = state
    if state then
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
                                    safeInstantTeleport(enemyHRP.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0))
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
end)

-- [[ 8. ระบบฟาร์มกล่อง ดีเลย์ความปลอดภัย 1.50 วินาที ]]
ChestSection:NewToggle("เปิดฟาร์มกล่อง (วาร์ปดีเลย์ 1.50 วิ)", "เก็บเงินอัตโนมัติในเซิร์ฟส่วนตัว", function(state)
    _G.AutoChest = state
    if state then
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
                                task.wait(1.50) -- หน่วงเวลา 1.50 วินาทีตามที่กำหนด
                            end
                        end
                    end
                    if not chestFound then task.wait(5) end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

-- [[ 9. ระบบอัปสเตตัสอัตโนมัติ ]]
StatsSection:NewDropdown("เลือกสายสเตตัส", "สายพลังที่ต้องการอัปแต้ม", {"Melee", "Defense", "Sword", "Devil Fruit"}, function(Value)
    _G.StatTarget = Value
end)

StatsSection:NewToggle("เปิดระบบ Auto Stats", "อัปแต้มอัตโนมัติเมื่อเลเวลอัป", function(state)
    _G.AutoStats = state
    if state then
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
end)

-- [[ 10. ระบบป้องกันการโดนเตะออกจากเกม (Anti-AFK) ]]
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)
