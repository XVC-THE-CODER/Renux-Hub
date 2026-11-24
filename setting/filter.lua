local ProtectionLink = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/protection/main.lua"

local PlaceScripts = {
    [537413528] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua",
    [90568084448279] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/one-tap.lua",
    [142823291] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/mm2.lua",
    [205224386] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua",
    [12137249458] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/Gunground.lua",
    [123847390309161] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/sdco.lua",
    [7211666966] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/tower-of-jump.lua",
    [4580204640] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/stk.lua",
}

local FallbackLink = "https://pastebin.com/raw/LvRLf96s"
local BackupLink = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/setting/backup.lua"
local currentPlaceId = game.PlaceId

local function Notif(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 5
        })
    end)
end

local function TryLoad(url)
    local success, code = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not code or code == "" then
        return false
    end
    local func = loadstring(code)
    if not func then
        return false
    end
    local success2 = pcall(func)
    return success2
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(0.5)

if not TryLoad(ProtectionLink) then
    Notif("ERROR", "Failed to load protection!", 5)
    return
end

if PlaceScripts[currentPlaceId] then
    Notif("INFO", "Game Supported! Loading script...", 3.5)
    if not TryLoad(PlaceScripts[currentPlaceId]) then
        Notif("WARNING", "Failed to load main script, trying fallback...", 3.5)
        if not TryLoad(FallbackLink) then
            if not TryLoad(BackupLink) then
                Notif("ERROR", "All links failed to load!", 5)
            end
        end
    end
else
    Notif("WARNING", "Game Not Supported! Trying universal...", 3.5)
    if not TryLoad(FallbackLink) then
        if not TryLoad(BackupLink) then
            Notif("ERROR", "All links failed to load!", 5)
        end
    end
end
