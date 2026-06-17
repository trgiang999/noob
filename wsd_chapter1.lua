-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()
print('8:22PM')
-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Lighting = game:GetService("Lighting")
local Players    = game:GetService("Players")
local VisibilityCheckDispatcher = game:GetService("VisibilityCheckDispatcher")
local player     = Players.LocalPlayer
-- Đợi cho tới khi character xuất hiện VÀ có đầy đủ HumanoidRootPart bên trong
local char = player.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then
    char = player.CharacterAdded:Wait()
end
local hrp = char:WaitForChild("HumanoidRootPart", 10) -- Giới hạn đợi tối đa 10 giây tránh treo script
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
-- Kích hoạt ProximityPrompt tức thì:
-- 1. Lưu MaxActivationDistance gốc
-- 2. Đặt thành math.huge để đảm bảo kích hoạt được dù đứng xa
-- 3. Fire prompt
-- 4. Khôi phục về giá trị gốc
local function firePrompt(prompt)
    local originalDist      = prompt.MaxActivationDistance
    prompt.MaxActivationDistance = math.huge
    prompt.HoldDuration     = 0
    fireproximityprompt(prompt)
    prompt.MaxActivationDistance = originalDist
end
-- Helper: Camera handler
local function firstPersonCamera()
    player.CameraMode = Enum.CameraMode.LockFirstPerson
end

local function thirdPersonCamera()
    player.CameraMode = Enum.CameraMode.Classic
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
    firstPersonCamera()
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
    thirdPersonCamera()
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
    firstPersonCamera()
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
    thirdPersonCamera()
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
    firstPersonCamera()
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
    thirdPersonCamera()
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
ViewTab:AddDivider()
ViewTab:AddSection({Name="ESP"})

local function dadEsp(value)
    -- Nếu tắt toggle thì xóa highlight luôn
    if not value then
        local dadModel = workspace.Game.dad:FindFirstChild("PossesedDad")
        if dadModel then
            local h = dadModel:FindFirstChild("DadHighlight")
            if h then h:Destroy() end
        end
        return
    end

    -- Kiểm tra dad đã bị possesed chưa
    local dadModel = workspace.Game.dad:FindFirstChild("PossesedDad")
    if not dadModel then
        OrionLib:MakeNotification({
            Name    = "Error!",
            Content = "Dad wasn't possesed! Please re-enable later.",
            Image   = "rbxassetid://4483345998",
            Time    = 3,
        })
        OrionLib.Flags["dadESP"]:Set(false) -- tự tắt toggle
        return
    end

    -- Tạo highlight nếu chưa có
    local highlight = dadModel:FindFirstChild("DadHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name                = "DadHighlight"
        highlight.FillColor           = Color3.fromRGB(255, 80, 80)
        highlight.FillTransparency    = 0.5
        highlight.OutlineTransparency = 1
        highlight.Parent              = dadModel
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
        dadEsp(value)
    end,
})
-- ═════════════════════════════════════════════════════════════════════════════
-- SECTION: CAMERA
-- ═════════════════════════════════════════════════════════════════════════════
local function fixCam()
    thirdPersonCamera()
    OrionLib:MakeNotification({
        Name    = "Information!",
        Content = "Third Person camera might break main scripts(get noodles, water, refill generator)",
        Image   = "rbxassetid://4483345998",
        Time    = 3,
    })
end
local function force1stCam()
    firstPersonCamera()
    OrionLib:MakeNotification({
        Name    = "Information!",
        Content = "First Person camera might make it harder to see.",
        Image   = "rbxassetid://4483345998",
        Time    = 3,
    })
end
ViewTab:AddDivider()
ViewTab:AddSection({Name="Camera"})
ViewTab:AddButton({
    Name = "Unlock 3rd Person camera",
    Visible = true,
    Disabled = false,
    Callback = fixCam,
})

ViewTab:AddButton({
    Name = "1st Person Camera",
    Visible = true,
    Disabled = false,
    Callback = force1stCam
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
