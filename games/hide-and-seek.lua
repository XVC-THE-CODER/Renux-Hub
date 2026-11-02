local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local success_load = "script has 100% loaded"
local gamename = "Unknown"
local version = "version: 1.4"
local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
if success and info then gamename = info.Name else gamename = game.Name end
local function GetExecutorName()
    if identifyexecutor then
        local name, ver = identifyexecutor()
        return name
    elseif getexecutorname then
            return getexecutorname()
        elseif syn then
                return "Synapse X"
            elseif KRNL_LOADED then
                    return "Krnl"
                elseif Fluxus then
                        return "Fluxus"
                    end
                    return "Unknown"
                end
                local currentExecutor = GetExecutorName()
                local function doServerHop()
                    pcall(function()
                    local servers = {}
                    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
                    local body = game:GetService("HttpService"):JSONDecode(req)
                    if body and body.data then
                        for _, v in pairs(body.data) do
                            if type(v) == "table" and v.maxPlayers and v.playing and v.playing < v.maxPlayers and v.id ~= game.JobId then
                                table.insert(servers, v.id)
                            end
                        end
                    end
                    if #servers > 0 then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
                    end
                end)
            end
            local function doRejoin()
                pcall(function()
                TeleportService:Teleport(game.PlaceId, Player)
            end)
        end
        local Library = nil
        local Toggles = nil
        local Options = nil
        local libSuccess, libResult = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
    end)
    if libSuccess and libResult then
        Library = libResult
        Toggles = Library.Toggles
        Options = Library.Options
    else
            warn("[Renux] Failed to load Obsidian Library, retrying...")
            local retrySuccess, retryResult = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45wrapper/Obsidian/main/Library.lua"))()
        end)
        if retrySuccess and retryResult then
            Library = retryResult
            Toggles = Library.Toggles
            Options = Library.Options
        else
                error("[Renux] Obsidian Library failed to load, UI cannot show")
            end
        end
        if not Library then error("Library nil") end
        local NoclipConn = nil
        local XRayEnabled = nil
        local OriginalTransparencies = {}
        local InvisiblePart = nil
        local CloneChar = nil
        local OriginalChar = nil
        local InvisLoopConn = nil
        local InfiniteJumpConn = nil
        local InvisibleActive = false
        local InfiniteJumpActive = false
        local JumpTweenConn = nil
        local AntiVoidEnabled = nil
        local AntiVoidThread = nil
        local LastSavedCFrame = nil
        local LastCheckPos = nil
        local AvoidItEnabled = nil
        local AvoidRadius = 15
        local AvoidThread = nil
        local WalkSpeedEnabled = nil
        local WalkSpeedValue = 16
        local JumpPowerEnabled = nil
        local JumpPowerValue = 50
        local SavedWalkSpeed = 16
        local SavedJumpPower = 50
        local isEnabled = false
        local oldSettings = {}
        local VisitedCredits = {}
        local CreditTweenEnabled = nil
        local CreditTweenThread = nil
        local LastFarmStartCFrame = nil
        local SafePlatform = nil
        local NewlyJoinedPlayers = {}
        local SpawnLocationsCache = nil
        local function IsPlayerNewlyJoined(p)
            if not p then return false end
            local joinTime = NewlyJoinedPlayers[p]
            if not joinTime then return false end
            return (tick() - joinTime) < 15
        end
        local function GetSpawnLocations()
            if SpawnLocationsCache and #SpawnLocationsCache > 0 then return SpawnLocationsCache end
            local spawns = {}
            for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("SpawnLocation") or v.Name:lower():find("spawn") then
                if v:IsA("BasePart") then table.insert(spawns, v) end
            end
        end
        SpawnLocationsCache = spawns
        return spawns
    end
    local function IsPlayerTouchingSpawn(p)
        if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end
        local hrp = p.Character.HumanoidRootPart
        local spawns = GetSpawnLocations()
        for _, sp in ipairs(spawns) do
            if sp and sp.Parent then
                local dist = (hrp.Position - sp.Position).Magnitude
                if dist < 20 then return true end
            end
        end
        return false
    end
    local function GetOrCreateSafePlatform()
        if SafePlatform and SafePlatform.Parent then return SafePlatform end
        SafePlatform = Instance.new("Part")
        SafePlatform.Name = "RenuxSafePlatform"
        SafePlatform.Size = Vector3.new(100, 2, 100)
        SafePlatform.Position = Vector3.new(0, 100000, 0)
        SafePlatform.Anchored = true
        SafePlatform.CanCollide = true
        SafePlatform.Transparency = 0.3
        SafePlatform.Color = Color3.fromRGB(0,255,0)
        SafePlatform.Parent = Workspace
        return SafePlatform
    end
    local function IsCreditName(name)
        local l = string.lower(name)
        return l:find("credit") or l:find("creadit") or l:find("kredit") or l:find("credits") or l:find("cred")
    end
    local function GetCreditParts()
        local found = {}
        for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and IsCreditName(v.Name) then table.insert(found, v) end
    end
    return found
end
local function GetClosestUnvisitedCredit(list)
    local closest = nil
    local shortestDist = math.huge
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return list[1] end
    for _, part in ipairs(list) do
        if not VisitedCredits[part] then
            local dist = (hrp.Position - part.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = part
            end
        end
    end
    return closest
end
local SeekerHighlights = {}
local SeekerTracers = {}
local SeekerNames = {}
local SeekerConn = nil
local IceBreakerParts = {}
local function GetIceBreakerParts()
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local ln = v.Name:lower()
        if ln:find("icebreak") or ln:find("icebrik") or ln == "icebreaker" or ln == "icebriker"
        or (ln:find("ice") and (ln:find("cage") or ln:find("jail") or ln:find("prison") or ln:find("spawn")))
        or ln:find("itcage") or ln:find("seekercage") or ln:find("itspawn") then
            table.insert(found, v)
        end
    end
end
return found
end
local function IsPlayerAlive(p)
    if not p or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end
local function IsPlayerIt_Verify2(p)
    local result = nil
    pcall(function()
    local playersFolder = Workspace:FindFirstChild("Players") or Workspace:FindFirstChild("players")
    if playersFolder then
        local pf = playersFolder:FindFirstChild(p.Name)
        if pf then
            local pd = pf:FindFirstChild("PlayerData") or pf:FindFirstChild("playerData") or pf:FindFirstChild("Data") or pf
            if pd then
                local itFile = pd:FindFirstChild("It") or pd:FindFirstChild("it") or pd:FindFirstChild("IT") or pd:FindFirstChild("IsIT") or pd:FindFirstChild("IsIt") or pd:FindFirstChild("IsSeeker") or pd:FindFirstChild("Seeker")
                if itFile then
                    if itFile:IsA("BoolValue") then
                        result = itFile.Value
                    elseif itFile:IsA("StringValue") then
                            result = itFile.Value == "true" or itFile.Value == "True"
                        elseif itFile:IsA("IntValue") or itFile:IsA("NumberValue") then
                                result = itFile.Value == 1 or itFile.Value == true
                            end
                        end
                        if result == nil then
                            if pd:GetAttribute("It") ~= nil then result = pd:GetAttribute("It") == true end
                            if result == nil and pd:GetAttribute("IsIT") ~= nil then result = pd:GetAttribute("IsIT") == true end
                            if result == nil and pf:GetAttribute("It") ~= nil then result = pf:GetAttribute("It") == true end
                            if result == nil and pf:GetAttribute("IsIT") ~= nil then result = pf:GetAttribute("IsIT") == true end
                        end
                    end
                end
            end
        end)
        return result
    end
    local function IsPlayerIt(p)
        if not p or not p.Character then return false end
        local char = p.Character
        local v1 = false
        if char:FindFirstChild("Glue") or char:FindFirstChild("Sprint") or char:FindFirstChild("Place Camera")then
        v1 = true
    else
            for _, v in ipairs(char:GetDescendants()) do
            if v.Name == "Glue" or v.Name == "Sprint" or v.Name == "Place Camera" then
                v1 = true
                break
            end
        end
    end
    local v2 = IsPlayerIt_Verify2(p)
    if v1 and v2 == nil then return true end
    if v1 and v2 == false then return true end
    if v1 and v2 == true then return true end
    if not v1 and v2 == true then return true end
    return false
end
local function antifling()
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local heartbeatConnection = nil
    local stateConnection = nil
    local function cleanup()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        if stateConnection then
            stateConnection:Disconnect()
            stateConnection = nil
        end
    end
    local function applyProtections(character)
        cleanup()
        local humanoid = character:WaitForChild("Humanoid", 10)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not humanoid or not rootPart then
            return
        end
        stateConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Ragdoll
        or newState == Enum.HumanoidStateType.FallingDown
        or newState == Enum.HumanoidStateType.PlatformStanding then
            task.defer(function()
            if humanoid and humanoid.Parent then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end)
heartbeatConnection = RunService.Heartbeat:Connect(function()
if not character:IsDescendantOf(workspace) or humanoid.Health <= 0 then
return
end
local currentState = humanoid:GetState()
local isRagdolled = (
currentState == Enum.HumanoidStateType.Ragdoll
or currentState == Enum.HumanoidStateType.FallingDown
or currentState == Enum.HumanoidStateType.PlatformStanding
)
if isRagdolled then
    if rootPart.AssemblyLinearVelocity.Magnitude > 30 then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if rootPart.AssemblyAngularVelocity.Magnitude > 30 then
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end
end)
end
if LocalPlayer.Character then
    applyProtections(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyProtections)
RunService.Stepped:Connect(function()
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        for _, child in ipairs(player.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide then
            child.CanCollide = false
        end
    end
end
end
end)
end
antifling()
local function ClearSeekerESP()
    for p, hl in pairs(SeekerHighlights) do pcall(function() hl:Destroy() end) end
    for p, line in pairs(SeekerTracers) do pcall(function() line:Remove() end) end
    for p, text in pairs(SeekerNames) do pcall(function() text:Remove() end) end
    SeekerHighlights = {}
    SeekerTracers = {}
    SeekerNames = {}
end
local CreditESPDrawings = {}
local CreditESPConn = nil
local CreditESPLoop = nil
local CreditESPEnabled = nil
local function ClearCreditESP()
    for _, d in pairs(CreditESPDrawings) do
        pcall(function() d.box:Remove() end)
        pcall(function() d.text:Remove() end)
    end
    CreditESPDrawings = {}
end
local function CreateCreditESPForPart(part)
    if CreditESPDrawings[part] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Transparency = 1
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Color = Color3.fromRGB(0, 255, 0)
    text.Text = part.Name
    CreditESPDrawings[part] = { box = box, text = text }
end
local TPAllEnabled = nil
local TPAllThread = nil
local TPSpeedValue = "normal"
local BlacklistPlayers = {}
local DeadHistory = {}
local function IsPlayerInIce(p)
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = p.Character.HumanoidRootPart
    local iceParts = GetIceBreakerParts()
    for _, ice in ipairs(iceParts) do
        if (ice.Position - hrp.Position).Magnitude <= 20 then
            return true
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Name:lower():find("ice") and v.Transparency < 1 then
        if (v.Position - hrp.Position).Magnitude <= 15 then
            return true
        end
    end
end
return false
end
local function GetGroundPartBelowPlayer(targetPlayer)
    local char = targetPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), params)
    if result then return result.Instance end
    return nil
end
RunService.Stepped:Connect(function()
local char = Player.Character
if not char then
    if InvisibleActive and CloneChar and CloneChar.Parent then
        char = CloneChar
    end
end
if char then
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if WalkSpeedEnabled then
            hum.WalkSpeed = WalkSpeedValue
        end
        if JumpPowerEnabled then
            hum.JumpPower = JumpPowerValue
        end
    end
end
if InvisibleActive and CloneChar and CloneChar.Parent then
    local hum2 = CloneChar:FindFirstChildOfClass("Humanoid")
    if hum2 then
        if WalkSpeedEnabled then hum2.WalkSpeed = WalkSpeedValue end
        if JumpPowerEnabled then hum2.JumpPower = JumpPowerValue end
    end
end
end)
local Window = nil
local winSuccess, winResult = pcall(function()
return Library:CreateWindow({
Title = "Renux Hub",
Footer = "executor: " .. currentExecutor .. " / " .. version .. " / game: " .. gamename,
Icon = "flame",
NotifySide = "Right",
AutoShow = true,
})
end)
if winSuccess and winResult then
    Window = winResult
else
        warn("[Renux] Window creation failed: " .. tostring(winResult))
        local ok2, win2 = pcall(function()
        return Library:CreateWindow({
        Title = "Renux Hub",
        Footer = gamename,
        NotifySide = "Right",
        AutoShow = true,
        })
    end)
    if ok2 and win2 then Window = win2 else error("Window creation totally failed: " .. tostring(win2)) end
end
print("[Renux] Window created OK")
local tabsOk, tabsErr = pcall(function() end)
local Tab = Window:AddTab({ Name = "info", Description = "side information", Icon = "bell" })
local Tab1 = Window:AddTab({ Name = "Main", Description = "Main features", Icon = "house" })
local Tab2 = Window:AddTab({ Name = "Misc", Description = "Other features", Icon = "between-horizontal-end" })
local SettingTab = Window:AddTab("Setting", "settings")
Window:AddDialog("DialogueIdx", {
Title = "Welcome Back!",
Description = "Do you want to execute the script components?",
AutoDismiss = true,
OutsideClickDismiss = true,
FooterButtons = {
Delete = { Title = "No", Variant = "Destructive", Order = 3, Callback = function() Library:Unload() end },
Confirm = { Title = "Yes", Variant = "Primary", Order = 4, Callback = function() print("[Renux] Script loaded successfully") end }
}
})
print("[Renux] Script loaded in game: " .. gamename)
pcall(function()
Library:SetWatermarkVisibility(true)
end)
pcall(function()
Library:SetWatermark("Renux Hub | " .. version)
end)
pcall(function()
local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
if pg then
    for _, gui in ipairs(pg:GetChildren()) do
        if gui.Name:lower():find("drag") then
            local isWatermark = false
            local lbl = gui:FindFirstChildWhichIsA("TextLabel", true)
            if lbl and lbl.Text:find("Renux Hub") then isWatermark = true end
            if not isWatermark then
                pcall(function() gui:Destroy() end)
            end
        end
        local lbl = gui:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl.Text:lower() == "watermark" then
            pcall(function() gui:Destroy() end)
        end
    end
end
if Library.RemoveDraggableLabel then
    pcall(function() Library:RemoveDraggableLabel("watermark") end)
    pcall(function() Library:RemoveDraggableLabel("renux_version") end)
end
end)
local main = Tab:AddLeftGroupbox("support", "bell")
local setGB = Tab:AddLeftGroupbox("credits", "clipboard")
local seGroupBox = Tab:AddRightGroupbox("logs update", "clipboard")
local main1 = Tab1:AddLeftGroupbox("Main", "house")
local main2 = Tab1:AddRightGroupbox("Farm", "zap")
local tabmain1 = Tab2:AddLeftGroupbox("Movement", "user")
local tabmain2 = Tab2:AddRightGroupbox("ESP", "eye")
local tabmain3 = Tab2:AddRightGroupbox("Server", "server")
local setGroupBox = SettingTab:AddLeftGroupbox("Setting", "settings")
local setGroupBox2 = SettingTab:AddRightGroupbox("Server", "settings")
main:AddButton({
Text = "join discord",
Func = function()
(setclipboard or toclipboard)("https://discord.gg/mXnTVYYYsy")
print("link discord has copy")
end
})
local MyToggle = main1:AddToggle("MyToggle", { Text = "Enable Main Script", Default = false })
local Box = main1:AddDependencyBox()
Box:AddDivider()
Box:AddInput("AvoidRadiusInput", { Text = "Avoid IT Radius", Default = "15", Numeric = true, Finished = false, ClearTextOnFocus = true, Callback = function(Value)
local n = tonumber(Value)
if n then AvoidRadius = n end
end })
Box:AddToggle("AvoidIt", { Text = "Avoid IT", Default = false, Callback = function(Value)
AvoidItEnabled = Value
if Value then
    AvoidThread = task.spawn(function()
    while AvoidItEnabled do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid") then
            local myChar = Player.Character
            local myHrp = myChar.HumanoidRootPart
            local myHum = myChar:FindFirstChildOfClass("Humanoid")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and IsPlayerAlive(p) and IsPlayerIt(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = p.Character.HumanoidRootPart
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude
                    if dist <= AvoidRadius then
                        local dir = (myHrp.Position - targetHrp.Position)
                        if dir.Magnitude == 0 then
                            dir = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
                            if dir.Magnitude == 0 then dir = Vector3.new(1,0,0) end
                        end
                        dir = dir.Unit
                        local tpDist = AvoidRadius + 15
                        local targetPos = myHrp.Position + (dir * tpDist) + Vector3.new(0,1,0)
                        pcall(function()
                        for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = false
                        end
                    end
                end)
                pcall(function()
                myHrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                myHrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end)
            pcall(function()
            myHrp.CFrame = CFrame.new(targetPos)
        end)
        pcall(function()
        if myHum then
            myHum:MoveTo(targetPos)
            myHum.Jump = true
        end
    end)
    pcall(function()
    myHrp.AssemblyLinearVelocity = dir * 50 + Vector3.new(0,20,0)
end)
task.wait(0.08)
pcall(function()
myHrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
myHrp.Velocity = Vector3.new(0,0,0)
end)
break
end
end
end
end
task.wait(0.08)
end
end)
else
        if AvoidThread then
            pcall(function() task.cancel(AvoidThread) end)
            AvoidThread = nil
        end
        pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = true
                end
            end
        end
    end
end)
end
end })
Box:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = function(Value)
if Value then
    NoclipConn = RunService.Stepped:Connect(function()
    if Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
        end
    end
end
end)
else
        if NoclipConn then
            NoclipConn:Disconnect()
            NoclipConn = nil
        end
    end
end })
Box:AddToggle("Invisible", { Text = "Invisible", Default = false, Callback = function(Value)
local function ToggleInvisible(value)
    if value then
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        OriginalChar = Player.Character
        local savedCF = OriginalChar.HumanoidRootPart.CFrame
        if InvisiblePart then InvisiblePart:Destroy() end
        InvisiblePart = Instance.new("Part")
        InvisiblePart.Name = "RenuxAnchor"
        InvisiblePart.Size = Vector3.new(10, 1, 10)
        InvisiblePart.Position = Vector3.new(0, 10000, 0)
        InvisiblePart.Anchored = true
        InvisiblePart.CanCollide = true
        InvisiblePart.Transparency = 1
        InvisiblePart.Parent = Workspace
        OriginalChar.Archivable = true
        CloneChar = OriginalChar:Clone()
        CloneChar.Name = Player.Name .. "_Clone"
        CloneChar.Parent = Workspace
        for _, v in pairs(CloneChar:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = (v.Name ~= "HumanoidRootPart") and 0.75 or 1
            v.CanCollide = true
            v.Anchored = false
        elseif v:IsA("Decal") then
                v.Transparency = 0.75
            end
        end
        if CloneChar:FindFirstChild("HumanoidRootPart") then
            CloneChar.HumanoidRootPart.CFrame = savedCF
        end
        if OriginalChar:FindFirstChild("HumanoidRootPart") then
            OriginalChar.HumanoidRootPart.CFrame = CFrame.new(0, 10000, 0) + Vector3.new(0, 3, 0)
            OriginalChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
        task.wait(0.1)
        Player.Character = CloneChar
        Workspace.CurrentCamera.CameraSubject = CloneChar:FindFirstChildOfClass("Humanoid")
        if InvisLoopConn then InvisLoopConn:Disconnect() end
        InvisLoopConn = RunService.Heartbeat:Connect(function()
        pcall(function()
        if OriginalChar and OriginalChar:FindFirstChild("HumanoidRootPart") and InvisiblePart then
            OriginalChar.HumanoidRootPart.CFrame = InvisiblePart.CFrame + Vector3.new(0, 3, 0)
            OriginalChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end)
else
        if InvisLoopConn then
            InvisLoopConn:Disconnect()
            InvisLoopConn = nil
        end
        if OriginalChar and CloneChar and CloneChar:FindFirstChild("HumanoidRootPart") then
            local targetCF = CloneChar.HumanoidRootPart.CFrame
            if OriginalChar:FindFirstChild("HumanoidRootPart") then
                OriginalChar.HumanoidRootPart.CFrame = targetCF
            end
            task.wait(0.1)
            Player.Character = OriginalChar
            Workspace.CurrentCamera.CameraSubject = OriginalChar:FindFirstChildOfClass("Humanoid")
            task.wait(0.2)
            if OriginalChar:FindFirstChild("HumanoidRootPart") then
                OriginalChar.HumanoidRootPart.CFrame = targetCF
            end
        end
        if CloneChar then CloneChar:Destroy() CloneChar = nil end
        if InvisiblePart then InvisiblePart:Destroy() InvisiblePart = nil end
        OriginalChar = nil
    end
end
if Value then
    local gui = Instance.new("ScreenGui")
    gui.Name = "RenuxInvisibleUI"
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 140, 0, 50)
    frame.Position = UDim2.new(0.5, -70, 0.5, -25)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    frame.BackgroundTransparency = 0.25
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = frame
    local dragging = false
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end
end)
frame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
    dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
btn.BackgroundTransparency = 0.25
btn.Text = "invisible : off"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 12
btn.Font = Enum.Font.Gotham
btn.TextStrokeTransparency = 0.6
btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btn.Parent = frame
local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 8)
c1.Parent = btn
local s1 = Instance.new("UIStroke")
s1.Color = Color3.fromRGB(255, 255, 255)
s1.Thickness = 1
s1.Parent = btn
local function EnableOriginal()
    ToggleInvisible(true)
    InvisibleActive = true
    btn.Text = "invisible : on"
end
local function DisableOriginal()
    ToggleInvisible(false)
    InvisibleActive = false
    btn.Text = "invisible : off"
end
btn.MouseButton1Click:Connect(function()
if InvisibleActive then
    DisableOriginal()
else
        EnableOriginal()
    end
end)
ToggleInvisible(true)
InvisibleActive = true
btn.Text = "invisible : on"
else
        pcall(function()
        local pg = Player:FindFirstChild("PlayerGui")
        if pg then
            local g = pg:FindFirstChild("RenuxInvisibleUI")
            if g then g:Destroy() end
        end
    end)
    ToggleInvisible(false)
    InvisibleActive = false
end
end })
local FreecamEnabled = nil
local FreecamConn = nil
local FreecamPart = nil
local FreecamCtrl = nil
local FreecamSaved = {}
local FreecamOriginalHRPAnchored = false
local FreecamSpeed = 40
local function StartFreecam()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if FreecamPart and FreecamPart.Parent then FreecamPart:Destroy() end
    FreecamPart = Instance.new("Part")
    FreecamPart.Name = "Renux_FreecamPart"
    FreecamPart.Size = Vector3.new(1,1,1)
    FreecamPart.Transparency = 1
    FreecamPart.Anchored = true
    FreecamPart.CanCollide = false
    FreecamPart.CanQuery = false
    FreecamPart.CanTouch = false
    FreecamPart.CFrame = hrp.CFrame + Vector3.new(0,2,0)
    FreecamPart.Parent = Workspace
    FreecamSaved.WalkSpeed = hum.WalkSpeed
    FreecamSaved.JumpPower = hum.JumpPower
    FreecamSaved.JumpHeight = hum.JumpHeight
    FreecamSaved.AutoRotate = hum.AutoRotate
    FreecamSaved.PlatformStand = hum.PlatformStand
    FreecamSaved.CameraType = Workspace.CurrentCamera.CameraType
    FreecamSaved.CameraSubject = Workspace.CurrentCamera.CameraSubject
    FreecamSaved.CameraMaxZoom = Player.CameraMaxZoomDistance
    FreecamSaved.CameraMinZoom = Player.CameraMinZoomDistance
    FreecamSaved.FieldOfView = Workspace.CurrentCamera.FieldOfView
    FreecamOriginalHRPAnchored = hrp.Anchored
    pcall(function()
    local playerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
    FreecamCtrl = playerModule:GetControls()
end)
hum.PlatformStand = true
hum.AutoRotate = false
hrp.Anchored = true
hum:ChangeState(Enum.HumanoidStateType.Physics)
Player.CameraMaxZoomDistance = 0
Player.CameraMinZoomDistance = 0
Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
Workspace.CurrentCamera.CameraSubject = FreecamPart
Workspace.CurrentCamera.CFrame = CFrame.new(FreecamPart.Position, FreecamPart.Position + Workspace.CurrentCamera.CFrame.LookVector)
if FreecamConn then FreecamConn:Disconnect() end
FreecamConn = RunService.RenderStepped:Connect(function(dt)
if not FreecamEnabled then return end
if not FreecamPart or not FreecamPart.Parent then return end
local cam = Workspace.CurrentCamera
if not cam then return end
local moveVector = Vector3.new(0,0,0)
if FreecamCtrl then
    pcall(function() moveVector = FreecamCtrl:GetMoveVector() end)
end
if moveVector.Magnitude < 0.1 then
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0,0,-1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1,0,0) end
end
local upDown = 0
if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then upDown = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then upDown = -1 end
local rightVec = cam.CFrame.RightVector
local lookVec = cam.CFrame.LookVector
local upVec = Vector3.new(0,1,0)
local finalMove = (rightVec * moveVector.X) + (lookVec * -moveVector.Z) + (upVec * upDown)
if finalMove.Magnitude > 0 then
    finalMove = finalMove.Unit * FreecamSpeed * dt * 3
    FreecamPart.CFrame = FreecamPart.CFrame + finalMove
end
Player.CameraMaxZoomDistance = 0
Player.CameraMinZoomDistance = 0
cam.CameraSubject = FreecamPart
if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
end)
end
local function StopFreecam()
    FreecamEnabled = false
    if FreecamConn then FreecamConn:Disconnect() FreecamConn=nil end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored = FreecamOriginalHRPAnchored or false end
    if hum then
        hum.PlatformStand = FreecamSaved.PlatformStand or false
        hum.AutoRotate = FreecamSaved.AutoRotate == nil and true or FreecamSaved.AutoRotate
        hum.WalkSpeed = FreecamSaved.WalkSpeed or 16
        hum.JumpPower = FreecamSaved.JumpPower or 50
        hum.JumpHeight = FreecamSaved.JumpHeight or 7.2
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    Player.CameraMaxZoomDistance = FreecamSaved.MaxZoom or 20
    Player.CameraMinZoomDistance = FreecamSaved.MinZoom or 0.5
    if FreecamSaved.CameraType then Workspace.CurrentCamera.CameraType = FreecamSaved.CameraType end
    if hum then Workspace.CurrentCamera.CameraSubject = hum else Workspace.CurrentCamera.CameraSubject = FreecamSaved.CameraSubject end
    if FreecamPart and FreecamPart.Parent then FreecamPart:Destroy() end
    FreecamPart = nil
    FreecamCtrl = nil
end
Box:AddToggle("Freecam", { Text = "Freecam", Default = false, Callback = function(Value)
local function ToggleFreecam(value)
    if value then
        StartFreecam()
        FreecamEnabled = true
    else
            StopFreecam()
            FreecamEnabled = false
        end
    end
    if Value then
        local gui = Instance.new("ScreenGui")
        gui.Name = "RenuxFreecamUI"
        gui.ResetOnSpawn = false
        gui.Parent = Player:WaitForChild("PlayerGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 140, 0, 50)
        frame.Position = UDim2.new(0.5, 70, 0.5, -25)
        frame.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        frame.BackgroundTransparency = 0.25
        frame.Active = true
        frame.Draggable = true
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.2
        stroke.Parent = frame
        local dragging = false
        local dragInput, dragStart, startPos
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
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
btn.BackgroundTransparency = 0.25
btn.Text = "freecam : off"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 12
btn.Font = Enum.Font.Gotham
btn.TextStrokeTransparency = 0.6
btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btn.Parent = frame
local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 8)
c1.Parent = btn
local s1 = Instance.new("UIStroke")
s1.Color = Color3.fromRGB(255, 255, 255)
s1.Thickness = 1
s1.Parent = btn
local function EnableFC() ToggleFreecam(true) FreecamEnabled=true btn.Text="freecam : on" end
local function DisableFC() ToggleFreecam(false) FreecamEnabled=false btn.Text="freecam : off" end
btn.MouseButton1Click:Connect(function() if FreecamEnabled then DisableFC() else EnableFC() end end)
ToggleFreecam(true) FreecamEnabled=true btn.Text="freecam : on"
else
        pcall(function()
        local pg = Player:FindFirstChild("PlayerGui")
        if pg then local g = pg:FindFirstChild("RenuxFreecamUI") if g then g:Destroy() end end
    end)
    ToggleFreecam(false) FreecamEnabled=false
end
end })
Box:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false, Callback = function(Value)
InfiniteJumpActive = Value
if Value then
    if InfiniteJumpConn then InfiniteJumpConn:Disconnect() end
    InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpActive then return end
    local char = nil
    if InvisibleActive and CloneChar and CloneChar.Parent then
        char = CloneChar
    else
            char = Player.Character
        end
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
else
        if InfiniteJumpConn then
            InfiniteJumpConn:Disconnect()
            InfiniteJumpConn = nil
        end
        if JumpTweenConn then
            JumpTweenConn:Disconnect()
            JumpTweenConn = nil
        end
    end
end })
local MasterTPToggle = main2:AddToggle("MasterTP", { Text = "Enable Farm", Default = false })
local TPBox = main2:AddDependencyBox()
TPBox:AddDivider()
TPBox:AddDropdown("TPSpeedDropdown", {
Text = "mode kill all",
Values = { "normal", "fastest" },
Default = 1,
Multi = false,
Callback = function(Value)
TPSpeedValue = Value
end
})
local function GetPlayerNamesList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list, "None") end
    return list
end
TPBox:AddDropdown("BlacklistDropdown", {
Text = "Blacklist Player",
Values = GetPlayerNamesList(),
Default = {},
Multi = true,
Callback = function(Value)
local newList = {}
if type(Value) == "table" then
    for k, v in pairs(Value) do
        if type(k) == "string" and v == true then
            newList[k] = true
        elseif type(v) == "string" and v ~= "None" then
                newList[v] = true
            end
        end
    end
    BlacklistPlayers = newList
end
})
Players.PlayerAdded:Connect(function(p)
NewlyJoinedPlayers[p] = tick()
pcall(function()
if Options.BlacklistDropdown then
    Options.BlacklistDropdown:SetValues(GetPlayerNamesList())
end
end)
end)
Players.PlayerRemoving:Connect(function(p)
NewlyJoinedPlayers[p] = nil
end)
local FrozenTargets = {}
local OriginalAnimStates = {}
local IceHistory = {}
local function GetIceCubePartsNearChar(char, radius)
    radius = radius or 12
    local parts = {}
    if not char or not char:FindFirstChild("HumanoidRootPart") then return parts end
    local hrp = char.HumanoidRootPart
    for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local ln = v.Name:lower()
        if ln:find("icecube") or ln:find("ice cube") or (ln:find("ice") and (ln:find("cube") or ln:find("cage") or ln:find("break"))) then
            if (v.Position - hrp.Position).Magnitude <= radius and v.Transparency < 1 then
                table.insert(parts, v)
            end
        end
    end
end
return parts
end
local function IsPlayerInIce(p)
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end
    local ices = GetIceCubePartsNearChar(p.Character, 12)
    return #ices > 0
end
local function LocalHasIceCube()
    local char = (InvisibleActive and CloneChar and CloneChar.Parent) and CloneChar or Player.Character
    if not char then return false end
    local ices = GetIceCubePartsNearChar(char, 12)
    return #ices > 0, ices
end
local function FreezeTarget(p)
    if not p or not p.Character then return end
    if FrozenTargets[p] then return end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    FrozenTargets[p] = true
    OriginalAnimStates[p] = {}
    pcall(function()
    for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
        OriginalAnimStates[p][tr] = true
        tr:Stop()
    end
    hum.AutoRotate = false
    hum.PlatformStand = true
    hrp.Anchored = true
end)
end
local function UnfreezeTarget(p)
    if not p or not p.Character then return end
    if not FrozenTargets[p] then return end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        pcall(function()
        hrp.Anchored = false
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
end
FrozenTargets[p] = nil
OriginalAnimStates[p] = nil
end
TPBox:AddToggle("TPAllGroundCheck", { Text = "kill all Players", Default = false, Callback = function(Value)
TPAllEnabled = Value
if Value then
    TPAllThread = task.spawn(function()
    while TPAllEnabled do
        if not IsPlayerIt(Player) then task.wait(0.5)
        else
                local hasIceLocal, _ = LocalHasIceCube()
                if hasIceLocal then
                    task.wait(0.3)
                    while TPAllEnabled and IsPlayerIt(Player) do
                        local stillHas, _ = LocalHasIceCube()
                        if not stillHas then break end
                        task.wait(0.2)
                    end
                    continue
                end
                for _, target in ipairs(Players:GetPlayers()) do
                    if not TPAllEnabled then break end
                    if not IsPlayerIt(Player) then break end
                    local hasIceNow, _ = LocalHasIceCube()
                    if hasIceNow then break end
                    if target == Player then continue end
                    if BlacklistPlayers[target.Name] == true then continue end
                    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then continue end
                    if TPSpeedValue == "normal" then
                        if IsPlayerNewlyJoined(target) then continue end
                        if IsPlayerTouchingSpawn(target) then continue end
                    end
                    local inIce = IsPlayerInIce(target)
                    if inIce then
                        IceHistory[target] = true
                        continue
                    else
                            if IceHistory[target] then
                                IceHistory[target] = nil
                                UnfreezeTarget(target)
                                if DeadHistory[target] then DeadHistory[target] = nil end
                            end
                        end
                        local hum = target.Character:FindFirstChildOfClass("Humanoid")
                        if not hum then continue end
                        if hum.Health <= 0 then DeadHistory[target]=true UnfreezeTarget(target) continue else if DeadHistory[target] then DeadHistory[target]=nil end end
                        if IsPlayerIt(target) then continue end
                        local ground = GetGroundPartBelowPlayer(target)
                        if ground and ground.Transparency == 0 then
                            local activeChar = (InvisibleActive and CloneChar and CloneChar.Parent) and CloneChar or Player.Character
                            if activeChar and activeChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = target.Character.HumanoidRootPart
                                if TPSpeedValue == "fastest" then
                                    FreezeTarget(target)
                                    pcall(function()
                                    for _, part in ipairs(target.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end)
                            hrp.CFrame = activeChar.HumanoidRootPart.CFrame
                            hrp.Velocity = Vector3.new(0,0,0)
                            if not IsPlayerAlive(target) then DeadHistory[target]=true UnfreezeTarget(target) end
                        else
                                pcall(function()
                                for _, otherP in ipairs(Players:GetPlayers()) do
                                    if otherP ~= Player and otherP ~= target and otherP.Character then
                                        for _, part in ipairs(otherP.Character:GetDescendants()) do
                                        if part:IsA("BasePart") then
                                            part.CanCollide = false
                                            part.CanTouch = false
                                        end
                                    end
                                end
                            end
                            for _, part in ipairs(target.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = true end
                        end
                    end)
                    local killStart = tick()
                    while TPAllEnabled and IsPlayerAlive(target) and not IsPlayerIt(target) and not IsPlayerInIce(target) and (tick()-killStart) < 5 do
                        local hasIceNow2, _ = LocalHasIceCube()
                        if hasIceNow2 then break end
                        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then break end
                        local tHrp = target.Character.HumanoidRootPart
                        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                        if not tHum or tHum.Health <= 0 then DeadHistory[target]=true UnfreezeTarget(target) break end
                        if IsPlayerIt(target) then break end
                        local targetCF = tHrp.CFrame
                        local targetPos = Vector3.new(targetCF.Position.X, targetCF.Position.Y, targetCF.Position.Z)
                        pcall(function()
                        activeChar.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                        activeChar.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                        activeChar.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        local activeHum = activeChar:FindFirstChildOfClass("Humanoid")
                        if activeHum then
                            activeHum:MoveTo(targetPos)
                        end
                    end)
                    task.wait(0.12)
                end
                pcall(function()
                for _, otherP in ipairs(Players:GetPlayers()) do
                    if otherP ~= Player and otherP.Character then
                        for _, part in ipairs(otherP.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = true
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
        if not IsPlayerAlive(target) then DeadHistory[target]=true UnfreezeTarget(target) end
    end
end
end
end
task.wait(0.2)
end
end
for _, target in ipairs(Players:GetPlayers()) do
    UnfreezeTarget(target)
    IceHistory[target]=nil
    if target ~= Player and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = true end
    end
end
end)
else
        TPAllEnabled = false
        for _, target in ipairs(Players:GetPlayers()) do
            UnfreezeTarget(target)
            IceHistory[target]=nil
            if target ~= Player and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = true end
            end
        end
    end
end })
TPBox:AddToggle("CreditTween", { Text = "farm credit", Default = false, Callback = function(Value)
CreditTweenEnabled = Value
if Value then
    CreditTweenThread = task.spawn(function()
    while CreditTweenEnabled do
        local list = GetCreditParts()
        if #list == 0 then
            table.clear(VisitedCredits)
            task.wait(0.5)
        else
                local nextPart = GetClosestUnvisitedCredit(list)
                if not nextPart then
                    table.clear(VisitedCredits)
                    nextPart = GetClosestUnvisitedCredit(list)
                end
                local activeChar = (InvisibleActive and CloneChar and CloneChar.Parent) and CloneChar or Player.Character
                if nextPart and activeChar and activeChar:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                    local hrp = activeChar.HumanoidRootPart
                    local dist = (hrp.Position - nextPart.Position).Magnitude
                    if dist > 50 then
                        hrp.CFrame = nextPart.CFrame + Vector3.new(0, 2, 0)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    else
                            local speed = 350
                            local tweenTime = math.max(dist / speed, 0.05)
                            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(hrp, tweenInfo, { CFrame = nextPart.CFrame + Vector3.new(0, 2, 0) })
                            tween:Play()
                            local elapsed = 0
                            while tween.PlaybackState == Enum.PlaybackState.Playing and CreditTweenEnabled do
                                task.wait(0.01)
                                elapsed = elapsed + 0.01
                                if elapsed > tweenTime + 0.1 then break end
                            end
                        end
                    end)
                    VisitedCredits[nextPart] = true
                end
                task.wait(0.05)
            end
        end
    end)
else
        CreditTweenEnabled = false
    end
end })
TPBox:AddDivider()
TPBox:AddButton({
Text = "TP Safe Platform",
Func = function()
local plat = GetOrCreateSafePlatform()
if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
    pcall(function()
    Player.Character.HumanoidRootPart.CFrame = plat.CFrame + Vector3.new(0, 5, 0)
    Player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
end)
print("Teleported to Safe Platform!")
end
end
})
TPBox:SetupDependencies({ { Toggles.MasterTP, true } })
Box:SetupDependencies({ { Toggles.MyToggle, true } })
tabmain1:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed Enable", Default = false, Callback = function(Value)
if Value then
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        SavedWalkSpeed = hum.WalkSpeed
    end
    WalkSpeedEnabled = true
else
        WalkSpeedEnabled = false
        local function RestoreWS(char)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = SavedWalkSpeed end
            end
        end
        RestoreWS(Player.Character)
        if CloneChar then RestoreWS(CloneChar) end
        if OriginalChar then RestoreWS(OriginalChar) end
    end
end })
tabmain1:AddToggle("JumpPowerToggle", { Text = "JumpPower Enable", Default = false, Callback = function(Value)
if Value then
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        SavedJumpPower = hum.JumpPower
    end
    JumpPowerEnabled = true
else
        JumpPowerEnabled = false
        local function RestoreJP(char)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = SavedJumpPower end
            end
        end
        RestoreJP(Player.Character)
        if CloneChar then RestoreJP(CloneChar) end
        if OriginalChar then RestoreJP(OriginalChar) end
    end
end })
tabmain1:AddDivider()
tabmain1:AddInput("WalkSpeedInput", { Default = "16", Numeric = true, Finished = false, ClearTextOnFocus = true, Text = "WalkSpeed Value", Callback = function(Value) local n = tonumber(Value) if n then WalkSpeedValue = n end end })
tabmain1:AddInput("JumpPowerInput", { Default = "50", Numeric = true, Finished = false, ClearTextOnFocus = true, Text = "JumpPower Value", Callback = function(Value) local n = tonumber(Value) if n then JumpPowerValue = n end end })
tabmain2:AddToggle("ESPAllPlayers", { Text = "ESP Player", Default = false, Callback = function(Value)
if Value then
    SeekerConn = RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    for _, p in ipairs(Players:GetPlayers()) do
        if p == Player then continue end
        if not IsPlayerAlive(p) or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            if SeekerHighlights[p] then pcall(function() SeekerHighlights[p]:Destroy() end) SeekerHighlights[p] = nil end
            if SeekerTracers[p] then pcall(function() SeekerTracers[p]:Remove() end) SeekerTracers[p] = nil end
            if SeekerNames[p] then pcall(function() SeekerNames[p]:Remove() end) SeekerNames[p] = nil end
            continue
        end
        local isIt = IsPlayerIt(p)
        local espColor = isIt and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        if not SeekerHighlights[p] or SeekerHighlights[p].Parent ~= p.Character then
            if SeekerHighlights[p] then pcall(function() SeekerHighlights[p]:Destroy() end) end
            local hl = Instance.new("Highlight")
            hl.Name = "RenuxPlayerHL"
            hl.FillColor = espColor
            hl.OutlineColor = espColor
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.Parent = p.Character
            SeekerHighlights[p] = hl
        else
                SeekerHighlights[p].FillColor = espColor
                SeekerHighlights[p].OutlineColor = espColor
            end
            if not SeekerTracers[p] then
                local line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Color = espColor
                line.Transparency = 1
                SeekerTracers[p] = line
            else
                    SeekerTracers[p].Color = espColor
                end
                if not SeekerNames[p] then
                    local text = Drawing.new("Text")
                    text.Size = 13
                    text.Center = true
                    text.Outline = true
                    text.OutlineColor = Color3.new(0, 0, 0)
                    text.Color = espColor
                    SeekerNames[p] = text
                else
                        SeekerNames[p].Color = espColor
                    end
                    local hrp = p.Character.HumanoidRootPart
                    local dist = math.floor((cam.CFrame.Position - hrp.Position).Magnitude)
                    SeekerNames[p].Text = p.Name .. (isIt and " [IT]" or "") .. " [" .. dist .. "m]"
                    local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        SeekerTracers[p].From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        SeekerTracers[p].To = Vector2.new(pos.X, pos.Y)
                        SeekerTracers[p].Visible = true
                    else
                            SeekerTracers[p].Visible = false
                        end
                        local namePos, nameOnScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, -3.2, 0))
                        if nameOnScreen then
                            SeekerNames[p].Position = Vector2.new(namePos.X, namePos.Y)
                            SeekerNames[p].Visible = true
                        else
                                SeekerNames[p].Visible = false
                            end
                        end
                        for p, hl in pairs(SeekerHighlights) do
                            if not Players:FindFirstChild(p.Name) or not IsPlayerAlive(p) then
                                pcall(function() hl:Destroy() end)
                                SeekerHighlights[p] = nil
                                if SeekerTracers[p] then
                                    pcall(function() SeekerTracers[p]:Remove() end)
                                    SeekerTracers[p] = nil
                                end
                                if SeekerNames[p] then
                                    pcall(function() SeekerNames[p]:Remove() end)
                                    SeekerNames[p] = nil
                                end
                            end
                        end
                    end)
                else
                        if SeekerConn then SeekerConn:Disconnect() SeekerConn = nil end
                        ClearSeekerESP()
                    end
                end })
                tabmain2:AddToggle("CreditESP", { Text = "ESP Credit", Default = false, Callback = function(Value)
                CreditESPEnabled = Value
                if Value then
                    ClearCreditESP()
                    for _, part in ipairs(GetCreditParts()) do CreateCreditESPForPart(part) end
                    CreditESPConn = RunService.RenderStepped:Connect(function()
                    local cam = Workspace.CurrentCamera
                    for part, draws in pairs(CreditESPDrawings) do
                        if not part or not part.Parent then
                            pcall(function() draws.box:Remove() end)
                            pcall(function() draws.text:Remove() end)
                            CreditESPDrawings[part] = nil
                        else
                                local vec, onScreen = cam:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local dist = (cam.CFrame.Position - part.Position).Magnitude
                                    draws.text.Visible = true
                                    draws.text.Position = Vector2.new(vec.X, vec.Y - 20)
                                    draws.text.Text = part.Name .. " [" .. math.floor(dist) .. "m]"
                                    draws.box.Visible = true
                                    local size = math.clamp(2500 / dist, 15, 120)
                                    draws.box.Size = Vector2.new(size, size)
                                    draws.box.Position = Vector2.new(vec.X - size / 2, vec.Y - size / 2)
                                else
                                        draws.text.Visible = false
                                        draws.box.Visible = false
                                    end
                                end
                            end
                        end)
                        CreditESPLoop = task.spawn(function()
                        while CreditESPEnabled do
                            for _, part in ipairs(GetCreditParts()) do
                                if not CreditESPDrawings[part] then CreateCreditESPForPart(part) end
                            end
                            task.wait(3)
                        end
                    end)
                else
                        if CreditESPConn then CreditESPConn:Disconnect() CreditESPConn = nil end
                        ClearCreditESP()
                    end
                end })
                tabmain3:AddToggle("fullbright", {
                Text = "fullbright",
                Default = false,
                Callback = function()
                isEnabled = not isEnabled
                if isEnabled then
                    oldSettings = {
                    Ambient = Lighting.Ambient,
                    OutdoorAmbient = Lighting.OutdoorAmbient,
                    Brightness = Lighting.Brightness,
                    ColorShift_Bottom = Lighting.ColorShift_Bottom,
                    ColorShift_Top = Lighting.ColorShift_Top,
                    ExposureCompensation = Lighting.ExposureCompensation,
                    FogEnd = Lighting.FogEnd,
                    GlobalShadows = Lighting.GlobalShadows,
                    ClockTime = Lighting.ClockTime
                    }
                    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                    Lighting.Brightness = 2
                    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
                    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
                    Lighting.ExposureCompensation = 0
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    Lighting.ClockTime = 14
                else
                        for prop, value in pairs(oldSettings) do
                            Lighting[prop] = value
                        end
                    end
                end
                })
                tabmain3:AddToggle("XRay", { Text = "X-Ray", Default = false, Callback = function(Value)
                XRayEnabled = Value
                if Value then
                    OriginalTransparencies = {}
                    task.spawn(function()
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    local allParts = {}
                    for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Transparency < 1 then
                        if hrp and (v.Position - hrp.Position).Magnitude > 300 then
                        end
                        if v.Name:lower():find("spawn") or v.Name:lower():find("safe") then
                            continue
                        end
                        table.insert(allParts, v)
                    end
                end
                local batchSize = 80
                local steps = {0.1, 0.25, 0.4, 0.55, 0.75}
                for i = 1, #allParts, batchSize do
                    if not XRayEnabled then break end
                    local batchEnd = math.min(i + batchSize - 1, #allParts)
                    for _, s in ipairs(steps) do
                        if not XRayEnabled then break end
                        for j = i, batchEnd do
                            local v = allParts[j]
                            if v and v.Parent then
                                if OriginalTransparencies[v] == nil then
                                    OriginalTransparencies[v] = v.Transparency
                                end
                                v.Transparency = s
                            end
                        end
                        task.wait(0.02)
                    end
                    for j = i, batchEnd do
                        local v = allParts[j]
                        if v and v.Parent and XRayEnabled then
                            v.Transparency = 0.75
                        end
                    end
                end
            end)
        else
                for v, orig in pairs(OriginalTransparencies) do
                    if v and v.Parent then
                        v.Transparency = orig
                    end
                end
                OriginalTransparencies = {}
            end
        end })
        tabmain3:AddToggle("AntiVoid", { Text = "Anti Void", Default = false, Callback = function(Value)
        AntiVoidEnabled = Value
        if Value then
            AntiVoidThread = task.spawn(function()
            while AntiVoidEnabled do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid") then
                    local hrp = Player.Character.HumanoidRootPart
                    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                    local pos = hrp.Position
                    if pos.Y <= -175 then
                        if LastSavedCFrame then
                            hrp.CFrame = LastSavedCFrame
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                            if hum.FloorMaterial ~= Enum.Material.Air then
                                if not LastCheckPos or (pos - LastCheckPos).Magnitude > 0.1 then
                                    LastSavedCFrame = hrp.CFrame
                                    LastCheckPos = pos
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
                AntiVoidEnabled = false
            end
        end })
        setGroupBox:AddLabel("setting Script")
        local function DisableAllSystemsInstant()
            getgenv().MasterTP = false
            getgenv().TPAllEnabled = false
            getgenv().CreditTweenEnabled = false
            getgenv().AntiVoidEnabled = false
            getgenv().AvoidItEnabled = false
            pcall(function() if Toggles.AntiIT then Toggles.AntiIT:SetValue(false) end end)
            getgenv().InfiniteJumpActive = false
            getgenv().InvisibleActive = false
            getgenv().WalkSpeedEnabled = false
            getgenv().JumpPowerEnabled = false
            pcall(function() if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end end)
            pcall(function() if InvisLoopConn then InvisLoopConn:Disconnect() InvisLoopConn = nil end end)
            pcall(function() if InfiniteJumpConn then InfiniteJumpConn:Disconnect() InfiniteJumpConn = nil end end)
            pcall(function() if SeekerConn then SeekerConn:Disconnect() SeekerConn = nil end ClearSeekerESP() end)
            pcall(function() if CreditESPConn then CreditESPConn:Disconnect() CreditESPConn = nil end ClearCreditESP() end)
            pcall(function() if XRayEnabled then XRayEnabled = false for v, orig in pairs(OriginalTransparencies) do if v and v.Parent then v.Transparency = orig end end OriginalTransparencies = {} end end)
            pcall(function() if TPAllThread then task.cancel(TPAllThread) TPAllThread = nil end end)
            pcall(function() if CreditTweenThread then task.cancel(CreditTweenThread) CreditTweenThread = nil end end)
            pcall(function() if AvoidThread then task.cancel(AvoidThread) AvoidThread = nil end end)
            pcall(function() if AntiVoidThread then task.cancel(AntiVoidThread) AntiVoidThread = nil end end)
            pcall(function()
            local pg = Player:FindFirstChild("PlayerGui")
            if pg then
                local g = pg:FindFirstChild("RenuxInvisibleUI")
                if g then g:Destroy() end
            end
        end)
    end
    setGroupBox:AddButton({ Text = "restart Script", Func = function()
    DisableAllSystemsInstant()
    if Library then Library:Unload() end
    task.spawn(function()
    task.wait(0.2)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua", true))()
end)
end })
setGroupBox:AddButton({
Text = "delete Script",
Func = function()
print("[Renux] Notify removed")
DisableAllSystemsInstant()
task.wait(0.35)
Library:Unload()
end
})
setGroupBox2:AddButton({ Text = "Server Hop", Func = doServerHop })
setGroupBox2:AddButton({ Text = "Rejoin", Func = doRejoin })
setGB:AddLabel("• Renux Hub")
setGB:AddLabel("• mspaint")
seGroupBox:AddLabel("• add ui invisible")
seGroupBox:AddLabel("• change esp color")
seGroupBox:AddLabel("• fix kill all")
seGroupBox:AddLabel("• add Freecam")
print(success_load)