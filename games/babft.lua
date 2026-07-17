local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()

local window = library:window({
    title = "Renux hub",
    desc = "v1.0",
    transparent = 0.15,
    theme = "fire",
    autoshow = false,
    addbacksound = false
})

window:AddTag({
    title = "babft",
    icon = "globe",
    color = Color3.fromRGB(180, 30, 30),
    getclick = false,
})

window:AddTag({
    title = "Join Discord",
    icon = "globe",
    color = Color3.fromRGB(180, 30, 30),
    getclick = true,
    callback = function()
        local invite = "https://discord.gg/dbE59H6grJ"

        if setclipboard then
            setclipboard(invite)
        elseif toclipboard then
            toclipboard(invite)
        else
            library:Notification({
                title = "Clipboard",
                desc = "Clipboard is not supported by your executor.",
                duration = 5
            })
            return
        end

        library:Notification({
            title = "Clipboard",
            desc = "Discord invite copied to clipboard!",
            duration = 5
        })
    end
})

local Tab = window:AddTab("Main", "home")
local ServerTab = window:AddTab("Server", "server")

-- // SERVICES & VARIABLES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local autoFarmEnabled = false
local hasReachedTrigger = false
local tpDelay = 0.75
local maxTpParts = 9
local farmMode = "teleport"
local darknessTpParts = {}
local farmingThread = nil

local antiLagEnabled = false
local waterNoDamageEnabled = false
local antiLagConn = nil
local waterConn = nil

-- // REJOIN & SERVER HOP
local function rejoinServer()
    task.spawn(function()
        if #Players:GetPlayers() > 1 then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end)
            task.wait(1)
        end
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

local function hopServer()
    task.spawn(function()
        local function getServers(cursor)
            local url = "https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor then
                url = url .. "&cursor=" .. cursor
            end
            
            local success, result
            local req = request or http_request or syn.request or (http and http.request)
            if req then
                success, result = pcall(function()
                    local r = req({Url = url, Method = "GET"})
                    return r.Body
                end)
            else
                success, result = pcall(function()
                    return game:HttpGet(url)
                end)
            end
            
            if success and result then
                return HttpService:JSONDecode(result)
            end
            return nil
        end

        local cursor = nil
        local validServers = {}
        
        -- Mengambil data server aktif (maksimal 2 halaman pencarian)
        for _ = 1, 2 do
            local data = getServers(cursor)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        table.insert(validServers, s)
                    end
                end
                cursor = data.nextPageCursor
                if not cursor then break end
            else
                break
            end
        end

        if #validServers > 0 then
            -- Memilih server acak agar tidak selalu menumpuk di server yang sama
            local randomIndex = math.random(1, #validServers)
            local targetServer = validServers[randomIndex]
            if targetServer then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, player)
            end
        else
            -- Fallback jika tidak ada server cadangan yang terdeteksi
            TeleportService:Teleport(game.PlaceId, player)
        end
    end)
end

-- // UTILITY FUNCTIONS
local function clearTpParts()
    for _, p in ipairs(darknessTpParts) do
        if p and p.Parent then p:Destroy() end
    end
    table.clear(darknessTpParts)
end

local function findDarknessParts()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("darkness") then
            table.insert(list, v)
        end
    end
    local filtered = {}
    for _, part in ipairs(list) do
        local tooClose = false
        for _, kept in ipairs(filtered) do
            if (part.Position - kept.Position).Magnitude < 8 then
                tooClose = true
                break
            end
        end
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
            for i, p in ipairs(remaining) do
                local dist = (p.Position - current.Position).Magnitude
                if dist < closestDist then closestDist = dist closestIndex = i end
            end
            current = table.remove(remaining, closestIndex)
            table.insert(sorted, current)
        end
        return sorted
    end
    return filtered
end

local function findTriggerPart()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("trigger") then return v end
    end
    return nil
end

local function teleportTo(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function tweenPart(part, targetPos, duration)
    if not part or not part.Parent then return end
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {Position = targetPos}
    local tween = TweenService:Create(part, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

local function cleanOne(v)
    if not v or not v.Parent then return end
    if v.Name:find("Renux") then return end
    if v.Name:lower():find("darkness") or v.Name:lower():find("trigger") then return end
    if v.Parent and v.Parent:FindFirstChild("Humanoid") then return end
    if v:IsA("BasePart") then
        if v.Size.Magnitude < 6 and not v.Anchored and v.CanCollide == false then
            pcall(function() v:Destroy() end) return
        end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (v.Position - hrp.Position).Magnitude > 600 and v.Size.Magnitude < 12 then
            pcall(function() v:Destroy() end) return
        end
        pcall(function()
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
            if v:IsA("MeshPart") then v.TextureID = "" end
        end)
    elseif v:IsA("Decal") or v:IsA("Texture") then
        pcall(function() v:Destroy() end)
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
        pcall(function() v.Enabled = false v:Destroy() end)
    end
end

local function runAntiLag()
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if not antiLagEnabled then break end
            cleanOne(v)
            if _ % 200 == 0 then task.wait() end
        end
    end)
end

local function setWaterNoDamage(state)
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("water") then
                pcall(function() v.CanTouch = not state end)
            end
        end
    end)
end

local function startFarm()
    if farmingThread then task.cancel(farmingThread) end
    farmingThread = task.spawn(function()
        while autoFarmEnabled do
            if hasReachedTrigger then break end
            local darknessParts = findDarknessParts()
            if #darknessParts == 0 then warn("Darkness part tidak ditemukan!") task.wait(2) continue end
            clearTpParts()
            if farmMode == "tween" then
                local firstPart = darknessParts[1]
                local lastPart = darknessParts[#darknessParts]
                local trigger = findTriggerPart()
                local platform = Instance.new("Part")
                platform.Name = "Renux_TWEEN_Platform"
                platform.Size = Vector3.new(14, 1, 14)
                platform.Position = firstPart.Position + Vector3.new(0, 6, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 1
                platform.Parent = workspace
                table.insert(darknessTpParts, platform)

                local durationToLast
                if tpDelay >= 1.2 then durationToLast = 30
                elseif tpDelay >= 0.7 then durationToLast = 20
                else durationToLast = 14 end

                local keepFollowing = true
                local followConn
                followConn = RunService.Heartbeat:Connect(function()
                    if not keepFollowing or not autoFarmEnabled or not platform.Parent or hasReachedTrigger then
                        if followConn then followConn:Disconnect() end return
                    end
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - platform.Position).Magnitude > 4 then
                        hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
                    end
                end)

                tweenPart(platform, lastPart.Position + Vector3.new(0, 6, 0), durationToLast)
                keepFollowing = false
                if followConn then followConn:Disconnect() end
                if not autoFarmEnabled or hasReachedTrigger then continue end
                task.wait(0.2)
                clearTpParts()
                if trigger and autoFarmEnabled then
                    for j = 1, 3 do teleportTo(trigger.Position + Vector3.new(0, 3, 0)) task.wait(0.3) end
                    hasReachedTrigger = true
                    break
                end
            else
                if #darknessParts > maxTpParts then
                    local limited = {}
                    for i = 1, maxTpParts do table.insert(limited, darknessParts[i]) end
                    darknessParts = limited
                end
                for i, dp in ipairs(darknessParts) do
                    local tpPart = Instance.new("Part")
                    tpPart.Name = "Renux_TP_"..i
                    tpPart.Size = Vector3.new(10,1,10)
                    tpPart.Position = dp.Position + Vector3.new(0, 6, 0)
                    tpPart.Anchored = true
                    tpPart.CanCollide = true
                    tpPart.Transparency = 1
                    tpPart.Parent = workspace
                    table.insert(darknessTpParts, tpPart)
                end
                for i, tpPart in ipairs(darknessTpParts) do
                    if not autoFarmEnabled or hasReachedTrigger then break end
                    teleportTo(tpPart.Position)
                    task.wait(tpDelay)
                end
                if not autoFarmEnabled or hasReachedTrigger then continue end
                local trigger = findTriggerPart()
                if trigger then
                    for j = 1, 3 do teleportTo(trigger.Position + Vector3.new(0, 3, 0)) task.wait(0.3) end
                    hasReachedTrigger = true
                    break
                end
            end
        end
    end)
end

-- // UI MAIN TAB
Tab:AddDropdown({
    Title = "mode",
    Desc = "choose value",
    Values = {"tween", "teleport"},
    Value = {"teleport"},
    Multi = false,
    Search = true,
    Callback = function(selected)
        local mode = type(selected) == "table" and selected[1] or selected
        farmMode = mode
    end
})

Tab:AddDropdown({
    Title = "speed tp",
    Desc = "choose value",
    Values = {"slow (all gold But slow)", "normal (recommend)", "fast (low gold)"},
    Value = {"normal (recommend)"},
    Multi = false,
    Search = true,
    Callback = function(selected)
        local mode = type(selected) == "table" and selected[1] or selected
        if mode:find("slow") then tpDelay = 1.25
        elseif mode:find("fast") then tpDelay = 0.35
        else tpDelay = 0.75 end
    end
})

Tab:AddDivider()

Tab:Addtoggle({
    title = "Auto Farm Gold",
    desc = "Mengaktifkan fungsi perulangan otomatis",
    value = false,
    callback = function(state)
        autoFarmEnabled = state
        if state then
            if not hasReachedTrigger then startFarm() end
        else
            clearTpParts()
            if farmingThread then task.cancel(farmingThread) farmingThread = nil end
        end
    end
})

Tab:AddDivider()

Tab:Addtoggle({
    title = "Anti Lag",
    value = false,
    callback = function(state)
        antiLagEnabled = state
        if state then
            runAntiLag()
            if antiLagConn then antiLagConn:Disconnect() end
            antiLagConn = workspace.DescendantAdded:Connect(function(v)
                if antiLagEnabled then task.wait(0.1) cleanOne(v) end
            end)
        else
            if antiLagConn then antiLagConn:Disconnect() antiLagConn = nil end
        end
    end
})

Tab:Addtoggle({
    title = "Water No Damage",
    value = false,
    callback = function(state)
        waterNoDamageEnabled = state
        setWaterNoDamage(state)
        if state then
            if waterConn then waterConn:Disconnect() end
            waterConn = workspace.DescendantAdded:Connect(function(v)
                if waterNoDamageEnabled and v:IsA("BasePart") and v.Name:lower():find("water") then
                    task.wait(0.1)
                    pcall(function() v.CanTouch = false end)
                end
            end)
        else
            if waterConn then waterConn:Disconnect() waterConn = nil end
            setWaterNoDamage(false)
        end
    end
})

-- // UI SERVER TAB
ServerTab:Addbutton({
    title = "Rejoin Server",
    desc = "Reconnect to the same server",
    callback = function()
        rejoinServer()
    end
})

ServerTab:Addbutton({
    title = "Server Hop",
    desc = "Hop to a random public server",
    callback = function()
        hopServer()
    end
})

-- // EVENTS
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(1)
    if hasReachedTrigger then hasReachedTrigger = false end
    if autoFarmEnabled then task.wait(1) startFarm() end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if autoFarmEnabled and not hasReachedTrigger and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local trigger = findTriggerPart()
            if trigger and (player.Character.HumanoidRootPart.Position - trigger.Position).Magnitude < 15 then
                hasReachedTrigger = true
                clearTpParts()
            end
        end
    end
end)
