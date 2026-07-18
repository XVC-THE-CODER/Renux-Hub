local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()

local window = library:window({
    title = "Renux hub",
    desc = "v1.2",
    transparent = 0.15,
    theme = "fire",
    autoshow = false,
    addbacksound = false
})

window:AddTag({ title = "babft", icon = "globe", color = Color3.fromRGB(180, 30, 30), getclick = false })
window:AddTag({
    title = "Join Discord", icon = "globe", color = Color3.fromRGB(180, 30, 30), getclick = true,
    callback = function()
        local invite = "https://discord.gg/dbE59H6grJ"
        if setclipboard then setclipboard(invite) elseif toclipboard then toclipboard(invite)
        else library:Notification({title = "Clipboard", desc = "Clipboard not supported", duration = 5}) return end
        library:Notification({title = "Clipboard", desc = "Discord invite copied!", duration = 5})
    end
})

local Tab = window:AddTab("Main", "home")
local ServerTab = window:AddTab("Server", "server")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local autoFarmEnabled = false
local autoFarmGoldBlockEnabled = false
local hasReachedTrigger = false
local tpDelay = 0.75
local maxTpParts = 9
local farmMode = "teleport"
local darknessTpParts = {}
local farmingThread = nil
local farmingBlockThread = nil

local antiLagEnabled = false
local waterNoDamageEnabled = false
local antiLagConn = nil
local waterConn = nil

local deleteObstacleEnabled = false
local deleteObstacleConn = nil

local targetPos = Vector3.new(-56, -359, 9495)

local function rejoinServer()
    task.spawn(function()
        if #Players:GetPlayers() > 1 then pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end) task.wait(1) end
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)
end

local function hopServer()
    task.spawn(function()
        library:Notification({title = "Server Hop", desc = "Finding best server...", duration = 3})
        local function getServers(cursor)
            local url = "https://games.roproxy.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            if cursor then url = url.."&cursor="..cursor end
            local req = request or http_request or (syn and syn.request) or (http and http.request)
            local success, result
            if req then success, result = pcall(function() return req({Url = url, Method = "GET"}).Body end)
            else success, result = pcall(function() return game:HttpGet(url) end) end
            if success and result then local ok, data = pcall(function() return HttpService:JSONDecode(result) end) if ok then return data end end
            return nil
        end
        local cursor = nil
        local validServers = {}
        for _ = 1, 3 do
            local data = getServers(cursor)
            if data and data.data then
                for _, s in ipairs(data.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 0 then table.insert(validServers, s) end end
                cursor = data.nextPageCursor if not cursor then break end
            else break end
            task.wait(0.3)
        end
        if #validServers > 0 then
            for attempt = 1, 3 do
                local pick = validServers[math.random(1, #validServers)]
                local ok = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player) end)
                if ok then return end
                task.wait(1)
            end
        end
        library:Notification({title = "Server Hop", desc = "No server found, rejoining...", duration = 3})
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)
end

local function clearTpParts()
    for _, p in ipairs(darknessTpParts) do if p and p.Parent then p:Destroy() end end
    table.clear(darknessTpParts)
end

local function findDarknessParts()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("darkness") then table.insert(list, v) end end
    local filtered = {}
    for _, part in ipairs(list) do
        local tooClose = false
        for _, kept in ipairs(filtered) do if (part.Position - kept.Position).Magnitude < 8 then tooClose = true break end end
        if not tooClose then table.insert(filtered, part) end
    end
    if #filtered > 1 then
        local sorted = {}
        local remaining = table.clone(filtered)
        local charPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        table.sort(remaining, function(a,b) return (a.Position - charPos).Magnitude < (b.Position - charPos).Magnitude end)
        local current = table.remove(remaining, 1)
        table.insert(sorted, current)
        while #remaining > 0 do
            local closestIndex, closestDist = 1, math.huge
            for i, p in ipairs(remaining) do local dist = (p.Position - current.Position).Magnitude if dist < closestDist then closestDist = dist closestIndex = i end end
            current = table.remove(remaining, closestIndex)
            table.insert(sorted, current)
        end
        return sorted
    end
    return filtered
end

local function teleportTo(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
end

local function tweenPart(part, targetPos, duration)
    if not part or not part.Parent then return end
    local tween = TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = targetPos})
    tween:Play() tween.Completed:Wait()
end

local antiLagBackup = {}
local function cleanOne(v)
    if not v or not v.Parent then return end
    if v.Name:find("Renux") then return end
    if v.Name:lower():find("darkness") or v.Name:lower():find("trigger") then return end
    if v.Parent and v.Parent:FindFirstChild("Humanoid") then return end
    if v:IsA("BasePart") then
        if v.Size.Magnitude < 6 and not v.Anchored and v.CanCollide == false then
            if not antiLagBackup[v] then antiLagBackup[v] = {type="Hidden", Parent=v.Parent} end
            pcall(function() v.Parent = nil end) return
        end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (v.Position - hrp.Position).Magnitude > 600 and v.Size.Magnitude < 12 then
            if not antiLagBackup[v] then antiLagBackup[v] = {type="Hidden", Parent=v.Parent} end
            pcall(function() v.Parent = nil end) return
        end
        if not antiLagBackup[v] then antiLagBackup[v] = {type="BasePart", Material=v.Material, Reflectance=v.Reflectance, CastShadow=v.CastShadow, TextureID = v:IsA("MeshPart") and v.TextureID or nil} end
        pcall(function() v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 v.CastShadow = false if v:IsA("MeshPart") then v.TextureID = "" end end)
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if not antiLagBackup[v] then antiLagBackup[v] = {type="Decal", Transparency=v.Transparency} end
        pcall(function() v.Transparency = 1 end)
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
        if not antiLagBackup[v] then antiLagBackup[v] = {type="Effect", Enabled=v.Enabled} end
        pcall(function() v.Enabled = false end)
    end
end
local function restoreAntiLag()
    for inst, data in pairs(antiLagBackup) do
        pcall(function()
            if data.type == "BasePart" and inst then inst.Material=data.Material inst.Reflectance=data.Reflectance inst.CastShadow=data.CastShadow if inst:IsA("MeshPart") and data.TextureID then inst.TextureID=data.TextureID end
            elseif data.type == "Decal" and inst then inst.Transparency=data.Transparency
            elseif data.type == "Effect" and inst then inst.Enabled=data.Enabled
            elseif data.type == "Hidden" and inst and data.Parent and not inst.Parent then inst.Parent=data.Parent end
        end)
    end
    table.clear(antiLagBackup)
end
local function runAntiLag() task.spawn(function() for _, v in ipairs(workspace:GetDescendants()) do if not antiLagEnabled then break end cleanOne(v) if _ % 200 == 0 then task.wait() end end end) end
local function setWaterNoDamage(state) task.spawn(function() for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("water") then pcall(function() v.CanTouch = not state end) end end end) end
local function deleteRocks() task.spawn(function() for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("rock") then pcall(function() v:Destroy() end) end end end) end

local function startFarm()
    if farmingThread then task.cancel(farmingThread) end
    farmingThread = task.spawn(function()
        while autoFarmEnabled do
            if hasReachedTrigger then break end
            local darknessParts = findDarknessParts()
            if #darknessParts == 0 then warn("Darkness part not found!") task.wait(2) continue end
            clearTpParts()
            if farmMode == "tween" then
                local firstPart = darknessParts[1]
                local lastPart = darknessParts[#darknessParts]
                local platform = Instance.new("Part")
                platform.Name = "Renux_TWEEN_Platform" platform.Size = Vector3.new(14,1,14) platform.Position = firstPart.Position + Vector3.new(0,6,0)
                platform.Anchored = true platform.CanCollide = true platform.Transparency = 1 platform.Parent = workspace
                table.insert(darknessTpParts, platform)
                local durationToLast if tpDelay >= 1.2 then durationToLast=30 elseif tpDelay >=0.7 then durationToLast=20 else durationToLast=14 end
                local keepFollowing=true
                local followConn
                followConn = RunService.Heartbeat:Connect(function()
                    if not keepFollowing or not autoFarmEnabled or not platform.Parent or hasReachedTrigger then if followConn then followConn:Disconnect() end return end
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - platform.Position).Magnitude > 4 then hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0,3,0)) end
                end)
                tweenPart(platform, lastPart.Position + Vector3.new(0,6,0), durationToLast)
                keepFollowing=false if followConn then followConn:Disconnect() end
                if not autoFarmEnabled or hasReachedTrigger then continue end
                task.wait(0.2) clearTpParts()
                if autoFarmEnabled then for j=1,3 do teleportTo(targetPos + Vector3.new(0,3,0)) task.wait(0.3) end hasReachedTrigger=true break end
            else
                if #darknessParts > maxTpParts then local limited={} for i=1,maxTpParts do table.insert(limited, darknessParts[i]) end darknessParts=limited end
                for i, dp in ipairs(darknessParts) do
                    local tpPart = Instance.new("Part")
                    tpPart.Name="Renux_TP_"..i tpPart.Size=Vector3.new(10,1,10) tpPart.Position=dp.Position+Vector3.new(0,6,0)
                    tpPart.Anchored=true tpPart.CanCollide=true tpPart.Transparency=1 tpPart.Parent=workspace
                    table.insert(darknessTpParts, tpPart)
                end
                for i, tpPart in ipairs(darknessTpParts) do if not autoFarmEnabled or hasReachedTrigger then break end teleportTo(tpPart.Position) task.wait(tpDelay) end
                if not autoFarmEnabled or hasReachedTrigger then continue end
                for j=1,3 do teleportTo(targetPos + Vector3.new(0,3,0)) task.wait(0.3) end
                hasReachedTrigger=true break
            end
        end
    end)
end

local function startFarmGoldBlock()
    if farmingBlockThread then task.cancel(farmingBlockThread) end
    farmingBlockThread = task.spawn(function()
        while autoFarmGoldBlockEnabled do
            if hasReachedTrigger then break end
            local darknessParts = findDarknessParts()
            if #darknessParts == 0 then warn("Gold Block part not found!") task.wait(2) continue end
            clearTpParts()

            if farmMode == "teleport" then
                local goldBlockDelay
                if tpDelay >= 1.2 then goldBlockDelay = 3.2
                elseif tpDelay >= 0.7 then goldBlockDelay = 2.4
                else goldBlockDelay = 1.8 end

                local first = darknessParts[1]
                local last = darknessParts[#darknessParts]
                local positions = {}
                if first then table.insert(positions, first.Position + Vector3.new(0,6,-15)) end
                if last and last ~= first then table.insert(positions, last.Position + Vector3.new(0,6,-15)) end

                for i, pos in ipairs(positions) do
                    local tpPart = Instance.new("Part")
                    tpPart.Name = "Renux_TP_Block_"..i
                    tpPart.Size = Vector3.new(10,1,10)
                    tpPart.Position = pos
                    tpPart.Anchored = true
                    tpPart.CanCollide = true
                    tpPart.Transparency = 1
                    tpPart.Parent = workspace
                    table.insert(darknessTpParts, tpPart)
                end

                for _, tpPart in ipairs(darknessTpParts) do
                    if not autoFarmGoldBlockEnabled or hasReachedTrigger then break end
                    teleportTo(tpPart.Position)
                    task.wait(goldBlockDelay)
                end
                if not autoFarmGoldBlockEnabled or hasReachedTrigger then continue end

                for j=1,3 do teleportTo(targetPos + Vector3.new(0,3,0)) task.wait(0.8) end
                hasReachedTrigger=true break
            else
                local platform = Instance.new("Part")
                platform.Name = "Renux_TWEEN_Platform"
                platform.Size = Vector3.new(14,1,14)
                platform.Position = darknessParts[1].Position + Vector3.new(0,6,0)
                platform.Anchored = true platform.CanCollide = true platform.Transparency = 1
                platform.Parent = workspace
                table.insert(darknessTpParts, platform)

                local speed
                if tpDelay >= 1.2 then speed = 70
                elseif tpDelay >= 0.7 then speed = 120
                else speed = 200 end

                local keepFollowing=true
                local followConn
                followConn = RunService.Heartbeat:Connect(function()
                    if not keepFollowing or not autoFarmGoldBlockEnabled or not platform.Parent or hasReachedTrigger then if followConn then followConn:Disconnect() end return end
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0,3,0)) end
                end)

                for i=2,#darknessParts do
                    if not autoFarmGoldBlockEnabled or hasReachedTrigger then break end
                    local target = darknessParts[i].Position + Vector3.new(0,6,0)
                    local dist = (platform.Position - target).Magnitude
                    local dur = math.clamp(dist / speed, 0.05, 1.2)
                    tweenPart(platform, target, dur)
                end

                keepFollowing=false
                if followConn then followConn:Disconnect() end
                clearTpParts()

                if autoFarmGoldBlockEnabled and not hasReachedTrigger then
                    for j=1,3 do teleportTo(targetPos + Vector3.new(0,3,0)) task.wait(0.8) end
                    hasReachedTrigger=true break
                end
            end
            task.wait(0.2)
        end
    end)
end

Tab:AddDropdown({ Title = "Mode", Desc = "Choose farming movement method", Values = {"tween", "teleport"}, Value = {"teleport"}, Multi = false, Search = true, Callback = function(s) farmMode = type(s)=="table" and s[1] or s end })
Tab:AddDropdown({ Title = "Speed", Desc = "Choose teleport speed and delay", Values = {"slow (all gold But slow)", "normal (recommend)", "fast (low gold)"}, Value = {"normal (recommend)"}, Multi = false, Search = true, Callback = function(s) local m = type(s)=="table" and s[1] or s if m:find("slow") then tpDelay=1.25 elseif m:find("fast") then tpDelay=0.35 else tpDelay=0.75 end end })
Tab:AddDivider()
Tab:Addtoggle({
    title = "Auto Farm Gold", desc = "Automatically farm gold best", value = false,
    callback = function(state)
        autoFarmEnabled=state
        if state then
            if autoFarmGoldBlockEnabled then autoFarmGoldBlockEnabled=false if farmingBlockThread then task.cancel(farmingBlockThread) end end
            if not hasReachedTrigger then startFarm() end
        else clearTpParts() if farmingThread then task.cancel(farmingThread) farmingThread=nil end end
    end
})
Tab:Addtoggle({
    title = "Auto Farm Gold Block", desc = "Farm gold blocks and skip gold", value = false,
    callback = function(state)
        autoFarmGoldBlockEnabled=state
        if state then
            if autoFarmEnabled then autoFarmEnabled=false if farmingThread then task.cancel(farmingThread) end end
            if not hasReachedTrigger then startFarmGoldBlock() end
        else clearTpParts() if farmingBlockThread then task.cancel(farmingBlockThread) farmingBlockThread=nil end end
    end
})

ServerTab:Addbutton({ title = "Rejoin Server", desc = "Reconnect to current server", callback = function() rejoinServer() end })
ServerTab:Addbutton({ title = "Server Hop", desc = "Find and hop to a new public server", callback = function() hopServer() end })

ServerTab:AddDivider()
ServerTab:Addtoggle({
    title = "Anti Lag", desc = "Reduce lag, hide effects. Turn off to restore map to normal", value = false,
    callback = function(state)
        antiLagEnabled=state
        if state then runAntiLag() if antiLagConn then antiLagConn:Disconnect() end antiLagConn=workspace.DescendantAdded:Connect(function(v) if antiLagEnabled then task.wait(0.1) cleanOne(v) end end)
        else if antiLagConn then antiLagConn:Disconnect() antiLagConn=nil end restoreAntiLag() library:Notification({title="Anti Lag", desc="Map restored to normal", duration=3}) end
    end
})
ServerTab:Addtoggle({ title = "Water No Damage", desc = "Disable water damage by making water untouchable", value = false, callback = function(state) waterNoDamageEnabled=state setWaterNoDamage(state) if state then if waterConn then waterConn:Disconnect() end waterConn=workspace.DescendantAdded:Connect(function(v) if waterNoDamageEnabled and v:IsA("BasePart") and v.Name:lower():find("water") then task.wait(0.1) pcall(function() v.CanTouch=false end) end end) else if waterConn then waterConn:Disconnect() waterConn=nil end setWaterNoDamage(false) end end })
ServerTab:Addtoggle({
    title = "Delete Obstacle", desc = "Remove rock obstacles in workspace", value = false,
    callback = function(state)
        deleteObstacleEnabled=state
        if state then deleteRocks() if deleteObstacleConn then deleteObstacleConn:Disconnect() end deleteObstacleConn=workspace.DescendantAdded:Connect(function(v) if deleteObstacleEnabled and v:IsA("BasePart") and v.Name:lower():find("rock") then task.wait(0.1) pcall(function() v:Destroy() end) end end)
        else if deleteObstacleConn then deleteObstacleConn:Disconnect() deleteObstacleConn=nil end end
    end
})

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart",10) task.wait(1)
    if hasReachedTrigger then hasReachedTrigger=false end
    if autoFarmEnabled then task.wait(1) startFarm() end
    if autoFarmGoldBlockEnabled then task.wait(1) startFarmGoldBlock() end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if (autoFarmEnabled or autoFarmGoldBlockEnabled) and not hasReachedTrigger and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if (player.Character.HumanoidRootPart.Position - targetPos).Magnitude < 15 then hasReachedTrigger=true clearTpParts() end
        end
    end
end)

-- ANTI STUCK SYSTEM: SOUND + SKYBOX CHECK
local SoundService = game:GetService("SoundService")
local SOUND_CHECK_DURATION = 2
local SOUND_AT_TARGET_DIST = 150
_G.Renux_TargetSoundData = _G.Renux_TargetSoundData or { savedIds = {}, hasEverHadSound = false }

local soundCheckActive=false
local soundDetected=false
local soundConns={}
local soundAddedConn=nil

local function resetCharacterNow() pcall(function() if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=0 else player.Character:BreakJoints() end end end) end
local function clearSoundListeners() for _,c in ipairs(soundConns) do pcall(function() c:Disconnect() end) end table.clear(soundConns) if soundAddedConn then pcall(function() soundAddedConn:Disconnect() end) soundAddedConn=nil end end
local function getSoundPos(soundObj) local p=soundObj.Parent if not p then return nil end if p:IsA("BasePart") then return p.Position end if p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then return p.Parent.Position end local cur=p for i=1,4 do if not cur then break end if cur:IsA("BasePart") then return cur.Position end cur=cur.Parent end return nil end
local function isSoundAtTarget(soundObj) local pos=getSoundPos(soundObj) if not pos then local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if hrp and (hrp.Position - targetPos).Magnitude <= 120 then return true end return false end return (pos - targetPos).Magnitude <= SOUND_AT_TARGET_DIST end

-- NEW: SKYBOX DARK CHECK
local function isSkyboxDark()
    local amb = Lighting.Ambient
    local outAmb = Lighting.OutdoorAmbient
    local avgAmb = (amb.R + amb.G + amb.B) / 3
    local avgOut = (outAmb.R + outAmb.G + outAmb.B) / 3
    local brightness = Lighting.Brightness
    local clock = Lighting.ClockTime
    local fogColor = Lighting.FogColor
    local avgFog = (fogColor.R + fogColor.G + fogColor.B) / 3

    -- Kalo brightness rendah + ambient gelap = dark skybox
    if brightness <= 1.5 and avgAmb < 0.5 and avgOut < 0.5 then return true end
    if clock < 6.5 or clock > 18.5 then return true end
    if avgFog < 0.25 then return true end

    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then
        local bk = sky.SkyboxBk and sky.SkyboxBk:lower() or ""
        if bk:find("dark") or bk:find("night") or bk:find("moon") then return true end
        -- Cek kalo skybox texture hitam
        if sky.SkyboxUp == "" and sky.SkyboxBk == "" then return false end
    end
    return false
end

local function hookSound(soundObj)
    if not soundObj:IsA("Sound") then return end
    if soundObj.IsPlaying and isSoundAtTarget(soundObj) then soundDetected=true local id=soundObj.SoundId~="" and soundObj.SoundId or soundObj.Name if id~="" then _G.Renux_TargetSoundData.savedIds[id]=true _G.Renux_TargetSoundData.hasEverHadSound=true end end
    table.insert(soundConns, soundObj.Played:Connect(function() if isSoundAtTarget(soundObj) then soundDetected=true local id=soundObj.SoundId~="" and soundObj.SoundId or soundObj.Name if id~="" then _G.Renux_TargetSoundData.savedIds[id]=true _G.Renux_TargetSoundData.hasEverHadSound=true print("[Renux] Saved sound at target:", id) end end end))
end

local function startPostTriggerAntiStuckCheck()
    if soundCheckActive then return end
    soundCheckActive=true soundDetected=false clearSoundListeners()
    for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("Sound") then hookSound(v) end end
    for _,v in ipairs(SoundService:GetDescendants()) do if v:IsA("Sound") then hookSound(v) end end
    soundAddedConn=workspace.DescendantAdded:Connect(function(v) if v:IsA("Sound") then task.wait(0.05) hookSound(v) end end)
    task.spawn(function()
        local elapsed=0
        while elapsed < SOUND_CHECK_DURATION do
            task.wait(0.1) elapsed+=0.1
            if not soundDetected then
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Sound") and v.IsPlaying and isSoundAtTarget(v) then
                        soundDetected=true
                        local id=v.SoundId~="" and v.SoundId or v.Name
                        if id~="" then _G.Renux_TargetSoundData.savedIds[id]=true _G.Renux_TargetSoundData.hasEverHadSound=true end
                        break
                    end
                end
            end
            -- Kalo suara kedeteksi ATAU skybox gelap = aman
            if soundDetected or isSkyboxDark() then break end
            if not hasReachedTrigger then clearSoundListeners() soundCheckActive=false return end
        end
        if hasReachedTrigger then
            local dark = isSkyboxDark()
            print("[Renux] Check - Sound:", soundDetected, " SkyboxDark:", dark)
            if not soundDetected and not dark then
                print("[Renux] Skybox terang + no sound, resetting...")
                resetCharacterNow()
            else
                print("[Renux] Aman - tidak reset")
            end
        end
        task.wait(0.5) clearSoundListeners() soundCheckActive=false
    end)
end

task.spawn(function() local wasTriggered=hasReachedTrigger while true do task.wait(0.15) if hasReachedTrigger and not wasTriggered then wasTriggered=true startPostTriggerAntiStuckCheck() elseif not hasReachedTrigger and wasTriggered then wasTriggered=false clearSoundListeners() soundCheckActive=false end end end)
