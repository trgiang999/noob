-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Giangplay/Script/main/Orion_Library_PE_V2.lua"))()
-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Lighting = game:GetService("Lighting")
local Players    = game:GetService("Players")
local player     = Players.LocalPlayer
local char       = player.Character or player.CharacterAdded:Wait()
local hrp        = char:WaitForChild("HumanoidRootPart")
local camera     = workspace.CurrentCamera

-- ── Helper: Equip tool từ Backpack theo tên ───────────────────────────────────
-- Equip tool theo tên.
-- Tìm trong Backpack trước, nếu không có thì chờ tối đa `timeout` giây.
-- Trả về true nếu equip thành công, false nếu không tìm thấy.
local function equipTool(toolName, timeout)
    timeout = timeout or 0.4
    local humanoid = char:WaitForChild("Humanoid")
    local backpack  = player:WaitForChild("Backpack")

    -- Tìm ngay lập tức trước (tool có thể đã ở Backpack rồi)
    local tool = backpack:FindFirstChild(toolName)
               or char:FindFirstChild(toolName) -- hoặc đang được equipped trong char

    -- Nếu chưa có → chờ nó xuất hiện trong Backpack
    if not tool then
        tool = backpack:WaitForChild(toolName, timeout)
    end

    if not tool then
        warn(("equipTool: '%s' không tìm thấy sau %ds"):format(toolName, timeout))
        return false
    end

    humanoid:EquipTool(tool)
    return true
end


-- ── Helper: Kích hoạt ProximityPrompt tức thì (bỏ qua HoldDuration) ──────────
-- Kích hoạt ProximityPrompt tức thì:
-- 1. Lưu MaxActivationDistance gốc
-- 2. Đặt thành math.huge để đảm bảo kích hoạt được dù đứng xa
-- 3. Fire prompt
-- 4. Khôi phục về giá trị gốc
local function firePrompt(prompt)
    local originalDist = prompt.MaxActivationDistance
    local originalHD = prompt.HoldDuration
    prompt.MaxActivationDistance = math.huge
    prompt.HoldDuration = 0
    fireproximityprompt(prompt)
    prompt.MaxActivationDistance = originalDist
    prompt.HoldDuration = originalHD
end

-- ── Helper: TP sát object rồi wait để server nhận vị trí ─────────────────────
-- Thay thế tpLookAt — không cần nhìn hướng, chỉ cần đứng gần là fire được
local function tpTo(position)
    hrp.CFrame = CFrame.new(position)
    task.wait(0.2)
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
    Name            = "G_Hub - Chapter 1",
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
    IntroEnabled    = true,
    IntroText       = "G_Hub - Chapter 1",
    IntroIcon       = "rbxassetid://7734091286",
    Icon            = "rbxassetid://7734091286",
    CloseCallback   = function()
        print("UI closed")
    end,
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

-- ═════════════════════════════════════════════════════════════════════════════
--  SECTION: Main.Main
-- ═════════════════════════════════════════════════════════════════════════════
MainTab:AddSection({ Name = "Main" })



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

    -- [1] Lấy mì sống từ tủ lạnh
    tpTo(fridge.Position)
    firePrompt(fridge.ProximityPrompt)
    equipTool("Raw Noodle")

    -- [2] Nấu mì trên bếp
    tpTo(stove.Position)
    firePrompt(stove.ProximityPrompt)
    equipTool("Cooked Noodle")

    -- [3] Đặt mì lên đĩa (fire 2 lần)
    local plate = getPlate()
    tpTo(plate.Position)
    firePrompt(plate.ProximityPrompt)
    task.wait(0.1)
    firePrompt(plate.ProximityPrompt)

    -- [4] Về vị trí cũ
    task.wait(0.1)
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

    -- [1] Lấy cốc từ kệ
    local glass = getDrinkingGlass()
    tpTo(glass.Position)
    firePrompt(glass.ProximityPrompt)
    equipTool("Drinking Glass")

    -- [2] Rót nước từ máy lọc
    tpTo(water_Dispenser.Position)
    firePrompt(water_Dispenser.ProximityPrompt)
    equipTool("Glass of Water")

    -- [3] Về vị trí cũ
    task.wait(0.1)
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
local generator = workspace.House.Generator.Button
local function refillGenerator()
    local oldCFrame = hrp.CFrame

    -- [1] Lấy gas can (dynamic object, lấy lại mỗi lần)
    local can     = workspace.House.GasCans:GetChildren()[1]
    local primary = can and can:FindFirstChild("Primary")

    if not primary then
        OrionLib:MakeNotification({ Name = "Error!", Content = "Gas can not found!", Time = 3 })
        return
    end

    tpTo(primary.Position)
    firePrompt(primary:FindFirstChildOfClass("ProximityPrompt"))
    equipTool("gas can")

    -- [2] Đổ xăng vào generator
    tpTo(generator.Position)
    firePrompt(generator:FindFirstChildOfClass("ProximityPrompt"))
    task.wait(0.1)

    -- [3] Về vị trí ban đầu
    hrp.CFrame = oldCFrame
end

MainTab:AddButton({
    Name     = "Refill Generator",
    Visible  = true,
    Disabled = false,
    Callback = refillGenerator,
})

MainTab:AddDivider()
MainTab:AddSection({Name = "Misc"})
-- ═════════════════════════════════════════════════════════════════════════════
-- SECTION: Main.Misc
-- ═════════════════════════════════════════════════════════════════════════════

--AntiSit: Auto escape seats.
local antiSeatConnection = nil

local function handleSeated(isSeated)
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if isSeated and humanoid then
        humanoid.Jump = true
        task.defer(function() if humanoid.Sit then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    end
end

local function toggleAntiSit(value)
    OrionLib:MakeNotification({
        Name    = "Notification!",
        Content = "Use after preparing noodles part.",
        Image   = "rbxassetid://4483345998",
        Time    = 3,
    })
    if antiSeatConnection then 
        antiSeatConnection:Disconnect() 
        antiSeatConnection = nil 
    end
    if _G.AntiSitCharacterAddedConnection then _G.AntiSitCharacterAddedConnection:Disconnect()
        _G.AntiSitCharacterAddedConnection = nil 
    end
    
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        antiSeatConnection = humanoid.Seated:Connect(handleSeated)
        if humanoid.Sit then handleSeated(true) end
    end
    
    _G.AntiSitCharacterAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
        char = newCharacter
        local newHumanoid = newCharacter:WaitForChild("Humanoid", 5) :: Humanoid?
        if newHumanoid then
            antiSeatConnection = newHumanoid.Seated:Connect(handleSeated)
            if newHumanoid.Sit then handleSeated(true) end
        end
    end)
end

MainTab:AddToggle({
    Name     = "Anti Sit(Anti Stun)",
    Default  = false,
    Type     = "CheckBox",
    Flag     = "antiSit",
    Save     = true,
    Visible  = true,
    Disabled = false,
    Callback = toggleAntiSit,
})

-- ┌─ Instant ProximityPrompt ───────────────────────────────────────────────┐
-- │  Toggle: tự động fire bất kỳ ProximityPrompt nào ngay khi giữ.         │
-- │  connection lưu ngoài hàm để Disconnect() được khi tắt toggle.         │
-- └────────────────────────────────────────────────────────────────────────-┘
local instantPPConnection = nil   -- <-- khai báo NGOÀI hàm

local function instantProximityPrompt(value)
    if value then
        instantPPConnection = game:GetService("ProximityPromptService")
            .PromptButtonHoldBegan:Connect(function(prompt)
                firePrompt(prompt)
            end)
    elseif instantPPConnection then   -- guard: chỉ disconnect nếu đang có
        instantPPConnection:Disconnect()
        instantPPConnection = nil
    end
end

MainTab:AddToggle({
    Name     = "Instant Interact",
    Default  = false,          -- Giá trị mặc định
    Type     = "CheckBox",       -- "Switch" hoặc "CheckBox"
    Flag     = "instantPP",    -- ID dùng với OrionLib.Flags
    Save     = true,           -- Lưu vào config
    Visible  = true,
    Disabled = false,
    Callback = function(value)
        instantProximityPrompt(value)
    end,
})
-- ═════════════════════════════════════════════════════════════════════════════
-- TAB: TELEPORT
-- ═════════════════════════════════════════════════════════════════════════════
local teleportTab = Window:MakeTab({
    Name        = "Teleport",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Tab có hiển thị trong sidebar không
    Disabled    = false,   -- Tab bị vô hiệu hóa (mờ, không click được)
    PremiumOnly = false,   -- Khoá tab cho Sirius Premium users
})

teleportTab:AddSection({Name="Teleport"})

teleportTab:AddButton({
    Name = "Teleport to Bed",
    Visible = true,
    Disabled = false,
    Callback = function()
        hrp.CFrame = CFrame.new(Vector3.new(-126, 19, 42))
    end,
})

teleportTab:AddButton({
    Name = "Teleport to Generator",
    Visible = true,
    Disabled = false,
    Callback = function()
        hrp.CFrame = CFrame.new(Vector3.new(-157, 5, 47))
    end
})

teleportTab:AddButton({
    Name = "Teleport to Kitchen",
    Visible = true,
    Disabled = false,
    Callback = function()
        hrp.CFrame = CFrame.new(Vector3.new(-117, 5, 19))
    end
})
-- ═════════════════════════════════════════════════════════════════════════════
-- TAB: STATISTICS VALUE
-- ═════════════════════════════════════════════════════════════════════════════
local statsTab = Window:MakeTab({
    Name        = "Stats",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Tab có hiển thị trong sidebar không
    Disabled    = false,   -- Tab bị vô hiệu hóa (mờ, không click được)
    PremiumOnly = false,   -- Khoá tab cho Sirius Premium users
})
-- Thay hàm createStatLabel thành:
local function createStatLabel(text: string, valueObject: IntValue): any
    local para = statsTab:AddParagraph(text, "...")

    local function update(value: number)
        -- Dùng task.defer để đợi Roblox render xong rồi mới set
        -- tránh TextBounds đọc sai → frame phình đột biến
        task.defer(function()
            para:Set(tostring(value) .. " / 100")
        end)
    end

    OrionLib:AddConnect(valueObject.Changed, update)

    update(valueObject.Value)

    return para
end

createStatLabel("Fuel", workspace.House.Generator.Bar)
createStatLabel("Thirst", player.Thirst)
createStatLabel("Hunger", player.Hunger)
createStatLabel("Energy", player.Energy)

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
ViewTab:AddDivider()
ViewTab:AddSection({Name="Camera"})
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

ViewTab:AddButton({
    Name = "3rd Person camera",
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
