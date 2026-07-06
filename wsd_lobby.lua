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

getgenv().GHUB_LOADED = true

local Window = OrionLib:MakeWindow({
    Name            = "G_Hub - Lobby",
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },
    IntroToggleIcon = "rbxassetid://14229447778",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "WSD_FreeHub",
    IntroEnabled    = true,
    IntroText       = "G_Hub - Lobby",
    IntroIcon       = "rbxassetid://14229447778",
    Icon            = "rbxassetid://14229447778",
    CloseCallback   = function()
        
    end,
})
local MainTab = Window:MakeTab({
    Name        = "Main",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Tab có hiển thị trong sidebar không
    Disabled    = false,   -- Tab bị vô hiệu hóa (mờ, không click được)
    PremiumOnly = false,   -- Khoá tab cho Sirius Premium users
})

MainTab:AddButton({
    Name     = "Teleport to Chapter 1",
    Visible  = true,
    Disabled = false,
    Callback = function()
        cloneref(game:GetService("TeleportService")):Teleport(14787381917, game.Players.LocalPlayer)
    end,
})

MainTab:AddButton({
    Name = "Teleport to Chapter 2",
    Callback = function()
        cloneref(game:GetService("TeleportService")):Teleport(15322497988, game.Players.LocalPlayer);
    end;
});
MainTab:AddButton({
    Name = "Teleport to Chapter 3",
    Callback = function()
        cloneref(game:GetService("TeleportService")):Teleport(16375066410, game.Players.LocalPlayer);
    end;
});
MainTab:AddButton({
    Name = "Teleport to Chapter 4",
    Callback = function()
        cloneref(game:GetService("TeleportService")):Teleport(17619037026, game.Players.LocalPlayer);
    end;
});
MainTab:AddButton({
    Name = "Teleport to Book2 Chapter1",
    Callback = function()
        cloneref(game:GetService("TeleportService")):Teleport(71718624482170, game.Players.LocalPlayer);
    end;
});

MainTab:AddButton({
    Name = "Destroy UI",
    CallBack = function()
        OrionLib:Destroy()
        getgenv().GHUB_LOADED = false
    end
})
