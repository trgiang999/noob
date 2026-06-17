-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()
print('6:09PM')
-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Lighting = game:GetService("Lighting")
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

MainTab:AddSection({ Name = "Main" })

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

MainTab:AddButton({
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

MainTab:AddButton({
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

local function getWater()
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
    -- [Bước 3] Về vị trí cũ
    task.wait(0.3)
    hrp.CFrame = originalCFrame
end

MainTab:AddButton({
    Name     = "Get Water",
    Visible  = true,
    Disabled = false,
    Callback = getWater,
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

MainTab:AddButton({
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
    hrp.CFrame = CFrame.new(Vector3.new(-126, 19, 42))
end
MainTab:AddSection({Name="Teleport"})

MainTab:AddButton({
    Name = "Teleport to Bed",
    Visible = true,
    Disabled = false,
    Callback = tpToBed,
})
-- ═════════════════════════════════════════════════════════════════════════════
--  TAB: VIEWING
-- ═════════════════════════════════════════════════════════════════════════════
local ViewTab = Window:MakeTab({
    Name     = "Viewing",
    Icon     = "rbxassetid://4483345998",
    Visible  = true,
    Disabled = false,
})

-- ═════════════════════════════════════════════════════════════════════════════
-- SECTION: ESP
-- ═════════════════════════════════════════════════════════════════════════════
ViewTab:AddDivider({Text = "ESP"})
ViewTab:AddSection({Name="ESP"})
local dad = workspace.Game.dad.PossesedDad
local highlight = dad:FindFirstChild("DadHighlight")
local state = 0 
-- 0 = chưa có
-- 1 = đang hiển thị đỏ
-- 2 = đang tắt (trong suốt)

local function dadEsp()
    if not highlight then
		-- Bật lần 1: tạo highlight đỏ
		highlight = Instance.new("Highlight")
		highlight.Name = "DadHighlight"
		highlight.FillColor = Color3.fromRGB(255, 80, 80) -- đỏ nhạt
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 1
		highlight.Parent = dad
		
		state = 1
	else
		if state == 1 then
			-- Tắt: làm trong suốt
			highlight.FillTransparency = 1
			state = 2
		elseif state == 2 then
			-- Bật lại: đỏ nhạt
			highlight.FillTransparency = 0.5
			state = 1
		end
	end
end
ViewTab:AddToggle({
    Name     = "Dad ESP",
    Default  = false,          -- Giá trị mặc định
    Type     = "CheckBox",     -- "Switch" hoặc "CheckBox"
    Flag     = "dadESP",    -- ID dùng với OrionLib.Flags
    Save     = true,           -- Lưu vào config
    Visible  = true,
    Disabled = false,
    Callback = function(value)
        print("Toggle is now:", value)
    end,
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


MiscTab:AddButton({
    Name = "Infinite Yield",
    Visible = true,
    Disabled = false,
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
    end
})

MiscTab:AddButton({
    Name = "FullBright",
    Visible = true,
    Disabled = false,
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
})
MiscTab:AddButton({
    Name = "NoFog",
    Visible = true,
    Disabled = false,
    Callback = function()
        Lighting.FogEnd = 100000
        for i,v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
    end
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
