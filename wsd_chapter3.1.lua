-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local function githubGetRaw(user, repo, branch, path)
    local rawUrl = ("https://raw.githubusercontent.com/%s/%s/%s/%s#t=%s")
        :format(user, repo, branch, path, os.time())

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

getgenv().GHUB_LOADED = true

OrionLib:MakeNotification({
    Name    = "Success",
    Content = "Script loaded successfully!",
    Time    = 3
})


-- ── Các biến toàn cục thường dùng ────────────────────────────────────────────
local Players    = game:GetService("Players")
local player     = Players.LocalPlayer
local char       = player.Character or player.CharacterAdded:Wait()
local hrp        = char:WaitForChild("HumanoidRootPart")

-- ── Helper: Equip tool từ Backpack theo tên ───────────────────────────────────
local function equipTool(toolName, timeout)
    timeout = timeout or 0.1
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


-- ── Helper: Kích hoạt ProximityPrompt tức thì ──────────
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
    task.wait(0.15)
end

-- Tạo cửa sổ
local WindowName = "G_Hub - Chapter 3"
local Window = OrionLib:MakeWindow({
    Name            = WindowName,
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
    IntroEnabled    = true,
    IntroText       = WindowName,
    IntroIcon       = "rbxassetid://7734091286",
    Icon            = "rbxassetid://7734091286",
    CloseCallback   = function()
        print("UI closed")
    end,
})

-- ═════════════════════════════════════════════════════════════════════════════
--  TAB: MAIN
-- ═════════════════════════════════════════════════════════════════════════════
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://7733960981",
    Visible = true,
    Disabled = false
})

--Location
local house = workspace.House
local kitchen = house.Rooms.Kitchen
local fridge  = kitchen.FridgeNoodles.Primary
local stove   = kitchen.Stove.Primary
local glassShelf = workspace.House.Spares:FindFirstChild("Shelf with Drinks").Primary
local waterDispenser = house.Spares:FindFirstChild("WaterDispenser").Primary

local RETURN_POSITION = Vector3.new(-113, 5, 61)
local STORE_PROMPT = workspace.Game.Baggage.Store

local gasCanSuccess = false
local isRunning = false
--Position
local FRIDGE_POSITION = Vector3.new(-122, 5, 16)
local STOVE_POSITION = Vector3.new(-111, 5, 17)
local SHELF_POSITION = Vector3.new(-126, 5, 25)
local DISPENSER_POSITION = Vector3.new(-125, 5, 30)

local function getGasCan()
    --[1] Equip
    local can     = workspace.House.GasCans:GetChildren()[1]
    local primary = can and can:FindFirstChild("Primary")

    if not primary then
        gasCanSuccess = true
        OrionLib:MakeNotification({ Name = "Success!", Content = "Collected all gas cans", Time = 5})
        return
    end

    tpTo(primary.Position + Vector3.new(0, 3, 0))
    firePrompt(primary:FindFirstChildOfClass("ProximityPrompt"))
end

local function getCookedNoodles()
    -- [1] Lấy mì sống từ tủ lạnh
    tpTo(FRIDGE_POSITION)
    firePrompt(fridge.ProximityPrompt)
    equipTool("Raw Noodle")

    -- [2] Nấu mì trên bếp
    tpTo(STOVE_POSITION)
    firePrompt(stove.ProximityPrompt)
end

local function getWaterGlasses()
    tpTo(SHELF_POSITION)
    firePrompt(glassShelf.ProximityPrompt)
    equipTool("Drinking Glass")

    -- [2] Rót nước từ máy lọc
    tpTo(DISPENSER_POSITION)
    firePrompt(waterDispenser.ProximityPrompt)
end

local function putAll()
    tpTo(RETURN_POSITION)
    equipTool('gas can')
    firePrompt(STORE_PROMPT)

    task.wait(0.3)
    equipTool('Glass of Water')
    firePrompt(STORE_PROMPT)

    task.wait(0.3)
    equipTool('Cooked Noodle')
    firePrompt(STORE_PROMPT)

end

local function getAllStuff(value)
    isRunning = value
    if value then
        local function getAll()
            OrionLib:MakeNotification({
                Name = "Information",
                Content = "Auto Collect Started",
                Timeout = 3,
                Image   = "rbxassetid://4483345998",
            })
            
            while isRunning do
                if not gasCanSuccess then
                    getGasCan()
                end
                
                -- Kiểm tra lại trạng thái trước mỗi hành động đề phòng người dùng vừa bấm Tắt
                if not isRunning then break end 
                getCookedNoodles()
                
                if not isRunning then break end
                getWaterGlasses()

                putAll()
            end
        end
        task.spawn(getAll)
    end
end

MainTab:AddToggle({
    Name     = "Auto get all",
    Default  = false,          -- Giá trị mặc định
    Type     = "Switch",       -- "Switch" hoặc "CheckBox"
    Flag     = "getAllStuff",    -- ID dùng với OrionLib.Flags
    Save     = true,           -- Lưu vào config
    Visible  = true,
    Disabled = false,
    Callback = getAllStuff,
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
    Name     = "Destroy UI",
    Visible  = true,
    Disabled = false,
    Callback = function()
        OrionLib:Destroy()
        getgenv().GHUB_LOADED = false
    end,
})
