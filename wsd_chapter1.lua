-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()
print('5:15PM')
-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Players    = game:GetService("Players")
local player     = Players.LocalPlayer
local char       = player.Character or player.CharacterAdded:Wait()
local hrp        = char:WaitForChild("HumanoidRootPart")
local camera     = workspace.CurrentCamera

-- ── Helper: Equip tool từ Backpack theo tên ───────────────────────────────────
-- Duyệt Backpack, tìm tool trùng tên rồi dùng Humanoid:EquipTool()
local function equipTool(toolName)
    local backpack = player:WaitForChild("Backpack")
    local tool     = backpack:FindFirstChild(toolName)
    if tool then
        char:WaitForChild("Humanoid"):EquipTool(tool)
    end
end

-- ── Helper: Teleport + nhìn vào một object ───────────────────────────────────
-- Phiên bản chính xác hơn: tp đến pos, sau đó nhìn thẳng vào target
local function tpLookAt(pos, lookTarget)
    local dir = (pos - lookTarget)
    local offset = (dir.Magnitude > 0 and dir.Unit or Vector3.zAxis) * 2
    local targetCFrame = CFrame.lookAt(lookTarget + offset, lookTarget)

    hrp.CFrame    = targetCFrame  -- Đặt vị trí + hướng nhân vật
    camera.CFrame = targetCFrame  -- Đặt camera nhìn cùng hướng
end


-- ── Helper: Kích hoạt ProximityPrompt tức thì (bỏ qua HoldDuration) ──────────
local function firePrompt(prompt)
    prompt.HoldDuration = 0
    fireproximityprompt(prompt)
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Tạo cửa sổ UI chính
-- ─────────────────────────────────────────────────────────────────────────────
local Window = OrionLib:MakeWindow({
    Name            = "G_Hub",
    SearchBar       = { Default = "Search Tabs", ClearTextOnFocus = true },
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
})

-- ═════════════════════════════════════════════════════════════════════════════
--  TAB: Main
-- ═════════════════════════════════════════════════════════════════════════════
local MainTab = Window:MakeTab({
    Name     = "Main",
    Icon     = "rbxassetid://4483345998",
    Visible  = true,
    Disabled = false,
})

local mainMainSection = MainTab:AddSection({ Name = "Main" })

-- ┌─ Instant ProximityPrompt ───────────────────────────────────────────────┐
-- │  Hook vào PromptButtonHoldBegan: mỗi khi người chơi giữ bất kỳ prompt  │
-- │  nào, đặt HoldDuration = 0 rồi fireprox ngay lập tức.                  │
-- └────────────────────────────────────────────────────────────────────────-┘
local function instantProximityPrompt()
    game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(
        function(prompt)
            firePrompt(prompt)
        end
    )
end

mainMainSection:AddButton({
    Name     = "Instant ProximityPrompt",
    Visible  = true,
    Disabled = false,
    Callback = instantProximityPrompt,
})

-- ┌─ Get Cooked Noodles ────────────────────────────────────────────────────┐
-- │  Quy trình tự động nấu mì:                                              │
-- │    1. TP → Fridge  → fireprox → đợi → equip "Raw Noodle"                │
-- │    2. TP → Stove   → fireprox → đợi → equip "Cooked Noodle"             │
-- │    3. TP → Plate   → fireprox 2 lần (đặt mì lên đĩa)                    │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Các object trong map
local kitchen = workspace.House.Rooms.Kitchen
local fridge  = kitchen.FridgeNoodles.Primary
local stove   = kitchen.Stove.Primary


-- (index tính từ 1 theo thứ tự GetChildren)
local function getPlate()
    return kitchen.DiningTable.Noodles:GetChildren()[6].Plate
end

local function getAndEatCookedNoodles()
    local originalCFrame = hrp.CFrame
    -- [Bước 1] Lấy mì sống từ tủ lạnh ──────────────────────────────────────
    tpLookAt(hrp.Position, fridge.Position)   -- TP đến fridge, nhìn vào fridge
    task.wait(0.3)
    firePrompt(fridge.ProximityPrompt)            -- Mở tủ lạnh
    task.wait(0.2)
    equipTool("Raw Noodle")                       -- Cầm mì sống trong Backpack

    -- [Bước 2] Nấu mì trên bếp ──────────────────────────────────────────────
    tpLookAt(hrp.Position,stove.Position)      -- TP đến bếp, nhìn vào bếp
    firePrompt(stove.ProximityPrompt)             -- Bật bếp / nấu
    equipTool("Cooked Noodle")                    -- Cầm mì chín trong Backpack
    task.wait(0.5)

    -- [Bước 3] Đặt mì lên đĩa ───────────────────────────────────────────────
    local plate = getPlate()                      -- Lấy object đĩa
    tpLookAt(hrp.Position, plate.Position)      -- TP đến đĩa, nhìn vào đĩa
    firePrompt(plate.ProximityPrompt)             -- Tương tác lần 1 (đặt mì)
    task.wait(0.3)
    firePrompt(plate.ProximityPrompt)             -- Tương tác lần 2 (xác nhận)

    -- [Bước 4] Về vị trí cũ
    task.wait(0.3)
    hrp.CFrame = originalCFrame
end

mainMainSection:AddButton({
    Name     = "Eat Cooked Noodle",
    Visible  = true,
    Disabled = false,
    Callback = getAndEatCookedNoodles,
})
-- ┌─ Drink Water Glasses────────────────────────────────────────────────────┐
-- │  Quy trình tự động uống nước:                                           │
-- │    1. TP → Shelf  → fireprox → đợi → equip "Drinking Glass"             │
-- │    2. TP → Water Dispenser   → fireprox → đợi → equip "Glass of Water"  │
-- │    3. Uống/Fire click/REmoteevent -> TP old position                    │
-- └─────────────────────────────────────────────────────────────────────────┘
local water_Dispenser = workspace.House.Spares:GetChildren()[7].Primary
local function getDrinkingGlass()
    return workspace.House.Spares:GetChildren()[6].Primary
end

local function drinkWater()
    local originalCFrame = hrp.CFrame
    -- [Bước 1] Lấy cốc ──────────────────────────────────────
    local glass = getDrinkingGlass()
    tpLookAt(hrp.Position, glass.Position)
    firePrompt(glass.ProximityPrompt)
    task.wait(0.3)
    equipTool("Drinking Glass")
    -- [Bước 2] Rót nước & uống nước ──────────────────────────────────────────────
    tpLookAt(hrp.Position, water_Dispenser.Position)
    firePrompt(water_Dispenser.ProximityPrompt)
    task.wait(0.3)
    equipTool("Glass of Water")
    mouse1click()
    -- [Bước 3] Về vị trí cũ
    task.wait(0.3)
    hrp.CFrame = originalCFrame
end

mainMainSection:AddButton({
    Name     = "Drink Water",
    Visible  = true,
    Disabled = false,
    Callback = drinkWater,
})
-- ┌─ Refill Generator   ────────────────────────────────────────────────────┐
-- │  Quy trình tự động đổ xăng:                                             │
-- │    1. TP → GasCan  → fireprox → đợi → equip "gas can"                   │
-- │    2. TP → Generator -> fireprox -> Tp old pos                          |
-- │                                                                         │
-- └─────────────────────────────────────────────────────────────────────────┘
local gasCans = workspace.House.GasCans:GetChildren()
local generator = workspace.House.Generator.Button
local function refillGenerator()
    local oldCFrame = hrp.CFrame

    -- [1] Lấy gas can đầu tiên (chỉ cần 1)
    local can     = gasCans[1]
    local primary = can.Primary
    tpLookAt(hrp.Position, primary.Position)
    firePrompt(primary:FindFirstChildOfClass("ProximityPrompt"))
    task.wait(0.5)

    -- [2] Equip gas can vừa lấy
    equipTool("gas can")
    task.wait(0.3)

    -- [3] TP đến generator và đổ xăng
    tpLookAt(hrp.Position, generator.Position)
    firePrompt(generator:FindFirstChildOfClass("ProximityPrompt"))
    task.wait(0.5)

    -- [4] Về vị trí ban đầu
    hrp.CFrame = oldCFrame
end

mainMainSection:AddButton({
    Name     = "Refill Generator",
    Visible  = true,
    Disabled = false,
    Callback = refillGenerator,
})
MainTab:AddDivider()
-- ═════════════════════════════════════════════════════════════════════════════
-- SECTION: TELEPORT
-- ═════════════════════════════════════════════════════════════════════════════
local function tpToBed()
    local bed = workspace.House.Rooms.Bedroom.Beds.Bed.Primary
    tpLookAt(hrp.Position, bed.Position)
end
local mainTPSection = MainTab:AddSection({name="Teleport"})
mainTPSection.AddButton({
    Name = "Teleport to Bed",
    Visible = true,
    Disabled = false,
    Callback = tpToBed
})
-- ═════════════════════════════════════════════════════════════════════════════
--  TAB: Misc
-- ═════════════════════════════════════════════════════════════════════════════
local MiscTab = Window:MakeTab({
    Name     = "Misc",
    Icon     = "rbxassetid://4483345998",
    Visible  = true,
    Disabled = false,
})

-- Nút huỷ toàn bộ UI Orion
MiscTab:AddButton({
    Name     = "Destroy UI",
    Visible  = true,
    Disabled = false,
    Callback = function()
        OrionLib:Destroy()  -- Dùng OrionLib:Destroy() thay vì Window:Destroy()
                            -- để ngắt sạch tất cả connection
    end,
})
MiscTab:AddButton({
    Name = "Infinite Yield",
    Visible = true,
    Disabled = false,
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
    end
})
