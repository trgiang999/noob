-- ── Chờ game load xong ────────────────────────────────────────────────────
if not game:IsLoaded() then game.Loaded:Wait() end
local request = request or http_request or (syn and syn.request)

local function githubGetRaw(user, repo, branch, path)
    local rawUrl = ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(user, repo, branch, path)
    
    -- Nếu Executor hỗ trợ hàm request cao cấp
    if request then
        local success, response = pcall(request, {
            Url = rawUrl,
            Method = "GET",
            Headers = {
                ["Cache-Control"] = "no-cache",
                ["Pragma"] = "no-cache"
            }
        })
        
        if success and response.Success then
            if response.Body == "404: Not Found" then
                error("Lỗi 404: Không tìm thấy file trên GitHub!")
            end
            return response.Body
        end
    end
    
    -- Fallback về HttpGet nếu Executor không có hàm request (nhưng đổi sang dùng game:HttpGet cho ổn định)
    -- Thêm math.random để phụ trợ bypass cache của riêng Executor
    local fallbackUrl = rawUrl .. "?v=" .. math.random(10000, 99999)
    local success, content = pcall(game.HttpGet, game, fallbackUrl)
    if not success or content == "404: Not Found" then
        error("githubGet failed: Kiểm tra lại đường dẫn hoặc kết nối mạng!")
    end
    return content
end

-- ── Kiểm tra script đã chạy chưa ─────────────────────────────────────────
if getgenv().GHUB_LOADED then
    print("Already loaded the script!")
    -- Load OrionLib riêng để show notification

    local OrionLib = loadstring(githubGetRaw("trgiang999", "noob", "main", "OrionLibSource.lua"))()
    OrionLib:MakeNotification({
        Name    = "Warning!",
        Content = "The script is already running!",
        Image   = "rbxassetid://4483345998",
        Time    = 3,
    })
    return
end

-- ── Bảng chapter ID → PlaceId ─────────────────────────────────────────────
type ChapterMap = {[string]: number}
local ChapterTable: ChapterMap = {
    -- Book 1
    ["chapter1"]   = 14787381917,
    ["chapter2"]   = 15322497988,
    ["chapter3.1"] = 16375066410,
    ["chapter3.2"] = 16485242214,
    ["chapter3.3"] = 16554037885,
    ["chapter4.1"] = 17619037026,
    ["chapter4.2"] = 17680488855,
    -- Book 2
    ["chapter1_b2"] = 71718624482170,
}

-- ── Bảng PlaceId → URL script tương ứng ──────────────────────────────────
type ExecuteMap = {[number]: string}
local LoaderTable: ExecuteMap = {
    [ChapterTable["chapter1"]]      = "wsd_chapter1.lua",
    [ChapterTable["chapter2"]]      = "wsd_chapter2.lua",
    [ChapterTable["chapter3.1"]]    = "wsd_chapter3.1.lua",
    [ChapterTable["chapter3.2"]]    = "",
    [ChapterTable["chapter3.3"]]    = "",
    [ChapterTable["chapter4.1"]]    = "",
    [ChapterTable["chapter4.2"]]    = "",
    [ChapterTable["chapter1_b2"]]   = "",
}


-- ── Tìm URL cho PlaceId hiện tại ─────────────────────────────────────────
local url = LoaderTable[game.PlaceId]

if not url or url == "" then
    print(("UNSUPPORTED PlaceId: %d"):format(game.PlaceId))
    return
end

-- ── Fetch và thực thi script ──────────────────────────────────────────────
local raw = githubGetRaw('trgiang999', 'noob', 'main', url)

if raw == "" then
    print("Failed to fetch script!")
    return
end

loadstring(raw)()
