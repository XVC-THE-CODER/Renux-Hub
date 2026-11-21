local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local function safeJSONDecode(content)
    if type(content) ~= "string" then return nil end
    local trimmed = content:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" or trimmed == "null" then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(trimmed) end)
    if not ok or type(data) ~= "table" then return nil end
    return data
end

local function safeJSONEncode(data)
    if type(data) ~= "table" then return nil end
    local clean = {}
    for k, v in pairs(data) do
        if type(v) == "number" then
            if v ~= v or v == math.huge or v == -math.huge then v = 0 end
            clean[k] = v
        elseif type(v) == "boolean" or type(v) == "string" then
            clean[k] = v
        end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(clean) end)
    if not ok or type(json) ~= "string" or json == "" then return nil end
    return json
end

local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Player = LocalPlayer
local F = {
    ["kill all"] = false,
    ["esp"] = false,
    ["avoid killer"] = false,
    ["auto loot"] = false,
    ["fullbright"] = false,
    ["noclip"] = false,
    ["xray"] = false,
    ["walkspeed"] = false,
    ["jumppower"] = false,
    ["anti void"] = false,
    ["anti afk"] = false,
    ["infinite jump"] = false,
    ["auto save"] = false,
    ["auto self revive"] = false,
    ["auto revive"] = false,
    avoidKillerDistance = 25,
    walkspeedValue = 16,
    jumppowerValue = 50,
    killAllLoopRunning = false,
    autoSaveLoopRunning = false,
    autoLootThread = nil,
    autoSelfReviveThread = nil,
    autoReviveThread = nil,
    autoReviveLooping = false,
    autoReviveLastPlace = nil,
    autoReviveList = {},
    autoReviveSaved = {},
    autoReviveLocked = {},
    autoReviveHit = {},
    savedLootSpawns = {},
    savedCameraCF = nil,
    savedCameraType = nil,
    savedCameraSubject = nil,
    savedAutoLootGravity = nil,
    snakeCamera = false,
    lastSelfReviveTPTime = 0,
    selfReviveWaiting = false,
    cachedLootSpawns = nil,
    ["start auto voting"] = false,
    votingPlace = "1",
    autoVotingConn = nil,
    autoVotingThread = nil,
    ["auto exit door"] = false,
    autoExitDoorThread = nil,
    autoExitDoorTween = nil,
    autoExitDoorRunning = false,
    exitDoorMapAppearedAt = nil,
    exitDoorGameStartAt = nil,
    exitDoorLastMapName = nil,
    exitDoorTweenDone = false,
    exitDoorWaitTime = 256,
    exitDoorCurrentMap = nil,
    exitDoorSpawnPart = nil,
    exitDoorTimerNotified = false,
    autoLootSpawnTouched = false,
    autoLootCurrentMap = nil,
    autoLootSpawnPart = nil,
}

local espToggle = nil
local avoidKillerToggle = nil
local fullbrightToggle = nil
local noclipToggle = nil
local xrayToggle = nil
local killAllToggle = nil
local autoCollectLootToggle = nil
local enableWalkSpeedToggle = nil
local enableJumpPowerToggle = nil
local infiniteJumpToggle = nil
local antiVoidToggle = nil
local antiAfkToggle = nil
local walkspeedSlider = nil
local jumppowerSlider = nil
local AvoidKillerDistanceInput = nil
local configDropdown = nil
local configNameInput = nil
selectedConfigName = nil
local configNameText = ""
local Window = nil
local autoSaveToggle = nil
local lastAutoSaveJson = ""
local autoSelfReviveToggle = nil
local autoReviveToggle = nil
local autoExitDoorToggle = nil
local exitDoorTimerLabel = nil
local votingPlaceDropdown = nil
local startAutoVotingToggle = nil
local isApplyingConfig = false
local xraySaved = {}
local xrayQueue = {}
local xrayQueueSet = {}
local xrayProcessing = false
local xrayDescendantConn = nil

local function ensureConfigFolder()
    pcall(function()
        if not isfolder("Renuxhub") then makefolder("Renuxhub") end
    end)
    pcall(function()
        if not isfolder("Renuxhub/stk") then makefolder("Renuxhub/stk") end
    end)
    return true
end

local function getMainData()
    local ok, content = pcall(function() return readfile("Renuxhub/stk/main.json") end)
    if not ok or not content or content == "" then
        return { ["auto-save"] = false }
    end
    local data = safeJSONDecode(content)
    if not data then
        return { ["auto-save"] = false }
    end
    return { ["auto-save"] = data["auto-save"] == true }
end

local function saveMainData(autoSave)
    ensureConfigFolder()
    local data = {
        ["auto-save"] = autoSave == true
    }
    local json = safeJSONEncode(data)
    if not json then return end
    pcall(function() writefile("Renuxhub/stk/main.json", json) end)
end

local function getConfigDisplayNames()
    ensureConfigFolder()
    local ok, files = pcall(function() return listfiles("Renuxhub/stk") end)
    if not ok or not files then return {} end
    local names = {}
    for _, path in ipairs(files) do
        local base = string.match(tostring(path), "[^/\\]+$")
        if base then
            local lower = string.lower(base)
            if string.sub(lower, -5) == ".json" then
                local display = string.sub(base, 1, -6)
                if display ~= "" and display ~= "main" then
                    table.insert(names, display)
                end
            end
        end
    end
    table.sort(names)
    return names
end

local function getConfigOptions()
    local opts = {}
    table.insert(opts, { Label = "None", Value = "None" })
    for _, name in ipairs(getConfigDisplayNames()) do
        table.insert(opts, { Label = name, Value = name })
    end
    return opts
end

local function getConfigOptionsKey()
    return table.concat(getConfigDisplayNames(), ",")
end

local function refreshConfigDropdown()
    if not configDropdown then return end
    local newOpts = getConfigOptions()
    local current = nil
    pcall(function()
        current = configDropdown:GetValue()
    end)
    if type(current) == "table" then
        current = current.Value or current.Label
    elseif type(current) == "number" then
        local opts = getConfigOptions()
        local opt = opts[current]
        if opt then current = opt.Value else current = "None" end
    end
    if current and current ~= "None" and current ~= nil then
        local found = false
        for _, name in ipairs(getConfigDisplayNames()) do
            if name == current then found = true break end
        end
        if not found then
            selectedConfigName = nil
            pcall(function()
                configDropdown:SetOptions(newOpts, true)
            end)
            pcall(function()
                configDropdown:SetValue("None")
            end)
            return
        end
    end
    pcall(function()
        configDropdown:SetOptions(newOpts, true)
    end)
    if current then
        if current == "None" then
            selectedConfigName = nil
        else
            selectedConfigName = current
        end
    end
end

local function normalizeConfigFileName(inputName)
    if not inputName then return nil, nil end
    local trimmed = string.gsub(tostring(inputName), "^%s*(.-)%s*$", "%1")
    if trimmed == "" then return nil, nil end
    local fileName = trimmed
    if string.lower(string.sub(trimmed, -5)) == ".json" then
        fileName = trimmed
    else
        fileName = trimmed .. ".json"
    end
    local display = string.sub(fileName, 1, -6)
    return fileName, display
end

local function getCurrentConfigData()
    return {
        ["esp-player-killer"] = F["esp"],
        ["avoid-killer"] = F["avoid killer"],
        ["fullbright"] = F["fullbright"],
        ["noclip"] = F["noclip"],
        ["x-ray"] = F["xray"],
        ["kill-all"] = F["kill all"],
        ["auto-collect-loot"] = F["auto loot"],
        ["enable-walkspeed"] = F["walkspeed"],
        ["enable-jumppower"] = F["jumppower"],
        ["infinite-jump"] = F["infinite jump"],
        ["anti-void"] = F["anti void"],
        ["anti-afk"] = F["anti afk"],
        ["walkspeed"] = F.walkspeedValue,
        ["jumppower"] = F.jumppowerValue,
        ["avoid-killer-distance"] = F.avoidKillerDistance,
        ["auto-self-revive"] = F["auto self revive"],
        ["auto-revive"] = F["auto revive"],
        ["start-auto-voting"] = F["start auto voting"],
        ["select-voting-place"] = F.votingPlace,
        ["auto-exit-door"] = F["auto exit door"],
    }
end

local function doSaveConfig()
    local nameToUse = configNameText
    if not nameToUse or nameToUse == "" then
        if selectedConfigName and selectedConfigName ~= "None" then
            nameToUse = selectedConfigName
        else
            if Window then
                Window:Notify({ Title = "config", Content = "enter config name first", Kind = "error", Duration = 3 })
            end
            return
        end
    end
    local fileName, displayName = normalizeConfigFileName(nameToUse)
    if not fileName then return end
    if displayName == "main" then
        if Window then
            Window:Notify({ Title = "config", Content = "main is reserved", Kind = "error", Duration = 3 })
        end
        return
    end
    ensureConfigFolder()
    local data = getCurrentConfigData()
    local json = safeJSONEncode(data)
    if not json then return end
    local okWrite = pcall(function()
        writefile("Renuxhub/stk/" .. fileName, json)
    end)
    if okWrite then
        lastAutoSaveJson = json
        selectedConfigName = displayName
        refreshConfigDropdown()
        pcall(function()
            configDropdown:SetValue(displayName)
        end)
        if Window then
            Window:Notify({ Title = "config", Content = "saved " .. displayName, Kind = "success", Duration = 3 })
        end
    else
        if Window then
            Window:Notify({ Title = "config", Content = "failed to save", Kind = "error", Duration = 3 })
        end
    end
end

local function doLoadConfig()
    local nameToLoad = selectedConfigName
    if not nameToLoad or nameToLoad == "None" or nameToLoad == "" then
        if configDropdown then
            local cur = nil
            pcall(function()
                cur = configDropdown:GetValue()
            end)
            if type(cur) == "table" then cur = cur.Value or cur.Label end
            if type(cur) == "number" then
                local opts = getConfigOptions()
                local opt = opts[cur]
                if opt then cur = opt.Value end
            end
            if cur and cur ~= "None" and cur ~= "" then nameToLoad = cur end
        end
    end
    if not nameToLoad or nameToLoad == "None" or nameToLoad == "" then
        if Window then
            Window:Notify({ Title = "config", Content = "select config first", Kind = "error", Duration = 3 })
        end
        return
    end
    if nameToLoad == "main" then return end
    local fileName = nameToLoad .. ".json"
    local okRead, content = pcall(function()
        return readfile("Renuxhub/stk/" .. fileName)
    end)
    if not okRead or not content then
        if Window then
            Window:Notify({ Title = "config", Content = "config not found", Kind = "error", Duration = 3 })
        end
        return
    end
    local data = safeJSONDecode(content)
    if not data then return end
    isApplyingConfig = true
    if data["esp-player-killer"] ~= nil then
        F["esp"] = data["esp-player-killer"] == true
        if espToggle then pcall(function() espToggle:SetValue(F["esp"]) end) end
    end
    if data["avoid-killer"] ~= nil then
        F["avoid killer"] = data["avoid-killer"] == true
        if avoidKillerToggle then pcall(function() avoidKillerToggle:SetValue(F["avoid killer"]) end) end
    end
    if data["fullbright"] ~= nil then
        F["fullbright"] = data["fullbright"] == true
        if fullbrightToggle then pcall(function() fullbrightToggle:SetValue(F["fullbright"]) end) end
    end
    if data["noclip"] ~= nil then
        F["noclip"] = data["noclip"] == true
        if noclipToggle then pcall(function() noclipToggle:SetValue(F["noclip"]) end) end
    end
    if data["x-ray"] ~= nil then
        F["xray"] = data["x-ray"] == true
        if xrayToggle then pcall(function() xrayToggle:SetValue(F["xray"]) end) end
    end
    if data["kill-all"] ~= nil then
        F["kill all"] = data["kill-all"] == true
        if killAllToggle then pcall(function() killAllToggle:SetValue(F["kill all"]) end) end
    end
    if data["auto-collect-loot"] ~= nil then
        F["auto loot"] = data["auto-collect-loot"] == true
        if autoCollectLootToggle then pcall(function() autoCollectLootToggle:SetValue(F["auto loot"]) end) end
    end
    if data["enable-walkspeed"] ~= nil then
        F["walkspeed"] = data["enable-walkspeed"] == true
        if enableWalkSpeedToggle then pcall(function() enableWalkSpeedToggle:SetValue(F["walkspeed"]) end) end
    end
    if data["enable-jumppower"] ~= nil then
        F["jumppower"] = data["enable-jumppower"] == true
        if enableJumpPowerToggle then pcall(function() enableJumpPowerToggle:SetValue(F["jumppower"]) end) end
    end
    if data["infinite-jump"] ~= nil then
        F["infinite jump"] = data["infinite-jump"] == true
        if infiniteJumpToggle then pcall(function() infiniteJumpToggle:SetValue(F["infinite jump"]) end) end
    end
    if data["anti-void"] ~= nil then
        F["anti void"] = data["anti-void"] == true
        if antiVoidToggle then pcall(function() antiVoidToggle:SetValue(F["anti void"]) end) end
    end
    if data["anti-afk"] ~= nil then
        F["anti afk"] = data["anti-afk"] == true
        if antiAfkToggle then pcall(function() antiAfkToggle:SetValue(F["anti afk"]) end) end
    end
    if data["walkspeed"] ~= nil then
        F.walkspeedValue = tonumber(data["walkspeed"]) or F.walkspeedValue
        if walkspeedSlider then pcall(function() walkspeedSlider:SetValue(F.walkspeedValue) end) end
    end
    if data["jumppower"] ~= nil then
        F.jumppowerValue = tonumber(data["jumppower"]) or F.jumppowerValue
        if jumppowerSlider then pcall(function() jumppowerSlider:SetValue(F.jumppowerValue) end) end
    end
    if data["avoid-killer-distance"] ~= nil then
        F.avoidKillerDistance = tonumber(data["avoid-killer-distance"]) or F.avoidKillerDistance
        if AvoidKillerDistanceInput then pcall(function() AvoidKillerDistanceInput:SetValue(tostring(F.avoidKillerDistance)) end) end
    end
    if data["auto-self-revive"] ~= nil then
        F["auto self revive"] = data["auto-self-revive"] == true
        if autoSelfReviveToggle then pcall(function() autoSelfReviveToggle:SetValue(F["auto self revive"]) end) end
    end
    if data["auto-revive"] ~= nil then
        F["auto revive"] = data["auto-revive"] == true
        if autoReviveToggle then pcall(function() autoReviveToggle:SetValue(F["auto revive"]) end) end
    end
    if data["start-auto-voting"] ~= nil then
        F["start auto voting"] = data["start-auto-voting"] == true
        if startAutoVotingToggle then pcall(function() startAutoVotingToggle:SetValue(F["start auto voting"]) end) end
    end
    if data["select-voting-place"] ~= nil then
        F.votingPlace = tostring(data["select-voting-place"])
        if votingPlaceDropdown then pcall(function() votingPlaceDropdown:SetValue(F.votingPlace) end) end
    end
    if data["auto-exit-door"] ~= nil then
        F["auto exit door"] = data["auto-exit-door"] == true
        if autoExitDoorToggle then pcall(function() autoExitDoorToggle:SetValue(F["auto exit door"]) end) end
    end
    isApplyingConfig = false
    lastAutoSaveJson = content
    if Window then
        Window:Notify({ Title = "config", Content = "loaded " .. nameToLoad, Kind = "success", Duration = 3 })
    end
end

local function doDeleteConfig()
    local nameToDelete = selectedConfigName
    if not nameToDelete or nameToDelete == "None" or nameToDelete == "" then
        if configDropdown then
            local cur = nil
            pcall(function()
                cur = configDropdown:GetValue()
            end)
            if type(cur) == "table" then cur = cur.Value or cur.Label end
            if type(cur) == "number" then
                local opts = getConfigOptions()
                local opt = opts[cur]
                if opt then cur = opt.Value end
            end
            if cur and cur ~= "None" and cur ~= "" then nameToDelete = cur end
        end
    end
    if not nameToDelete or nameToDelete == "None" or nameToDelete == "" then
        if Window then
            Window:Notify({ Title = "config", Content = "select config first", Kind = "error", Duration = 3 })
        end
        return
    end
    if nameToDelete == "main" then return end
    local fileName = nameToDelete .. ".json"
    pcall(function()
        delfile("Renuxhub/stk/" .. fileName)
    end)
    selectedConfigName = nil
    configNameText = ""
    if configNameInput then pcall(function() configNameInput:SetValue("") end) end
    refreshConfigDropdown()
    if configDropdown then pcall(function() configDropdown:SetValue("None") end) end
    if Window then
        Window:Notify({ Title = "config", Content = "deleted " .. nameToDelete, Kind = "success", Duration = 3 })
    end
end

local function doAutoSaveSilent()
    if not F["auto save"] then return end
    if isApplyingConfig then return end
    local targetName = selectedConfigName
    if not targetName or targetName == "None" or targetName == "" then return end
    if targetName == "main" then return end
    local fileName, displayName = normalizeConfigFileName(targetName)
    if not fileName then return end
    ensureConfigFolder()
    local data = getCurrentConfigData()
    local json = safeJSONEncode(data)
    if not json then return end
    local existing = nil
    local okRead, content = pcall(function()
        return readfile("Renuxhub/stk/" .. fileName)
    end)
    if okRead then existing = content end
    if existing == json then return end
    local okWrite = pcall(function()
        writefile("Renuxhub/stk/" .. fileName, json)
    end)
    if okWrite then
        lastAutoSaveJson = json
        refreshConfigDropdown()
    end
end

local function startAutoSaveLoop()
    if F.autoSaveLoopRunning then return end
    F.autoSaveLoopRunning = true
    task.spawn(function()
        while true do
            task.wait(2)
            if F["auto save"] then
                pcall(function()
                    doAutoSaveSilent()
                end)
            end
        end
    end)
end

local lastConfigOptionsKey = ""
local configWatcherRunning = false

local function startConfigWatcher()
    if configWatcherRunning then return end
    configWatcherRunning = true
    task.spawn(function()
        lastConfigOptionsKey = getConfigOptionsKey()
        while true do
            task.wait(1)
            local key = getConfigOptionsKey()
            if key ~= lastConfigOptionsKey then
                lastConfigOptionsKey = key
                refreshConfigDropdown()
            end
        end
    end)
end

local function hasKnifeModel(plr)
    local char = Workspace:FindFirstChild(plr.Name)
    if char then
        local knife = char:FindFirstChild("Knife")
        if knife and knife.Name == "Knife" and (knife:IsA("Model") or knife:IsA("Tool")) then
            return true
        end
    end
    local char2 = plr.Character
    if char2 and char2 ~= char then
        local knife2 = char2:FindFirstChild("Knife")
        if knife2 and knife2.Name == "Knife" and (knife2:IsA("Model") or knife2:IsA("Tool")) then
            return true
        end
    end
    return false
end

local function checkKiller(plr)
    return hasKnifeModel(plr)
end

local function checkHuman(plr)
    return not hasKnifeModel(plr)
end

local function selfIsKiller()
    return hasKnifeModel(LocalPlayer)
end

local function getKillerPosition()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if checkKiller(plr) then
            local kc = Workspace:FindFirstChild(plr.Name) or plr.Character
            local khrp = kc and kc:FindFirstChild("HumanoidRootPart")
            if khrp then return khrp.Position, plr end
        end
    end
    return nil, nil
end

local function isKillerExists()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and checkKiller(plr) then return true, plr end
    end
    return false, nil
end

local movementHeartbeat = nil

local function startMovementLoop()
    if movementHeartbeat then return end
    movementHeartbeat = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if F["walkspeed"] then
            if hum.WalkSpeed ~= F.walkspeedValue then
                hum.WalkSpeed = F.walkspeedValue
            end
        end
        if F["jumppower"] then
            if hum.UseJumpPower ~= true then
                hum.UseJumpPower = true
            end
            if hum.JumpPower ~= F.jumppowerValue then
                hum.JumpPower = F.jumppowerValue
            end
        end
    end)
end

local function stopMovementLoopIfNeeded()
    if not F["walkspeed"] and not F["jumppower"] then
        if movementHeartbeat then
            movementHeartbeat:Disconnect()
            movementHeartbeat = nil
        end
    end
end

local function resetWalkSpeedOnce()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
    end
end

local function resetJumpPowerOnce()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = false
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
    end
end

local lastSafeCF = nil
local antiVoidHeartbeat = nil
local lastAntiVoidSave = 0

local function startAntiVoid()
    if antiVoidHeartbeat then return end
    antiVoidHeartbeat = RunService.Heartbeat:Connect(function()
        if not F["anti void"] then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if hrp.Position.Y < -100 then
            if lastSafeCF then
                hrp.CFrame = lastSafeCF
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            return
        end
        if hum.FloorMaterial ~= Enum.Material.Air then
            if tick() - lastAntiVoidSave >= 0.3 then
                if not lastSafeCF or (hrp.Position - lastSafeCF.Position).Magnitude > 1 then
                    lastSafeCF = hrp.CFrame
                    lastAntiVoidSave = tick()
                else
                    lastAntiVoidSave = tick()
                end
            end
        end
    end)
end

local function stopAntiVoid()
    if antiVoidHeartbeat then
        antiVoidHeartbeat:Disconnect()
        antiVoidHeartbeat = nil
    end
end

local antiAfkConn = nil

local function enableAntiAFK()
    if antiAfkConn then return end
    antiAfkConn = LocalPlayer.Idled:Connect(function()
        if not F["anti afk"] then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end)
end

local function disableAntiAFK()
    if antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
end

local infiniteJumpConn = nil

local function enableInfiniteJump()
    if infiniteJumpConn then return end
    infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
        if not F["infinite jump"] then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum:GetState() == Enum.HumanoidStateType.Dead then return end
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

local function disableInfiniteJump()
    if infiniteJumpConn then
        pcall(function() infiniteJumpConn:Disconnect() end)
        infiniteJumpConn = nil
    end
end

local function unanchorPlayer(targetChar)
    if not targetChar then return end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
    end
    for _, part in ipairs(targetChar:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CanCollide = true
            end)
        end
    end
end

local function doBring(targetChar, myRoot, offset)
    if not targetChar or not myRoot then return false end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, part in ipairs(targetChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    hrp.Anchored = true
    hrp.CFrame = myRoot.CFrame * offset
    return true
end
F.killAllLoopRunning = false

local function bringKillAll(offset)
    if F.killAllLoopRunning then return end
    F.killAllLoopRunning = true
    task.spawn(function()
        while F["kill all"] do
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                if not selfIsKiller() then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            local c = Workspace:FindFirstChild(plr.Name) or plr.Character
                            if c then unanchorPlayer(c) end
                        end
                    end
                else
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            local targetChar = Workspace:FindFirstChild(plr.Name) or plr.Character
                            if targetChar then
                                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    if checkHuman(plr) then
                                        local distance = (hrp.Position - myRoot.Position).Magnitude
                                        if distance <= 250 then
                                            doBring(targetChar, myRoot, offset)
                                        end
                                    else
                                        unanchorPlayer(targetChar)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c = Workspace:FindFirstChild(plr.Name) or plr.Character
                if c then unanchorPlayer(c) end
            end
        end
        F.killAllLoopRunning = false
    end)
end

local function enforceRevivePrompt(targetChar)
    if not targetChar then return end
    for _, prompt in ipairs(targetChar:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.KeyboardKeyCode = Enum.KeyCode.F
                prompt.HoldDuration = 0.3
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 100
            end)
        end
    end
end

local function pressFAndPrompt(targetChar)
    if not targetChar then return end
    enforceRevivePrompt(targetChar)
    for _, prompt in ipairs(targetChar:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                end
            end)
        end
    end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.35)
        vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function findLootSpawns()
    if F.cachedLootSpawns and F.cachedLootSpawns.Parent then return F.cachedLootSpawns end
    local direct = Workspace:FindFirstChild("LootSpawns") or Workspace:FindFirstChild("lootSpawns") or Workspace:FindFirstChild("LOOTSPAWNS")
    if direct then F.cachedLootSpawns = direct return direct end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if string.lower(v.Name) == "lootspawns" then F.cachedLootSpawns = v return v end
    end
    return nil
end

local savedLighting = nil
local savedCastShadow = {}
local fullbrightHeartbeat = nil
local fullbrightDescendantConn = nil

local function applyFullbrightRemovedStateOnce()
    Lighting.FogStart = 1000000
    Lighting.FogEnd = 1000000
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        atm.Density = 0
    end
end

local function enableFullbright()
    if savedLighting then return end
    savedLighting = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        ShadowSoftness = Lighting.ShadowSoftness,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    }
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        savedLighting.AtmosphereDensity = atm.Density
        savedLighting.AtmosphereOffset = atm.Offset
        savedLighting.AtmosphereColor = atm.Color
        savedLighting.AtmosphereDecay = atm.Decay
        savedLighting.AtmosphereGlare = atm.Glare
        savedLighting.AtmosphereHaze = atm.Haze
        savedLighting.HasAtmosphere = true
    end
    savedCastShadow = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            savedCastShadow[v] = v.CastShadow
            v.CastShadow = false
        end
    end
    applyFullbrightRemovedStateOnce()
    if fullbrightHeartbeat then fullbrightHeartbeat:Disconnect() end
    fullbrightHeartbeat = RunService.Heartbeat:Connect(function()
        if not F["fullbright"] then return end
        if Lighting.FogStart ~= 1000000 then Lighting.FogStart = 1000000 end
        if Lighting.FogEnd ~= 1000000 then Lighting.FogEnd = 1000000 end
        if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
        if Lighting.ShadowSoftness ~= 0 then Lighting.ShadowSoftness = 0 end
        local atm2 = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm2 and atm2.Density ~= 0 then atm2.Density = 0 end
    end)
    if fullbrightDescendantConn then fullbrightDescendantConn:Disconnect() end
    fullbrightDescendantConn = Workspace.DescendantAdded:Connect(function(v)
        if F["fullbright"] and v:IsA("BasePart") then
            if savedCastShadow[v] == nil then
                savedCastShadow[v] = v.CastShadow
            end
            v.CastShadow = false
        end
    end)
end

local function disableFullbright()
    if fullbrightHeartbeat then
        fullbrightHeartbeat:Disconnect()
        fullbrightHeartbeat = nil
    end
    if fullbrightDescendantConn then
        fullbrightDescendantConn:Disconnect()
        fullbrightDescendantConn = nil
    end
    if not savedLighting then return end
    Lighting.FogStart = savedLighting.FogStart
    Lighting.FogEnd = savedLighting.FogEnd
    Lighting.FogColor = savedLighting.FogColor
    Lighting.Ambient = savedLighting.Ambient
    Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
    Lighting.Brightness = savedLighting.Brightness
    Lighting.GlobalShadows = savedLighting.GlobalShadows
    Lighting.ShadowSoftness = savedLighting.ShadowSoftness
    Lighting.ExposureCompensation = savedLighting.ExposureCompensation
    Lighting.EnvironmentDiffuseScale = savedLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = savedLighting.EnvironmentSpecularScale
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm and savedLighting.HasAtmosphere then
        atm.Density = savedLighting.AtmosphereDensity
        atm.Offset = savedLighting.AtmosphereOffset
        atm.Color = savedLighting.AtmosphereColor
        atm.Decay = savedLighting.AtmosphereDecay
        atm.Glare = savedLighting.AtmosphereGlare
        atm.Haze = savedLighting.AtmosphereHaze
    end
    for part, oldVal in pairs(savedCastShadow) do
        if part and part.Parent then
            pcall(function()
                part.CastShadow = oldVal
            end)
        end
    end
    savedLighting = nil
    savedCastShadow = {}
end

local noclipConn = nil

local function isAccessoryPart(part)
    local cur = part
    while cur do
        if cur:IsA("Accessory") then
            return true
        end
        cur = cur.Parent
    end
    return false
end

local function applyNoclipOffState(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if isAccessoryPart(part) then
                part.CanCollide = false
            else
                part.CanCollide = true
            end
        end
    end
end

local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not F["noclip"] then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        applyNoclipOffState(char)
    end
end

local function isXrayExcludedPart(part)
    local char = LocalPlayer.Character
    if char and part:IsDescendantOf(char) then return true end
    return false
end

local function enqueueXrayPart(part)
    if not part or not part:IsA("BasePart") then return end
    if isXrayExcludedPart(part) then return end
    if part.Transparency >= 0.7 then return end
    if xraySaved[part] ~= nil then return end
    if xrayQueueSet[part] then return end
    table.insert(xrayQueue, part)
    xrayQueueSet[part] = true
end

local function startXrayProcessing()
    if xrayProcessing then return end
    xrayProcessing = true
    task.spawn(function()
        while F["xray"] do
            if #xrayQueue == 0 then
                task.wait(0.1)
            else
                local part = table.remove(xrayQueue, 1)
                xrayQueueSet[part] = nil
                if part and part.Parent and part:IsA("BasePart") then
                    if part.Transparency < 0.7 then
                        if xraySaved[part] == nil then
                            xraySaved[part] = part.Transparency
                        end
                        pcall(function()
                            part.Transparency = 0.7
                        end)
                    end
                end
                task.wait(1 / 50)
            end
        end
        xrayProcessing = false
    end)
end

local function enableXray()
    F["xray"] = true
    xrayQueue = {}
    xrayQueueSet = {}
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.new(0, 0, 0)
    local parts = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not isXrayExcludedPart(v) and v.Transparency < 0.7 then
                table.insert(parts, v)
            end
        end
    end
    table.sort(parts, function(a, b)
        local da = (a.Position - myPos).Magnitude
        local db = (b.Position - myPos).Magnitude
        return da < db
    end)
    for _, part in ipairs(parts) do
        enqueueXrayPart(part)
    end
    startXrayProcessing()
    if xrayDescendantConn then xrayDescendantConn:Disconnect() end
    xrayDescendantConn = Workspace.DescendantAdded:Connect(function(v)
        if F["xray"] and v:IsA("BasePart") then
            enqueueXrayPart(v)
        end
    end)
end

local function disableXray()
    F["xray"] = false
    xrayQueue = {}
    xrayQueueSet = {}
    if xrayDescendantConn then
        xrayDescendantConn:Disconnect()
        xrayDescendantConn = nil
    end
    for part, old in pairs(xraySaved) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = old
            end)
        end
    end
    xraySaved = {}
end

local espObjects = {}
local espHeartbeat = nil

local function clearESP(plr)
    local data = espObjects[plr]
    if data then
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.billboard then pcall(function() data.billboard:Destroy() end) end
        espObjects[plr] = nil
    end
end

local function clearAllESP()
    for plr, _ in pairs(espObjects) do
        clearESP(plr)
    end
end

local function createESP(plr, char, isKiller)
    if not char or not char.Parent then return nil end
    if not char:IsA("Model") then return nil end
    if espObjects[plr] then return espObjects[plr] end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local highlight = Instance.new("Highlight")
    highlight.Name = "RenuxESP"
    highlight.Adornee = char
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    if isKiller then
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    else
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    end
    pcall(function() highlight.Parent = Workspace end)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RenuxESPBillboard"
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    pcall(function() billboard.Parent = Workspace end)
    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextWrapped = true
    label.Text = plr.Name
    if isKiller then
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
    else
        label.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
    label.Parent = billboard
    local data = { highlight = highlight, billboard = billboard, label = label, isKiller = isKiller }
    espObjects[plr] = data
    return data
end

local function startESPHeartbeat()
    if espHeartbeat then return end
    espHeartbeat = RunService.Heartbeat:Connect(function()
        if not F["esp"] then
            clearAllESP()
            if espHeartbeat then
                espHeartbeat:Disconnect()
                espHeartbeat = nil
            end
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then
                clearESP(plr)
                continue
            end
            local char = Workspace:FindFirstChild(plr.Name) or plr.Character
            if char and not char.Parent then clearESP(plr) continue end
            if char and char:IsA("Model") and not char.Parent then clearESP(plr) continue end
            if not char then
                clearESP(plr)
                continue
            end
            local isKiller = checkKiller(plr)
            local isHuman = checkHuman(plr)
            local needESP = F["esp"] and (isKiller or isHuman)
            if not needESP then
                clearESP(plr)
                continue
            end
            local data = espObjects[plr]
            if not data or data.isKiller ~= isKiller or not data.highlight.Parent then
                clearESP(plr)
                data = createESP(plr, char, isKiller)
            end
            if data and data.label then
                if data.highlight.Adornee ~= char then
                    data.highlight.Adornee = char
                    pcall(function() if data.highlight.Parent ~= Workspace then data.highlight.Parent = Workspace end end)
                end
                if data.billboard.Parent ~= Workspace then
                    pcall(function() if data.billboard.Parent ~= Workspace then data.billboard.Parent = Workspace end end)
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then data.billboard.Adornee = hrp end
                end
                if isKiller then
                    data.highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    data.highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    data.label.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    data.highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    data.highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and myRoot then
                    local dist = math.floor((hrp.Position - myRoot.Position).Magnitude)
                    data.label.Text = plr.Name .. "\n" .. dist .. " studs"
                else
                    data.label.Text = plr.Name
                end
            end
        end
        for plr, _ in pairs(espObjects) do
            local found = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p == plr then found = true break end
            end
            if not found then clearESP(plr) end
        end
    end)
end

local avoidKillerHeartbeat = nil
local lastAvoidKillerTP = 0

local function startAvoidKiller()
    if avoidKillerHeartbeat then return end
    avoidKillerHeartbeat = RunService.Heartbeat:Connect(function()
        if not F["avoid killer"] then return end
        if selfIsKiller() then return end
        if tick() - lastAvoidKillerTP < 1 then return end
        local killerPos = getKillerPosition()
        if not killerPos then return end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local distToKiller = (myHRP.Position - killerPos).Magnitude
        if distToKiller > F.avoidKillerDistance then return end
        local candidates = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not checkKiller(plr) then
                local c = Workspace:FindFirstChild(plr.Name) or plr.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    local d = (h.Position - killerPos).Magnitude
                    if d > F.avoidKillerDistance and d <= 300 then
                        table.insert(candidates, { hrp = h, dist = d })
                    end
                end
            end
        end
        if #candidates > 0 then
            table.sort(candidates, function(a, b) return a.dist > b.dist end)
            local target = candidates[1]
            myHRP.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 3)
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            lastAvoidKillerTP = tick()
            return
        end
        local lootSpawns = findLootSpawns()
        if lootSpawns then
            local farthestLoot = nil
            local farthestDist = -1
            for _, v in ipairs(lootSpawns:GetDescendants()) do
                if v:IsA("BasePart") then
                    local d = (v.Position - killerPos).Magnitude
                    if d > farthestDist then
                        farthestDist = d
                        farthestLoot = v
                    end
                end
            end
            if farthestLoot then
                myHRP.CFrame = farthestLoot.CFrame + Vector3.new(0, 2, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                lastAvoidKillerTP = tick()
            end
        end
    end)
end

local function stopAvoidKiller()
    if avoidKillerHeartbeat then
        avoidKillerHeartbeat:Disconnect()
        avoidKillerHeartbeat = nil
    end
end

local function findLobbySeat()
    local benches = Workspace:FindFirstChild("Benches")
    if not benches then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Benches" then
                benches = v
                break
            end
        end
    end
    if not benches then return nil end
    for _, child in ipairs(benches:GetChildren()) do
        if child.Name == "Bench" then
            local seat = child:FindFirstChild("Seat")
            if seat then return seat end
            for _, d in ipairs(child:GetDescendants()) do
                if d.Name == "Seat" then
                    return d
                end
            end
        end
    end
    for _, d in ipairs(benches:GetDescendants()) do
        if d.Name == "Seat" then
            return d
        end
    end
    return nil
end

local function doToLobby()
    local seat = findLobbySeat()
    if not seat then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local seatCF = seat.CFrame
    myHRP.CFrame = seatCF + Vector3.new(0, 3, 0)
    myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local function doTpMap()
    local lootSpawns = findLootSpawns()
    if not lootSpawns then return end
    local killerPos = getKillerPosition()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local referencePos = killerPos or myHRP.Position
    local farthest = nil
    local farthestDist = -1
    for _, v in ipairs(lootSpawns:GetDescendants()) do
        if v:IsA("BasePart") then
            local d = (v.Position - referencePos).Magnitude
            if d > farthestDist then
                farthestDist = d
                farthest = v
            end
        end
    end
    if farthest then
        myHRP.CFrame = farthest.CFrame + Vector3.new(0, 2, 0)
        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function findChildCaseInsensitive(parent, targetName)
    if not parent then return nil end
    local exact = parent:FindFirstChild(targetName)
    if exact then return exact end
    local lowerTarget = string.lower(targetName)
    for _, child in ipairs(parent:GetChildren()) do
        if string.lower(child.Name) == lowerTarget then
            return child
        end
    end
    return nil
end

local function findDescendantCaseInsensitive(parent, targetName)
    if not parent then return nil end
    local lowerTarget = string.lower(targetName)
    for _, v in ipairs(parent:GetDescendants()) do
        if string.lower(v.Name) == lowerTarget then
            return v
        end
    end
    return nil
end

local STK_MAPS = {
    "Happy Neighborhood",
    "Water Treatment Facility",
    "Willow Marsh",
    "Classic Willow Marsh",
    "Papa Ronis Pizzeria",
    "Night School",
    "Fair Grounds",
    "Classic Fair Grounds",
    "Darkwood Asylum",
    "Space Lab",
    "Haunted Mansion",
    "Skate Zone",
    "Scary Garys Academy",
    "???",
    "Deadmans Point",
    "Junkyard",
    "Subway",
    "Mines",
}

local EXITS_NAME = "Exits"
local EXIT_GATEWAY_NAME = "ExitGateway"
local EXIT_TRIGGER_NAME = "Trigger"

local function findExitTrigger()
    for _, mapName in ipairs(STK_MAPS) do
        local mapModel = Workspace:FindFirstChild(mapName)
        if mapModel then
            local exits = findChildCaseInsensitive(mapModel, EXITS_NAME)
            if not exits then exits = findDescendantCaseInsensitive(mapModel, EXITS_NAME) end
            if exits then
                local gateway = findChildCaseInsensitive(exits, EXIT_GATEWAY_NAME)
                if not gateway then gateway = findDescendantCaseInsensitive(exits, EXIT_GATEWAY_NAME) end
                if gateway then
                    local trigger = findChildCaseInsensitive(gateway, EXIT_TRIGGER_NAME)
                    if not trigger then trigger = findDescendantCaseInsensitive(gateway, EXIT_TRIGGER_NAME) end
                    if trigger and trigger:IsA("BasePart") then return trigger, mapModel end
                else
                    local triggerFallback = findDescendantCaseInsensitive(exits, EXIT_TRIGGER_NAME)
                    if triggerFallback and triggerFallback:IsA("BasePart") then return triggerFallback, mapModel end
                end
            end
        end
    end
    return nil, nil
end

local function setExitDoorCanCollide(char, canCollide)
    if not char then return {} end
    local saved = {}
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then saved[v] = v.CanCollide pcall(function() v.CanCollide = canCollide end) end
    end
    return saved
end

local function restoreExitDoorCanCollide(saved)
    for part, val in pairs(saved) do
        if part and part.Parent then pcall(function() part.CanCollide = val end) end
    end
end

local function tweenHRPToExitDoor(targetPos)
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myChar or not myHRP then return false end
    if F.autoExitDoorTween then pcall(function() F.autoExitDoorTween:Cancel() end) F.autoExitDoorTween = nil end
    local saved = setExitDoorCanCollide(myChar, false)
    local dist = (myHRP.Position - targetPos).Magnitude
    local duration = math.clamp(dist / 40, 0.5, 5)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = { CFrame = CFrame.new(targetPos) }
    local tween = nil
    local ok, err = pcall(function() tween = TweenService:Create(myHRP, info, goal) end)
    if not ok or not tween then restoreExitDoorCanCollide(saved) return false end
    F.autoExitDoorTween = tween
    F.autoExitDoorRunning = true
    pcall(function() myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end)
    tween.Completed:Connect(function(status)
        F.autoExitDoorTween = nil
        F.autoExitDoorRunning = false
        restoreExitDoorCanCollide(saved)
    end)
    tween:Play()
    return true, duration
end

local function findMapModelInWorkspace()
    for _, mapName in ipairs(STK_MAPS) do
        local m = Workspace:FindFirstChild(mapName)
        if m then return m, mapName end
    end
    return nil, nil
end

local function findSurvivorSpawnPart(mapModel)
    if not mapModel then return nil, nil end
    local folderNames = { "SurvivorSpawns", "SurvivorSpawn", "Survivor Spawns", "Spawns", "SpawnPoints", "SpawnLocations" }
    local folder = nil
    for _, fname in ipairs(folderNames) do
        folder = findChildCaseInsensitive(mapModel, fname)
        if folder then break end
        folder = findDescendantCaseInsensitive(mapModel, fname)
        if folder then break end
    end
    if folder then
        local spawn = findChildCaseInsensitive(folder, "Spawn")
        if not spawn then spawn = findDescendantCaseInsensitive(folder, "Spawn") end
        if spawn and spawn:IsA("BasePart") then return spawn, folder end
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then return v, folder end
        end
    end
    local backupSpawn = findDescendantCaseInsensitive(mapModel, "Spawn")
    if backupSpawn and backupSpawn:IsA("BasePart") then return backupSpawn, nil end
    return nil, nil
end

local function isPlayerAtSpawn(spawnPart)
    if not spawnPart then return false, nil end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myChar or not myHRP then return false, nil end
    local dist = (myHRP.Position - spawnPart.Position).Magnitude
    return dist <= 25, dist
end

local function getExitDoorTimeLeft()
    local startAt = F.exitDoorGameStartAt or F.exitDoorMapAppearedAt
    if not startAt then return nil end
    local elapsed = tick() - startAt
    local left = (F.exitDoorWaitTime or 256) - elapsed
    if left < 0 then left = 0 end
    return left, elapsed
end

local function doTpExitDoorTween()
    local trigger, mapModel = findExitTrigger()
    if not trigger then return false end
    local targetPos = trigger.Position + Vector3.new(0, 3, 0)
    local ok, duration = tweenHRPToExitDoor(targetPos)
    if ok then F.exitDoorTweenDone = true end
    return ok
end

local function startAutoExitDoor()
    F["auto exit door"] = true
    if F.autoExitDoorThread then return end
    F.autoExitDoorThread = task.spawn(function()
        while F["auto exit door"] do
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myChar or not myHRP then task.wait(0.5)
            elseif selfIsKiller() then task.wait(0.5)
            else
                local mapModel, mapName = findMapModelInWorkspace()
                if not mapModel then
                    F.exitDoorGameStartAt = nil
                    F.exitDoorMapAppearedAt = nil
                    F.exitDoorLastMapName = nil
                    F.exitDoorCurrentMap = nil
                    F.exitDoorSpawnPart = nil
                    F.exitDoorTweenDone = false
                    F.exitDoorTimerNotified = false
                    task.wait(0.5)
                else
                    if F.exitDoorCurrentMap ~= mapModel then
                        F.exitDoorCurrentMap = mapModel
                        F.exitDoorLastMapName = mapName
                        F.exitDoorGameStartAt = nil
                        F.exitDoorMapAppearedAt = nil
                        F.exitDoorTweenDone = false
                        F.exitDoorTimerNotified = false
                        local spawnP, spawnF = findSurvivorSpawnPart(mapModel)
                        F.exitDoorSpawnPart = spawnP
                    end
                    if not F.exitDoorSpawnPart or not F.exitDoorSpawnPart.Parent then
                        local spawnP2, _ = findSurvivorSpawnPart(mapModel)
                        F.exitDoorSpawnPart = spawnP2
                    end
                    if not F.exitDoorGameStartAt then
                        local atSpawn, _dist = isPlayerAtSpawn(F.exitDoorSpawnPart)
                        if atSpawn then
                            F.exitDoorGameStartAt = tick()
                            F.exitDoorMapAppearedAt = F.exitDoorGameStartAt
                        else
                            task.wait(0.3)
                        end
                    end
                    if not F.exitDoorGameStartAt then task.wait(0.2)
                    elseif F.exitDoorTweenDone then task.wait(1)
                    else
                        local left = getExitDoorTimeLeft()
                        if left and left > 0 then task.wait(0.5)
                        else
                            local trigger = findExitTrigger()
                            if not trigger then task.wait(0.5)
                            else
                                local targetPos = trigger.Position + Vector3.new(0, 3, 0)
                                local dist = (myHRP.Position - targetPos).Magnitude
                                if dist <= 3 then
                                    F.exitDoorTweenDone = true
                                    task.wait(1)
                                else
                                    local ok, duration = tweenHRPToExitDoor(targetPos)
                                    if ok then
                                        F.exitDoorTweenDone = true
                                        task.wait((duration or 1) + 0.3)
                                    else task.wait(0.5) end
                                end
                            end
                        end
                    end
                end
            end
        end
        F.autoExitDoorThread = nil
    end)
end

local function stopAutoExitDoor()
    F["auto exit door"] = false
    F.autoExitDoorRunning = false
    if F.autoExitDoorTween then pcall(function() F.autoExitDoorTween:Cancel() end) F.autoExitDoorTween = nil end
    if F.autoExitDoorThread then pcall(function() task.cancel(F.autoExitDoorThread) end) F.autoExitDoorThread = nil end
    local myChar = LocalPlayer.Character
    if myChar then for _, v in ipairs(myChar:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end end end
end

local function doTpVotingPlace()
    if selfIsKiller() then return end
    if isKillerExists() then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local lobby = Workspace:FindFirstChild("_Lobby")
    if not lobby then return end
    local voting = findChildCaseInsensitive(lobby, "MapVoting")
    if not voting then voting = findChildCaseInsensitive(lobby, "MapVoiting") end
    if not voting then voting = findDescendantCaseInsensitive(lobby, "MapVoting") end
    if not voting then voting = findDescendantCaseInsensitive(lobby, "MapVoiting") end
    if not voting then return end
    local mapName = "Map" .. tostring(F.votingPlace or "1")
    local mapFolder = findChildCaseInsensitive(voting, mapName)
    if not mapFolder then mapFolder = findDescendantCaseInsensitive(voting, mapName) end
    if not mapFolder then return end
    local trigger = findChildCaseInsensitive(mapFolder, "Trigger")
    if not trigger then trigger = findDescendantCaseInsensitive(mapFolder, "Trigger") end
    if not trigger then return end
    local targetCF = nil
    if trigger:IsA("BasePart") then targetCF = trigger.CFrame
    else local okPivot, pivot = pcall(function() return trigger:GetPivot() end) if okPivot and pivot then targetCF = pivot else for _, part in ipairs(trigger:GetDescendants()) do if part:IsA("BasePart") then targetCF = part.CFrame break end end end end
    if not targetCF then return end
    pcall(function() myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0) myHRP.CFrame = targetCF end)
end

local function startAutoVoting()
    F["start auto voting"] = true
    if F.autoVotingConn then return end
    F.autoVotingConn = LocalPlayer.CharacterAdded:Connect(function(char)
        if not F["start auto voting"] then return end
        if selfIsKiller() then return end
        if isKillerExists() then return end
        task.wait(0.5)
        if not F["start auto voting"] then return end
        if selfIsKiller() then return end
        if isKillerExists() then return end
        local hum = char:WaitForChild("Humanoid", 3)
        if not hum then return end
        if hum.Health > 0 then doTpVotingPlace() end
    end)
end

local function stopAutoVoting()
    F["start auto voting"] = false
    if F.autoVotingConn then pcall(function() F.autoVotingConn:Disconnect() end) F.autoVotingConn = nil end
    if F.autoVotingThread then pcall(function() task.cancel(F.autoVotingThread) end) F.autoVotingThread = nil end
end

local function getKillerHead()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if checkKiller(plr) then
            local kc = Workspace:FindFirstChild(plr.Name) or plr.Character
            if kc then
                local head = kc:FindFirstChild("Head")
                if head then return head end
                local hrp = kc:FindFirstChild("HumanoidRootPart")
                if hrp then return hrp end
            end
        end
    end
    return nil
end

local function getKillerHumanoid()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if checkKiller(plr) then
            local kc = Workspace:FindFirstChild(plr.Name) or plr.Character
            if kc then
                local hum = kc:FindFirstChildOfClass("Humanoid")
                if hum then return hum, kc, plr end
            end
        end
    end
    return nil, nil, nil
end

local function setSpectateKiller()
    if selfIsKiller() then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local killerHum, killerChar, killerPlr = getKillerHumanoid()
    if killerHum and killerPlr ~= LocalPlayer then
        pcall(function() cam.CameraSubject = killerHum cam.CameraType = Enum.CameraType.Custom end)
    else
        local killerHead = getKillerHead()
        if killerHead then pcall(function() cam.CameraSubject = killerHead cam.CameraType = Enum.CameraType.Custom end) end
    end
end

local function saveLootSpawns()
    local lootSpawns = findLootSpawns()
    if not lootSpawns then return end
    for _, part in ipairs(lootSpawns:GetDescendants()) do
        if part:IsA("BasePart") then
            if F.savedLootSpawns[part] == nil then F.savedLootSpawns[part] = { CFrame = part.CFrame, Anchored = part.Anchored, CanCollide = part.CanCollide } end
        end
    end
end

local function lockLootSpawns()
    local lootSpawns = findLootSpawns()
    if not lootSpawns then return end
    for _, part in ipairs(lootSpawns:GetDescendants()) do
        if part:IsA("BasePart") then
            if F.savedLootSpawns[part] == nil then F.savedLootSpawns[part] = { CFrame = part.CFrame, Anchored = part.Anchored, CanCollide = part.CanCollide } end
            pcall(function() part.Anchored = true part.CanCollide = true part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) part.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end)
        end
    end
end

local function restoreLootSpawns()
    for part, data in pairs(F.savedLootSpawns) do
        if part and part.Parent then pcall(function() part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) part.AssemblyAngularVelocity = Vector3.new(0, 0, 0) part.CFrame = data.CFrame part.Anchored = data.Anchored part.CanCollide = data.CanCollide end) end
    end
    F.savedLootSpawns = {}
end

local function isKillerKnifeModel(plr)
    if not plr then return false end
    local function hasKnifeModelIn(inst)
        if not inst then return false end
        local direct = inst:FindFirstChild("Knife", true)
        if direct and direct:IsA("Model") then return true end
        for _, desc in ipairs(inst:GetDescendants()) do
            if desc.Name == "Knife" and desc:IsA("Model") then return true end
        end
        return false
    end
    local char = plr.Character or Workspace:FindFirstChild(plr.Name)
    if char and hasKnifeModelIn(char) then return true end
    local char2 = Workspace:FindFirstChild(plr.Name)
    if char2 and char2 ~= char and hasKnifeModelIn(char2) then return true end
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then for _, desc in ipairs(backpack:GetDescendants()) do if desc.Name == "Knife" and (desc:IsA("Model") or desc:IsA("Tool")) then return true end end end
    if checkKiller(plr) then return true end
    return false
end

local function getKillerForSelfRevive()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isKillerKnifeModel(plr) then
            local kc = plr.Character or Workspace:FindFirstChild(plr.Name)
            if not kc then continue end
            local khrp = kc:FindFirstChild("HumanoidRootPart")
            if khrp then return khrp.Position, plr, khrp end
            local okPivot, pivot = pcall(function() return kc:GetPivot() end)
            if okPivot and pivot then return pivot.Position, plr, nil end
        end
    end
    return nil, nil, nil
end

local function getKillerPosForRevive()
    local pos1, _, hrp1 = getKillerForSelfRevive()
    if pos1 then return pos1, hrp1 end
    local ok, pos2, plr2 = pcall(function() return getKillerPosition() end)
    if ok and pos2 then
        if plr2 then
            local kc2 = Workspace:FindFirstChild(plr2.Name) or plr2.Character
            local hrp2 = kc2 and kc2:FindFirstChild("HumanoidRootPart")
            return pos2, hrp2
        end
        return pos2, nil
    end
    return nil, nil
end

local function getTargetTorso(char)
    if not char then return nil end
    local t = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso")
    if t and t:IsA("BasePart") then return t end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function getPlayerChar(plr)
    return Workspace:FindFirstChild(plr.Name) or plr.Character
end

local function isHitAudio(char)
    if not char then return false end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Sound") and v.Playing then return true end
    end
    return false
end

local function isInAutoReviveList(name)
    for _, n in ipairs(F.autoReviveList) do if n == name then return true end end
    return false
end

local function getHorizontalDist(a, b)
    return (Vector2.new(a.X, a.Z) - Vector2.new(b.X, b.Z)).Magnitude
end

local function findFarthestPlayerForSelfRevive(myHRP, killerPos)
    local bestInRangeSafe = nil
    local bestInRangeSafeDist = -1
    local bestInRange = nil
    local bestInRangeDist = -1
    local bestAnySafe = nil
    local bestAnySafeDist = -1
    local bestAny = nil
    local bestAnyDist = -1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isKillerKnifeModel(plr) then continue end
        local c = getPlayerChar(plr)
        if not c then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then continue end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local d = (hrp.Position - myHRP.Position).Magnitude
        if d < 1 then continue end
        local safeFromKiller = true
        if killerPos then if getHorizontalDist(hrp.Position, killerPos) < 10 then safeFromKiller = false end end
        if d > bestAnyDist then bestAnyDist = d bestAny = hrp end
        if safeFromKiller and d > bestAnySafeDist then bestAnySafeDist = d bestAnySafe = hrp end
        if d <= 300 then
            if d > bestInRangeDist then bestInRangeDist = d bestInRange = hrp end
            if safeFromKiller and d > bestInRangeSafeDist then bestInRangeSafeDist = d bestInRangeSafe = hrp end
        end
    end
    if bestInRangeSafe then return bestInRangeSafe end
    if bestInRange then return bestInRange end
    if bestAnySafe then return bestAnySafe end
    return bestAny
end

local function doSelfReviveTP(myHRP, targetHRP)
    if not myHRP or not targetHRP then return false end
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then pcall(function() myHum.PlatformStand = false end) end
    F.lastSelfReviveTPTime = tick()
    local tpStart = tick()
    while tick() - tpStart < 0.6 do
        local curChar = LocalPlayer.Character
        local curHRP = curChar and curChar:FindFirstChild("HumanoidRootPart")
        if not curHRP then break end
        if not targetHRP or not targetHRP.Parent then break end
        local targetCF = targetHRP.CFrame * CFrame.new(0, 1, -3)
        pcall(function() curHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0) curHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0) curHRP.CFrame = targetCF end)
        task.wait()
    end
    local curChar2 = LocalPlayer.Character
    local curHRP2 = curChar2 and curChar2:FindFirstChild("HumanoidRootPart")
    if curHRP2 and targetHRP and targetHRP.Parent then pcall(function() curHRP2.AssemblyLinearVelocity = Vector3.new(0, 0, 0) curHRP2.AssemblyAngularVelocity = Vector3.new(0, 0, 0) curHRP2.CFrame = targetHRP.CFrame * CFrame.new(0, 1, -3) end) end
    F.lastSelfReviveTPTime = tick()
    return true
end

local function startAutoSelfRevive()
    F["auto self revive"] = true
    if F.autoSelfReviveThread then return end
    F.autoSelfReviveThread = task.spawn(function()
        local lastTP = 0
        while F["auto self revive"] do
            if selfIsKiller() or isKillerKnifeModel(LocalPlayer) then task.wait(0.2)
            elseif F.selfReviveWaiting then task.wait(0.05)
            elseif F.autoReviveLooping then task.wait(0.1)
            else
                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local killerPos, killerHRP = getKillerPosForRevive()
                if not myHRP or not killerPos then task.wait(0.05)
                else
                    local distToKiller = getHorizontalDist(myHRP.Position, killerPos)
                    if distToKiller <= 2 and tick() - lastTP > 3 then
                        F.selfReviveWaiting = true
                        task.wait(0.1)
                        local myChar2 = LocalPlayer.Character
                        local myHRP2 = myChar2 and myChar2:FindFirstChild("HumanoidRootPart")
                        local kp2, _ = getKillerPosForRevive()
                        if myHRP2 then
                            local targetHRP = findFarthestPlayerForSelfRevive(myHRP2, kp2)
                            if targetHRP then doSelfReviveTP(myHRP2, targetHRP) lastTP = tick() end
                        end
                        F.selfReviveWaiting = false
                    else task.wait(0.05) end
                end
            end
        end
        F.autoSelfReviveThread = nil
    end)
end

local function stopAutoSelfRevive()
    F["auto self revive"] = false
    F.selfReviveWaiting = false
    if F.autoSelfReviveThread then pcall(function() task.cancel(F.autoSelfReviveThread) end) F.autoSelfReviveThread = nil end
end

local function getReviveLidarHeight(torsoPos, desiredHeight, targetChar)
    if not torsoPos then return 11 end
    local maxH = 11
    local origin = torsoPos + Vector3.new(0, 0.5, 0)
    local dir = Vector3.new(0, 20, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {}
    if LocalPlayer.Character then table.insert(params.FilterDescendantsInstances, LocalPlayer.Character) end
    if targetChar then table.insert(params.FilterDescendantsInstances, targetChar) end
    params.IgnoreWater = true
    local ok, result = pcall(function() return Workspace:Raycast(origin, dir, params) end)
    if not ok or not result then return maxH end
    local distToCeil = result.Distance + 0.5
    if distToCeil > maxH then return maxH end
    local fitted = distToCeil - 1
    if fitted < 2 then fitted = 2 end
    if fitted > maxH then fitted = maxH end
    return fitted
end

local function startAutoRevive()
    F["auto revive"] = true
    if F.autoReviveThread then return end
    F.autoReviveThread = task.spawn(function()
        while F["auto revive"] do
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then task.wait(0.2)
            elseif selfIsKiller() or isKillerKnifeModel(LocalPlayer) then F.autoReviveList = {} F.autoReviveLocked = {} F.autoReviveLooping = false task.wait(0.5)
            else
                if not F.autoReviveLooping then F.autoReviveLastPlace = myHRP.CFrame end
                local killerPos, killerHRP = getKillerPosForRevive()
                if killerPos then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr == LocalPlayer then continue end
                        if isKillerKnifeModel(plr) then continue end
                        if isInAutoReviveList(plr.Name) then continue end
                        if F.autoReviveLocked[plr.Name] then continue end
                        local savedAt = F.autoReviveSaved[plr.Name]
                        local scanChar = getPlayerChar(plr)
                        local scanHit = isHitAudio(scanChar)
                        if scanHit then F.autoReviveHit[plr.Name] = tick() end
                        if savedAt and tick() - savedAt < 10 and not scanHit then continue end
                        if savedAt and tick() - savedAt >= 10 then F.autoReviveSaved[plr.Name] = nil end
                        local c = getPlayerChar(plr)
                        if not c then continue end
                        local torso = getTargetTorso(c)
                        if not torso then continue end
                        local d = getHorizontalDist(torso.Position, killerPos)
                        if d <= 3 then
                            table.insert(F.autoReviveList, plr.Name)
                            F.autoReviveLocked[plr.Name] = { addedAt = tick(), lastPos = torso.Position }
                        end
                    end
                end
                if #F.autoReviveList == 0 then task.wait(0.2)
                else
                    F.autoReviveLooping = true
                    local returnCF = F.autoReviveLastPlace
                    local reviveIndex = 0
                    while #F.autoReviveList > 0 and F["auto revive"] do
                        if selfIsKiller() or isKillerKnifeModel(LocalPlayer) then F.autoReviveList = {} F.autoReviveLocked = {} break end
                        local targetName = F.autoReviveList[1]
                        reviveIndex = reviveIndex + 1
                        local hitChar0 = getPlayerChar(Players:FindFirstChild(targetName))
                        local hitAgain = F.autoReviveHit[targetName] ~= nil or isHitAudio(hitChar0)
                        local remaining = 5.5
                        local reviveHeight = 10
                        if hitAgain then remaining = 3.5 reviveHeight = 11 end
                        if reviveIndex == 1 and not hitAgain then remaining = 3.5 end
                        local jumpChar = LocalPlayer.Character
                        local jumpHum = jumpChar and jumpChar:FindFirstChildOfClass("Humanoid")
                        if jumpHum then pcall(function() jumpHum.Jump = true jumpHum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
                        task.wait(0.15)
                        local lastTick = tick()
                        while remaining > 0 and F["auto revive"] do
                            local targetPlr = Players:FindFirstChild(targetName)
                            if not targetPlr then task.wait(0.1) lastTick = tick() continue end
                            local c2 = getPlayerChar(targetPlr)
                            if not c2 then task.wait(0.1) lastTick = tick() continue end
                            local torso2 = getTargetTorso(c2)
                            if not torso2 or not torso2.Parent then task.wait(0.1) lastTick = tick() continue end
                            local hum2 = c2:FindFirstChildOfClass("Humanoid")
                            if hum2 and hum2.Health <= 0 then break end
                            if F.autoReviveLocked[targetName] then F.autoReviveLocked[targetName].lastPos = torso2.Position end
                            local kPos2, _ = getKillerPosForRevive()
                            if kPos2 then
                                local dKillerToTarget = getHorizontalDist(torso2.Position, kPos2)
                                if dKillerToTarget <= 5 then task.wait(0.1) lastTick = tick() continue end
                            end
                            local myChar2 = LocalPlayer.Character
                            local myHRP2 = myChar2 and myChar2:FindFirstChild("HumanoidRootPart")
                            if not myHRP2 then task.wait(0.1) lastTick = tick() continue end
                            if isHitAudio(c2) then F.autoReviveHit[targetName] = tick() reviveHeight = 11 if remaining > 3.5 then remaining = 3.5 end end
                            local lidarHeight = getReviveLidarHeight(torso2.Position, 11, c2)
                            local targetPos = torso2.Position + Vector3.new(0, lidarHeight, 0)
                            pcall(function() myHRP2.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRP2.AssemblyAngularVelocity = Vector3.new(0, 0, 0) myHRP2.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0) end)
                            local now = tick()
                            local dt = now - lastTick
                            lastTick = now
                            if dt > 0 and dt < 1 then remaining = remaining - dt end
                            task.wait()
                        end
                        F.autoReviveSaved[targetName] = tick()
                        local endChar = getPlayerChar(Players:FindFirstChild(targetName))
                        if not isHitAudio(endChar) then F.autoReviveHit[targetName] = nil end
                        F.autoReviveLocked[targetName] = nil
                        table.remove(F.autoReviveList, 1)
                    end
                    F.autoReviveLooping = false
                    if F["auto revive"] and returnCF then
                        local myChar3 = LocalPlayer.Character
                        local myHRP3 = myChar3 and myChar3:FindFirstChild("HumanoidRootPart")
                        if myHRP3 then pcall(function() myHRP3.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRP3.AssemblyAngularVelocity = Vector3.new(0, 0, 0) myHRP3.CFrame = returnCF end) end
                    end
                    task.wait(0.2)
                end
            end
        end
        F.autoReviveThread = nil
    end)
end

local function stopAutoRevive()
    F["auto revive"] = false
    if F.autoReviveThread then pcall(function() task.cancel(F.autoReviveThread) end) F.autoReviveThread = nil end
    F.autoReviveLooping = false
    F.autoReviveList = {}
    F.autoReviveSaved = {}
    F.autoReviveLocked = {}
    F.autoReviveHit = {}
end

local function startAutoCollectLoot()
    if selfIsKiller() then F["auto loot"] = false return end
    F["auto loot"] = true
    F.snakeCamera = false
    if F.autoLootThread then return end
    F.autoLootSpawnTouched = false
    F.autoLootCurrentMap = nil
    F.autoLootSpawnPart = nil
    F.autoLootThread = task.spawn(function()
        while F["auto loot"] and not F.autoLootSpawnTouched do
            if selfIsKiller() then break end
            local mapModel, mapName = findMapModelInWorkspace()
            if not mapModel then
                F.autoLootCurrentMap = nil
                F.autoLootSpawnPart = nil
                F.autoLootSpawnTouched = false
                task.wait(0.5)
            else
                if F.autoLootCurrentMap ~= mapModel then
                    F.autoLootCurrentMap = mapModel
                    F.autoLootSpawnTouched = false
                    local spawnP, _ = findSurvivorSpawnPart(mapModel)
                    F.autoLootSpawnPart = spawnP
                end
                if not F.autoLootSpawnPart or not F.autoLootSpawnPart.Parent then
                    local spawnP2, _ = findSurvivorSpawnPart(mapModel)
                    F.autoLootSpawnPart = spawnP2
                end
                local atSpawn, _ = isPlayerAtSpawn(F.autoLootSpawnPart)
                if atSpawn then
                    F.autoLootSpawnTouched = true
                    break
                else
                    task.wait(0.3)
                end
            end
        end
        if not F["auto loot"] then F.autoLootThread = nil return end
        if selfIsKiller() then F["auto loot"] = false F.autoLootThread = nil return end
        if not F.autoLootSpawnTouched then F.autoLootThread = nil return end
        F.savedAutoLootGravity = Workspace.Gravity
        Workspace.Gravity = 0
        saveLootSpawns()
        lockLootSpawns()
        local cam = Workspace.CurrentCamera
        if cam then F.savedCameraCF = cam.CFrame F.savedCameraType = cam.CameraType F.savedCameraSubject = cam.CameraSubject end
        setSpectateKiller()
        local myCharStart = LocalPlayer.Character
        local myHRPStart = myCharStart and myCharStart:FindFirstChild("HumanoidRootPart")
        local myHumStart = myCharStart and myCharStart:FindFirstChildOfClass("Humanoid")
        if myHumStart then pcall(function() myHumStart.PlatformStand = true end) end
        if myHRPStart then pcall(function() myHRPStart.CFrame = myHRPStart.CFrame * CFrame.Angles(math.rad(90), 0, 0) end) end
        while F["auto loot"] do
            if selfIsKiller() then break end
            if tick() - F.lastSelfReviveTPTime < 1 then task.wait(0.1)
            elseif F.autoReviveLooping then task.wait(0.1)
            else
                local lootSpawns = findLootSpawns()
                if not lootSpawns then task.wait(0.05)
                else
                    local myChar = LocalPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if not myHRP then task.wait(0.1)
                    else
                        local foundAny = false
                        for _, spawnPart in ipairs(lootSpawns:GetChildren()) do
                            if not F["auto loot"] then break end
                            if selfIsKiller() then break end
                            if tick() - F.lastSelfReviveTPTime < 1 then break end
                            if F.autoReviveLooping then break end
                            local targetPart = nil
                            for _, inner in ipairs(spawnPart:GetDescendants()) do if inner:IsA("BasePart") then targetPart = inner break end end
                            if targetPart == nil then if spawnPart:IsA("BasePart") then targetPart = spawnPart end end
                            if targetPart == nil then continue end
                            local lootSpawnCF = nil
                            if spawnPart:IsA("BasePart") then lootSpawnCF = spawnPart.CFrame else local okPivot, pivot = pcall(function() return spawnPart:GetPivot() end) if okPivot and pivot then lootSpawnCF = pivot else lootSpawnCF = targetPart.CFrame end end
                            local killerPos2 = getKillerPosition()
                            if killerPos2 and (lootSpawnCF.Position - killerPos2).Magnitude < 10 then continue end
                            foundAny = true
                            setSpectateKiller()
                            local partTargetCF = lootSpawnCF * CFrame.new(0, -2, 0) * CFrame.Angles(math.rad(90), 0, 0)
                            pcall(function() targetPart.Anchored = true targetPart.CanCollide = true targetPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) targetPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0) targetPart.CFrame = partTargetCF end)
                            local loopStart = tick()
                            while F["auto loot"] and targetPart and targetPart.Parent do
                                if selfIsKiller() then break end
                                if tick() - F.lastSelfReviveTPTime < 1 then break end
                                if F.autoReviveLooping then break end
                                local myCharLoop = LocalPlayer.Character
                                local myHRPLoop = myCharLoop and myCharLoop:FindFirstChild("HumanoidRootPart")
                                if not myHRPLoop then break end
                                pcall(function() myHRPLoop.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRPLoop.AssemblyAngularVelocity = Vector3.new(0, 0, 0) myHRPLoop.CFrame = partTargetCF end)
                                if tick() - loopStart > 0.05 then break end
                                task.wait()
                            end
                            if firetouchinterest then pcall(function() firetouchinterest(myHRP, targetPart, 0) firetouchinterest(myHRP, targetPart, 1) end) end
                            for _, prompt in ipairs(targetPart:GetDescendants()) do if prompt:IsA("ProximityPrompt") then if fireproximityprompt then pcall(function() fireproximityprompt(prompt) end) end end end
                            for _, prompt in ipairs(spawnPart:GetDescendants()) do if prompt:IsA("ProximityPrompt") then if fireproximityprompt then pcall(function() fireproximityprompt(prompt) end) end end end
                            task.wait(0.05)
                        end
                        if not foundAny then task.wait(0.05) end
                    end
                end
                task.wait(0.05)
            end
        end
        F.autoLootThread = nil
        if selfIsKiller() then stopCloneAutoLoot() end
    end)
end

local function stopCloneAutoLoot()
    F["auto loot"] = false
    F.snakeCamera = false
    F.autoLootSpawnTouched = false
    F.autoLootCurrentMap = nil
    F.autoLootSpawnPart = nil
    if F.autoLootThread then pcall(function() task.cancel(F.autoLootThread) end) F.autoLootThread = nil end
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then pcall(function() myHum.PlatformStand = false end) end
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHRP then pcall(function() myHRP.CFrame = CFrame.new(myHRP.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0, myHRP.CFrame.Rotation.Y, 0) myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0) myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end) end
    if F.savedAutoLootGravity ~= nil then Workspace.Gravity = F.savedAutoLootGravity F.savedAutoLootGravity = nil end
    local curCam = Workspace.CurrentCamera
    if curCam then pcall(function() if F.savedCameraSubject then curCam.CameraSubject = F.savedCameraSubject end if F.savedCameraType then curCam.CameraType = F.savedCameraType end if F.savedCameraCF then curCam.CFrame = F.savedCameraCF end end) end
    F.savedCameraCF = nil
    F.savedCameraType = nil
    F.savedCameraSubject = nil
    restoreLootSpawns()
end

local function stopDesyncSystem()
    stopCloneAutoLoot()
end

local function doServerHop()
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not result then return end
    local decoded = safeJSONDecode(result)
    if not decoded or not decoded.data then return end
    local candidates = {}
    for _, server in ipairs(decoded.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId and (server.fps or 0) >= 40 then
            table.insert(candidates, server)
        end
    end
    if #candidates == 0 then return end
    table.sort(candidates, function(a, b)
        return (a.fps or 0) > (b.fps or 0)
    end)
    local target = candidates[1]
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
    end)
end

local function doRejoin()
    local placeId = game.PlaceId
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, game.JobId, LocalPlayer)
    end)
end

local version = ": 1.1"
local MacUI = nil
local macUIUrl = "https://raw.githubusercontent.com/Ngducok/MacUI-luau/main/dist/MacUI.luau"
for _try = 1, 3 do
    local okHttp, src = pcall(function() return game:HttpGet(macUIUrl) end)
    if okHttp and src and src ~= "" then
        local okLoad, loaded = pcall(function() return loadstring(src)() end)
        if okLoad and loaded then MacUI = loaded break end
    end
    task.wait(1)
end
if not MacUI then warn("[Renuxhub] ui library failed load") return end
Window = MacUI:CreateWindow({
    Size = UDim2.fromOffset(40, 62.5),
    ToggleKey = Enum.KeyCode.RightShift,
    ReducedMotion = false,
    Acrylic = true,
    Account = { Enabled = false },
    Scale = 0.7,
    AutoScale = false
})

local information = Window:AddPage({ Id = "information", Title = "information", Icon = "rbxassetid://97392696311902" })

local isolator1 = information:AddSection({ Title = "information" })

local main1 = isolator1:AddCard({
    Id = "information-script", Title = "information script", Description = "support the script and version script",
    Icon = "rbxassetid://97392696311902"
})

main1:AddDivider()
main1:AddLabel({ Title = "Renux hub version" .. version })
main1:AddDivider({})
main1:AddLabel({ Title = "discord Renux hub" })
main1:AddButton({
    Title = "copy link",
    Callback = function()
        (setclipboard or toclipboard)("https://discord.gg/mXnTVYYYsy")
        Window:Notify({ Title = "info copy", Content = "success copy link discord", Kind = "success", Duration = 3 })
    end
})

local isolator2 = information:AddSection({ Title = "change logs" })

local main2 = isolator2:AddCard({
    Id = "changelogs", Title = "change logs", Description = "view change logs update this script",
    Icon = "rbxassetid://89601995828423"
})

main2:AddDivider()
main2:AddParagraph({ Content = "• release game survive the killer" })

local maingame = Window:AddPage({ Id = "script", Title = "main", Icon = "rbxassetid://98755624629571" })

local isolator3 = maingame:AddSection({ Title = "main game" })

local main3 = isolator3:AddCard({
    Id = "main-feature", Title = "feature script", Description = "feature script in game",
    Icon = "rbxassetid://98755624629571"
})

main3:AddDivider()
AvoidKillerDistanceInput = main3:AddInput({
    Id = "avoid-killer-distance", Title = "avoid killer distance", Default = "25",
    Placeholder = "Enter distance in studs", Width = 190, Clearable = true,
    Validate = function(text)
        if text == "" then return true end
        local num = tonumber(text)
        if not num then return "Enter number only" end
        if num < 1 or num > 300 then return "Use 1 - 300 studs" end
        return true
    end,
    Callback = function(text) local num = tonumber(text) if num then F.avoidKillerDistance = math.clamp(num, 1, 300) end end,
    OnSubmit = function(text) local num = tonumber(text) if num then F.avoidKillerDistance = math.clamp(num, 1, 300) end end,
})

votingPlaceDropdown = main3:AddDropdown({
    Id = "select-voting-place", Title = "select voting place", Width = 160, Searchable = false,
    Options = {"1", "2", "3"}, Default = "1",
    Callback = function(value)
        local sel = value
        if type(value) == "table" then sel = value.Value or value.Label
        elseif type(value) == "number" then local opts = {"1", "2", "3"} sel = opts[value] or tostring(value) end
        if sel then F.votingPlace = tostring(sel) end
        if F["start auto voting"] then doTpVotingPlace() end
    end
})

main3:AddDivider()
espToggle = main3:AddToggle({
    Id = "esp-player-killer", Title = "esp player/killer", Default = false,
    Callback = function(value) F["esp"] = value if value then startESPHeartbeat() end end
})

avoidKillerToggle = main3:AddToggle({
    Id = "avoid-killer", Title = "avoid killer", Default = false,
    Callback = function(value) F["avoid killer"] = value if value then startAvoidKiller() else stopAvoidKiller() end end
})

startAutoVotingToggle = main3:AddToggle({
    Id = "start-auto-voting", Title = "start auto voting", Default = false,
    Callback = function(value) F["start auto voting"] = value if value then startAutoVoting() doTpVotingPlace() else stopAutoVoting() end end
})

local isolator4 = maingame:AddSection({ Title = "universal", Icon = "rbxassetid://114238209622913" })

local main4 = isolator4:AddCard({
    Id = "universal", Title = "universal feature", Description = "universal feature script in game",
    Icon = "rbxassetid://114238209622913"
})

main4:AddDivider()
fullbrightToggle = main4:AddToggle({
    Id = "fullbright", Title = "fullbright", Default = false,
    Callback = function(value) F["fullbright"] = value if value then enableFullbright() else disableFullbright() end end
})

noclipToggle = main4:AddToggle({
    Id = "noclip", Title = "noclip", Default = false,
    Callback = function(value) F["noclip"] = value if value then startNoclip() else stopNoclip() end end
})

xrayToggle = main4:AddToggle({
    Id = "x-ray", Title = "x ray", Default = false,
    Callback = function(value) if value then enableXray() else disableXray() end end
})

local farmingPage = Window:AddPage({ Id = "farming", Title = "farming", Icon = "rbxassetid://100091687832508" })

local isolator5 = farmingPage:AddSection({ Title = "farming" })

local main5 = isolator5:AddCard({
    Id = "farming-system", Title = "farming system", Description = "farming system automatic",
    Icon = "rbxassetid://100091687832508"
})

main5:AddDivider()
killAllToggle = main5:AddToggle({
    Id = "kill-all", Title = "kill all", Default = false,
    Callback = function(value) F["kill all"] = value if value then bringKillAll(CFrame.new(0, 0, -3)) end end
 })

autoCollectLootToggle = main5:AddToggle({
    Id = "auto-loot", Title = "auto loot", Default = false,
    Callback = function(value)
        F["auto loot"] = value
        if value then
            startAutoCollectLoot()
        else
            stopCloneAutoLoot()
        end
    end
 })

autoExitDoorToggle = main5:AddToggle({
    Id = "auto-exit-door", Title = "auto exit door", Default = false,
    Callback = function(value) F["auto exit door"] = value if value then startAutoExitDoor() else stopAutoExitDoor() end end
})

main5:AddDivider()
main5:AddLabel({ Title = "unstable feature" })
autoSelfReviveToggle = main5:AddToggle({
    Id = "auto-self-revive", Title = "auto self revive", Default = false,
    Callback = function(value)
        F["auto self revive"] = value
        if value then
            startAutoSelfRevive()
        else
            stopAutoSelfRevive()
        end
    end
 })

autoReviveToggle = main5:AddToggle({
    Id = "auto-revive", Title = "auto revive", Default = false,
    Callback = function(value)
        F["auto revive"] = value
        if value then
            startAutoRevive()
        else
            stopAutoRevive()
        end
    end
 })

local miscPage = Window:AddPage({ Id = "misc", Title = "miscellaneous", Icon = "rbxassetid://136372617578355" })

local isolator6 = miscPage:AddSection({ Title = "player" })

local main6 = isolator6:AddCard({
    Id = "player-settings", Title = "player settings", Description = "player settings movement and others",
    Icon = "rbxassetid://81589895647169"
})

main6:AddDivider()
enableWalkSpeedToggle = main6:AddToggle({
    Id = "enable-walkspeed", Title = "enable walk speed", Default = false,
    Callback = function(value) F["walkspeed"] = value if value then startMovementLoop() else resetWalkSpeedOnce() stopMovementLoopIfNeeded() end end
})

walkspeedSlider = main6:AddSlider({
    Id = "walkspeed", Title = "Walk Speed", Min = 10, Max = 125, Default = 16, Step = 1,
    Callback = function(value) F.walkspeedValue = value if F["walkspeed"] then startMovementLoop() end end,
})

enableJumpPowerToggle = main6:AddToggle({
    Id = "enable-jumppower", Title = "enable jump power", Default = false,
    Callback = function(value) F["jumppower"] = value if value then startMovementLoop() else resetJumpPowerOnce() stopMovementLoopIfNeeded() end end
})

jumppowerSlider = main6:AddSlider({
    Id = "jumppower", Title = "Jump Power", Min = 10, Max = 125, Default = 50, Step = 1,
    Callback = function(value) F.jumppowerValue = value if F["jumppower"] then startMovementLoop() end end,
})

main6:AddDivider()
infiniteJumpToggle = main6:AddToggle({
    Id = "infinite-jump", Title = "infinite jump", Default = false,
    Callback = function(value) F["infinite jump"] = value if value then enableInfiniteJump() else disableInfiniteJump() end end
})

antiVoidToggle = main6:AddToggle({
    Id = "anti-void", Title = "anti void", Default = false,
    Callback = function(value) F["anti void"] = value if value then startAntiVoid() else stopAntiVoid() end end
})

antiAfkToggle = main6:AddToggle({
    Id = "anti-afk", Title = "anti afk", Default = false,
    Callback = function(value) F["anti afk"] = value if value then enableAntiAFK() else disableAntiAFK() end end
})

local isolator7 = miscPage:AddSection({ Title = "game" })

local main7 = isolator7:AddCard({
    Id = "game-misc", Title = "game misc", Description = "feature game misc",
    Icon = "rbxassetid://92483947987410"
})

main7:AddDivider()
main7:AddButton({ Title = "to lobby", Callback = function() doToLobby() end })
main7:AddButton({ Title = "tp map", Callback = function() doTpMap() end })
-- auto exit door pindah ke farming di bawah auto loot

local serverPage = Window:AddPage({ Id = "server", Title = "server", Icon = "rbxassetid://92188766517878" })

local isolator8 = serverPage:AddSection({ Title = "server" })

local main8 = isolator8:AddCard({
    Id = "server-service", Title = "server service", Description = "server service feature",
    Icon = "rbxassetid://92188766517878"
})

main8:AddDivider()
main8:AddButton({ Title = "server hop", Callback = function() doServerHop() end })
main8:AddButton({ Title = "rejoin", Callback = function() doRejoin() end })

local settingPage = Window:AddPage({ Id = "setting", Title = "setting", Icon = "rbxassetid://80758916183665" })

local isolator9 = settingPage:AddSection({ Title = "setting" })

local main9 = isolator9:AddCard({
    Id = "setting-script", Title = "setting script", Description = "setting script config system",
    Icon = "rbxassetid://80758916183665"
})

main9:AddDivider()
configDropdown = main9:AddDropdown({
    Id = "list-config", Title = "list config", Width = 160, Searchable = false,
    Options = getConfigOptions(), Default = "None",
    Callback = function(value)
        local sel = value
        if type(value) == "table" then sel = value.Value or value.Label
        elseif type(value) == "number" then local opts = getConfigOptions() local opt = opts[value] if opt then sel = opt.Value else sel = "None" end end
        if sel == nil or sel == "None" or sel == "" then selectedConfigName = nil else selectedConfigName = sel end
    end
})

configNameInput = main9:AddInput({
    Id = "name-config", Title = "name config", Default = "",
    Placeholder = "Enter config name", Width = 190, Clearable = true,
    Validate = function(text) return true end,
    Callback = function(text) configNameText = text or "" end,
    OnSubmit = function(text) configNameText = text or "" end,
})

main9:AddButton({ Title = "save/create config", Callback = function() doSaveConfig() end })
main9:AddDivider()
main9:AddButton({ Title = "load config", Callback = function() doLoadConfig() end })
main9:AddButton({ Title = "delete config", Callback = function() doDeleteConfig() end })
main9:AddDivider()
autoSaveToggle = main9:AddToggle({
    Id = "auto-save", Title = "auto save", Default = false,
    Callback = function(value)
        if isApplyingConfig then F["auto save"] = value return end
        F["auto save"] = value
        saveMainData(F["auto save"])
        if value then lastAutoSaveJson = "" startAutoSaveLoop() pcall(function() doAutoSaveSilent() end) end
    end
})

local function initMainAutoSave()
    ensureConfigFolder()
    local exists = false
    pcall(function() exists = isfile("Renuxhub/stk/main.json") end)
    if not exists then saveMainData(false) end
    local mainData = getMainData()
    isApplyingConfig = true
    F["auto save"] = mainData["auto-save"] == true
    if autoSaveToggle then pcall(function() autoSaveToggle:SetValue(F["auto save"]) end) end
    isApplyingConfig = false
end
startConfigWatcher()
startAutoSaveLoop()
initMainAutoSave()
if F["auto exit door"] then task.spawn(function() task.wait(1) if F["auto exit door"] then startAutoExitDoor() end end) end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not F["noclip"] then applyNoclipOffState(char) end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    char.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") and not F["noclip"] then
            task.wait(0.05)
            if isAccessoryPart(v) then v.CanCollide = false end
        end
    end)
end)
