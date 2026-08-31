local PlaceScripts = {
    [537413528] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua",
    [90568084448279] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/one-tap.lua",
    [142823291] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/mm2.lua",
    [205224386] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua",
    [12137249458] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/Gunground.lua",
}

local FallbackLink = "https://pastebin.com/raw/LvRLf96s"
local BackupLink = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/setting/backup.lua"
local currentPlaceId = game.PlaceId

local function TryLoad(url)
    local success, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not code or code == "" then
        return false
    end
    local success2 = pcall(function()
        loadstring(code)()
    end)
    return success2
end

if PlaceScripts[currentPlaceId] then
    if not TryLoad(PlaceScripts[currentPlaceId]) then
        if not TryLoad(FallbackLink) then
            TryLoad(BackupLink)
        end
    end
else
    if not TryLoad(FallbackLink) then
        TryLoad(BackupLink)
    end
end

local function Notif(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 5
        })
    end)
end

Notif("INFO", "script has loaded", 3.5)
