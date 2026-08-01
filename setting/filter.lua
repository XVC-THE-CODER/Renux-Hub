local PlaceScripts = {
    [537413528] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua",
    [90568084448279] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/one-tap.lua",
    [142823291] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/mm2.lua",
    [205224386] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua",
    [136801880565837] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/flick.lua",
}

local FallbackLink = "https://pastebin.com/raw/LvRLf96s"
local currentPlaceId = game.PlaceId

if PlaceScripts[currentPlaceId] then
    loadstring(game:HttpGet(PlaceScripts[currentPlaceId]))()
else
    loadstring(game:HttpGet(FallbackLink))()
end
