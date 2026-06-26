# Orion Library — Complete Documentation
> Credits: Article Hub - https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua
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
-- Load Orion Library từ GitHub
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()
```
---

## 2. Global Configuration

Các hàm này nên được gọi **trước** khi tạo Window.

### Set Toggle Key

```lua
-- Thay đổi phím tắt để mở/đóng UI (mặc định: RightShift)
-- Tham khảo KeyCode: https://create.roblox.com/docs/reference/engine/enums/KeyCode
OrionLib:SetKeyToggleUI(Enum.KeyCode.RightShift)
```

### Set Background Video

```lua
-- Đặt video nền cho cửa sổ (nhận URL dạng string)
OrionLib:SetVideoLink("https://example.com/video.mp4")
```

### Set Global Font

```lua
-- Thay đổi font chữ toàn bộ UI
-- Tham khảo Font: https://create.roblox.com/docs/reference/engine/enums/Font
OrionLib:SetFont(Enum.Font.GothamBold)
```

---

## 3. Creating a Window

```lua
local Window = OrionLib:MakeWindow({
    -- Tiêu đề hiển thị trên cửa sổ
    Name            = "My Hub",

    -- Thanh tìm kiếm trong danh sách tab (nil = tắt)
    SearchBar       = {
        Default          = "Search tabs...",
        ClearTextOnFocus = true,
    },

    -- Icon hiển thị trên nút tái mở UI (sau khi đóng)
    IntroToggleIcon = "rbxassetid://7734091286",

    -- Ẩn badge Premium của người dùng
    HidePremium     = false,

    -- Bật hệ thống lưu config
    SaveConfig      = true,

    -- Tên thư mục lưu config trong exploiter filesystem
    ConfigFolder    = "MyHubConfigs",

    -- Bật/tắt animation intro khi khởi động
    IntroEnabled    = true,

    -- Văn bản hiển thị trong màn hình intro
    IntroText       = "My Hub",

    -- Icon hiển thị trong màn hình intro
    IntroIcon       = "rbxassetid://7734091286",

    -- Icon nhỏ bên cạnh tiêu đề cửa sổ (cần ShowIcon = true)
    Icon            = "rbxassetid://7734091286",

    -- Hàm được gọi khi người dùng nhấn nút Close
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
-- MakeTab trả về 2 giá trị: element table và tab control table
local Tab, TabControl = Window:MakeTab({
    Name        = "Main",
    Icon        = "rbxassetid://4483345998",
    Visible     = true,    -- Tab có hiển thị trong sidebar không
    Disabled    = false,   -- Tab bị vô hiệu hóa (mờ, không click được)
    PremiumOnly = false,   -- Khoá tab cho Sirius Premium users
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

-- Ẩn/hiện tab button trong sidebar
TabControl:SetVisible(false)

-- Bật/tắt disable state của tab
TabControl:SetDisabled(true)
```

---

## 5. Creating a Section

Section nhóm các element lại với nhau dưới một tiêu đề nhỏ.
Tất cả phương thức của `Tab` đều dùng được trong `Section`.

```lua
local Section = Tab:AddSection({
    Name = "Movement",
})

-- Thêm element vào section giống hệt tab
Section:AddButton({ Name = "Fly", Callback = function() end })

-- Đổi tiêu đề section sau khi tạo
Section:Set("New Section Name")
```

---

## 6. Divider

Kẻ đường ngang để phân tách nhóm element.

```lua
-- Divider đơn giản (chỉ đường kẻ)
Tab:AddDivider()

-- Divider có chữ ở giữa
Tab:AddDivider({ Text = "Settings" })
```

---

## 7. Notification

```lua
OrionLib:MakeNotification({
    Name    = "Alert",                          -- Tiêu đề thông báo
    Content = "Something happened!",            -- Nội dung thông báo
    Image   = "rbxassetid://4483345998",        -- Icon bên trái tiêu đề
    Time    = 5,                                -- Thời gian hiển thị (giây)
})

--[[
PARAMETERS:
    Name    <string> - Notification title
    Content <string> - Notification body text
    Image   <string> - rbxassetid icon
    Time    <number> - Duration in seconds (default: 5)

NOTE:
    Content hỗ trợ Rich Text tags:
        [Highlight:"text"]      → in đậm, màu trắng
        [underline:"text"]      → gạch chân
        [Color_#RRGGBB:"text"]  → màu tuỳ chọn
]]
```

---

## 8. Watermark

Watermark là một label nổi có thể kéo được, hiển thị thông tin realtime.

```lua
local Watermark = OrionLib:MakeWatermark({
    Text    = "MyHub | v1.0",
    Visible = true,
    Flag    = "Watermark",   -- Dùng để truy cập qua OrionLib.Flags
})

-- Cập nhật text của watermark
Watermark:SetText("New Text")
OrionLib.Flags["Watermark"]:SetText("New Text")

-- Ẩn/hiện watermark
Watermark:SetVisible(false)
```

### Live FPS / Ping Example

```lua
-- Hiển thị FPS và Ping realtime trên watermark
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

Cửa sổ nhỏ liệt kê tất cả Toggle đang có bind key.

```lua
-- Bật/tắt cửa sổ Keybind Panel
OrionLib:SetKeyBindVisible(true)

--[[
NOTE:
    Keybind Panel tự động được điền khi bạn dùng Toggle:AddBind().
    Không cần thêm thủ công.
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

-- Đổi label
MyButton:Set("New Label")

-- Đổi callback
MyButton:SetCallback(function()
    print("New callback!")
end)

-- Trigger click bằng code (không cần người dùng nhấn)
MyButton:Click()

-- Bật/tắt disabled
MyButton:SetDisabled(true)

-- Ẩn/hiện
MyButton:SetVisible(false)
```

#### Tạo Button đôi (split button)

```lua
-- AddButton trả về object; gọi :AddButton() trên nó để tạo button thứ 2 bên cạnh
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
    Default  = false,          -- Giá trị mặc định
    Type     = "Switch",       -- "Switch" hoặc "CheckBox"
    Flag     = "myFeature",    -- ID dùng với OrionLib.Flags
    Save     = true,           -- Lưu vào config
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

-- Đặt giá trị
MyToggle:Set(true)
OrionLib.Flags["myFeature"]:Set(true)

-- Đổi label
MyToggle:SetText("New Label")

-- Đổi callback
MyToggle:SetCallback(function(v) print(v) end)

-- Bật/tắt disabled
MyToggle:SetDisabled(false)

-- Ẩn/hiện
MyToggle:SetVisible(true)
```

#### Toggle + Bind (phím tắt để toggle)

```lua
-- Gọi :AddBind() ngay sau :AddToggle() để gắn keybind
local MyToggle = Tab:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Flag     = "speedHack",
    Callback = function(v) print("Speed:", v) end,
}):AddBind({
    Default = Enum.KeyCode.F,   -- Phím mặc định
    Flag    = "speedHackBind",  -- Flag riêng cho bind
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
    ValueName = "studs/s",     -- Đơn vị hiển thị sau số
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

-- Đặt giá trị
MySlider:Set(50)
OrionLib.Flags["walkSpeed"]:Set(50)

-- Thay đổi giới hạn
MySlider:SetMax(200)
MySlider:SetMin(0)

-- Đổi callback
MySlider:SetCallback(function(v) print(v) end)

-- Ẩn/hiện, disable
MySlider:SetVisible(false)
MySlider:SetDisabled(true)
```

---

### Dropdown

#### Dropdown đơn (Single Select)

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

#### Dropdown đa chọn (Multi Select)

```lua
local MyMultiDropdown = Tab:AddDropdown({
    Name     = "Enabled Hacks",
    Default  = { "Speed", "Jump" },   -- Mảng các option mặc định
    Options  = { "Speed", "Jump", "Fly", "NoClip" },
    Multi    = true,
    Flag     = "enabledHacks",
    Callback = function(value)
        -- value là table { "Speed", "Jump", ... }
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
        print("Chosen key:", value)  -- value là key string ("sword", "bow", ...)
    end,
})

--[[
PARAMETERS:
    Name     <string>   - Dropdown label
    Default  <string|table> - Initial selection (string for single, table for multi)
    Options  <table>    - List of options (array or dict with metadata)
    Multi    <bool>     - Allow multiple selections
    Flag     <string>   - Flag ID
    Save     <bool>     - Save selection to config
    Visible  <bool>     - Show/hide
    Disabled <bool>     - Disable interaction
    Callback <function> - Called with selected value(s)
]]

-- Chọn một option bằng code
MyDropdown:Set("Hard")
OrionLib.Flags["gameMode"]:Set("Hard")

-- Làm mới danh sách options (true = xóa cũ trước)
MyDropdown:Refresh({ "Option A", "Option B" }, true)

-- Đổi callback
MyDropdown:SetCallback(function(v) print(v) end)

-- Ẩn/hiện, disable
MyDropdown:SetVisible(false)
MyDropdown:SetDisabled(true)
```

---

### Textbox

```lua
local MyTextbox = Tab:AddTextbox({
    Name          = "Player Name",
    Default       = "",              -- Giá trị ban đầu
    TextDisappear = false,           -- Xóa text khi mất focus
    Finished      = true,            -- Chỉ trigger callback khi nhấn Enter/mất focus
    Numeric       = false,           -- Chỉ nhận số
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
    Finished      <bool>     - Fire callback only on FocusLost (true) or every change (false)
    Numeric       <bool>     - Restrict input to numbers only
    Flag          <string>   - Flag ID
    Save          <bool>     - Save value to config
    Callback      <function> - Called with (string) on input
]]

-- Đặt text bằng code
MyTextbox:SetText("Roblox")
OrionLib.Flags["targetPlayer"]:SetText("Roblox")

-- Đổi label
MyTextbox:SetLabel("Target Username")

-- Đổi callback
MyTextbox:SetCallback(function(v) print(v) end)
```

---

### Bind

Bind độc lập (không gắn vào Toggle).

```lua
local MyBind = Tab:AddBind({
    Name     = "Teleport Key",
    Default  = Enum.KeyCode.T,
    Hold     = false,   -- true = callback trả về bool (giữ/thả), false = callback khi nhấn
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
    Hold     <bool>          - Hold mode: callback(true) khi giữ, callback(false) khi thả
    Flag     <string>        - Flag ID
    Save     <bool>          - Save key to config
    Callback <function>      - Called on key press (or with bool in Hold mode)
]]

-- Đổi key bằng code
MyBind:Set(Enum.KeyCode.G)
OrionLib.Flags["tpKey"]:Set(Enum.KeyCode.G)

-- Đổi label
MyBind:SetText("New Label")

-- Đổi callback
MyBind:SetCallback(function() print("New bind!") end)
```

---

### Colorpicker

```lua
local MyColor = Tab:AddColorpicker({
    Name         = "ESP Color",
    Default      = Color3.fromRGB(255, 0, 0),
    DefaultAlpha = 1,              -- Độ mờ mặc định (0–1), cần Alpha = true
    Alpha        = false,          -- Hiển thị thanh điều chỉnh alpha
    Flag         = "espColor",
    Save         = true,
    Callback     = function(color, alpha)
        -- color: Color3, alpha: number (chỉ có giá trị khi Alpha = true)
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

-- Đặt màu bằng code
MyColor:Set(Color3.fromRGB(0, 255, 0))
OrionLib.Flags["espColor"]:Set(Color3.fromRGB(0, 255, 0))

-- Đặt màu + alpha cùng lúc
MyColor:Set(Color3.fromRGB(0, 255, 0), 0.8)
```

---

### Label

Label là text thuần, không có tương tác.

```lua
local MyLabel = Tab:AddLabel("Status: Idle")

-- Cập nhật text
MyLabel:Set("Status: Running")

-- Cập nhật text + trạng thái màu (success / error / warning / fail)
MyLabel:Set("Connected!", "success")
MyLabel:Set("Failed to connect", "error")
MyLabel:Set("Low HP warning", "warning")
MyLabel:Set("Server rejected", "fail")
```

---

### Paragraph

Paragraph hiển thị tiêu đề + đoạn văn bản dài, tự động xuống dòng.

```lua
local MyParagraph = Tab:AddParagraph(
    "How to use",                        -- Tiêu đề
    "Press F to activate the feature."   -- Nội dung
)

-- Cập nhật cả tiêu đề lẫn nội dung
MyParagraph:Set("New Title", "New content text here.")
```

---

### Image

```lua
local MyImage = Tab:AddImage({
    Icon    = "rbxassetid://3944703587",
    Size    = 100,     -- Kích thước ảnh tính bằng pixel
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

-- Đổi ảnh
MyImage:SetIcon("rbxassetid://123456789")

-- Đổi kích thước
MyImage:SetSize(150)

-- Ẩn/hiện
MyImage:SetVisible(false)
```

---

### Viewport

Viewport là cửa sổ 3D nhỏ để hiển thị object.

```lua
local MyViewport = Tab:AddViewport({
    Object  = Instance.new("Part"),     -- Instance hiển thị trong viewport
    Camera  = Instance.new("Camera"),   -- Camera dùng để nhìn object
    Orbit   = true,     -- Tự động xoay object
    Control = true,     -- Người dùng có thể kéo để xoay
    Zoom    = true,     -- Người dùng có thể scroll để zoom
    Size    = 270,      -- Kích thước khung (pixel)
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

-- Đổi object — cách 1: truyền Instance có sẵn
local part = Instance.new("Part")
part.Size = Vector3.new(2, 2, 2)
MyViewport:SetObject(part)

-- Đổi object — cách 2: truyền tên class + properties
MyViewport:SetObject("Part", { Size = Vector3.new(3, 3, 3), BrickColor = BrickColor.new("Bright red") })

-- Tuỳ chỉnh zoom limits
MyViewport:SetZoomCamera({ MaxZoom = 50, MinZoom = 5, Distance = 20 })

-- Bật/tắt tính năng
MyViewport:SetVisible(true)
MyViewport:SetControl(false)
MyViewport:SetOrbit(false)
MyViewport:SetZoom(true)
```

---

## 11. Flags System

Flag là một ID duy nhất bạn đặt cho element, cho phép truy cập element đó từ **bất kỳ đâu** trong code.

```lua
-- Khai báo element với Flag
local MyToggle = Tab:AddToggle({
    Name    = "Auto Farm",
    Default = false,
    Flag    = "autoFarm",
    Save    = true,
    Callback = function(value)
        print("AutoFarm:", value)
    end,
})

-- Đọc giá trị hiện tại từ Flag
print(OrionLib.Flags["autoFarm"].Value)   -- true hoặc false

-- Gọi method qua Flag (tương đương dùng biến MyToggle trực tiếp)
OrionLib.Flags["autoFarm"]:Set(true)
OrionLib.Flags["autoFarm"]:SetDisabled(false)
OrionLib.Flags["autoFarm"]:SetVisible(true)
```

**Elements hỗ trợ Flag:**

| Element      | .Value type  |
|-------------|--------------|
| Toggle      | `bool`       |
| Slider      | `number`     |
| Dropdown    | `string` / `table` |
| Bind        | `string` (KeyCode name) |
| Textbox     | `string`     |
| Colorpicker | `Color3`     |

> Button, Label, Paragraph, Divider, Section **không hỗ trợ** Flag.

---

## 12. Config System

Config cho phép lưu và tải lại giá trị của các element giữa các lần chạy.

### Yêu cầu

1. Window phải có `SaveConfig = true` và `ConfigFolder = "FolderName"`.
2. Mỗi element muốn lưu phải có `Flag = "uniqueId"` và `Save = true`.

```lua
-- Window setup
local Window = OrionLib:MakeWindow({
    Name         = "My Hub",
    SaveConfig   = true,
    ConfigFolder = "MyHubConfigs",
})

-- Element có Save
Tab:AddToggle({
    Name    = "Speed Hack",
    Default = false,
    Flag    = "speedHack",
    Save    = true,    -- ← bắt buộc để lưu
    Callback = function(v) end,
})
```

### BuildSettings — Trang quản lý Config

```lua
-- Truyền vào một Tab; hàm sẽ tự thêm các nút Save/Load/Autoload...
OrionLib:BuildSettings(SettingsTab)
```

### Autoload

```lua
-- Tải config được đặt là autoload (gọi sau khi tất cả element đã được tạo)
OrionLib:LoadAutoloadConfig()
```

---

## 13. AddConnect

Dùng `OrionLib:AddConnect` thay cho `:Connect()` để connection tự động bị ngắt khi UI bị destroy.

```lua
-- Ví dụ: loop mỗi frame
OrionLib:AddConnect(game:GetService("RunService").RenderStepped, function()
    -- Code chạy mỗi frame
end)

-- Ví dụ: lắng nghe input
OrionLib:AddConnect(game:GetService("UserInputService").InputBegan, function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        print("X pressed")
    end
end)

--[[
NOTE:
    Khi OrionLib:Destroy() được gọi, TẤT CẢ connection tạo bởi AddConnect
    sẽ tự động bị Disconnect() — tránh spam error và memory leak.
]]
```

---

## 14. Build Settings & Autoload

```lua
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "" })

-- Tạo toàn bộ UI quản lý config trong tab này
OrionLib:BuildSettings(SettingsTab)

-- Sau khi tất cả element được tạo xong, load config autoload (nếu có)
OrionLib:LoadAutoloadConfig()
```

**BuildSettings tự động thêm:**
- Toggle hiển thị/ẩn Keybind Panel
- Toggle hiển thị/ẩn Watermark (nếu có)
- Slider âm lượng thông báo
- Textbox nhập tên config
- Dropdown chọn config đã lưu
- Nút: Create / Load / Overwrite / Set Autoload / Remove Autoload / Refresh List
- Textbox + nút đặt video nền (nếu window có LinkVideo)

---

## 15. Destroying the UI

```lua
-- Hủy toàn bộ UI và ngắt tất cả connection
OrionLib:Destroy()

-- Đăng ký callback chạy trước khi UI bị hủy
OrionLib:OnDestroy(function()
    print("UI is being destroyed!")
    -- Cleanup code ở đây
end)
```

---

## 16. Icon Reference

Orion sử dụng **Feather Icons**. Bạn có thể truyền tên icon dạng string thay vì rbxassetid.

```
Icon JSON:
https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/icons.json
```

```lua
-- Dùng tên icon Feather thay vì asset ID
local Tab = Window:MakeTab({
    Name = "Combat",
    Icon = "sword",   -- tên icon từ icons.json
})
```

---

## Full Example Script

```lua
--================================================
--  Orion Library — Full Example
--================================================

-- [1] Load thư viện
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/Orion/Source.lua"
))()

-- [2] Tạo cửa sổ chính
local Window = OrionLib:MakeWindow({
    Name            = "My Hub",
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium     = false,
    SaveConfig      = true,
    ConfigFolder    = "MyHub",
    IntroEnabled    = true,
    IntroText       = "My Hub",
})

-- [3] Tạo các tab
local MainTab, _     = Window:MakeTab({ Name = "Main",     Icon = "home" })
local SettingsTab, _ = Window:MakeTab({ Name = "Settings", Icon = "settings" })

-- [4] Thêm elements vào MainTab
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

-- [5] Watermark realtime
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
