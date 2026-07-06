-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local function githubGetRaw(user, repo, branch, path)
    local rawUrl = ("https://raw.githubusercontent.com/%s/%s/%s/%s#t=%s")
        :format(user, repo, branch, path, tostring(os.time()))
    local success, content = pcall(game.HttpGetAsync, game, rawUrl)
    if not success or content == "404: Not Found" then
        error("githubGet failed: Kiểm tra lại đường dẫn hoặc kết nối mạng!")
    end
    return content
end

local OrionLib = loadstring(githubGetRaw("trgiang999", "noob", "main", "OrionLibSource.lua"))()

if getgenv().GHUB_LOADED then 
    OrionLib:MakeNotification({
        Name    = "Warning!",                          
        Content = "The script is already running!",            
        Image   = "rbxassetid://4483345998",        
        Time    = 3,      
    })
    return
end

-- Đánh dấu script đã được kích hoạt lần đầu thành công
getgenv().GHUB_LOADED = true

-- ── Phần code chính của Script đặt ở phía dưới này ───────────────────────────
OrionLib:MakeNotification({
    Name    = "Success",
    Content = "Script loaded successfully!",
    Time    = 3
})

-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local player     = Players.LocalPlayer
local char       = player.Character or player.CharacterAdded:Wait()
local hrp        = char:WaitForChild("HumanoidRootPart")

-- ── Helper: Equip tool từ Backpack theo tên ───────────────────────────────────
local function equipTool(toolName, timeout)
    timeout = timeout or 0.4
    local humanoid = char:WaitForChild("Humanoid")
    local backpack  = player:WaitForChild("Backpack")

    local tool = backpack:FindFirstChild(toolName)
               or char:FindFirstChild(toolName)

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

local function getToolLocation(toolName, timeout)
    timeout = timeout or 0.4
    local backpack  = player:WaitForChild("Backpack")

    local tool = backpack:FindFirstChild(toolName)
               or char:FindFirstChild(toolName)

    if not tool then
        tool = backpack:WaitForChild(toolName, timeout)
    end

    if not tool then
        warn(("equipTool: '%s' không tìm thấy sau %ds"):format(toolName, timeout))
        return
    end

    return tool
end

-- ── Helper: Kích hoạt ProximityPrompt tức thì (bỏ qua HoldDuration) ──────────
local function firePrompt(prompt: ProximityPrompt)
    local originalDist = prompt.MaxActivationDistance
    local originalHD = prompt.HoldDuration
    local originalEnabled = prompt.Enabled
    prompt.MaxActivationDistance = math.huge
    prompt.HoldDuration = 0
    prompt.Enabled = true
    fireproximityprompt(prompt)
    prompt.MaxActivationDistance = originalDist
    prompt.HoldDuration = originalHD
    prompt.Enabled = originalEnabled
end

-- ── Helper: TP sát object rồi wait để server nhận vị trí ─────────────────────
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
    IntroToggleIcon = "rbxassetid://14229447778",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
    IntroEnabled    = true,
    IntroText       = "G_Hub - Chapter 1",
    IntroIcon       = "rbxassetid://14229447778",
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
--Location
local house = workspace.House
local kitchen = house.Rooms.Kitchen
local fridge  = kitchen.FridgeNoodles.Primary
local stove   = kitchen.Stove.Primary
local glassShelf = house.Spares:FindFirstChild("Shelf with Drinks").Primary
local waterDispenser = house.Spares:FindFirstChild("WaterDispenser").Primary

--Position
local FRIDGE_POSITION = Vector3.new(-122, 5, 16)
local STOVE_POSITION = Vector3.new(-111, 5, 17)
local PLATE_POSITION = Vector3.new(-120, 5, 25)

local SHELF_POSITION = Vector3.new(-126, 5, 25)
local DISPENSER_POSITION = Vector3.new(-125, 5, 30)

local GENERATOR_POSITION = Vector3.new(-159, 5, 48)

local function eatCookedNoodles()
    local originalCFrame = hrp.CFrame

    -- [1] Lấy mì sống từ tủ lạnh
    tpTo(FRIDGE_POSITION)
    firePrompt(fridge.ProximityPrompt)
    equipTool("Raw Noodle")

    -- [2] Nấu mì trên bếp
    tpTo(STOVE_POSITION)
    firePrompt(stove.ProximityPrompt)
    equipTool("Cooked Noodle")

    -- [3] Đặt mì lên đĩa (fire 2 lần)
    local plate = kitchen.DiningTable.Noodles:GetChildren()[6].Plate
    tpTo(PLATE_POSITION)
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
    Callback = eatCookedNoodles,
})
-- ┌─ Drink Water Glasses────────────────────────────────────────────────────┐
-- │  Quy trình tự động uống nước:                                           │
-- │    1. TP → Shelf  → fireprox → đợi → equip "Drinking Glass"             │
-- │    2. TP → Water Dispenser   → fireprox → đợi → equip "Glass of Water"  │
-- │    3. Uống/Fire click/REmoteevent -> TP old position                    │
-- └─────────────────────────────────────────────────────────────────────────┘

local function drinkWater()
    local originalCFrame = hrp.CFrame

    -- [1] Lấy cốc từ kệ
    local glass = house.Spares:GetChildren()[6].Primary
    tpTo(SHELF_POSITION)
    firePrompt(glass.ProximityPrompt)
    equipTool("Drinking Glass")

    -- [2] Rót nước từ máy lọc + uống
    tpTo(DISPENSER_POSITION)
    firePrompt(waterDispenser.ProximityPrompt)
    equipTool("Glass of Water")

    local waterGlass = getToolLocation("Glass of Water")
    -- Kiểm tra nil trước khi fire
    local useEvent = waterGlass and waterGlass:FindFirstChild("Use")
    if useEvent then
        useEvent:FireServer()
    else
        warn("getWater: RemoteEvent 'Use' không tìm thấy trong Glass of Water")
    end
    -- [3] Về vị trí cũ
    task.wait(0.1)
    hrp.CFrame = originalCFrame
end


MainTab:AddButton({
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
local generator = house.Generator.Button
local function refillGenerator()
    local oldCFrame = hrp.CFrame
    -- [1]. Equip
    local can     = house.GasCans:GetChildren()[1]
    local primary = can and can:FindFirstChild("Primary")

    if not primary then
        OrionLib:MakeNotification({ Name = "Error!", Content = "Gas can not found!", Time = 3 })
        return
    end

    tpTo(primary.Position)
    firePrompt(primary:FindFirstChildOfClass("ProximityPrompt"))
    equipTool("gas can")

    -- [2] Đổ xăng vào generator
    tpTo(GENERATOR_POSITION)
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


--GodMode/Kill dad
local DadFolder = workspace:WaitForChild("Game"):WaitForChild("dad")
local isListening: boolean = false

local function autoKill(dad)
	local humanoid = dad:WaitForChild("Humanoid", 5)

	if not humanoid then return end

	local function kill() humanoid.Health = 0 end

	local function checkChaseDoor(child)
		if child.Name == "ChaseDoor" and child:IsA("BoolValue") then
			if child.Value then kill() end
			child.Changed:Connect(function(val) if val then kill() end end)
		end
	end

    local function checkKillCondition()
        local time = Lighting.ClockTime
        if (dad and dad.Parent and humanoid.Health and ((time > 22) or (time <= 6))) then
            return true
        end
        OrionLib:MakeNotification({
            Name    = "Warning!",                          -- Tiêu đề thông báo
            Content = "God-mode isn't ready yet.(Use after 10 PM)",            -- Nội dung thông báo
            Time    = 3,                                -- Thời gian hiển thị (giây)
        })
        return false
    end

	local chaseDoor = dad:FindFirstChild("ChaseDoor")
	if chaseDoor then checkChaseDoor(chaseDoor) else dad.ChildAdded:Connect(checkChaseDoor) end

	task.spawn(function()
		while checkKillCondition() do
			kill()
			task.wait(0.5)
		end
	end)
end

function killDad()
    if isListening then 
        OrionLib:MakeNotification({
            Name    = "Warning!",                          -- Tiêu đề thông báo
            Content = "You've already pressed God-mode! Please wait until dad is possessed.",            -- Nội dung thông báo
            Time    = 3,                                -- Thời gian hiển thị (giây)
        })
        return
    end
	local possessedDad = DadFolder:FindFirstChild("PossesedDad")
	if possessedDad then 
		autoKill(possessedDad) 
	else
		DadFolder.ChildAdded:Connect(function(child)
			if child.Name == "PossesedDad" then autoKill(child) end
		end)
	end
end

MainTab:AddButton({
    Name     = "God mode(Kill dad)",
    Visible  = true,
    Disabled = false,
    Callback = killDad,
})


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

local ppTable = {}
local ppConnection: RBXScriptConnection = nil

local function enablePrompts(value: boolean)
    local function processPrompt(obj: Instance)
        if obj:IsA("ProximityPrompt") then
            if ppTable[obj] == nil then
                ppTable[obj] = obj.Enabled
            end
            obj.Enabled = true
        end
    end

    if value then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            processPrompt(obj)
        end
        
        if not ppConnection then
            ppConnection = Workspace.DescendantAdded:Connect(processPrompt)
        end
    else
        if ppConnection then
            ppConnection:Disconnect()
            ppConnection = nil
        end
        
        for obj, originalState in pairs(ppTable) do
            if obj and obj.Parent then
                obj.Enabled = originalState
            end
        end
        
        table.clear(ppTable)
    end
end

MainTab:AddToggle({
    Name     = "Enable locked interactions",
    Default  = false,          -- Giá trị mặc định
    Type     = "CheckBox",       -- "Switch" hoặc "CheckBox"
    Flag     = "enablePrompts",    -- ID dùng với OrionLib.Flags
    Save     = true,           -- Lưu vào config
    Visible  = true,
    Disabled = false,
    Callback = enablePrompts,
})

-- ┌─ Instant ProximityPrompt ───────────────────────────────────────────────┐
-- │  Toggle: tự động fire bất kỳ ProximityPrompt nào ngay khi giữ.         │
-- │  connection lưu ngoài hàm để Disconnect() được khi tắt toggle.         │
-- └────────────────────────────────────────────────────────────────────────-┘
local instantPPConnection = nil

local function instantProximityPrompt(value)
    if value then
        instantPPConnection = game:GetService("ProximityPromptService")
            .PromptButtonHoldBegan:Connect(function(prompt)
                firePrompt(prompt)
            end)
    elseif instantPPConnection then
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
    Callback = instantProximityPrompt,
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
local function createStatLabel(text: string, valueObject: IntValue): any
    local para = statsTab:AddParagraph(text, "...")

    local function update(value: number)
        task.defer(function()
            para:Set(tostring(value) .. " / 100")
        end)
    end

    OrionLib:AddConnect(valueObject.Changed, update)

    update(valueObject.Value)

    return para
end

createStatLabel("Fuel", house.Generator.Bar)
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
    if not value then
        local dadModel = Workspace.Game.dad:FindFirstChild("PossesedDad")
        if dadModel then
            local h = dadModel:FindFirstChild("DadHighlight")
            if h then h:Destroy() end
        end
        return
    end

    local dadModel = Workspace.Game.dad:FindFirstChild("PossesedDad")
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
    Callback = dadEsp,
})
-- ═════════════════════════════════════════════════════════════════════════════
-- SECTION: CAMERA
-- ═════════════════════════════════════════════════════════════════════════════
ViewTab:AddSection({Name="Camera"})
local brightLoop
local function loopfb(value)
    if value then
        if brightLoop then
            brightLoop:Disconnect()
        end
        local function brightFunc()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
        brightLoop = OrionLib:AddConnect(RunService.RenderStepped, brightFunc)
    else
        if brightLoop then
            brightLoop:Disconnect()
        end
    end
end

ViewTab:AddToggle({
    Name     = "FullBright",
    Default  = false,          -- Initial value
    Type     = "CheckBox",       -- "Switch" or "CheckBox"
    Flag     = "fullBright",    -- ID used with OrionLib.Flags
    Save     = true,           -- Save to config
    Visible  = true,
    Disabled = false,
    Callback = function(value)
        loopfb(value)
    end,
})

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


ViewTab:AddButton({
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

local function ManualDisconnect(connection: RBXScriptConnection)
    if connection and typeof(connection) == 'RBXScriptConnection' then
        if connection.Connected then
            connection:Disconnect()
        end
    end
end

function destroyUI()
    --connections
    ManualDisconnect(instantPPConnection)
    ManualDisconnect(antiSeatConnection)
    ManualDisconnect(ppConnection)
    --toggles
    dadEsp(false)
    loopfb(false)
    --true deletion
    OrionLib:Destroy()
    getgenv().GHUB_LOADED = false
end

MiscTab:AddButton({
    Name     = "Destroy UI",
    Visible  = true,
    Disabled = false,
    Callback = destroyUI,
})
