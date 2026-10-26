local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local gamename = "Unknown"
local version = "version: 1.3"
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
local Options = Library.Options

local NoclipConn = nil
local XRayEnabled = nil
local OriginalTransparencies = {}

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

local VisitedCredits = {}
local CreditTweenEnabled = nil
local CreditTweenThread = nil

local SafePlatform = nil

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
    if char:FindFirstChild("Glue") or char:FindFirstChild("Sprint") then
        v1 = true
    else
        for _, v in ipairs(char:GetDescendants()) do
            if v.Name == "Glue" or v.Name == "Sprint" then
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

local Tab = Window:AddTab({ Name = "info", Description = "info script", Icon = "bell" })
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

local main = Tab:AddLeftGroupbox("info", "bell")
local seGroupBox = Tab:AddRightGroupbox("credits", "clipboard")
local main1 = Tab1:AddLeftGroupbox("Main", "house")
local main2 = Tab1:AddRightGroupbox("Farm", "zap")
local tabmain1 = Tab2:AddLeftGroupbox("Movement", "user")
local tabmain2 = Tab2:AddRightGroupbox("ESP", "eye")
local setGroupBox = SettingTab:AddLeftGroupbox("Setting", "settings")

main:AddButton({
    Text = "join discord",
    Func = function()
        (setclipboard or toclipboard)("https://discord.gg/mXnTVYYYsy")
        Library:Notify("link discord has copy", 3)
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
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local myHrp = Player.Character.HumanoidRootPart
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and IsPlayerAlive(p) and IsPlayerIt(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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

Box:AddToggle("XRay", { Text = "X-Ray", Default = false, Callback = function(Value)
    XRayEnabled = Value
    if Value then
        OriginalTransparencies = {}
        task.spawn(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp and CloneChar then
                hrp = CloneChar:FindFirstChild("HumanoidRootPart")
            end
            local allParts = {}
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency < 0.75 then
                    local isPlayerPart = false
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character and v:IsDescendantOf(pl.Character) then
                            isPlayerPart = true
                            break
                        end
                    end
                    if CloneChar and v:IsDescendantOf(CloneChar) then isPlayerPart = true end
                    if OriginalChar and v:IsDescendantOf(OriginalChar) then isPlayerPart = true end
                    if not isPlayerPart and v.Name ~= "RenuxSafePlatform" and v.Name ~= "RenuxFollowPart" then
                        table.insert(allParts, v)
                    end
                end
            end
            if hrp then
                table.sort(allParts, function(a, b)
                    return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
                end)
            end
            local batchSize = 20
            local targetTrans = 0.75
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
                    task.wait(0.03)
                end
                task.wait(0.05)
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
        local gui = Instance.new("ScreenGui")
        gui.Name = "RenuxInvisibleUI"
        gui.ResetOnSpawn = false
        gui.Parent = Player:WaitForChild("PlayerGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 60)
        frame.Position = UDim2.new(0.5, -100, 0.5, -30)
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
        btn.Size = UDim2.new(0, 180, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, 10)
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        btn.BackgroundTransparency = 0.25
        btn.Text = "invisible : off"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
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
        local function EnableInvis()
            if InvisibleActive then return end
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
            OriginalChar = Player.Character
            local savedCF = OriginalChar.HumanoidRootPart.CFrame
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
                OriginalChar.HumanoidRootPart.CFrame = CFrame.new(0, 10000, 0)
                OriginalChar.HumanoidRootPart.Anchored = true
            end
            task.wait(0.1)
            Player.Character = CloneChar
            Workspace.CurrentCamera.CameraSubject = CloneChar:FindFirstChildOfClass("Humanoid")
            if InvisLoopConn then InvisLoopConn:Disconnect() end
            InvisLoopConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if OriginalChar and OriginalChar:FindFirstChild("HumanoidRootPart") then
                        OriginalChar.HumanoidRootPart.CFrame = CFrame.new(0, 10000, 0)
                        OriginalChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end)
            InvisibleActive = true
            btn.Text = "invisible : on"
        end
        local function DisableInvis()
            if not InvisibleActive then return end
            if InvisLoopConn then
                InvisLoopConn:Disconnect()
                InvisLoopConn = nil
            end
            if OriginalChar then
                pcall(function()
                    if OriginalChar:FindFirstChild("HumanoidRootPart") then
                        OriginalChar.HumanoidRootPart.Anchored = false
                    end
                end)
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
            InvisibleActive = false
            btn.Text = "invisible : off"
        end
        btn.MouseButton1Click:Connect(function()
            if InvisibleActive then
                DisableInvis()
            else
                EnableInvis()
            end
        end)
    else
        pcall(function()
            local pg = Player:FindFirstChild("PlayerGui")
            if pg then
                local g = pg:FindFirstChild("RenuxInvisibleUI")
                if g then g:Destroy() end
            end
        end)
        if InvisLoopConn then
            InvisLoopConn:Disconnect()
            InvisLoopConn = nil
        end
        if OriginalChar then
            pcall(function()
                if OriginalChar:FindFirstChild("HumanoidRootPart") then
                    OriginalChar.HumanoidRootPart.Anchored = false
                end
            end)
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
        OriginalChar = nil
        InvisibleActive = false
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
    Values = { "normal", "light speed" },
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
        BlacklistPlayers = Value
    end
})

Players.PlayerAdded:Connect(function(p)
    pcall(function()
        if Options.BlacklistDropdown then
            Options.BlacklistDropdown:SetValues(GetPlayerNamesList())
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    pcall(function()
        if Options.BlacklistDropdown then
            Options.BlacklistDropdown:SetValues(GetPlayerNamesList())
        end
    end)
end)

TPBox:AddToggle("TPAllGroundCheck", { Text = "kill all Players", Default = false, Callback = function(Value)
    TPAllEnabled = Value
    if Value then
        if not IsPlayerIt(Player) then
            
        else
            
        end
        TPAllThread = task.spawn(function()
            local wasNotifiedNotIt = false
            while TPAllEnabled do
                if not IsPlayerIt(Player) then
                    if not wasNotifiedNotIt then
                        wasNotifiedNotIt = true
                    end
                    task.wait(0.5)
                else
                    if wasNotifiedNotIt then
                        
                        wasNotifiedNotIt = false
                    end
                    for _, target in ipairs(Players:GetPlayers()) do
                        if not TPAllEnabled then break end
                        if not IsPlayerIt(Player) then break end
                        if target == Player then continue end
                        if BlacklistPlayers[target.Name] == true then continue end
                        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then continue end
                        local hum = target.Character:FindFirstChildOfClass("Humanoid")
                        if not hum then continue end
                        if hum.Health <= 0 then
                            DeadHistory[target] = true
                            continue
                        else
                            if DeadHistory[target] then DeadHistory[target] = nil end
                        end
                        if IsPlayerIt(target) then continue end
                        local ground = GetGroundPartBelowPlayer(target)
                        if ground and ground.Transparency == 0 then
                            local activeChar = (InvisibleActive and CloneChar and CloneChar.Parent) and CloneChar or Player.Character
                            if activeChar and activeChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = target.Character.HumanoidRootPart
                                if TPSpeedValue == "light speed" then
                                    hrp.CanCollide = false
                                    hrp.CFrame = activeChar.HumanoidRootPart.CFrame
                                    task.wait(0.02)
                                else
                                    hrp.CanCollide = true
                                    activeChar.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 2)
                                    task.wait(0.8)
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
                    if nextPart and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            local hrp = Player.Character.HumanoidRootPart
                            local dist = (hrp.Position - nextPart.Position).Magnitude
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
            Library:Notify({ Title = "Safe Platform", Description = "Teleported to Safe Platform!", Time = 2 })
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
                local espColor = isIt and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)

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
local function DisableAllSystemsInstant()
    getgenv().MasterTP = false
    getgenv().TPAllEnabled = false
    getgenv().CreditTweenEnabled = false
    getgenv().AntiVoidEnabled = false
    getgenv().AvoidItEnabled = false
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

setGroupBox:AddButton({ Text = "restart ui", Func = function()
    DisableAllSystemsInstant()
    if Library then Library:Unload() end
    task.spawn(function()
        task.wait(0.2)
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
        DisableAllSystemsInstant()
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
seGroupBox:AddLabel("• esp it in esp Player")
seGroupBox:AddLabel("• avoid it")
seGroupBox:AddLabel("• fix Enable Ws and jp")
seGroupBox:AddLabel("• improve farm credits")
seGroupBox:AddLabel("• Blacklist Player kill all")
seGroupBox:AddLabel("• improve invisible")
