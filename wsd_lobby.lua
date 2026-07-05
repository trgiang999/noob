local OrionLib = loadstring("https://raw.githubusercontent.com/trgiang999/noob/refs/heads/main/OrionLibSource.lua")()
local Window = OrionLib:MakeWindow({
    Name            = "G_Hub - Lobby",
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
