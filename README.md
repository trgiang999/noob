# Orion Library — Complete Documentation

> Credits: Credits to ArticleHub for the source(https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua)
---

## Table of Contents

1. [Loading the Library](#1-loading-the-library)
2. [Global Configuration](#2-global-configuration)
3. [Creating a Window](#3-creating-a-window)
4. [Creating a Tab](#4-creating-a-tab)
5. [Creating a Section](#5-creating-a-section)
6. [Divider](#6-divider)
7. [Notification](#7-notification)
8. [Watermark](#8-watermark)
9. [Keybind Panel](#9-keybind-panel)
10. [Elements](#10-elements)
    - [Button](#button)
    - [Toggle](#toggle)
    - [Slider](#slider)
    - [Dropdown](#dropdown)
    - [Textbox](#textbox)
    - [Bind](#bind)
    - [Colorpicker](#colorpicker)
    - [Label](#label)
    - [Paragraph](#paragraph)
    - [Image](#image)
    - [Viewport](#viewport)
11. [Flags System](#11-flags-system)
12. [Config System](#12-config-system)
13. [AddConnect](#13-addconnect)
14. [Build Settings & Autoload](#14-build-settings--autoload)
15. [Destroying the UI](#15-destroying-the-ui)
16. [Icon Reference](#16-icon-reference)

---

## 1. Loading the Library

```lua
-- Load Orion Library from GitHub
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()
```

> **Note:** You do **not** need to call `OrionLib:Init()` — the source has **no** `Init()` function. Just call `OrionLib:MakeWindow()` directly.

---

## 2. Global Configuration

These functions should be called **before** creating a Window.

### Set Toggle Key

```lua
-- Change the hotkey used to open/close the UI (default: RightShift)
-- KeyCode reference: https://create.roblox.com/docs/reference/engine/enums/KeyCode
OrionLib:SetKeyToggleUI(Enum.KeyCode.RightShift)
```

### Set Background Video

```lua
-- Set a background video for the window (accepts a URL string)
OrionLib:SetVideoLink("https://example.com/video.mp4")
```

### Set Global Font

```lua
-- Change the font used across the entire UI
-- Font reference: https://create.roblox.com/docs/reference/engine/enums/Font
OrionLib:SetFont(Enum.Font.GothamBold)
```

---

## 3. Creating a Window

```lua
local Window = OrionLib:MakeWindow({
    -- Title displayed on the window
    Name            = "My Hub",

    -- Search bar inside the tab list (nil = disabled)
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },

    -- Icon shown on the reopen button (after the window is closed)
    IntroToggleIcon = "rbxassetid://7734091286",

    -- Hide the user's Premium badge
    HidePremium     = false,

    -- Enable the config save/load system
    SaveConfig      = true,

    -- Folder name used to store configs in the exploiter filesystem
    ConfigFolder    = "MyHubConfigs",

    -- Enable/disable the intro animation on startup
    IntroEnabled    = true,

    -- Text shown during the intro screen
    IntroText       = "My Hub",

    -- Icon shown during the intro screen
    IntroIcon       = "rbxassetid://7734091286",

    -- Small icon next to the window title (requires ShowIcon = true)
    Icon            = "rbxassetid://7734091286",

    -- Called when the user presses the Close button
    CloseCallback   = function()
        print("UI closed")
    end,
})

--[[
PARAMETERS:
    Name            <string>   - Window title
    SearchBar       <table>    - Search bar config ({ Default, ClearTextOnFocus })
    IntroToggleIcon <string>   - rbxassetid shown on the reopen button
    HidePremium     <bool>     - Hide the Premium badge in the user panel
    SaveConfig      <bool>     - Enable config save/load system
    ConfigFolder    <string>   - Folder name used to store config files
    IntroEnabled    <bool>     - Show intro animation on load (default: true)
    IntroText       <string>   - Text shown during intro animation
    IntroIcon       <string>   - Image shown during intro animation
    Icon            <string>   - Icon next to the window title
    LinkVideo       <string>   - URL of a background video (mp4/webm)
    CloseCallback   <function> - Called when the close button is pressed
]]
```

---

## 4. Creating a Tab

```lua
-- MakeTab returns 2 values: the element builder table and the tab control table
local Tab, TabControl = Window:MakeTab({
    Name        = "Main",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Whether the tab button is shown in the sidebar
    Disabled    = false,   -- Gray out the tab and block interaction
    PremiumOnly = false,   -- Lock the tab for Sirius Premium users only
})

--[[
PARAMETERS:
    Name        <string> - Tab label
    Icon        <string> - rbxassetid icon beside the label
    Visible     <bool>   - Whether the tab button is shown (default: true)
    Disabled    <bool>   - Grays out the tab and blocks interaction (default: false)
    PremiumOnly <bool>   - Locks content to Premium users only (default: false)

RETURNS:
    Tab         - Element builder (AddButton, AddToggle, etc.)
    TabControl  - Tab visibility/disabled controller
]]

-- Show/hide the tab button in the sidebar
TabControl:SetVisible(false)

-- Enable/disable the tab
TabControl:SetDisabled(true)
```

---

## 5. Creating a Section

Sections group elements under a small header label.
All methods available on a `Tab` are also available inside a `Section`.

```lua
local Section = Tab:AddSection({
    Name = "Movement",
})

-- Add elements to a section exactly like a tab
Section:AddButton({ Name = "Fly", Callback = function() end })

-- Rename the section after creation
Section:Set("New Section Name")
```

---

## 6. Divider

Draws a horizontal line to visually separate groups of elements.

```lua
-- Plain divider (line only)
Tab:AddDivider()

-- Divider with a label in the center
Tab:AddDivider({ Text = "Settings" })
```

---

## 7. Notification

```lua
OrionLib:MakeNotification({
    Name    = "Alert",                          -- Notification title
    Content = "Something happened!",            -- Notification body text
    Image   = "rbxassetid://4483345998",        -- Icon to the left of the title
    Time    = 5,                                -- Display duration in seconds
})

--[[
PARAMETERS:
    Name    <string> - Notification title
    Content <string> - Notification body text
    Image   <string> - rbxassetid icon
    Time    <number> - Duration in seconds (default: 5)

NOTE:
    Content supports Rich Text tags:
        [Highlight:"text"]      → bold, white color
        [underline:"text"]      → underline
        [Color_#RRGGBB:"text"]  → custom color
]]
```

---

## 8. Watermark

The watermark is a floating, draggable label for displaying realtime information.

```lua
local Watermark = OrionLib:MakeWatermark({
    Text    = "MyHub | v1.0",
    Visible = true,
    Flag    = "Watermark",   -- Used to access via OrionLib.Flags
})

-- Update the watermark text
Watermark:SetText("New Text")
OrionLib.Flags["Watermark"]:SetText("New Text")

-- Show/hide the watermark
Watermark:SetVisible(false)
```

### Live FPS / Ping Example

```lua
-- Display realtime FPS and ping on the watermark
local frameTimer   = tick()
local frameCounter = 0
local fps          = 60

OrionLib:AddConnect(game:GetService("RunService").RenderStepped, function()
    frameCounter += 1

    if (tick() - frameTimer) >= 1 then
        fps          = frameCounter
        frameTimer   = tick()
        frameCounter = 0
    end

    local ping = math.floor(
        game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    )

    OrionLib.Flags["Watermark"]:SetText(
        ("%d FPS | %d ms"):format(fps, ping)
    )
end)
```

---

## 9. Keybind Panel

A small floating window that lists all Toggles that have a keybind assigned.

```lua
-- Show/hide the Keybind Panel
OrionLib:SetKeyBindVisible(true)

--[[
NOTE:
    The Keybind Panel is populated automatically when you use Toggle:AddBind().
    No manual registration is required.
]]
```

---

## 10. Elements

### Button

```lua
local MyButton = Tab:AddButton({
    Name     = "Click Me",
    Visible  = true,
    Disabled = false,
    Callback = function()
        print("Button clicked!")
    end,
})

--[[
PARAMETERS:
    Name     <string>   - Button label
    Visible  <bool>     - Show/hide the button (default: true)
    Disabled <bool>     - Disable interaction (default: false)
    Callback <function> - Called when clicked
    Flag     <string>   - Optional flag ID
]]

-- Change the label
MyButton:Set("New Label")

-- Change the callback
MyButton:SetCallback(function()
    print("New callback!")
end)

-- Trigger a click programmatically (without user input)
MyButton:Click()

-- Enable/disable the button
MyButton:SetDisabled(true)

-- Show/hide the button
MyButton:SetVisible(false)
```

#### Split Button (two buttons side by side)

```lua
-- AddButton returns an object; call :AddButton() on it to create a second button beside it
local LeftBtn = Tab:AddButton({
    Name     = "Left",
    Callback = function() print("Left") end,
})

local RightBtn = LeftBtn:AddButton({
    Name     = "Right",
    Callback = function() print("Right") end,
})
```

---

### Toggle

```lua
local MyToggle = Tab:AddToggle({
    Name     = "Enable Feature",
    Default  = false,          -- Initial value
    Type     = "Switch",       -- "Switch" or "CheckBox"
    Flag     = "myFeature",    -- ID used with OrionLib.Flags
    Save     = true,           -- Save to config
    Visible  = true,
    Disabled = false,
    Callback = function(value)
        print("Toggle is now:", value)
    end,
})

--[[
PARAMETERS:
    Name     <string>   - Toggle label
    Default  <bool>     - Initial value (default: false)
    Type     <string>   - "Switch" | "CheckBox" (default: "CheckBox")
    Flag     <string>   - Flag ID for config / remote access
    Save     <bool>     - Include in config saves
    Visible  <bool>     - Show/hide
    Disabled <bool>     - Disable interaction
    Callback <function> - Called with (bool) when value changes
]]

-- Set the value
MyToggle:Set(true)
OrionLib.Flags["myFeature"]:Set(true)

-- Change the label
MyToggle:SetText("New Label")

-- Change the callback
MyToggle:SetCallback(function(v) print(v) end)

-- Enable/disable
MyToggle:SetDisabled(false)

-- Show/hide
MyToggle:SetVisible(true)
```

#### Toggle + Bind (hotkey to toggle)

```lua
-- Call :AddBind() immediately after :AddToggle() to attach a keybind
local MyToggle = Tab:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Flag     = "speedHack",
    Callback = function(v) print("Speed:", v) end,
}):AddBind({
    Default = Enum.KeyCode.F,   -- Default key
    Flag    = "speedHackBind",  -- Separate flag for this bind
    Save    = true,
})

--[[
AddBind PARAMETERS:
    Default <Enum.KeyCode> - Default keybind
    Flag    <string>       - Flag ID for this bind
    Save    <bool>         - Save the bind key to config
]]
```

---

### Slider

```lua
local MySlider = Tab:AddSlider({
    Name      = "Walk Speed",
    Min       = 16,
    Max       = 100,
    Default   = 16,
    Increment = 1,
    ValueName = "studs/s",     -- Unit label displayed after the value
    Color     = Color3.fromRGB(9, 149, 98),
    Flag      = "walkSpeed",
    Save      = true,
    Visible   = true,
    Disabled  = false,
    Callback  = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

--[[
PARAMETERS:
    Name      <string>   - Slider label
    Min       <number>   - Minimum value
    Max       <number>   - Maximum value
    Default   <number>   - Initial value
    Increment <number>   - Step size when dragging
    ValueName <string>   - Unit label shown after the value
    Color     <Color3>   - Slider fill color
    Flag      <string>   - Flag ID
    Save      <bool>     - Save value to config
    Visible   <bool>     - Show/hide
    Disabled  <bool>     - Disable dragging
    Callback  <function> - Called with (number) on value change
]]

-- Set the value
MySlider:Set(50)
OrionLib.Flags["walkSpeed"]:Set(50)

-- Change the range limits
MySlider:SetMax(200)
MySlider:SetMin(0)

-- Change the callback
MySlider:SetCallback(function(v) print(v) end)

-- Show/hide, enable/disable
MySlider:SetVisible(false)
MySlider:SetDisabled(true)
```

---

### Dropdown

#### Single Select

```lua
local MyDropdown = Tab:AddDropdown({
    Name     = "Game Mode",
    Default  = "Normal",
    Options  = { "Normal", "Hard", "Extreme" },
    Multi    = false,
    Flag     = "gameMode",
    Save     = true,
    Visible  = true,
    Disabled = false,
    Callback = function(value)
        print("Selected:", value)
    end,
})
```

#### Multi Select

```lua
local MyMultiDropdown = Tab:AddDropdown({
    Name     = "Enabled Hacks",
    Default  = { "Speed", "Jump" },   -- Array of default selections
    Options  = { "Speed", "Jump", "Fly", "NoClip" },
    Multi    = true,
    Flag     = "enabledHacks",
    Callback = function(value)
        -- value is a table: { "Speed", "Jump", ... }
        for _, v in ipairs(value) do
            print("Enabled:", v)
        end
    end,
})
```

#### Dropdown V2.6 — Metadata Mode (Icon + Thumbnail + Description)

```lua
local MyRichDropdown = Tab:AddDropdown({
    Name    = "Select Weapon",
    Default = "sword",
    Options = {
        ["sword"] = {
            Title     = "Excalibur",
            Desc      = "A legendary blade",
            Icon      = "rbxassetid://4483345998",
            Thumbnail = "rbxassetid://4483345998",
        },
        ["bow"] = {
            Title = "Longbow",
            Desc  = "Shoots arrows",
            Icon  = "rbxassetid://3944703587",
        },
        ["staff"] = {
            Title = "Magic Staff",
            Desc  = "Casts spells",
        },
    },
    Callback = function(value)
        print("Chosen key:", value)  -- value is the key string ("sword", "bow", ...)
    end,
})

--[[
PARAMETERS:
    Name     <string>        - Dropdown label
    Default  <string|table>  - Initial selection (string for single, table for multi)
    Options  <table>         - List of options (array or dict with metadata)
    Multi    <bool>          - Allow multiple selections
    Flag     <string>        - Flag ID
    Save     <bool>          - Save selection to config
    Visible  <bool>          - Show/hide
    Disabled <bool>          - Disable interaction
    Callback <function>      - Called with selected value(s)
]]

-- Select an option programmatically
MyDropdown:Set("Hard")
OrionLib.Flags["gameMode"]:Set("Hard")

-- Refresh the options list (true = clear old options first)
MyDropdown:Refresh({ "Option A", "Option B" }, true)

-- Change the callback
MyDropdown:SetCallback(function(v) print(v) end)

-- Show/hide, enable/disable
MyDropdown:SetVisible(false)
MyDropdown:SetDisabled(true)
```

---

### Textbox

```lua
local MyTextbox = Tab:AddTextbox({
    Name          = "Player Name",
    Default       = "",              -- Initial text value
    TextDisappear = false,           -- Clear text when focus is lost
    Finished      = true,            -- Only fire callback on Enter/FocusLost
    Numeric       = false,           -- Accept numbers only
    Flag          = "targetPlayer",
    Save          = false,
    Callback      = function(value)
        print("Input:", value)
    end,
})

--[[
PARAMETERS:
    Name          <string>   - Label
    Default       <string>   - Initial text value
    TextDisappear <bool>     - Clear text on focus loss
    Finished      <bool>     - Fire callback only on FocusLost (true) or every keystroke (false)
    Numeric       <bool>     - Restrict input to numbers only
    Flag          <string>   - Flag ID
    Save          <bool>     - Save value to config
    Callback      <function> - Called with (string) on input
]]

-- Set the text programmatically
MyTextbox:SetText("Roblox")
OrionLib.Flags["targetPlayer"]:SetText("Roblox")

-- Change the label
MyTextbox:SetLabel("Target Username")

-- Change the callback
MyTextbox:SetCallback(function(v) print(v) end)
```

---

### Bind

Standalone bind (not attached to a Toggle).

```lua
local MyBind = Tab:AddBind({
    Name     = "Teleport Key",
    Default  = Enum.KeyCode.T,
    Hold     = false,   -- true = callback receives bool (held/released); false = fires on press
    Flag     = "tpKey",
    Save     = true,
    Callback = function()
        print("Teleport triggered!")
    end,
})

--[[
PARAMETERS:
    Name     <string>        - Label
    Default  <Enum.KeyCode>  - Default key
    Hold     <bool>          - Hold mode: callback(true) on hold, callback(false) on release
    Flag     <string>        - Flag ID
    Save     <bool>          - Save key to config
    Callback <function>      - Called on key press (or with bool in Hold mode)
]]

-- Change the key programmatically
MyBind:Set(Enum.KeyCode.G)
OrionLib.Flags["tpKey"]:Set(Enum.KeyCode.G)

-- Change the label
MyBind:SetText("New Label")

-- Change the callback
MyBind:SetCallback(function() print("New bind!") end)
```

---

### Colorpicker

```lua
local MyColor = Tab:AddColorpicker({
    Name         = "ESP Color",
    Default      = Color3.fromRGB(255, 0, 0),
    DefaultAlpha = 1,              -- Default opacity (0–1); requires Alpha = true
    Alpha        = false,          -- Show the alpha slider
    Flag         = "espColor",
    Save         = true,
    Callback     = function(color, alpha)
        -- color: Color3, alpha: number (only meaningful when Alpha = true)
        print("Color:", color, "Alpha:", alpha)
    end,
})

--[[
PARAMETERS:
    Name         <string>   - Label
    Default      <Color3>   - Initial color
    DefaultAlpha <number>   - Initial alpha value (0–1)
    Alpha        <bool>     - Show alpha slider
    Flag         <string>   - Flag ID
    Save         <bool>     - Save color to config
    Callback     <function> - Called with (Color3, alpha) on change
]]

-- Set the color programmatically
MyColor:Set(Color3.fromRGB(0, 255, 0))
OrionLib.Flags["espColor"]:Set(Color3.fromRGB(0, 255, 0))

-- Set color and alpha at the same time
MyColor:Set(Color3.fromRGB(0, 255, 0), 0.8)
```

---

### Label

A label is plain text with no interaction.

```lua
local MyLabel = Tab:AddLabel("Status: Idle")

-- Update the text
MyLabel:Set("Status: Running")

-- Update the text with a color state (success / error / warning / fail)
MyLabel:Set("Connected!", "success")
MyLabel:Set("Failed to connect", "error")
MyLabel:Set("Low HP warning", "warning")
MyLabel:Set("Server rejected", "fail")
```

---

### Paragraph

Paragraph displays a title and a body of text with automatic word wrapping.

```lua
local MyParagraph = Tab:AddParagraph(
    "How to use",                        -- Title
    "Press F to activate the feature."   -- Body content
)

-- Update both the title and the body
MyParagraph:Set("New Title", "New content text here.")
```

---

### Image

```lua
local MyImage = Tab:AddImage({
    Icon    = "rbxassetid://3944703587",
    Size    = 100,     -- Image size in pixels
    Visible = true,
    Flag    = "myImage",
})

--[[
PARAMETERS:
    Icon    <string> - rbxassetid
    Size    <number> - Width and height in pixels
    Visible <bool>   - Show/hide
    Padding <number> - Padding around image (default: 8)
    Flag    <string> - Flag ID
]]

-- Change the image
MyImage:SetIcon("rbxassetid://123456789")

-- Change the size
MyImage:SetSize(150)

-- Show/hide
MyImage:SetVisible(false)
```

---

### Viewport

Viewport is a small 3D preview window for displaying instances.

```lua
local MyViewport = Tab:AddViewport({
    Object  = Instance.new("Part"),     -- Instance displayed inside the viewport
    Camera  = Instance.new("Camera"),   -- Camera used to view the object
    Orbit   = true,     -- Auto-rotate the object
    Control = true,     -- Allow the user to drag to rotate
    Zoom    = true,     -- Allow the user to scroll to zoom
    Size    = 270,      -- Frame size in pixels
    Visible = true,
    Flag    = "myViewport",
})

--[[
PARAMETERS:
    Object  <Instance>  - 3D object to display (BasePart or Model)
    Camera  <Camera>    - Camera instance
    Orbit   <bool>      - Auto-rotate object
    Control <bool>      - Enable drag-to-rotate
    Zoom    <bool>      - Enable scroll/pinch-to-zoom
    Size    <number>    - Frame size in pixels
    Visible <bool>      - Show/hide
    Padding <number>    - Padding around the frame (default: 8)
    Flag    <string>    - Flag ID
]]

-- Replace the object — method 1: pass an existing Instance
local part = Instance.new("Part")
part.Size = Vector3.new(2, 2, 2)
MyViewport:SetObject(part)

-- Replace the object — method 2: pass a class name + properties table
MyViewport:SetObject("Part", { Size = Vector3.new(3, 3, 3), BrickColor = BrickColor.new("Bright red") })

-- Customise zoom limits
MyViewport:SetZoomCamera({ MaxZoom = 50, MinZoom = 5, Distance = 20 })

-- Toggle features
MyViewport:SetVisible(true)
MyViewport:SetControl(false)
MyViewport:SetOrbit(false)
MyViewport:SetZoom(true)
```

---

## 11. Flags System

A Flag is a unique ID you assign to an element, allowing you to access it from **anywhere** in your code.

```lua
-- Declare an element with a Flag
local MyToggle = Tab:AddToggle({
    Name    = "Auto Farm",
    Default = false,
    Flag    = "autoFarm",
    Save    = true,
    Callback = function(value)
        print("AutoFarm:", value)
    end,
})

-- Read the current value via its Flag
print(OrionLib.Flags["autoFarm"].Value)   -- true or false

-- Call methods via Flag (equivalent to using the MyToggle variable directly)
OrionLib.Flags["autoFarm"]:Set(true)
OrionLib.Flags["autoFarm"]:SetDisabled(false)
OrionLib.Flags["autoFarm"]:SetVisible(true)
```

**Elements that support Flags:**

| Element      | `.Value` type           |
|-------------|-------------------------|
| Toggle      | `bool`                  |
| Slider      | `number`                |
| Dropdown    | `string` / `table`      |
| Bind        | `string` (KeyCode name) |
| Textbox     | `string`                |
| Colorpicker | `Color3`                |

> Button, Label, Paragraph, Divider, and Section do **not** support Flags.

---

## 12. Config System

The config system lets you save and reload element values between sessions.

### Requirements

1. The Window must have `SaveConfig = true` and `ConfigFolder = "FolderName"`.
2. Each element you want to save must have `Flag = "uniqueId"` and `Save = true`.

```lua
-- Window setup
local Window = OrionLib:MakeWindow({
    Name         = "My Hub",
    SaveConfig   = true,
    ConfigFolder = "MyHubConfigs",
})

-- Element with Save enabled
Tab:AddToggle({
    Name    = "Speed Hack",
    Default = false,
    Flag    = "speedHack",
    Save    = true,    -- ← required for saving
    Callback = function(v) end,
})
```

### BuildSettings — Config Management Page

```lua
-- Pass in a Tab; the function will automatically add Save/Load/Autoload buttons
OrionLib:BuildSettings(SettingsTab)
```

### Autoload

```lua
-- Load the config marked as autoload (call after all elements have been created)
OrionLib:LoadAutoloadConfig()
```

---

## 13. AddConnect

Use `OrionLib:AddConnect` instead of `:Connect()` so connections are automatically disconnected when the UI is destroyed.

```lua
-- Example: run every frame
OrionLib:AddConnect(game:GetService("RunService").RenderStepped, function()
    -- Code that runs every frame
end)

-- Example: listen for input
OrionLib:AddConnect(game:GetService("UserInputService").InputBegan, function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        print("X pressed")
    end
end)

--[[
NOTE:
    When OrionLib:Destroy() is called, ALL connections created with AddConnect
    are automatically Disconnect()ed — preventing error spam and memory leaks.
]]
```

---

## 14. Build Settings & Autoload

```lua
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "" })

-- Build the full config management UI inside this tab
OrionLib:BuildSettings(SettingsTab)

-- After all elements have been created, load the autoload config (if one is set)
OrionLib:LoadAutoloadConfig()
```

**BuildSettings automatically adds:**
- Toggle to show/hide the Keybind Panel
- Toggle to show/hide the Watermark (if one exists)
- Notification volume slider
- Textbox for entering a config name
- Dropdown for selecting a saved config
- Buttons: Create / Load / Overwrite / Set Autoload / Remove Autoload / Refresh List
- Textbox + button to set the background video (if the window has `LinkVideo`)

---

## 15. Destroying the UI

```lua
-- Destroy the entire UI and disconnect all connections
OrionLib:Destroy()

-- Register a callback to run before the UI is destroyed
OrionLib:OnDestroy(function()
    print("UI is being destroyed!")
    -- Cleanup code here
end)
```

---

## 16. Icon Reference

Orion uses **Feather Icons**. You can pass an icon name as a string instead of an rbxassetid.

```
Icon JSON:
https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/icons.json
```

```lua
-- Use a Feather icon name instead of an asset ID
local Tab = Window:MakeTab({
    Name = "Combat",
    Icon = "sword",   -- icon name from icons.json
})
```

---

## Full Example Script

```lua
--================================================
--  Orion Library — Full Example
--================================================

-- [1] Load the library
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()

-- [2] Create the main window
local Window = OrionLib:MakeWindow({
    Name            = "My Hub",
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "MyHub",
    IntroEnabled    = true,
    IntroText       = "My Hub",
})

-- [3] Create tabs
local MainTab, _     = Window:MakeTab({ Name = "Main",     Icon = "home" })
local SettingsTab, _ = Window:MakeTab({ Name = "Settings", Icon = "settings" })

-- [4] Add elements to MainTab
local SpeedToggle = MainTab:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Type     = "Switch",
    Flag     = "speedHack",
    Save     = true,
    Callback = function(enabled)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = enabled and 50 or 16
        end
    end,
})

local SpeedSlider = MainTab:AddSlider({
    Name      = "Walk Speed",
    Min       = 16,
    Max       = 200,
    Default   = 16,
    Increment = 1,
    ValueName = "stud/s",
    Flag      = "walkSpeed",
    Save      = true,
    Callback  = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end,
})

MainTab:AddDivider({ Text = "Teleport" })

MainTab:AddButton({
    Name     = "Teleport to Spawn",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end,
})

-- [5] Realtime watermark
local Watermark = OrionLib:MakeWatermark({
    Text    = "My Hub",
    Visible = true,
    Flag    = "Watermark",
})

local frameTimer   = tick()
local frameCounter = 0
local fps          = 60

OrionLib:AddConnect(game:GetService("RunService").RenderStepped, function()
    frameCounter += 1
    if (tick() - frameTimer) >= 1 then
        fps          = frameCounter
        frameTimer   = tick()
        frameCounter = 0
    end
    local ping = math.floor(
        game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    )
    OrionLib.Flags["Watermark"]:SetText(
        ("My Hub | %d FPS | %d ms"):format(fps, ping)
    )
end)

-- [6] BuildSettings + Autoload
OrionLib:BuildSettings(SettingsTab)
OrionLib:LoadAutoloadConfig()
```
