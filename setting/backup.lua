local PlaceScripts = {
    [537413528] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua",
    [90568084448279] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/one-tap.lua",
    [142823291] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/mm2.lua",
    [205224386] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua",
    [12137249458] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/Gunground.lua",
}

local FallbackLink = "https://pastebin.com/raw/LvRLf96s"

local function FastGet(url)
    for _ = 1, 3 do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and result and #result > 100 then
            return result
        end
        task.wait(0.4)
    end
    return nil
end

local function SafeLoad(url)
    local code = FastGet(url)
    if not code then return false end
    local func = loadstring(code)
    if not func then return false end
    task.spawn(function()
        pcall(func)
    end)
    return true
end

local targetUrl = PlaceScripts[game.PlaceId] or FallbackLink

if not SafeLoad(targetUrl) then
    if targetUrl ~= FallbackLink then
        SafeLoad(FallbackLink)
    end
end
