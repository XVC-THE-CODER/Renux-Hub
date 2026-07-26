local PlaceScripts = {
  [537413528] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua",
  [90568084448279] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/one-tap.lua",
  [142823291] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/mm2.lua",
  [205224386] = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua",
}
local FallbackLink = "https://pastebin.com/raw/LvRLf96s" local url = PlaceScripts[game.PlaceId] or FallbackLink
loadstring(game:HttpGet(url))()
