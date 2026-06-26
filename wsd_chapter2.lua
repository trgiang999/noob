-- ── Khởi động thư viện Orion ──────────────────────────────────────────────────
local function githubGetRaw(user, repo, branch, path)
    local rawUrl = ("https://raw.githubusercontent.com/%s/%s/%s/%s?t=%s")
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

-- ── Phần code chính của Script đặt ở phía dưới này ───────────────────────────
OrionLib:MakeNotification({
    Name    = "Success",
    Content = "Script loaded successfully!",
    Time    = 3
})

OrionLib:MakeNotification({
    Name    = "Warning!",                          -- Tiêu đề thông báo
    Content = "This chapter is currently not supported!",            -- Nội dung thông báo
    Image   = "rbxassetid://4483345998",        -- Icon bên trái tiêu đề
    Time    = 5,                                -- Thời gian hiển thị (giây)
})

local Window = OrionLib:MakeWindow({
    Name            = "G_Hub - Chapter 2",
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
    IntroEnabled    = true,
    IntroText       = "G_Hub - Chapter 2",
    IntroIcon       = "rbxassetid://7734091286",
    Icon            = "rbxassetid://7734091286",
    CloseCallback   = function()
        print("UI closed")
    end,
})

local Tab, TabControl = Window:MakeTab({
    Name        = "Main",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Tab có hiển thị trong sidebar không
    Disabled    = false,   -- Tab bị vô hiệu hóa (mờ, không click được)
    PremiumOnly = false,   -- Khoá tab cho Sirius Premium users
})

Tab:AddButton({
    Name     = "Skripthookv's hub",
    Visible  = true,
    Disabled = false,
    Callback = function()
        local url = 'https://raw.githubusercontent.com/xectray1/realloader/refs/heads/main/books.lua'
        OrionLib:MakeNotification({
            Name    = "Credits",                          -- Tiêu đề thông báo
            Content = "Credits to Skripthookv.",            -- Nội dung thông báo
            Image   = "rbxassetid://4483345998",        -- Icon bên trái tiêu đề
            Time    = 5,                                -- Thời gian hiển thị (giây)
        })
        loadstring(game:HttpGet(url))()
    end,
})

Tab:AddButton({
    Name     = "Skripthookv's YT",
    Visible  = true,
    Disabled = false,
    Callback = function()
        local url = 'https://raw.githubusercontent.com/xectray1/realloader/refs/heads/main/books.lua'
        OrionLib:MakeNotification({
            Name    = "Credits",                          -- Tiêu đề thông báo
            Content = "Credits to Skripthookv.",            -- Nội dung thông báo
            Image   = "rbxassetid://4483345998",        -- Icon bên trái tiêu đề
            Time    = 5,                                -- Thời gian hiển thị (giây)
        })
        if setclipboard then
            setclipboard(url)
        elseif toclipboard then
            toclipboard(url)
        end
    end,
})

Tab:AddButton({
    Name = "Destroy UI",
    Visible = true,
    Disabled = false,
    Callback = function()
        OrionLib:Destroy()
        getgenv().GHUB_LOADED = false
    end
})
