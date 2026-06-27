-- ── Chờ game load xong ────────────────────────────────────────────────────
if not game:IsLoaded() then game.Loaded:Wait() end

-- ── Kiểm tra script đã chạy chưa ─────────────────────────────────────────
if getgenv().GHUB_LOADED then
    print("Already loaded the script!")
    -- Load OrionLib riêng để show notification
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
local BASE = "https://raw.githubusercontent.com/trgiang999/noob/refs/heads/main/"
local LoaderTable: ExecuteMap = {
    [ChapterTable["chapter1"]]   = BASE .. "wsd_chapter1.lua",
    [ChapterTable["chapter2"]]   = BASE .. "wsd_chapter2.lua",
    [ChapterTable["chapter3.1"]] = BASE .. "wsd_chapter3.1.lua",
    [ChapterTable["chapter3.2"]] = "",
    [ChapterTable["chapter3.3"]] = "",
    [ChapterTable["chapter4.1"]] = "",
    [ChapterTable["chapter4.2"]] = "",
    [ChapterTable["chapter1_b2"]] = "",
}

-- ── Fetch raw content từ URL (cache-bust bằng timestamp) ─────────────────
local function githubGetRaw(directUrl: string): string
    local url = directUrl .. "?t=" .. tostring(os.time())
    local success, content = pcall(game.HttpGetAsync, game, url)
    if not success or content == "404: Not Found" then
        return ""
    end
    return content
end

-- ── Tìm URL cho PlaceId hiện tại ─────────────────────────────────────────
local url = LoaderTable[game.PlaceId]

if not url or url == "" then
    print(("UNSUPPORTED PlaceId: %d"):format(game.PlaceId))
    return
end

-- ── Fetch và thực thi script ──────────────────────────────────────────────
local raw = githubGetRaw(url)

if raw == "" then
    print("Failed to fetch script!")
    return
end

loadstring(raw)()
