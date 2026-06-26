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

OrionLib:MakeNotification({
    Name    = "Success",
    Content = "Script loaded successfully!",
    Time    = 3
})

local Window = OrionLib:MakeWindow({
    Name            = "G_Hub - Chapter 3",
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
