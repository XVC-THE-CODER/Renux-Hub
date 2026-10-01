local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local R = {
    murderEnabled = false,
    sheriffEnabled = false,
    innocentEnabled = false,
    espGunEnabled = false,
    espMaxDistance = 1000,
    killAuraEnabled = false,
    currentTarget = nil,
    killAllThread = nil,
    killAuraConn = nil,
    TP_RADIUS = 450,
    farmEnabled = false,
    farmPart = nil,
    platformPart = nil,
    farmConn = nil,
    farmSpeed = 3,
    savedParts = {},
    farmAddConn = nil,
    farmPausedByMurder = false,
    mapHREnabled = false,
    autoGetGunEnabled = false,
    autoGetGunThread = nil,
    loopGunEnabled = false,
    loopGunConn = nil,
    loopGunOffset = 35,
    loopGunPlatform = nil,
    mapHRGui = nil,
    mapHRAutoSaveConn = nil,
    mapHRSavedCFrame = nil,
    mapHRTPing = false,
    autoGetGunDisabledByDeath = false,
        mapHRList = {"Bank2","bank2","bank 2","bank_2","Bank 2","Bank_2","BioLab","biolab","bio lab","bio_lab","Bio Lab","Bio_Lab","Factory","factory","Hospital3","hospital3","hospital 3","hospital_3","Hospital 3","Hospital_3","Hotel2","hotel2","hotel 2","hotel_2","Hotel 2","Hotel_2","House2","house2","house 2","house_2","House 2","House_2","Mansion2","mansion2","mansion 2","mansion_2","Mansion 2","Mansion_2","MilBase","milbase","mil base","mil_base","Mil Base","Mil_Base","Office3","office3","office 3","office_3","Office 3","Office_3","PoliceStation","policestation","police station","police_station","Police Station","Police_Station","ResearchFacility","researchfacility","research facility","research_facility","Research Facility","Research_Facility","Workplace","workplace"},
    mapHRSet = {},
    avoidEnabled = false,
    avoidDistance = 25,
    avoidConn = nil,
    antiVoidEnabled = false,
    antiVoidConn = nil,
    lastSafePos = nil,
    lastSafePosString = nil,
    antiVoidLoop = nil,
    safePlatformPart = nil,
    walkSpeedEnabled = false,
    walkSpeedValue = 16,
    jumpEnabled = false,
    jumpValue = 50,
    movementConn = nil,
    noclipEnabled = false,
    noclipConnection = nil,
    infJumpEnabled = false,
    infJumpConn = nil,
    xrayEnabled = false,
    xrayConn = nil,
    xrayOriginal = {},
    xrayLoop = nil,
    fullbrightEnabled = false,
    fullbrightConn = nil,
    oldLighting = {},
    espData = {},
    espGunBox = nil,
    espGunBillboard = nil,
    espGunLoop = nil,
    espGunWasFound = false,
    espGunLastHrp = nil,
    aimbotMurderEnabled = true,
    aimbotSheriffEnabled = false,
    aimbotInnocentEnabled = false,
    aimbotEnabled = false,
    aimbotConn = nil,
    aimbotInfoGui = nil,
    aimbotInfoName = nil,
    aimbotInfoDist = nil,
    aimbotInfoConn = nil,
    aimbotCurrentTarget = nil,
    flingExecuted = false,
    trollMurderEnabled = false,
    trollMurderConn = nil,
    trollSheriffEnabled = false,
    trollSheriffConn = nil,
    votePadEnabled = false,
    votePadIndex = 1,
    votePadLoop = nil,
    votePadCharConn = nil,
    votePadTPed = false,
    startTime = tick(),
    fps = 0,
    frameCount = 0,
    lastFpsTick = tick(),
    lastPredictions = {},
    autoCoinWanted = false,
    autoCoinRoleConn = nil,
    autoCoinCheckLoop = nil,
    killAllOPEnabled = false,
    killAllOPConn = nil,
    killAllOPBringConn = nil,
    killAllOPFrozen = {},
    autoGetGunRefreshConn = nil,
    autoGetGunScanned = false,
    autoGetGunPartFound = nil,
    autoGetGunPartFound = nil,
    autoGetGunBringConn = nil,
    espGunDescConn = nil,
    espGunTextLoop = nil,
    espGunNotified = false,
    loopGunAutoRefresh = nil,
    loopGunToolCache = nil,
    killAllOPMurderCheck = nil,
    killAllOPAutoRefreshConn = nil,
}

R.toolCache = {hasGun = false, hasKnife = false, hasGunRead = false, hasKnifeRead = false}
R.toolRefreshConn = nil
R.toolRefreshActive = false
local function updateToolCache()
    local hasGun = hasTool(LocalPlayer, "gun")
    local hasKnife = hasTool(LocalPlayer, "knife")
    if hasGun then
        R.toolCache.hasGun = true
        R.toolCache.hasGunRead = true
    end
    if hasKnife then
        R.toolCache.hasKnife = true
        R.toolCache.hasKnifeRead = true
    end
    if not hasGun then
        R.toolCache.hasGun = false
    end
    if not hasKnife then
        R.toolCache.hasKnife = false
    end
end
local function startToolAutoRefresh()
    if R.toolRefreshActive then return end
    R.toolRefreshActive = true
    if R.toolRefreshConn then task.cancel(R.toolRefreshConn) end
    R.toolRefreshConn = task.spawn(function()
        while R.toolRefreshActive do
            updateToolCache()
            if R.toolCache.hasGun and R.toolCache.hasGunRead then
                if not hasTool(LocalPlayer, "gun") then
                else
                    if R.toolCache.hasKnife or not R.aimbotSheriffEnabled and not R.aimbotInnocentEnabled then
                    end
                end
            end
            if (R.toolCache.hasGunRead and R.toolCache.hasGun) and (R.toolCache.hasKnifeRead and R.toolCache.hasKnife or (not R.aimbotSheriffEnabled and not R.aimbotInnocentEnabled)) then
                if R.aimbotMurderEnabled and R.toolCache.hasGun then
                    R.toolRefreshActive = false
                    break
                end
                if (R.aimbotSheriffEnabled or R.aimbotInnocentEnabled) and R.toolCache.hasKnife then
                    R.toolRefreshActive = false
                    break
                end
            end
            if R.aimbotMurderEnabled and not R.aimbotSheriffEnabled and not R.aimbotInnocentEnabled then
                if R.toolCache.hasGunRead then
                    R.toolRefreshActive = false
                    break
                end
            end
            if (R.aimbotSheriffEnabled or R.aimbotInnocentEnabled) and not R.aimbotMurderEnabled then
                if R.toolCache.hasKnifeRead then
                    R.toolRefreshActive = false
                    break
                end
            end
            task.wait(0.5)
        end
        R.toolRefreshConn = nil
    end)
end
local function stopToolAutoRefresh()
    R.toolRefreshActive = false
    if R.toolRefreshConn then
        task.cancel(R.toolRefreshConn)
        R.toolRefreshConn = nil
    end
end

R.aimbotMurderEnabled = true
R.aimbotEnabled = false

task.spawn(function()
    while true do
        task.wait(1)
        if hasTool(LocalPlayer, "gun") then
            if not R.aimbotMurderEnabled then
                R.aimbotMurderEnabled = true
            end
            if not R.aimbotEnabled then
            end
        end
    end
end)

function isLocalMurder()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local ch = LocalPlayer.Character
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then
                return true
            end
        end
    end
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then
                return true
            end
        end
    end
    return false
end
function updateFarmByRole()
    if not R.autoCoinWanted then return end
    if isLocalMurder() then
        if R.farmEnabled then
            R.farmEnabled = false
            stopFarm()
        end
    else
        if not R.farmEnabled then
            R.farmEnabled = true
            R.farmPausedByMurder = false
            startFarm()
        end
    end
end

local library = nil
local attempts = 0
repeat
    pcall(function()
        loadstring(game:HttpGet("https://github.com/SCRIPTHUB-dev-god/User-Interface/releases/download/loader/wave-ui.lua"))()
        library = GetLibrary("latest")
    end)
    attempts = attempts + 1
    if not library then task.wait(0.5) end
until library or attempts > 20
if not library then
    warn("UI Library failed to load after 20 attempts")
    return
end
local window = library:CreateWindow({
    title = "Renux hub",
    desc = "Murder Mystery 2",
    opened = true,
    info = false,
    transparency = 0.12
})
pcall(function()
    window:AddTag({title = "keyless", canclicked = false, callback = function() end})
    window:AddTag({title = "made in indonesia", canclicked = false, callback = function() end})
    window:SetMovingText("script version 1.5")
end)
local InfoTab = library:CreateTab("Information")
local Tab = library:CreateTab("Main")
local MiscTab = library:CreateTab("Misc")
local AimbotTab = library:CreateTab("Aimbot")
local SettingTab = library:CreateTab("Setting")
local infoLeftGroup = InfoTab:CreateGroupBox("Invite", "left", "open")
local infoRightGroup = InfoTab:CreateGroupBox("Information", "right", "open")
local espGroup = Tab:CreateGroupBox("ESP", "left", "close")
local killGroup = Tab:CreateGroupBox("Murder", "right", "close")
local coinGroup = Tab:CreateGroupBox("Coin Farm", "left", "close")
local sheriffCounterGroup = Tab:CreateGroupBox("Sheriff", "right", "close")
local avoidGroup = Tab:CreateGroupBox("Avoid", "left", "close")
local votePadGroup = Tab:CreateGroupBox("auto Vote", "right", "close")
local miscGroup = MiscTab:CreateGroupBox("Option", "left", "close")
local movementGroup = MiscTab:CreateGroupBox("Movement", "right", "close")
local teleportGroup = MiscTab:CreateGroupBox("Teleport", "left", "close")
local utilityGroup = MiscTab:CreateGroupBox("Utility", "right", "close")
local aimbotGroup = AimbotTab:CreateGroupBox("Aimbot", "allside", "close")
local uiGroup = SettingTab:CreateGroupBox("UI", "allside", "open")
local function normalizeMapName(s)
    return string.lower(tostring(s)):gsub("_",""):gsub(" ",""):gsub("-","")
end
for _, n in ipairs(R.mapHRList) do R.mapHRSet[normalizeMapName(n)] = true end
local function isValidOffset()
    return R.loopGunOffset > R.avoidDistance
end
local function checkOffsetVsAvoid()
    if R.avoidEnabled and R.loopGunEnabled then
        if not isValidOffset() then
            pcall(function()
                library:Addnotification({title="Invalid Value", desc="TP Behind Murder distance must be greater than Avoid distance! Please change TP Behind Murder value or Avoid input.", duration=5})
            end)
        end
    end
end
RunService.RenderStepped:Connect(function()
    R.frameCount = R.frameCount + 1
    if tick() - R.lastFpsTick >= 1 then
        R.fps = R.frameCount
        R.frameCount = 0
        R.lastFpsTick = tick()
    end
end)
local function shortenName(name, maxLen)
    maxLen = maxLen or 10
    if #name > maxLen then
        return string.sub(name, 1, maxLen - 1).. "."
    else
        return name
    end
end
local function setNoclip(state)
    if state ~= nil then
        R.noclipEnabled = state
    else
        R.noclipEnabled = not R.noclipEnabled
    end
    if R.noclipEnabled then
        if not R.noclipConnection then
            R.noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if R.noclipConnection then
            R.noclipConnection:Disconnect()
            R.noclipConnection = nil
        end
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if part.Parent and part.Parent:IsA("Accessory") then
                        part.CanCollide = false
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.N then
        setNoclip()
    end
end)
getgenv().ToggleNoclip = setNoclip
local function hasTool(plr, keyword)
    keyword = string.lower(keyword)
    local bp = plr:FindFirstChild("Backpack")
    local ch = plr.Character
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), keyword) then
                return true
            end
        end
    end
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), keyword) then
                return true
            end
        end
    end
    return false
end
local function isAlive(plr)
    local ch = plr and plr.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end
local function hasKnifeInBackpack()
    return hasTool(LocalPlayer, "knife")
end
local function hasGunInBackpack()
    return hasTool(LocalPlayer, "gun")
end
local function getAnyAliveInTP()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - myHrp.Position).Magnitude <= R.TP_RADIUS then
                return plr
            end
        end
    end
    return nil
end
local function getNearestPlayer()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local near, md = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHrp.Position).Magnitude
                if d <= 250 and d < md then
                    md = d
                    near = plr
                end
            end
        end
    end
    return near
end
local function getMurderPlayer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and hasTool(plr, "knife") then
            return plr
        end
    end
    return nil
end
local function getSheriffPlayer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and hasTool(plr, "gun") then
            return plr
        end
    end
    return nil
end
local function isAnyPlayerHasTool()
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAlive(plr) and (hasTool(plr, "knife") or hasTool(plr, "gun")) then
            return true
        end
    end
    return false
end
local function isAllPlayersNoTool()
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAlive(plr) and (hasTool(plr, "knife") or hasTool(plr, "gun")) then
            return false
        end
    end
    return true
end
local function getInnocentPlayers()
    local arr = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not hasTool(plr, "knife") and not hasTool(plr, "gun") then
            table.insert(arr, plr)
        end
    end
    return arr
end
local function getAimbotTargets()
    local arr = {}
    if not R.toolRefreshActive and (not R.toolCache.hasGunRead or not R.toolCache.hasKnifeRead) then
        startToolAutoRefresh()
    end
    local hasGun = R.toolCache.hasGun or hasTool(LocalPlayer, "gun")
    local hasKnife = R.toolCache.hasKnife or hasTool(LocalPlayer, "knife")
    if not hasGun and not hasKnife then
        return arr
    end
    if R.aimbotMurderEnabled then
        if hasGun then
            local m = getMurderPlayer()
            if m then table.insert(arr, m) end
        end
    end
    if R.aimbotSheriffEnabled then
        if hasKnife then
            local s = getSheriffPlayer()
            if s then table.insert(arr, s) end
        end
    end
    if R.aimbotInnocentEnabled then
        if hasKnife then
            for _, p in ipairs(getInnocentPlayers()) do
                table.insert(arr, p)
            end
        end
    end
    return arr
end
local function getNearestAimbotTarget()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local list = getAimbotTargets()
    local near, md = nil, math.huge
    for _, plr in ipairs(list) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - myHrp.Position).Magnitude
            if d < md then
                md = d
                near = plr
            end
        end
    end
    return near
end
local function hasWallBetween(origin, targetPos, ignoreChar)
    local dir = targetPos - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local list = {LocalPlayer.Character}
    if ignoreChar then table.insert(list, ignoreChar) end
    params.FilterDescendantsInstances = list
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, params)
    if result then
        if result.Instance and ignoreChar and result.Instance:IsDescendantOf(ignoreChar) then
            return false
        end
        return true
    end
    return false
end
local function getAutoPredictedPosition(targetPlr, myHrp)
    local tChar = targetPlr.Character
    if not tChar then return nil end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return nil end
    local hum = tChar:FindFirstChildOfClass("Humanoid")
    local vel = tHrp.AssemblyLinearVelocity
    if vel.Magnitude < 2 and hum then
        vel = hum.MoveDirection * hum.WalkSpeed
        vel = Vector3.new(vel.X, tHrp.AssemblyLinearVelocity.Y, vel.Z)
    end
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    local distance = (tHrp.Position - myHrp.Position).Magnitude
    local timeToHit = distance / 1800 + 0.06
    local yOffset = 1.5
    local vertVel = vel.Y
    local gravity = Workspace.Gravity
    if hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or hum.Jump then
            local predictedY = vertVel * timeToHit - 0.5 * gravity * timeToHit * timeToHit * 0.25
            predictedY = math.clamp(predictedY, -3, 6)
            yOffset = yOffset + predictedY
            if vertVel > 5 then
                yOffset = yOffset + 0.8
            end
        else
            if vertVel > 3 then
                yOffset = yOffset + vertVel * timeToHit * 0.4
            end
        end
    end
    yOffset = math.clamp(yOffset, -1, 7)
    local predOffset = flatVel * timeToHit * 1.25
    if predOffset.Magnitude > 14 then
        predOffset = predOffset.Unit * 14
    end
    local rawPred = tHrp.Position + predOffset + Vector3.new(0, yOffset, 0)
    local id = targetPlr.UserId
    local last = R.lastPredictions[id]
    if last then
        local lerpFactor = 0.65
        if hum and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) then
            lerpFactor = 0.75
        end
        rawPred = last:Lerp(rawPred, lerpFactor)
    end
    R.lastPredictions[id] = rawPred
    return rawPred
end
local function createESP(plr)
    if R.espData[plr] then return end
    local ok, hl = pcall(function()
        local h = Instance.new("Highlight")
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Enabled = false
        h.Parent = Workspace
        return h
    end)
    if not ok then return end
    pcall(function() hl.Parent = game:GetService("CoreGui") end)
    local txtRole, txtName
    pcall(function()
        txtRole = Drawing.new("Text")
        txtRole.Visible = false
        txtRole.Center = true
        txtRole.Outline = true
        txtRole.Size = 13
        txtRole.Font = 2
        txtName = Drawing.new("Text")
        txtName.Visible = false
        txtName.Center = true
        txtName.Outline = true
        txtName.Size = 14
        txtName.Font = 2
    end)
    if txtRole and txtName then
        R.espData[plr] = {hl = hl, txtRole = txtRole, txtName = txtName}
    end
end
local function removeESP(plr)
    local d = R.espData[plr]
    if d then
        if d.hl then pcall(function() d.hl:Destroy() end) end
        if d.txtRole then pcall(function() d.txtRole:Remove() end) end
        if d.txtName then pcall(function() d.txtName:Remove() end) end
        R.espData[plr] = nil
    end
end
RunService.RenderStepped:Connect(function()
    pcall(function()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not R.espData[plr] then createESP(plr) end
                local d = R.espData[plr]
                if d then
                    local ch = plr.Character
                    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    if d and hrp and hum and hum.Health > 0 then
                        if myHrp and (hrp.Position - myHrp.Position).Magnitude > R.espMaxDistance then
                            d.hl.Enabled = false
                            d.txtRole.Visible = false
                            d.txtName.Visible = false
                        else
                            local hasKnife = hasTool(plr, "knife")
                            local hasGun = hasTool(plr, "gun")
                            local show, col, role = false, Color3.fromRGB(255,255,255), ""
                            if R.murderEnabled and hasKnife then
                                show = true
                                col = Color3.fromRGB(255,0,0)
                                role = "[MURDER]"
                            elseif R.sheriffEnabled and hasGun then
                                show = true
                                col = Color3.fromRGB(0,140,255)
                                role = "[SHERIFF]"
                            elseif R.innocentEnabled and not hasKnife and not hasGun then
                                show = true
                                col = Color3.fromRGB(0,255,0)
                                role = "[INNOCENT]"
                            end
                            if show then
                                d.hl.Adornee = ch
                                d.hl.FillColor = col
                                d.hl.OutlineColor = col
                                d.hl.Enabled = true
                                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                                if onScreen then
                                    d.txtRole.Visible = true
                                    d.txtRole.Position = Vector2.new(pos.X, pos.Y - 45)
                                    d.txtRole.Text = role
                                    d.txtRole.Color = col
                                    d.txtName.Visible = true
                                    d.txtName.Position = Vector2.new(pos.X, pos.Y - 28)
                                    d.txtName.Text = shortenName(plr.Name, 10)
                                else
                                    d.txtRole.Visible = false
                                    d.txtName.Visible = false
                                end
                            else
                                d.hl.Enabled = false
                                d.txtRole.Visible = false
                                d.txtName.Visible = false
                            end
                        end
                    else
                        d.hl.Enabled = false
                        d.txtRole.Visible = false
                        d.txtName.Visible = false
                    end
                end
            end
        end
    end)
end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)
local function findCoins()
    local arr = {}
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name), "coin") and o.Parent and o.Transparency < 0.9 then
            table.insert(arr, o)
        end
    end
    return arr
end
local function getNearestCoin(fromPos)
    local coins = findCoins()
    local near, md = nil, math.huge
    for _, c in ipairs(coins) do
        if c and c.Parent and c.Transparency < 0.9 then
            local d = (c.Position - fromPos).Magnitude
            if d < md then
                md = d
                near = c
            end
        end
    end
    return near
end
local function getContestingPlayer(coin)
    if not coin or not coin.Parent then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - coin.Position).Magnitude < 18 then
                return plr
            end
        end
    end
    return nil
end
local function isCoinContested(coin)
    return getContestingPlayer(coin) ~= nil
end
local function getThirdFarFromPlayer(contestedCoin)
    local contestPlr = getContestingPlayer(contestedCoin)
    if not contestPlr then return nil end
    local hrp = contestPlr.Character and contestPlr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pPos = hrp.Position
    local coins = findCoins()
    local filtered = {}
    for _, c in ipairs(coins) do
        if c and c.Parent and c.Transparency < 0.5 and c ~= contestedCoin then
            table.insert(filtered, c)
        end
    end
    table.sort(filtered, function(a,b) return (a.Position - pPos).Magnitude > (b.Position - pPos).Magnitude end)
    if #filtered >= 3 then return filtered[3] elseif #filtered >= 1 then return filtered[1] end
    return nil
end
local function getFarthestUncontested(fromPos)
    local coins = findCoins()
    local far, md = nil, -1
    for _, c in ipairs(coins) do
        if c and c.Parent and c.Transparency < 0.5 and not isCoinContested(c) then
            local d = (c.Position - fromPos).Magnitude
            if d > md then
                md = d
                far = c
            end
        end
    end
    return far
end
local function getNearestUncontested(fromPos)
    local coins = findCoins()
    local near, md = nil, math.huge
    for _, c in ipairs(coins) do
        if c and c.Parent and c.Transparency < 0.5 and not isCoinContested(c) then
            local d = (c.Position - fromPos).Magnitude
            if d < md then
                md = d
                near = c
            end
        end
    end
    return near
end
local function enableNoClipTransparent()
    R.savedParts = {}
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            local isChar = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and o:IsDescendantOf(plr.Character) then
                    isChar = true
                    break
                end
            end
            if not isChar and o ~= R.farmPart and o ~= R.platformPart and o.CanCollide then
                table.insert(R.savedParts, {part = o, canCollide = o.CanCollide, trans = o.Transparency})
                o.CanCollide = false
                o.Transparency = 1
            end
        end
    end
    if R.farmAddConn then R.farmAddConn:Disconnect() end
    R.farmAddConn = Workspace.DescendantAdded:Connect(function(obj)
        if not R.farmEnabled or R.farmPausedByMurder then return end
        if obj:IsA("BasePart") and obj.CanCollide and obj ~= R.farmPart and obj ~= R.platformPart then
            local isChar = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and obj:IsDescendantOf(plr.Character) then
                    isChar = true
                    break
                end
            end
            if not isChar then
                table.insert(R.savedParts, {part = obj, canCollide = obj.CanCollide, trans = obj.Transparency})
                obj.CanCollide = false
                obj.Transparency = 1
            end
        end
    end)
end
local function restoreParts()
    if R.farmAddConn then
        R.farmAddConn:Disconnect()
        R.farmAddConn = nil
    end
    for _, d in ipairs(R.savedParts) do
        if d.part and d.part.Parent then
            pcall(function()
                d.part.CanCollide = d.canCollide
                d.part.Transparency = d.trans
            end)
        end
    end
    R.savedParts = {}
end
local function createFarmPart()
    if R.farmPart then R.farmPart:Destroy() end
    if R.platformPart then R.platformPart:Destroy() end
    R.farmPart = Instance.new("Part")
    R.farmPart.Size = Vector3.new(1,1,1)
    R.farmPart.Anchored = true
    R.farmPart.CanCollide = false
    R.farmPart.Transparency = 1
    R.farmPart.Name = "FarmPart"
    R.farmPart.Parent = Workspace
    R.platformPart = Instance.new("Part")
    R.platformPart.Size = Vector3.new(10,1,10)
    R.platformPart.Anchored = true
    R.platformPart.CanCollide = false
    R.platformPart.Transparency = 1
    R.platformPart.Name = "FarmPlatform"
    R.platformPart.Parent = Workspace
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        R.farmPart.CFrame = hrp.CFrame
        R.platformPart.CFrame = hrp.CFrame * CFrame.new(0,-1,0)
    end
    return R.farmPart
end
local function stopFarm()
    R.farmEnabled = false
    R.farmPausedByMurder = false
    if R.farmConn then
        R.farmConn:Disconnect()
        R.farmConn = nil
    end
    if R.farmPart then
        R.farmPart:Destroy()
        R.farmPart = nil
    end
    if R.platformPart then
        R.platformPart:Destroy()
        R.platformPart = nil
    end
    restoreParts()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.05)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end
local function ragdollAndFarm()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.FallingDown)
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.PlatformStand = false
            hum.AutoRotate = false
        end)
    end
end
local function ensureRagdoll()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.FallingDown)
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    end
end
local function findLobbySpawn()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then return obj end
    end
    for _, name in ipairs({"Spawn","SpawnPoint","SpawnPart","LobbySpawn","SpawnLocation"}) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.lower(obj.Name) == string.lower(name) then
                return obj
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "spawn") then
            return obj
        end
    end
    return nil
end
local function isPlayerTeleportedByServer()
    if getMurderPlayer() or getSheriffPlayer() then return true end
    local spawn = findLobbySpawn()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if spawn and hrp then
        if (hrp.Position - spawn.Position).Magnitude > 80 then
            return true
        else
            return false
        end
    end
    return true
end
local function startFarm()
    if R.farmPausedByMurder then return end
    if R.farmConn then R.farmConn:Disconnect() end
    ragdollAndFarm()
    createFarmPart()
    enableNoClipTransparent()
    R.farmConn = RunService.Heartbeat:Connect(function()
        if not R.farmEnabled or R.farmPausedByMurder then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then ensureRagdoll() end
        if hrp and R.farmPart then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = R.farmPart.CFrame * CFrame.Angles(math.rad(90),0,0)
        end
        if R.platformPart and R.farmPart then
            R.platformPart.CFrame = R.farmPart.CFrame * CFrame.new(0,-1,0)
        end
    end)
    task.spawn(function()
        while R.farmEnabled and not R.farmPausedByMurder do
            ensureRagdoll()
            local origin = R.farmPart and R.farmPart.Position or Vector3.new(0,0,0)
            local target = getNearestCoin(origin)
            if not target or not target.Parent or target.Transparency >= 0.5 then
                local spawn = findLobbySpawn()
                if spawn and R.farmPart then
                    R.farmPart.CFrame = CFrame.new(spawn.Position + Vector3.new(0, -45, 0))
                else
                    if R.farmPart then R.farmPart.CFrame = CFrame.new(0, -45, 0) end
                end
                task.wait(1)
            else
                local isContested = isCoinContested(target)
                if isContested then
                    task.wait(0.45)
                    local alt = getThirdFarFromPlayer(target) or getFarthestUncontested(origin) or getNearestUncontested(origin)
                    if alt and alt.Parent and alt.Transparency < 0.5 then target = alt end
                end
                local dest = target.Position + Vector3.new(0, -3.85, 0)
                local stuckTime, lastDist = 0, (R.farmPart.Position - dest).Magnitude
                while R.farmEnabled and not R.farmPausedByMurder and target.Parent and R.farmPart and (R.farmPart.Position - dest).Magnitude > 1.2 do
                    if target.Transparency >= 0.5 then break end
                    local contestedNow = isCoinContested(target)
                    if contestedNow then
                        task.wait(0.45)
                        local alt2 = getThirdFarFromPlayer(target) or getFarthestUncontested(R.farmPart.Position) or getNearestUncontested(R.farmPart.Position)
                        if alt2 and alt2 ~= target and alt2.Transparency < 0.5 then
                            target = alt2
                            dest = target.Position + Vector3.new(0, -3.85, 0)
                        end
                    end
                    local curDist = (R.farmPart.Position - dest).Magnitude
                    if curDist < 4 then break end
                    if math.abs(curDist - lastDist) < 0.1 then
                        stuckTime = stuckTime + task.wait()
                        if stuckTime > 0.8 then break end
                    else
                        stuckTime = 0
                    end
                    lastDist = curDist
                    local distSpeedMult = curDist > 40 and 0.45 or 1.0
                    local factor = 0.55 + 0.45 * math.clamp(curDist / 90, 0, 1)
                    local slowMult = contestedNow and 0.3 or 1.0
                    local alpha = math.clamp((R.farmSpeed * 0.032 * factor) * slowMult * distSpeedMult, 0.008, 0.18)
                    R.farmPart.CFrame = R.farmPart.CFrame:Lerp(CFrame.new(dest), alpha)
                    task.wait(contestedNow and 0.045 or 0.012)
                end
                if R.farmEnabled and not R.farmPausedByMurder and R.farmPart then
                    for a = 0, 360, 25 do
                        if not R.farmEnabled or R.farmPausedByMurder or not R.farmPart then break end
                        R.farmPart.CFrame = CFrame.new(dest) * CFrame.Angles(math.rad(a),0,0)
                        task.wait(0.018)
                    end
                end
                local nextCoin = getNearestCoin(R.farmPart.Position)
                local distNext = nextCoin and (nextCoin.Position - R.farmPart.Position).Magnitude or 999
                local extraFarDelay = distNext > 40 and 0.45 or 0
                if distNext >= 1 and distNext <= 15 then
                    if R.farmPart then R.farmPart.CFrame = CFrame.new(dest) end
                    task.wait(0.25 + extraFarDelay)
                else
                    if R.farmPart then R.farmPart.CFrame = CFrame.new(dest) end
                    task.wait(0.85 + extraFarDelay)
                end
            end
        end
    end)
end
local function findMediumFloorFromMurder(murderPos)
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide and obj.Parent and obj ~= R.farmPart and obj ~= R.platformPart then
            local isChar = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and obj:IsDescendantOf(plr.Character) then
                    isChar = true
                    break
                end
            end
            if not isChar and obj.Size.X > obj.Size.Y and obj.Size.Z > obj.Size.Y and obj.Size.X >= 8 and obj.Size.Z >= 8 then
                local d = (obj.Position - murderPos).Magnitude
                if d >= 25 and d <= 90 then
                    table.insert(candidates, {part = obj, dist = d})
                end
            end
        end
    end
    table.sort(candidates, function(a,b) return a.dist < b.dist end)
    if #candidates == 0 then return nil end
    local mid = math.clamp(math.floor(#candidates/2),1,#candidates)
    return candidates[mid].part
end
local function startAvoid()
    if R.avoidConn then R.avoidConn:Disconnect() end
    R.avoidConn = RunService.Heartbeat:Connect(function()
        if not R.avoidEnabled then return end
        if hasKnifeInBackpack() then return end
        if R.avoidEnabled and R.loopGunEnabled and not isValidOffset() then
            if hasGunInBackpack() then
                return
            end
        end
        local murderPlr = getMurderPlayer()
        if not murderPlr or not isAlive(murderPlr) then return end
        local mHrp = murderPlr.Character and murderPlr.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not mHrp or not myHrp then return end
        if (mHrp.Position - myHrp.Position).Magnitude <= R.avoidDistance then
            local part = findMediumFloorFromMurder(mHrp.Position)
            if part then
                myHrp.CFrame = CFrame.new(part.Position + Vector3.new(0,4,0))
                task.wait(0.4)
            end
        end
    end)
end
local function stopAvoid()
    if R.avoidConn then
        R.avoidConn:Disconnect()
        R.avoidConn = nil
    end
end
local function startTP()
    if R.killAuraConn then
        R.killAuraConn:Disconnect()
        R.killAuraConn = nil
    end
    if R.killAllThread then
        pcall(function() task.cancel(R.killAllThread) end)
        R.killAllThread = nil
    end
    R.killAuraConn = RunService.Heartbeat:Connect(function()
        if not R.killAuraEnabled then return end
        if not hasKnifeInBackpack() then return end
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        if R.currentTarget and isAlive(R.currentTarget) then
            local cHrp = R.currentTarget.Character and R.currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if cHrp and (cHrp.Position - myHrp.Position).Magnitude > 250 then
                R.currentTarget = nil
            end
        end
        local sheriff = getSheriffPlayer()
        if sheriff and isAlive(sheriff) then
            local sHrp = sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart")
            if sHrp and (sHrp.Position - myHrp.Position).Magnitude <= 250 then
                R.currentTarget = sheriff
            end
        end
        if not R.currentTarget or not isAlive(R.currentTarget) then
            R.currentTarget = getNearestPlayer()
            if not R.currentTarget then
                R.currentTarget = getAnyAliveInTP()
            end
        end
        if not R.currentTarget or not isAlive(R.currentTarget) then return end
        local tHrp = R.currentTarget.Character and R.currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        local newSheriff = getSheriffPlayer()
        if newSheriff and isAlive(newSheriff) and newSheriff ~= R.currentTarget then
            local nsHrp = newSheriff.Character and newSheriff.Character:FindFirstChild("HumanoidRootPart")
            if nsHrp and (nsHrp.Position - myHrp.Position).Magnitude <= 250 then
                R.currentTarget = newSheriff
                return
            end
        end
        myHrp.CFrame = tHrp.CFrame * CFrame.new(0,0,2.5)
        local tool = myChar:FindFirstChildOfClass("Tool")
        if not tool or not string.find(string.lower(tool.Name), "knife") then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
    end)
end
local function stopTP()
    R.killAuraEnabled = false
    if R.killAuraConn then
        R.killAuraConn:Disconnect()
        R.killAuraConn = nil
    end
    if R.killAllThread then
        pcall(function() task.cancel(R.killAllThread) end)
        R.killAllThread = nil
    end
    R.currentTarget = nil
    pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
end
local function hrpHasParticle(hrp)
    if not hrp or not hrp.Parent then return false end
    for _, c in ipairs(hrp:GetChildren()) do if c:IsA("ParticleEmitter") then return true end end
    for _, c in ipairs(hrp.Parent:GetChildren()) do if c:IsA("ParticleEmitter") then return true end end
    for _, c in ipairs(hrp.Parent:GetDescendants()) do if c:IsA("ParticleEmitter") then return true end end
    return false
end
local function getMapNameFromHRP(hrp)
    if not hrp then return "Unknown Map" end
    local cur = hrp.Parent
    for i=1,12 do
        if not cur then break end
        local norm = normalizeMapName(cur.Name)
        if R.mapHRSet[norm] then return cur.Name end
        cur = cur.Parent
    end
    return "Unknown Map"
end
local function findMapFolder(normalizedName)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if normalizeMapName(obj.Name) == normalizedName then
            return obj
        end
    end
    return nil
end
local function hasMaplist()
    for _, mapName in ipairs(R.mapHRList) do
        local norm = normalizeMapName(mapName)
        for _, obj in ipairs(Workspace:GetChildren()) do
            if normalizeMapName(obj.Name) == norm then
                return true, obj
            end
        end
    end
    return false, nil
end
local function hasSheriffInServer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            if plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun")) then
                return true
            end
            if plr:GetAttribute("Role") == "Sheriff" then
                return true
            end
        end
    end
    local sheriff = getSheriffPlayer()
    return sheriff ~= nil
end
local function isMurderNearHRP(targetHRP, radius)
    radius = radius or 7
    local murderPlr = getMurderPlayer()
    if not murderPlr then return false end
    local mChar = murderPlr.Character
    local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
    if not mHrp or not targetHRP then return false end
    local dist = (mHrp.Position - targetHRP.Position).Magnitude
    return dist <= radius
end
local function startAutoGetGun()
    if R.autoGetGunThread then pcall(function() task.cancel(R.autoGetGunThread) end) R.autoGetGunThread = nil end
    if R.autoGetGunLoop then pcall(function() task.cancel(R.autoGetGunLoop) end) R.autoGetGunLoop = nil end
    if R.autoGetGunSheriffCheck then pcall(function() task.cancel(R.autoGetGunSheriffCheck) end) R.autoGetGunSheriffCheck = nil end
    if R.autoGetGunMaplistCheck then pcall(function() task.cancel(R.autoGetGunMaplistCheck) end) R.autoGetGunMaplistCheck = nil end
    if R.autoGetGunRefreshConn then pcall(function() R.autoGetGunRefreshConn:Disconnect() end) R.autoGetGunRefreshConn = nil end
    startSaveCFrame()
    R.autoGetGunMaplistCheck = task.spawn(function()
        while R.autoGetGunEnabled do
            local hasMap = hasMaplist()
            local hasSheriff = hasSheriffInServer()
            if not hasMap or hasSheriff then
                if R.autoGetGunThread then pcall(function() task.cancel(R.autoGetGunThread) end) R.autoGetGunThread = nil end
                task.wait(1)
            else
                if not R.autoGetGunThread then
                    R.autoGetGunThread = task.spawn(function()
                        while R.autoGetGunEnabled do
                            local hasMap2 = hasMaplist()
                            local hasSheriff2 = hasSheriffInServer()
                            if not hasMap2 or hasSheriff2 then break end
                            if hasGunInBackpack() then
                                task.wait(0.8)
                            else
                                local myChar = LocalPlayer.Character
                                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    local targetHRP = findHRPInMaps()
                                    if targetHRP and targetHRP.Parent and hrpHasParticle(targetHRP) then
                                        if isMurderNearHRP(targetHRP, 7) then
                                            task.wait(0.5)
                                        else
                                            if not R.mapHRTPing then
                                                R.mapHRTPing = true
                                                local before = R.mapHRSavedCFrame or myHrp.CFrame
                                                myHrp.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0,3,0))
                                                task.wait(0.2)
                                                if myHrp and myHrp.Parent then
                                                    myHrp.CFrame = before
                                                end
                                                task.wait(0.1)
                                                R.mapHRTPing = false
                                                task.wait(1.5)
                                            end
                                        end
                                    end
                                end
                                task.wait(0.5)
                            end
                        end
                    end)
                end
                task.wait(1)
            end
        end
    end)
end
local function findHRPInMaps()
    local allRaggyCandidates = {}
    for _, mapName in ipairs(R.mapHRList) do
        local norm = normalizeMapName(mapName)
        local folder = findMapFolder(norm)
        if not folder then
            for _, d in ipairs(Workspace:GetChildren()) do
                if normalizeMapName(d.Name) == norm then folder = d break end
            end
        end
        if folder then
            local raggyList = {}
            for _, d in ipairs(folder:GetDescendants()) do
                if d:IsA("Model") or d:IsA("Folder") then
                    if string.find(string.lower(d.Name), "raggy") then
                        table.insert(raggyList, d)
                    end
                end
            end
            if #raggyList > 0 then
                local targetRaggy = raggyList[#raggyList]
                local hrps = {}
                for _, part in ipairs(targetRaggy:GetDescendants()) do
                    if part.Name == "HumanoidRootPart" and part:IsA("BasePart") and hrpHasParticle(part) then
                        local isPlayer = false
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr.Character and part:IsDescendantOf(plr.Character) then isPlayer = true break end
                        end
                        if not isPlayer then table.insert(hrps, part) end
                    end
                end
                if #hrps > 0 then
                    table.insert(allRaggyCandidates, hrps[#hrps])
                end
            end
        end
    end
    if #allRaggyCandidates > 0 then
        return allRaggyCandidates[#allRaggyCandidates]
    end
    local fallbackRaggy = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("Folder")) and string.find(string.lower(d.Name), "raggy") then
            table.insert(fallbackRaggy, d)
        end
    end
    if #fallbackRaggy > 0 then
        local target = fallbackRaggy[#fallbackRaggy]
        local hrps = {}
        for _, part in ipairs(target:GetDescendants()) do
            if part.Name == "HumanoidRootPart" and part:IsA("BasePart") and hrpHasParticle(part) then
                local isPlayer = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and part:IsDescendantOf(plr.Character) then isPlayer = true break end
                end
                if not isPlayer then table.insert(hrps, part) end
            end
        end
        if #hrps > 0 then return hrps[#hrps] end
    end
    return nil
end
local function startSaveCFrame()
    if R.mapHRAutoSaveConn then return end
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHrp then R.mapHRSavedCFrame = myHrp.CFrame end
    R.mapHRAutoSaveConn = RunService.Heartbeat:Connect(function()
        if R.mapHRTPing then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y > -50 then R.mapHRSavedCFrame = hrp.CFrame end
    end)
end
local function stopSaveCFrameIfNeeded()
    if not R.mapHREnabled and not R.autoGetGunEnabled and not R.loopGunEnabled then
        if R.mapHRAutoSaveConn then
            R.mapHRAutoSaveConn:Disconnect()
            R.mapHRAutoSaveConn = nil
        end
        R.mapHRSavedCFrame = nil
        R.mapHRTPing = false
    end
end
local function startESPGun()
    if R.espGunLoop then pcall(function() task.cancel(R.espGunLoop) end) R.espGunLoop = nil end
    if R.espGunDescConn then pcall(function() R.espGunDescConn:Disconnect() end) R.espGunDescConn = nil end
    R.espGunWasFound = false
    R.espGunLastHrp = nil
    R.espGunNotified = false
    local function isValidGunPart(part)
        if not part or not part.Parent then return false end
        if part.Name ~= "HumanoidRootPart" then return false end
        if not part:IsA("BasePart") then return false end
        if not hrpHasParticle(part) then return false end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and part:IsDescendantOf(plr.Character) then return false end
        end
        return true
    end
    local function createOrUpdateESP(hrp)
        if not hrp or not hrp.Parent then return end
        local sheriff = getSheriffPlayer()
        if sheriff and isAlive(sheriff) then
            if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox=nil end
            if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard=nil end
            R.espGunLastHrp = nil
            R.espGunNotified = false
            return
        end
        if R.espGunLastHrp == hrp and R.espGunBox and R.espGunBox.Parent then
            pcall(function() R.espGunBox.Size = hrp.Size end)
            return
        end
        if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox=nil end
        if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard=nil end
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_GUN_BOX"
        box.Adornee = hrp
        box.Size = hrp.Size
        box.Color3 = Color3.fromRGB(0,255,0)
        box.Transparency = 0.4
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Parent = Workspace
        R.espGunBox = box
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP_GUN_NAME"
        bg.Adornee = hrp
        bg.Size = UDim2.new(0,120,0,40)
        bg.StudsOffset = Vector3.new(0,4,0)
        bg.AlwaysOnTop = true
        bg.Parent = Workspace
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 0.3
        lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
        lbl.Text = "GUN"
        lbl.TextColor3 = Color3.fromRGB(0,255,0)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,6)
        lbl.Parent = bg
        R.espGunBillboard = bg
        R.espGunLastHrp = hrp
        if R.espGunTextLoop then task.cancel(R.espGunTextLoop) end
        R.espGunTextLoop = task.spawn(function()
            while R.espGunEnabled and R.espGunBillboard and hrp.Parent do
                local sheriffCheck = getSheriffPlayer()
                if sheriffCheck and isAlive(sheriffCheck) then
                    if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox=nil end
                    if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard=nil end
                    R.espGunLastHrp = nil
                    R.espGunNotified = false
                    break
                end
                pcall(function()
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                        lbl.Text = "GUN ["..dist.."m]"
                    end
                end)
                task.wait(0.5)
            end
        end)
        if not R.espGunNotified then
            R.espGunNotified = true
            R.espGunWasFound = true
            local mapName = getMapNameFromHRP(hrp)
            pcall(function() library:Addnotification({title = "ESP Gun", desc = "Gun spawned at "..mapName.."!", duration = 4}) end)
        end
    end
    R.espGunDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if not R.espGunEnabled then return end
        task.wait(0.1)
        if isValidGunPart(obj) then
            createOrUpdateESP(obj)
        end
    end)
    R.espGunLoop = task.spawn(function()
        while R.espGunEnabled do
            local sheriff = getSheriffPlayer()
            if sheriff and isAlive(sheriff) then
                if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox = nil end
                if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard = nil end
                R.espGunLastHrp = nil
                R.espGunWasFound = false
                R.espGunNotified = false
                task.wait(1)
            else
                local hrp = findHRPInMaps()
                if hrp and isValidGunPart(hrp) then
                    createOrUpdateESP(hrp)
                else
                    if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox = nil end
                    if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard = nil end
                    R.espGunLastHrp = nil
                    R.espGunNotified = false
                    R.espGunWasFound = false
                end
                task.wait(1)
            end
        end
    end)
end
local function stopESPGun()
    R.espGunEnabled = false
    if R.espGunLoop then pcall(function() task.cancel(R.espGunLoop) end) R.espGunLoop = nil end
    if R.espGunDescConn then pcall(function() R.espGunDescConn:Disconnect() end) R.espGunDescConn = nil end
    if R.espGunTextLoop then pcall(function() task.cancel(R.espGunTextLoop) end) R.espGunTextLoop = nil end
    if R.espGunBox then pcall(function() R.espGunBox:Destroy() end) R.espGunBox = nil end
    if R.espGunBillboard then pcall(function() R.espGunBillboard:Destroy() end) R.espGunBillboard = nil end
    R.espGunWasFound = false
    R.espGunLastHrp = nil
    R.espGunNotified = false
end

local function startLoopGun()
    if R.loopGunConn then
        R.loopGunConn:Disconnect()
        R.loopGunConn = nil
    end
    if R.loopGunPlatform then
        pcall(function() R.loopGunPlatform:Destroy() end)
        R.loopGunPlatform = nil
    end
    R.loopGunPlatform = Instance.new("Part")
    R.loopGunPlatform.Name = "LoopGunPlatform"
    R.loopGunPlatform.Size = Vector3.new(14,1,14)
    R.loopGunPlatform.Anchored = true
    R.loopGunPlatform.CanCollide = true
    R.loopGunPlatform.Transparency = 0.5
    R.loopGunPlatform.Material = Enum.Material.ForceField
    R.loopGunPlatform.Color = Color3.fromRGB(100,100,255)
    R.loopGunPlatform.Parent = Workspace
    startSaveCFrame()
    local MIN_RADIUS = 12
    R.gravityBackup = Workspace.Gravity
    R.isFlying = false
    local function handleGravity(isTeleporting)
        if isTeleporting then
            if Workspace.Gravity > 35 then
                R.gravityBackup = Workspace.Gravity
            end
            Workspace.Gravity = 30
        else
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local velY = hrp.AssemblyLinearVelocity.Y
                if velY > 20 or hum:GetState() == Enum.HumanoidStateType.Freefall then
                    if tick() - (R.lastFreefallTime or 0) > 0.5 then
                        R.isFlying = true
                    end
                    if not R.lastFreefallTime then
                        R.lastFreefallTime = tick()
                    end
                else
                    R.lastFreefallTime = nil
                    R.isFlying = false
                end
                if R.isFlying then
                    if Workspace.Gravity < 196.2 then
                        Workspace.Gravity = math.min(Workspace.Gravity + 15, 196.2)
                    else
                        R.isFlying = false
                    end
                else
                    if Workspace.Gravity < R.gravityBackup then
                        Workspace.Gravity = math.min(Workspace.Gravity + 5, R.gravityBackup)
                    end
                end
            end
        end
    end
    R.loopGunConn = RunService.Heartbeat:Connect(function()
        if not R.loopGunEnabled then
            handleGravity(false)
            return
        end
        if R.mapHRTPing then return end
        local char = LocalPlayer.Character
        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        if R.loopGunPlatform and R.loopGunPlatform.Parent then
            R.loopGunPlatform.CFrame = CFrame.new(myHrp.Position + Vector3.new(0, -5, 0))
        end
        if not hasGunInBackpack() then
            if R.avoidEnabled and not isValidOffset() then return end
            handleGravity(false)
            return
        end
        local murderPlr = getMurderPlayer()
        if murderPlr and isAlive(murderPlr) then
            local mHrp = murderPlr.Character and murderPlr.Character:FindFirstChild("HumanoidRootPart")
            local mHum = murderPlr.Character and murderPlr.Character:FindFirstChildOfClass("Humanoid")
            if mHrp and mHum then
                pcall(function()
                    mHum.JumpPower = 0
                    mHum.JumpHeight = 0
                    if mHum.UseJumpPower then
                        mHum.JumpPower = 0
                    else
                        mHum.JumpHeight = 0
                    end
                    mHrp.AssemblyLinearVelocity = Vector3.new(mHrp.AssemblyLinearVelocity.X, 0, mHrp.AssemblyLinearVelocity.Z)
                    if mHum:GetState() == Enum.HumanoidStateType.Jumping or mHum:GetState() == Enum.HumanoidStateType.Freefall then
                        mHum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
                local radius = math.max(R.loopGunOffset, MIN_RADIUS)
                local behindOffset = CFrame.new(0,0,radius)
                local targetCF = mHrp.CFrame * behindOffset
                myHrp.CFrame = targetCF
                myHrp.AssemblyLinearVelocity = Vector3.zero
                handleGravity(true)
                handleGravity(false)
            end
        else
            handleGravity(false)
        end
    end)
end
local function stopLoopGun()
    R.loopGunEnabled = false
    if R.loopGunConn then
        R.loopGunConn:Disconnect()
        R.loopGunConn = nil
    end
    if R.loopGunPlatform then
        pcall(function() R.loopGunPlatform:Destroy() end)
        R.loopGunPlatform = nil
    end
    stopSaveCFrameIfNeeded()
end

local function isCharPart(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
    end
    return false
end

local function findDetectors()
    local detectors = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lname = string.lower(obj.Name)
            if lname == "detector1" or lname == "detector2" or lname == "detector3" then
                table.insert(detectors, obj)
            end
        end
    end
    table.sort(detectors, function(a,b) return a.Name < b.Name end)
    return detectors
end
local function getDetectorByIndex(idx)
    local list = findDetectors()
    if #list == 0 then return nil end
    idx = math.clamp(idx, 1, #list)
    return list[idx]
end
local function tpToDetector(idx)
    local part = getDetectorByIndex(idx)
    if not part then return false end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
        return true
    end
    return false
end
local function isAnyOtherPlayerHasWeapon()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            if hasTool(plr, "knife") or hasTool(plr, "gun") then
                return true
            end
        end
    end
    return false
end
local function startVotePad()
    R.votePadTPed = false
    if R.votePadCharConn then R.votePadCharConn:Disconnect() R.votePadCharConn = nil end
    R.votePadCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.5)
        if R.votePadEnabled then tpToDetector(R.votePadIndex) end
    end)
    if R.votePadLoop then pcall(function() task.cancel(R.votePadLoop) end) R.votePadLoop = nil end
    R.votePadLoop = task.spawn(function()
        while R.votePadEnabled do
            if not R.votePadTPed then
                if not isAnyOtherPlayerHasWeapon() then
                    local ok = tpToDetector(R.votePadIndex)
                    if ok then R.votePadTPed = true end
                end
            end
            task.wait(0.5)
        end
    end)
end
local function stopVotePad()
    R.votePadEnabled = false
    R.votePadTPed = false
    if R.votePadLoop then pcall(function() task.cancel(R.votePadLoop) end) R.votePadLoop = nil end
    if R.votePadCharConn then R.votePadCharConn:Disconnect() R.votePadCharConn = nil end
end
local function startMovement()
    if R.movementConn then R.movementConn:Disconnect() end
    R.movementConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if R.walkSpeedEnabled then hum.WalkSpeed = R.walkSpeedValue end
            if R.jumpEnabled then
                if hum.UseJumpPower then
                    hum.JumpPower = R.jumpValue
                else
                    hum.JumpHeight = R.jumpValue
                end
            end
        end
    end)
end
local function stopMovement()
    if not R.walkSpeedEnabled and not R.jumpEnabled then
        if R.movementConn then
            R.movementConn:Disconnect()
            R.movementConn = nil
        end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            if hum.UseJumpPower then
                hum.JumpPower = 50
            else
                hum.JumpHeight = 7.2
            end
        end
    end
end
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end
local function startAimbotLoop()
    if R.aimbotConn then R.aimbotConn:Disconnect() end
    if R.aimbotInfoConn then R.aimbotInfoConn:Disconnect() end
    if R.aimbotInfoGui then pcall(function() R.aimbotInfoGui:Destroy() end) end
    local sg = Instance.new("ScreenGui")
    sg.Name = "AimbotInfoGUI"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,130,0,55)
    main.Position = UDim2.new(1,-130,0.5,-27)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke")
    st.Thickness = 1
    st.Color = Color3.fromRGB(255,255,255)
    st.Transparency = 0.5
    st.Parent = main
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,16)
    title.BackgroundTransparency = 1
    title.Text = "AIMBOT INFO"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-6,0,16)
    nameLbl.Position = UDim2.new(0,3,0,18)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "Target: -"
    nameLbl.TextColor3 = Color3.fromRGB(0,255,0)
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = main
    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1,-6,0,14)
    distLbl.Position = UDim2.new(0,3,0,34)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "Dist: 0"
    distLbl.TextColor3 = Color3.fromRGB(255,255,0)
    distLbl.TextSize = 11
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = main
    R.aimbotInfoGui = sg
    R.aimbotInfoName = nameLbl
    R.aimbotInfoDist = distLbl
    R.aimbotConn = RunService.RenderStepped:Connect(function()
        if not R.aimbotEnabled then return end
        local hasGun = R.toolCache.hasGun or hasTool(LocalPlayer, "gun")
        local hasKnife = R.toolCache.hasKnife or hasTool(LocalPlayer, "knife")
        if not hasGun and not hasKnife then
            if not R.toolRefreshActive then
                startToolAutoRefresh()
            end
            return
        end
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local target = getNearestAimbotTarget()
        R.aimbotCurrentTarget = target
        if not target or not target.Character then return end
        local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        if hasWallBetween(Camera.CFrame.Position, tHrp.Position, target.Character) then return end
        local predictedPos = getAutoPredictedPosition(target, myHrp)
        if predictedPos then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
        end
    end)
    R.aimbotInfoConn = RunService.Heartbeat:Connect(function()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp or not R.aimbotInfoName then return end
        local target = R.aimbotCurrentTarget or getNearestAimbotTarget()
        if not target or not target.Character then
            R.aimbotInfoName.Text = "Target: -"
            R.aimbotInfoDist.Text = "Dist: 0"
            return
        end
        local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        local dist = (tHrp.Position - myHrp.Position).Magnitude
        R.aimbotInfoName.Text = "Target: ".. shortenName(target.Name, 10)
        R.aimbotInfoDist.Text = string.format("Dist: %.0f", dist)
    end)
end
local function stopAimbotLoop()
    if R.aimbotConn then
        R.aimbotConn:Disconnect()
        R.aimbotConn = nil
    end
    if R.aimbotInfoConn then
        R.aimbotInfoConn:Disconnect()
        R.aimbotInfoConn = nil
    end
    R.aimbotCurrentTarget = nil
    R.lastPredictions = {}
end
local function startMapHRPButton()
    if R.mapHRGui then
        R.mapHRGui:Destroy()
        R.mapHRGui = nil
    end
    startSaveCFrame()
    local sg = Instance.new("ScreenGui")
    sg.Name = "GetGunGUI"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,130,0,32)
    btn.Position = UDim2.new(0.5,-65,0.75,0)
    btn.Text = "COLLECT GUN"
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.BackgroundTransparency = 0.65
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    makeDraggable(btn)
    R.mapHRGui = sg
    btn.MouseButton1Click:Connect(function()
        if R.mapHRTPing then return end
        if not isPlayerTeleportedByServer() then return end
        R.mapHRTPing = true
        local myChar = LocalPlayer.Character
        local myHrp2 = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp2 then
            R.mapHRTPing = false
            return
        end
        local before = R.mapHRSavedCFrame or myHrp2.CFrame
        local targetHRP = findHRPInMaps()
        if targetHRP and targetHRP.Parent and hrpHasParticle(targetHRP) then
            myHrp2.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0,3,0))
            task.wait(0.2)
            if myHrp2 and myHrp2.Parent then myHrp2.CFrame = before end
        end
        task.wait(0.1)
        R.mapHRTPing = false
    end)
end
local function stopMapHRPButton()
    if R.mapHRGui then
        R.mapHRGui:Destroy()
        R.mapHRGui = nil
    end
    stopSaveCFrameIfNeeded()
end
local function isMurderNearHRP(targetHRP, radius)
    radius = radius or 3.5
    local murderPlr = getMurderPlayer()
    if not murderPlr then return false end
    local mChar = murderPlr.Character
    local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
    if not mHrp or not targetHRP then return false end
    local dist = (mHrp.Position - targetHRP.Position).Magnitude
    return dist <= radius
end
local function startAutoGetGun()
    if R.autoGetGunThread then pcall(function() task.cancel(R.autoGetGunThread) end) R.autoGetGunThread = nil end
    if R.autoGetGunLoop then pcall(function() task.cancel(R.autoGetGunLoop) end) R.autoGetGunLoop = nil end
    if R.autoGetGunSheriffCheck then pcall(function() task.cancel(R.autoGetGunSheriffCheck) end) R.autoGetGunSheriffCheck = nil end
    if R.autoGetGunMaplistCheck then pcall(function() task.cancel(R.autoGetGunMaplistCheck) end) R.autoGetGunMaplistCheck = nil end
    if R.autoGetGunRefreshConn then pcall(function() R.autoGetGunRefreshConn:Disconnect() end) R.autoGetGunRefreshConn = nil end
    startSaveCFrame()
    R.autoGetGunMaplistCheck = task.spawn(function()
        while R.autoGetGunEnabled do
            local hasMap = hasMaplist()
            if not hasMap then
                if R.autoGetGunThread then pcall(function() task.cancel(R.autoGetGunThread) end) R.autoGetGunThread = nil end
                task.wait(1)
            else
                if not R.autoGetGunThread then
                    R.autoGetGunThread = task.spawn(function()
                        while R.autoGetGunEnabled do
                            local hasMap2 = hasMaplist()
                            if not hasMap2 then break end
                            if hasGunInBackpack() then
                                task.wait(0.8)
                            else
                                local myChar = LocalPlayer.Character
                                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    local targetHRP = findHRPInMaps()
                                    if targetHRP and targetHRP.Parent and hrpHasParticle(targetHRP) then
                                        if isMurderNearHRP(targetHRP, 3.5) then
                                            task.wait(0.5)
                                        else
                                            if not R.mapHRTPing then
                                                R.mapHRTPing = true
                                                local before = R.mapHRSavedCFrame or myHrp.CFrame
                                                myHrp.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0,3,0))
                                                task.wait(0.2)
                                                if myHrp and myHrp.Parent then
                                                    myHrp.CFrame = before
                                                end
                                                task.wait(0.1)
                                                R.mapHRTPing = false
                                                task.wait(1.5)
                                            end
                                        end
                                    end
                                end
                                task.wait(0.5)
                            end
                        end
                    end)
                end
                task.wait(1)
            end
        end
    end)
end
local function stopAutoGetGun()
    R.autoGetGunEnabled = false
    if R.autoGetGunThread then
        pcall(function() task.cancel(R.autoGetGunThread) end)
        R.autoGetGunThread = nil
    end
    if R.autoGetGunLoop then pcall(function() task.cancel(R.autoGetGunLoop) end) R.autoGetGunLoop = nil end
    if R.autoGetGunSheriffCheck then pcall(function() task.cancel(R.autoGetGunSheriffCheck) end) R.autoGetGunSheriffCheck = nil end
    if R.autoGetGunMaplistCheck then pcall(function() task.cancel(R.autoGetGunMaplistCheck) end) R.autoGetGunMaplistCheck = nil end
    if R.autoGetGunRefreshConn then pcall(function() R.autoGetGunRefreshConn:Disconnect() end) R.autoGetGunRefreshConn = nil end
    stopSaveCFrameIfNeeded()
end
local function setupAutoGetGunDeathLogic()
    local function bindChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.Died:Connect(function()
            if isAnyPlayerHasTool() then
                if R.autoGetGunEnabled then
                    R.autoGetGunDisabledByDeath = true
                    R.autoGetGunEnabled = false
                    if R.autoGetGunThread then pcall(function() task.cancel(R.autoGetGunThread) end) R.autoGetGunThread = nil end
                    stopSaveCFrameIfNeeded()
                end
            end
        end)
    end
    if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(char)
        bindChar(char)
        task.wait(1)
        if R.autoGetGunDisabledByDeath and isAllPlayersNoTool() then
            R.autoGetGunDisabledByDeath = false
            R.autoGetGunEnabled = true
            startAutoGetGun()
        end
    end)
    task.spawn(function()
        while true do
            task.wait(1)
            if R.autoGetGunDisabledByDeath and isAllPlayersNoTool() then
                R.autoGetGunDisabledByDeath = false
                R.autoGetGunEnabled = true
                startAutoGetGun()
            end
        end
    end)
end
setupAutoGetGunDeathLogic()
pcall(function()
    infoLeftGroup:Createinvite({name = "support", image = "10734897102", link = "https://discord.gg/mXnTVYYYsy"})
end)
local infoParaFrame
pcall(function()
    infoParaFrame = infoRightGroup:CreateParagraph({title = "information", desc = "R.fps: 0\nplayer in server: 0\nTime: 00:00:00"})
end)
local infoDescLabel = nil
task.wait(0.2)
pcall(function()
    if infoParaFrame then
        for _, v in ipairs(infoParaFrame:GetDescendants()) do
            if v:IsA("TextLabel") and v.TextSize == 10 then
                infoDescLabel = v
                break
            end
        end
    end
end)
task.spawn(function()
    while true do
        local elapsed = math.floor(tick() - R.startTime)
        local hh = math.floor(elapsed / 3600)
        local mm = math.floor((elapsed % 3600) / 60)
        local ss = elapsed % 60
        local timeStr = string.format("%02d:%02d:%02d", hh, mm, ss)
        local plyr = #Players:GetPlayers()
        local newDesc = "R.fps: ".. tostring(R.fps).. "\nplayer in server: ".. tostring(plyr).. "\nTime: ".. timeStr
        if infoDescLabel and infoDescLabel.Parent then
            infoDescLabel.Text = newDesc
        end
        task.wait(0.3)
    end
end)
espGroup:CreateToggle("ESP Murder", false, function(s) R.murderEnabled = s end)
espGroup:CreateToggle("ESP Sheriff", false, function(s) R.sheriffEnabled = s end)
espGroup:CreateToggle("ESP Innocent", false, function(s) R.innocentEnabled = s end)
espGroup:CreateToggle("ESP Gun", false, function(s)
    R.espGunEnabled = s
    if s then startESPGun() else stopESPGun() end
end)

local function freezePlayer(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    pcall(function()
        hum.PlatformStand = true
        hum.AutoRotate = false
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.Anchored = true
        for _, anim in ipairs(hum:GetPlayingAnimationTracks()) do anim:Stop() end
    end)
    R.killAllOPFrozen[plr] = true
end
local function unfreezePlayer(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            if hrp then hrp.Anchored = false end
        end)
    end
    R.killAllOPFrozen[plr] = nil
end
local function bringPlayerFront(plr, index)
    if plr == LocalPlayer then return end
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local stackedPos = myHrp.CFrame * CFrame.new(0,0,-3)
    hrp.CFrame = stackedPos
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.Anchored = true
end
local function equipKnifeViaKeybind1()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local knifeTool = nil
    for _, t in ipairs(backpack:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then knifeTool = t break end
    end
    if not knifeTool then
        local char = LocalPlayer.Character
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then knifeTool = t break end
            end
        end
    end
    if knifeTool then
        pcall(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(knifeTool)
            knifeTool.Parent = LocalPlayer.Character
        end)
        return knifeTool
    end
    return nil
end
local function startKillAllOP()
    R.killAllOPEnabled = true
    R.killAllOPFrozen = {}
    if R.killAllOPAutoRefreshConn then pcall(function() R.killAllOPAutoRefreshConn:Disconnect() end) R.killAllOPAutoRefreshConn = nil end
    if R.killAllOPMurderCheck then task.cancel(R.killAllOPMurderCheck) R.killAllOPMurderCheck = nil end
    if R.killAllOPBringConn then pcall(function() R.killAllOPBringConn:Disconnect() end) R.killAllOPBringConn = nil end
    if R.killAllOPConn then task.cancel(R.killAllOPConn) R.killAllOPConn = nil end
    R.killAllOPMurderCheck = task.spawn(function()
        while R.killAllOPEnabled do
            local hasKnife = hasTool(LocalPlayer, "knife")
            if hasKnife then
                if not R.killAllOPBringConn then
                    R.killAllOPBringConn = RunService.Heartbeat:Connect(function()
                        if not R.killAllOPEnabled then return end
                        if not hasTool(LocalPlayer, "knife") then return end
                        local myChar = LocalPlayer.Character
                        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        if not myHrp then return end
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer then
                                local char = plr.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp and char then
                                    local dist = (hrp.Position - myHrp.Position).Magnitude
                                    if dist <= 200 then
                                        if isAlive(plr) then
                                            freezePlayer(plr)
                                            bringPlayerFront(plr, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
                if not R.killAllOPConn then
                    R.killAllOPConn = task.spawn(function()
                        while R.killAllOPEnabled and hasTool(LocalPlayer, "knife") do
                            local knife = equipKnifeViaKeybind1()
                            if knife then
                                for i = 1, 5 do
                                    if not R.killAllOPEnabled then break end
                                    if not hasTool(LocalPlayer, "knife") then break end
                                    pcall(function()
                                        knife:Activate()
                                        local vim = game:GetService("VirtualInputManager")
                                        vim:SendMouseButtonEvent(0,0,0,true,game,0)
                                        task.wait(0.05)
                                        vim:SendMouseButtonEvent(0,0,0,false,game,0)
                                    end)
                                    task.wait(0.1)
                                end
                            end
                            task.wait(0.3)
                        end
                    end)
                end
            else
                if R.killAllOPBringConn then R.killAllOPBringConn:Disconnect() R.killAllOPBringConn = nil end
                if R.killAllOPConn then task.cancel(R.killAllOPConn) R.killAllOPConn = nil end
            end
            task.wait(0.25)
        end
    end)
end
local function stopKillAllOP()
    R.killAllOPEnabled = false
    if R.killAllOPBringConn then R.killAllOPBringConn:Disconnect() R.killAllOPBringConn = nil end
    if R.killAllOPConn then task.cancel(R.killAllOPConn) R.killAllOPConn = nil end
    if R.killAllOPMurderCheck then task.cancel(R.killAllOPMurderCheck) R.killAllOPMurderCheck = nil end
    if R.killAllOPAutoRefreshConn then pcall(function() R.killAllOPAutoRefreshConn:Disconnect() end) R.killAllOPAutoRefreshConn = nil end
    for plr, _ in pairs(R.killAllOPFrozen) do unfreezePlayer(plr) end
    R.killAllOPFrozen = {}
end

killGroup:CreateToggle("Kill All", false, function(state)
    R.killAuraEnabled = state
    if state then
        if R.killAllOPEnabled then
            stopTP()
            startKillAllOP()
        else
            stopKillAllOP()
            startTP()
        end
    else
        stopTP()
        if not R.killAllOPEnabled then
            stopKillAllOP()
        end
    end
end)
killGroup:CreateToggle("mode OP", false, function(state)
    R.killAllOPEnabled = state
    if state then
        if R.killAuraEnabled then
            stopTP()
            startKillAllOP()
            pcall(function() library:Addnotification({title = "mode OP", desc = "Switched Normal Mode to OP Mode", duration = 3}) end)
        else
            startKillAllOP()
            pcall(function() library:Addnotification({title = "mode OP", desc = "OP Mode Ready - Enable Kill All to start", duration = 3}) end)
        end
    else
        stopKillAllOP()
        if R.killAuraEnabled then
            startTP()
            pcall(function() library:Addnotification({title = "Kill All", desc = "Switched to Normal Mode", duration = 3}) end)
        else
            pcall(function() library:Addnotification({title = "mode OP", desc = "OP Mode OFF", duration = 2}) end)
        end
    end
end)
coinGroup:CreateToggle("Farm Coin", false, function(state)
    if state then
        R.farmEnabled = true
        R.farmPausedByMurder = false
        startFarm()
    else
        stopFarm()
    end
end)
coinGroup:CreateSlider("Tween Speed", 1, 10, 3, function(v) R.farmSpeed = v end)
sheriffCounterGroup:CreateToggle("Get Gun", false, function(state)
    R.getGunEnabled = state
    if state then
        startGetGun()
    else
        stopGetGun()
    end
end)
sheriffCounterGroup:CreateToggle("Auto Get Gun", false, function(state)
    R.autoGetGunEnabled = state
    if state then
        startAutoGetGun()
    else
        stopAutoGetGun()
    end
end)
sheriffCounterGroup:CreateDivider()
sheriffCounterGroup:CreateToggle("TP Behind Murder", false, function(state)
    R.loopGunEnabled = state
    if state then
        checkOffsetVsAvoid()
        startLoopGun()
    else
        stopLoopGun()
    end
end)
sheriffCounterGroup:CreateSlider("TP Behind Murder Distance", 5, 45, 35, function(v)
    R.loopGunOffset = v
    checkOffsetVsAvoid()
end)
avoidGroup:CreateToggle("Avoid Murder", false, function(state)
    R.avoidEnabled = state
    if state then startAvoid() else stopAvoid() end
    checkOffsetVsAvoid()
end)
avoidGroup:CreateInput("Avoid Distance", "25", function(text)
    local num = tonumber(text)
    if num then
        R.avoidDistance = num
        checkOffsetVsAvoid()
    end
end)
votePadGroup:CreateSlider("select votes", 1, 3, 1, function(v)
    R.votePadIndex = math.clamp(math.floor(v + 0.5), 1, 3)
    if R.votePadEnabled and not isAnyOtherPlayerHasWeapon() then tpToDetector(R.votePadIndex) end
end)
votePadGroup:CreateToggle("Auto vote map", false, function(state)
    R.votePadEnabled = state
    if state then startVotePad() else stopVotePad() end
end)

miscGroup:CreateButton("Anti Fling", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/main-scipt/refs/heads/main/byte/anti-fling.lua"))()
end)
miscGroup:CreateToggle("Anti Void", false, function(state)
R.antiVoidEnabled = state
    if state then
        if R.antiVoidConn then R.antiVoidConn:Disconnect() end
        R.antiVoidLoop = nil
        R.lastSafePos = R.lastSafePos or nil
        R.lastSafePosString = R.lastSafePosString or nil
        R.antiVoidConn = RunService.Heartbeat:Connect(function()
            if not R.antiVoidEnabled then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local function round2(v)
                return math.floor(v * 100 + 0.5) / 100
            end
            local function isTouchingValidPart()
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local ray = Workspace:Raycast(hrp.Position, Vector3.new(0,-5,0), params)
                if ray and ray.Instance and ray.Instance.Anchored and ray.Instance.CanCollide and ray.Instance:IsDescendantOf(Workspace) and not ray.Instance:IsDescendantOf(char) then
                    if ray.Instance.Parent and ray.Instance.Parent:FindFirstChildOfClass("Humanoid") then
                        return false
                    end
                    return true, ray.Instance
                end
                local touching = false
                pcall(function()
                    for _, part in ipairs(hrp:GetTouchingParts()) do
                        if part.Anchored and part.CanCollide and part:IsDescendantOf(Workspace) then
                            if not part:IsDescendantOf(char) then
                                touching = true
                                break
                            end
                        end
                    end
                end)
                return touching
            end
            local touching, part = isTouchingValidPart()
            if touching then
                local pos = hrp.Position
                local rounded = Vector3.new(round2(pos.X), round2(pos.Y), round2(pos.Z))
                local posString = string.format("%.2f, %.2f, %.2f", rounded.X, rounded.Y, rounded.Z)
                if R.lastSafePosString ~= posString then
                    R.lastSafePos = rounded
                    R.lastSafePosString = posString
                end
            else
                -- auto save mati kalo ga nyentuh part anchor on cancollide on
            end
            if hrp.Position.Y < -200 then
                if R.lastSafePos then
                    hrp.CFrame = CFrame.new(R.lastSafePos + Vector3.new(0,5,0))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    hrp.CFrame = CFrame.new(0,50,0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    else
        if R.antiVoidConn then
            R.antiVoidConn:Disconnect()
            R.antiVoidConn = nil
        end
        R.lastSafePosString = nil
    end
end)
movementGroup:CreateToggle("Enable WalkSpeed", false, function(s)
    R.walkSpeedEnabled = s
    if s then startMovement() else stopMovement() end
end)
movementGroup:CreateInput("Value", "16", function(t)
    local n = tonumber(t)
    if n then
        R.walkSpeedValue = math.clamp(n, 1, 500)
        if R.walkSpeedEnabled then startMovement() end
    end
end)
movementGroup:CreateToggle("Enable JumpPower", false, function(s)
    R.jumpEnabled = s
    if s then startMovement() else stopMovement() end
end)
movementGroup:CreateInput("Value", "50", function(t)
    local n = tonumber(t)
    if n then
        R.jumpValue = math.clamp(n, 1, 500)
        if R.jumpEnabled then startMovement() end
    end
end)
utilityGroup:CreateToggle("Noclip", false, function(s)
    if s then setNoclip(true) else setNoclip(false) end
end)
utilityGroup:CreateToggle("Infinite Jump", false, function(s)
    R.infJumpEnabled = s
    if s then
        if R.infJumpConn then R.infJumpConn:Disconnect() end
        R.infJumpConn = UserInputService.JumpRequest:Connect(function()
            if R.infJumpEnabled then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if R.infJumpConn then
            R.infJumpConn:Disconnect()
            R.infJumpConn = nil
        end
    end
end)
utilityGroup:CreateToggle("X-Ray", false, function(s)
    R.xrayEnabled = s
    if s then
        R.xrayOriginal = {}
        if R.xrayLoop then pcall(function() task.cancel(R.xrayLoop) end) R.xrayLoop = nil end
        R.xrayLoop = task.spawn(function()
            while R.xrayEnabled do
                local batch = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not R.xrayEnabled then break end
                    if obj:IsA("BasePart") and obj.Parent and obj ~= R.farmPart and obj ~= R.platformPart and obj ~= R.safePlatformPart and obj ~= R.loopGunPlatform then
                        local isChar = false
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr.Character and obj:IsDescendantOf(plr.Character) then
                                isChar = true
                                break
                            end
                        end
                        if not isChar and not R.xrayOriginal[obj] then
                            if obj.Transparency < 0.75 then
                                table.insert(batch, obj)
                                if #batch >= 40 then
                                    for _, p in ipairs(batch) do
                                        if p and p.Parent then
                                            R.xrayOriginal[p] = p.Transparency
                                            p.Transparency = 0.75
                                        end
                                    end
                                    batch = {}
                                    task.wait(0.06)
                                end
                            end
                        end
                    end
                end
                for _, p in ipairs(batch) do
                    if p and p.Parent then
                        R.xrayOriginal[p] = p.Transparency
                        p.Transparency = 0.75
                    end
                end
                task.wait(1)
            end
        end)
        if R.xrayConn then R.xrayConn:Disconnect() end
        R.xrayConn = Workspace.DescendantAdded:Connect(function(obj)
            if not R.xrayEnabled then return end
            if obj:IsA("BasePart") and obj.Parent and obj ~= R.farmPart and obj ~= R.platformPart and obj ~= R.safePlatformPart and obj ~= R.loopGunPlatform then
                task.wait(0.05)
                local isChar = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and obj:IsDescendantOf(plr.Character) then
                        isChar = true
                        break
                    end
                end
                if not isChar and not R.xrayOriginal[obj] then
                    R.xrayOriginal[obj] = obj.Transparency
                    obj.Transparency = 0.75
                end
            end
        end)
    else
        if R.xrayConn then
            R.xrayConn:Disconnect()
            R.xrayConn = nil
        end
        if R.xrayLoop then
            pcall(function() task.cancel(R.xrayLoop) end)
            R.xrayLoop = nil
        end
        for part, old in pairs(R.xrayOriginal) do
            if part and part.Parent then
                pcall(function() part.Transparency = old end)
            end
        end
        R.xrayOriginal = {}
    end
end)
utilityGroup:CreateToggle("Fullbright", false, function(s)
    R.fullbrightEnabled = s
    if s then
        R.oldLighting = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            ExposureCompensation = Lighting.ExposureCompensation
        }
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.ExposureCompensation = 0.2
        if R.fullbrightConn then R.fullbrightConn:Disconnect() end
        R.fullbrightConn = RunService.RenderStepped:Connect(function()
            if not R.fullbrightEnabled then return end
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        end)
    else
        if R.fullbrightConn then
            R.fullbrightConn:Disconnect()
            R.fullbrightConn = nil
        end
        if R.oldLighting.Brightness then Lighting.Brightness = R.oldLighting.Brightness end
        if R.oldLighting.Ambient then Lighting.Ambient = R.oldLighting.Ambient end
        if R.oldLighting.OutdoorAmbient then Lighting.OutdoorAmbient = R.oldLighting.OutdoorAmbient end
        if R.oldLighting.ClockTime then Lighting.ClockTime = R.oldLighting.ClockTime end
        if R.oldLighting.FogEnd then Lighting.FogEnd = R.oldLighting.FogEnd end
        if R.oldLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = R.oldLighting.GlobalShadows end
        if R.oldLighting.ExposureCompensation then Lighting.ExposureCompensation = R.oldLighting.ExposureCompensation end
    end
end)
teleportGroup:CreateButton("TP to Safe Platform", function()
    local part = Instance.new("Part")
    part.Name = "SafePlatform"
    part.Size = Vector3.new(20,1,20)
    part.Position = Vector3.new(0,500000,0)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.3
    part.Material = Enum.Material.ForceField
    part.Parent = Workspace
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHrp then
        myHrp.CFrame = CFrame.new(part.Position + Vector3.new(0,3,0))
    end
end)
teleportGroup:CreateButton("TP Map", function()
    local LogService = game:GetService("LogService")
    local logs = {}
    pcall(function()
        logs = LogService:GetLogHistory()
    end)
    local latestXYZ = nil
    for i = #logs, 1, -1 do
        local entry = logs[i]
        local msg = entry.message or tostring(entry)
        local x,y,z = string.match(msg, "([%-]?%d+%.?%d*)[, ]+%s*([%-]?%d+%.?%d*)[, ]+%s*([%-]?%d+%.?%d*)")
        if x and y and z then
            local nx, ny, nz = tonumber(x), tonumber(y), tonumber(z)
            if nx and ny and nz then
                if math.abs(nx) < 10000 and math.abs(ny) < 10000 and math.abs(nz) < 10000 then
                    latestXYZ = Vector3.new(nx, ny, nz)
                    break
                end
            end
        end
        local vx, vy, vz = string.match(msg, "Vector3%.new%(%s*([%-]?%d+%.?%d*)%s*,%s*([%-]?%d+%.?%d*)%s*,%s*([%-]?%d+%.?%d*)%s*%)")
        if vx and vy and vz then
            latestXYZ = Vector3.new(tonumber(vx), tonumber(vy), tonumber(vz))
            break
        end
    end
    if latestXYZ then
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = CFrame.new(latestXYZ)
            pcall(function() library:Addnotification({title = "TP Map", desc = "TP Map working", duration = 3}) end)
        end
    else
        pcall(function() library:Addnotification({title = "TP Map", desc = "No coordinates found in console!", duration = 3}) end)
        local lastMsg = ""
        pcall(function()
            local history = LogService:GetLogHistory()
            if #history > 0 then
                lastMsg = history[#history].message
            end
        end)
    end
end)
teleportGroup:CreateButton("TP to Lobby", function()
    local spawn
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then spawn = obj break end
    end
    if spawn then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(spawn.Position + Vector3.new(0,3,0)) end
    end
end)
teleportGroup:CreateDivider("")
teleportGroup:CreateButton("TP to Murder", function()
    local m = getMurderPlayer()
    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = m.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2) end
    end
end)
teleportGroup:CreateButton("TP to Sheriff", function()
    local s = getSheriffPlayer()
    if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = s.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2) end
    end
end)
aimbotGroup:CreateToggle("Aimbot Murder", true, function(s)
    if s then
        if not hasTool(LocalPlayer, "gun") then
            pcall(function() library:Addnotification({title = "Aimbot", desc = "Butuh Gun untuk Aimbot Murder!", duration = 3}) end)
            R.aimbotMurderEnabled = false
            return
        end
    end
    R.aimbotMurderEnabled = s
end)
aimbotGroup:CreateToggle("Aimbot Sheriff", false, function(s)
    if s then
        if not hasTool(LocalPlayer, "knife") then
            pcall(function() library:Addnotification({title = "Aimbot", desc = "Butuh Knife untuk Aimbot Sheriff!", duration = 3}) end)
            R.aimbotSheriffEnabled = false
            return
        end
    end
    R.aimbotSheriffEnabled = s
end)
aimbotGroup:CreateToggle("Aimbot Innocent", false, function(s)
    if s then
        if not hasTool(LocalPlayer, "knife") then
            pcall(function() library:Addnotification({title = "Aimbot", desc = "Butuh Knife untuk Aimbot Innocent!", duration = 3}) end)
            R.aimbotInnocentEnabled = false
            return
        end
    end
    R.aimbotInnocentEnabled = s
end)
aimbotGroup:CreateDivider()
aimbotGroup:CreateToggle("Enable Aimbot", false, function(s)
    R.aimbotEnabled = s
    if s then
        startAimbotLoop()
    else
        stopAimbotLoop()
        if R.aimbotInfoGui then
            R.aimbotInfoGui:Destroy()
            R.aimbotInfoGui = nil
        end
    end
end)
uiGroup:CreateButton("Reload Script", function()
    pcall(function() stopTP() end)
    pcall(function() stopFarm() end)
    pcall(function() stopAvoid() end)
    pcall(function() stopLoopGun() end)
    pcall(function() if R.movementConn then R.movementConn:Disconnect() end end)
    pcall(function() setNoclip(false) end)
    pcall(function() if R.infJumpConn then R.infJumpConn:Disconnect() end end)
    pcall(function() if R.xrayConn then R.xrayConn:Disconnect() end end)
    pcall(function() if R.xrayLoop then task.cancel(R.xrayLoop) end end)
    pcall(function() if R.fullbrightConn then R.fullbrightConn:Disconnect() end end)
    pcall(function() stopAimbotLoop() end)
    pcall(function() stopMapHRPButton() end)
    pcall(function() stopAutoGetGun() end)
    pcall(function() stopESPGun() end)
    pcall(function() stopVotePad() end)
    for plr,_ in pairs(R.espData) do pcall(function() removeESP(plr) end) end
    pcall(function() if R.mapHRGui then R.mapHRGui:Destroy() R.mapHRGui=nil end end)
    pcall(function() if R.aimbotInfoGui then R.aimbotInfoGui:Destroy() R.aimbotInfoGui=nil end end)
    pcall(function() if R.espGunBox then R.espGunBox:Destroy() R.espGunBox=nil end end)
    pcall(function() if R.espGunBillboard then R.espGunBillboard:Destroy() R.espGunBillboard=nil end end)
    pcall(function() if R.safePlatformPart then R.safePlatformPart:Destroy() R.safePlatformPart=nil end end)
    pcall(function() if R.farmPart then R.farmPart:Destroy() R.farmPart=nil end end)
    pcall(function() if R.platformPart then R.platformPart:Destroy() R.platformPart=nil end end)
    pcall(function() if R.loopGunPlatform then R.loopGunPlatform:Destroy() R.loopGunPlatform=nil end end)
    task.wait(0.3)
    loadstring(game:HttpGet("https://github.com/XVC-THE-CODER/Renux-Hub/releases/latest/download/loader.lua",true))()
end)
