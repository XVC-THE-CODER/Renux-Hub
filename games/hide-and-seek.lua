local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

local gamename = "Unknown"
local version = "version: 1.2"
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

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local Toggles = Library.Toggles

local NoclipConn = nil
local XRayEnabled = false
local OriginalTransparencies = {}
local InvisiblePart = nil
local CloneChar = nil
local OriginalChar = nil
local InvisLoopConn = nil
local InfiniteJumpConn = nil

local AntiVoidEnabled = false
local AntiVoidThread = nil
local LastSavedCFrame = nil
local LastCheckPos = nil

local AvoidPlayersEnabled = false
local AvoidRadius = 15
local AvoidThread = nil

local WalkSpeedEnabled = false
local WalkSpeedValue = 16
local JumpPowerEnabled = false
local JumpPowerValue = 50

local VisitedCredits = {}
local CreditTPEnabled = false
local CreditTPThread = nil

local SafePlatform = nil
local SafeTPEnabled = false
local SafeTPThread = nil

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

local function GetNextUnvisitedCredit(list)
    for _, part in ipairs(list) do if not VisitedCredits[part] then return part end end
    return nil
end

local SeekerHighlights = {}
local SeekerTracers = {}
local SeekerNames = {}
local HiderHighlights = {}
local HiderTracers = {}
local SeekerConn = nil
local IceBreakerParts = {}
local IceBreakerScanTick = 0
local CurrentIceSeeker = nil

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

local function HasParticleSystem(char)
    if not char then return false end
    for _, d in pairs(char:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke") then return true end
    end
    return false
end

local function IsInIceBreakerRange(player, distThreshold)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    IceBreakerParts = GetIceBreakerParts()
    for _, part in ipairs(IceBreakerParts) do
        if not part or not part.Parent then continue end
        local d = (hrp.Position - part.Position).Magnitude
        local sizeLimit = (part.Size.Magnitude / 2) + distThreshold
        if d <= sizeLimit then return true end
    end
    return false
end

local function IsPlayerAlive(p)
    if not p or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function ClearSeekerESP()
    for _, hl in pairs(SeekerHighlights) do pcall(function() hl:Destroy() end) end
    for _, line in pairs(SeekerTracers) do pcall(function() line:Remove() end) end
    for _, text in pairs(SeekerNames) do pcall(function() text:Remove() end) end
    for _, hl in pairs(HiderHighlights) do pcall(function() hl:Destroy() end) end
    for _, line in pairs(HiderTracers) do pcall(function() line:Remove() end) end
    SeekerHighlights = {}
    SeekerTracers = {}
    SeekerNames = {}
    HiderHighlights = {}
    HiderTracers = {}
end

local CreditESPDrawings = {}
local CreditESPConn = nil
local CreditESPLoop = nil
local CreditESPEnabled = false

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

local TPAllEnabled = false
local TPAllThread = nil
local TPSpeedValue = "normal"

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
    if WalkSpeedEnabled or JumpPowerEnabled then
        if Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if WalkSpeedEnabled then hum.WalkSpeed = WalkSpeedValue end
                if JumpPowerEnabled then hum.JumpPower = JumpPowerValue end
            end
        end
    end
end)

local Window = Library:CreateWindow({
    Title = "Renux Hub",
    Footer = "executor: " .. currentExecutor .. " / " .. version .. " / game: " .. gamename,
    Icon = "zap",
    NotifySide = "Right",
    AutoShow = false,
    Animations = { ToggleWindow = true, TabSwitch = true, Groupbox = true },
    TabTransitionTime = 0.32,
    TabSwipeOffset = 26,
    TabSwipeFrom = "top",
})

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
        Confirm = { Title = "Yes", Variant = "Primary", Order = 4, Callback = function() Library:Notify({ Title = "Welcome", Description = "Script loaded successfully.", Icon = "info", Time = 4 }) end }
    }
})

Library:Notify({ Title = "Renux Hub", Description = "Script loaded in game: " .. gamename, Icon = "info", Time = 4 })
Library:SetWatermarkVisibility(true)
Library:SetWatermark("Renux Hub | " .. version)

local main1 = Tab1:AddLeftGroupbox("Main", "house")
local main2 = Tab1:AddRightGroupbox("Farm", "zap")
local tabmain1 = Tab2:AddLeftGroupbox("Movement", "user")
local tabmain2 = Tab2:AddRightGroupbox("ESP", "eye")
local setGroupBox = SettingTab:AddLeftGroupbox("Setting", "settings")
local seGroupBox = SettingTab:AddRightGroupbox("credits", "clipboard")

local MyToggle = main1:AddToggle("MyToggle", { Text = "Enable Main Script", Default = false })
local Box = main1:AddDependencyBox()
Box:AddDivider()

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

Box:AddInput("AvoidRadiusInput", { Text = "Avoid Radius", Default = "15", Numeric = true, Finished = false, ClearTextOnFocus = true, Callback = function(Value)
    local n = tonumber(Value)
    if n then AvoidRadius = n end
end })

Box:AddToggle("AvoidPlayers", { Text = "Avoid Players", Default = false, Callback = function(Value)
    AvoidPlayersEnabled = Value
    if Value then
        AvoidThread = task.spawn(function()
            while AvoidPlayersEnabled do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local myHrp = Player.Character.HumanoidRootPart
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and IsPlayerAlive(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = p.Character.HumanoidRootPart
                            local dist = (myHrp.Position - targetHrp.Position).Magnitude
                            if dist <= AvoidRadius then
                                local dir = (myHrp.Position - targetHrp.Position)
                                if dir.Magnitude == 0 then
                                    dir = Vector3.new(1, 0, 0)
                                else
                                    dir = dir.Unit
                                end
                                local tpDist = AvoidRadius + 10
                                local targetPos = myHrp.Position + (dir * tpDist)
                                myHrp.CFrame = CFrame.new(targetPos)
                                myHrp.Velocity = Vector3.new(0, 0, 0)
                                break
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end })

Box:AddToggle("XRay", { Text = "X-Ray", Default = false, Callback = function(Value)
    XRayEnabled = Value
    if Value then
        OriginalTransparencies = {}
        task.spawn(function()
            for targetTrans = 0.1, 0.75, 0.15 do
                if not XRayEnabled then break end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Transparency < 0.75 then
                        local isPlayerPart = false
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl.Character and v:IsDescendantOf(pl.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        if not isPlayerPart and v.Name ~= "RenuxSafePlatform" and v.Name ~= "RenuxAnchor" then
                            if OriginalTransparencies[v] == nil then
                                OriginalTransparencies[v] = v.Transparency
                            end
                            v.Transparency = targetTrans
                        end
                    end
                end
                task.wait(0.015)
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

Box:AddToggle("Invisible", { Text = "Invisible", Default = false, Callback = function(Value)
    if Value then
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
end })

Box:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false, Callback = function(Value)
    if Value then
        if InfiniteJumpConn then InfiniteJumpConn:Disconnect() end
        InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            if Player.Character then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if InfiniteJumpConn then
            InfiniteJumpConn:Disconnect()
            InfiniteJumpConn = nil
        end
    end
end })

Box:AddToggle("AntiVoid", { Text = "Anti Void", Default = false, Callback = function(Value)
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

local MasterTPToggle = main2:AddToggle("MasterTP", { Text = "Enable Farm", Default = false })
local TPBox = main2:AddDependencyBox()
TPBox:AddDivider()

TPBox:AddDropdown("TPSpeedDropdown", {
    Text = "mode kill all",
    Values = { "slow", "normal", "fast", "light speed" },
    Default = 2,
    Multi = false,
    Callback = function(Value)
        TPSpeedValue = Value
    end
})

TPBox:AddToggle("TPAllGroundCheck", { Text = "kill all Players", Default = false, Callback = function(Value)
    TPAllEnabled = Value
    if Value then
        TPAllThread = task.spawn(function()
            while TPAllEnabled do
                local imSeeker = HasParticleSystem(Player.Character) or IsInIceBreakerRange(Player, 12)
                if not imSeeker then
                    Library:Notify({ Title = "TP All", Description = "You do not possess seeker traits. Teleportation disabled.", Time = 2 })
                    task.wait(2)
                else
                    for _, target in ipairs(Players:GetPlayers()) do
                        if not TPAllEnabled then break end
                        if target == Player then continue end
                        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then continue end
                        if not IsPlayerAlive(target) then continue end
                        local ground = GetGroundPartBelowPlayer(target)
                        if ground and ground.Transparency == 0 then
                            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = target.Character.HumanoidRootPart
                                if TPSpeedValue == "light speed" then
                                    hrp.CanCollide = false
                                    hrp.CFrame = Player.Character.HumanoidRootPart.CFrame
                                    task.wait(0.05)
                                else
                                    hrp.CanCollide = true
                                    Player.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 2)
                                    if TPSpeedValue == "slow" then
                                        task.wait(1.5)
                                    elseif TPSpeedValue == "normal" then
                                        task.wait(0.8)
                                    elseif TPSpeedValue == "fast" then
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= Player and target.Character then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CanCollide = true end
                end
            end
        end)
    else
        TPAllEnabled = false
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= Player and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = true end
            end
        end
    end
end })

TPBox:AddToggle("CreditTP", { Text = "farm credit", Default = false, Callback = function(Value)
    CreditTPEnabled = Value
    if Value then
        CreditTPThread = task.spawn(function()
            while CreditTPEnabled do
                local list = GetCreditParts()
                if #list == 0 then
                    Library:Notify({ Title = "Credit", Description = "No credits found. Teleport paused.", Time = 2 })
                    table.clear(VisitedCredits)
                    task.wait(2)
                else
                    local nextPart = GetNextUnvisitedCredit(list)
                    if not nextPart then
                        table.clear(VisitedCredits)
                        nextPart = list[1]
                    end
                    if nextPart and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            local hrp = Player.Character.HumanoidRootPart
                            hrp.CFrame = CFrame.new(nextPart.Position + Vector3.new(0, 5, 0))
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                        VisitedCredits[nextPart] = true
                    end
                    task.wait(0.6)
                end
            end
        end)
    else
        CreditTPEnabled = false
    end
end })
TPBox:AddDivider()

TPBox:AddToggle("SafePlatformTP", {
    Text = "TP Safe Platform",
    Default = false,
    Callback = function(Value)
        SafeTPEnabled = Value
        if Value then
            local plat = GetOrCreateSafePlatform()
            Library:Notify({ Title = "Safe Platform", Description = "Safe platform Enable", Time = 3 })
            SafeTPThread = task.spawn(function()
                while SafeTPEnabled do
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and (HasParticleSystem(p.Character) or IsInIceBreakerRange(p, 12)) then
                            CurrentIceSeeker = p
                            break
                        end
                    end
                    if CurrentIceSeeker and CurrentIceSeeker ~= Player and IsPlayerAlive(CurrentIceSeeker) then
                        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                Player.Character.HumanoidRootPart.CFrame = plat.CFrame + Vector3.new(0, 5, 0)
                                Player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            end)
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            SafeTPEnabled = false
            Library:Notify({ Title = "Safe Platform", Description = "Safe TP loop disabled.", Time = 2 })
        end
    end
})

TPBox:SetupDependencies({ { Toggles.MasterTP, true } })
Box:SetupDependencies({ { Toggles.MyToggle, true } })

tabmain1:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed Enable", Default = false, Callback = function(Value) WalkSpeedEnabled = Value end })
tabmain1:AddInput("WalkSpeedInput", { Default = "16", Numeric = true, Finished = false, ClearTextOnFocus = true, Text = "WalkSpeed Value", Callback = function(Value) local n = tonumber(Value) if n then WalkSpeedValue = n end end })
tabmain1:AddToggle("JumpPowerToggle", { Text = "JumpPower Enable", Default = false, Callback = function(Value) JumpPowerEnabled = Value end })
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

                if not SeekerHighlights[p] or SeekerHighlights[p].Parent ~= p.Character then
                    if SeekerHighlights[p] then pcall(function() SeekerHighlights[p]:Destroy() end) end
                    local hl = Instance.new("Highlight")
                    hl.Name = "RenuxPlayerHL"
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = p.Character
                    SeekerHighlights[p] = hl
                end

                if not SeekerTracers[p] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Color = Color3.fromRGB(0, 255, 0)
                    line.Transparency = 1
                    SeekerTracers[p] = line
                end

                if not SeekerNames[p] then
                    local text = Drawing.new("Text")
                    text.Size = 13
                    text.Center = true
                    text.Outline = true
                    text.OutlineColor = Color3.new(0, 0, 0)
                    text.Color = Color3.fromRGB(0, 255, 0)
                    text.Text = p.Name
                    SeekerNames[p] = text
                end

                local hrp = p.Character.HumanoidRootPart
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    SeekerTracers[p].From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    SeekerTracers[p].To = Vector2.new(pos.X, pos.Y)
                    SeekerTracers[p].Visible = true
                else
                    SeekerTracers[p].Visible = false
                end

                local namePos, nameOnScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
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

tabmain2:AddDivider()
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

setGroupBox:AddLabel("setting ui")
setGroupBox:AddButton({ Text = "restart ui", Func = function()
    if Library then Library:Unload() end
    task.spawn(function()
        task.wait()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/hide-and-seek.lua", true))()
    end)
end })
setGroupBox:AddButton({
    Text = "delete ui",
    Func = function()
        Library:Notify({
            Title = "Renux_Hub",
            Description = "bye byee",
            Icon = "info",
            Time = 4,
        })
        task.wait(0.35)
        Library:Unload()
    end
})
setGroupBox:AddDivider()
setGroupBox:AddButton({ Text = "Server Hop", Func = doServerHop })
setGroupBox:AddButton({ Text = "Rejoin", Func = doRejoin })

seGroupBox:AddLabel("credits by")
seGroupBox:AddLabel("• Renux Hub")
seGroupBox:AddLabel("• mspaint")
seGroupBox:AddDivider()
seGroupBox:AddLabel("logs update")
seGroupBox:AddLabel("• avoid all player")
seGroupBox:AddLabel("• anti void")
