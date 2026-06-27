if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GHUB_LOADED then 
    print("Already loaded the script!")
    local function githubGetRaw1(user, repo, branch, path)
        local rawUrl = ("https://raw.githubusercontent.com/%s/%s/%s/%s?t=%s")
            :format(user, repo, branch, path, os.time())
        local success, content = pcall(game.HttpGetAsync, game, rawUrl)
        if not success or content == "404: Not Found" then
            error("githubGet failed: Kiểm tra lại đường dẫn hoặc kết nối mạng!")
        end
        return content
    end

    local OrionLib = loadstring(githubGetRaw1("trgiang999", "noob", "main", "OrionLibSource.lua"))()
    OrionLib:MakeNotification({
        Name    = "Warning!",                          
        Content = "The script is already running!",            
        Image   = "rbxassetid://4483345998",        
        Time    = 3,      
    })
    return 
end

type ExecuteMap = {[number]: string}
type ChapterMap = {[string]: number}

local ChapterTable: ChapterMap = {
    --Book 1
    ['chapter1'] = 14787381917,
    ['chapter2'] = 15322497988,
    ['chapter3.1'] = 16375066410,
    ['chapter3.2'] = 16485242214,
    ['chapter3.3'] = 16554037885,
    ['chapter4.1'] = 17619037026,
    ['chapter4.2'] = 17680488855,
    --Book 2
    ['chapter1_b2'] = 71718624482170

}

local LoaderTable: ExecuteMap = {
    [ChapterTable['chapter1']] = "https://raw.githubusercontent.com/trgiang999/noob/refs/heads/main/wsd_chapter1.lua",
    [ChapterTable['chapter2']] = "https://raw.githubusercontent.com/trgiang999/noob/refs/heads/main/wsd_chapter2.lua",
    [ChapterTable['chapter3.1']] = 'https://raw.githubusercontent.com/trgiang999/noob/refs/heads/main/wsd_chapter3.1.lua',
    [ChapterTable['chapter3.2']] = '',
    [ChapterTable['chapter3.3']] = '',
    [ChapterTable['chapter4.1']] = '',
    [ChapterTable['chapter4.2']] = '',
    [ChapterTable['chapter1_b2']] = ''
}

local function githubGetRaw(direct_url)
    local rawUrl = direct_url .. '?t=' .. tostring(os.time())
    local success, content = pcall(game.HttpGetAsync, game, rawUrl)
    if not success or content == "404: Not Found" then
        print('UNSUPPORTED')
        return ''
    end
    return content
end

url = LoaderTable[game.PlaceId]  --!= placeid = pass.
raw = githubGetRaw(url)
loadstring(raw)()
