loadstring(game:HttpGet("https://github.com/SCRIPTHUB-dev-god/User-Interface/releases/download/loader/fire-ui.lua"))()
local library = GetLibrary("latest")
library:CreateTheme({
    name = "Ametis",
    MainBG = Color3.fromRGB(32, 32, 36),
    HeaderBG = Color3.fromRGB(24, 24, 28),
    Stroke = Color3.fromRGB(60, 60, 65),
    ButtonBG = Color3.fromRGB(45, 45, 50),
    SectionBG = Color3.fromRGB(38, 38, 42),
    Accent = Color3.fromRGB(140, 140, 145),
    IconCl = Color3.fromRGB(200, 200, 205)
})
local window = library:window({
    title = "Renux Hub",
    desc = "spiral difficulty chart obby",
    transparent = 0.25,
    icon = "moon",
    theme = "Ametis",
    fileName = "RENUX-HUB_save",
    autoshow = true,
    addbacksound = false
})
window:AddTag({
    title = "v1.2",
    icon = "globe",
    color = Color3.fromRGB(55, 55, 60),
    getclick = false,
})
window:AddTag({
    title = "keyless",
    icon = "key",
    color = Color3.fromRGB(55, 55, 60),
    getclick = false,
})
window:SetToggleUi({
    title = "Renux Hub",
    icon = "moon"
})
local suptab = window:AddTab("support", "info")
suptab:Addbutton({
    title = "copy discord",
    callback = function()
        (setclipboard or toclipboard)("https://discord.gg/mXnTVYYYsy")
        library:Notification({ title = "copy discord link", desc = "copy link discord valid", duration = 3 })
    end
})
local tabMain = window:AddTab("Main", "house")
local mainSection = tabMain:section({
    title = "Main Features",
    icon = "house",
    opened = false
})
local tabBox = mainSection:AddTabbox()
local farmBox = tabBox:AddTab("Farm")
local settingBox = tabBox:AddTab("Setting")
local manualBox = tabBox:AddTab("Manual")
local statusBox = tabBox:AddTab("Status")
local tabMisc = window:AddTab("Misc", "server")
local serverSection = tabMisc:section({ title = "Server", icon = "settings", opened = false })
local playerSection = tabMisc:section({ title = "Player", icon = "eye", opened = false })
local localPlayerSection = tabMisc:section({ title = "Local Player", icon = "user", opened = false })
local tabSettingUI = window:AddTab("Setting UI", "settings")
local settingUISection = tabSettingUI:section({ title = "Setting UI", icon = "settings", opened = false })
getgenv().FarmEnabled = false
getgenv().AutoRebirth = false
getgenv().TPMode = "Default"
getgenv().BypassTP = false
getgenv().SpectatorEnabled = false
getgenv().SpectatorConn = nil
getgenv().CurrentTween = nil
getgenv().CurrentCheckpoint = 0
getgenv().SelectedCheckpoint = 0
getgenv().ManualTargetCheckpoint = 0
getgenv().SelectedSpyPlayer = nil
getgenv().RebirthAtCheckpoint = 61
getgenv().FarmSpeed = 40
getgenv().CurrentPing = 0
getgenv().CurrentFPS = 60
getgenv().InfiniteJumpEnabled = false
getgenv().InfiniteJumpConn = nil
getgenv().FullbrightEnabled = false
getgenv().NoclipEnabled = false
getgenv().NoclipConn = nil
getgenv().SpeedEnabled = false
getgenv().SpeedValue = 16
getgenv().JumpEnabled = false
getgenv().JumpValue = 50
getgenv().AntiKillBrickEnabled = true
getgenv().AntiKillBrickConn = nil
getgenv().OriginalGravity = workspace.Gravity
getgenv().FarmGravityConn = nil
getgenv().FarmPhysicsEnabled = false
getgenv().AutoReconnectEnabled = true
getgenv().AutoReconnectConn = nil
local function GetExecutorName()
    local ok, res = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        if getexecutorname then return getexecutorname() end
        if get_executor_name then return get_executor_name() end
    end)
    if ok and res and res ~= "" then
        if type(res) == "table" then
            return tostring(res[1] or res.Name or "Unknown")
        end
        return tostring(res)
    end
    if KRNL_LOADED then return "KRNL"
    elseif syn and syn.protect_gui then return "Synapse"
    elseif Fluxus or isfluxusclosure then return "Fluxus"
    elseif gethui then return "Delta/Codex"
    else return "Unknown" end
end
local ExecutorName = GetExecutorName()
pcall(function()
    if isfile and isfile("RENUX-HUB_save.txt") then
        local num = tonumber(readfile("RENUX-HUB_save.txt"))
        if num then
            getgenv().CurrentCheckpoint = num
            getgenv().SelectedCheckpoint = num
        end
    end
end)
local function SaveCheckpoint(i)
    getgenv().CurrentCheckpoint = i
    pcall(function()
        if writefile then
            writefile("RENUX-HUB_save.txt", tostring(i))
        end
    end)
end
local function GetFolder()
    local f = workspace:FindFirstChild("Checkpoints")
    if f then return f end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower() == "checkpoints" then
            return v
        end
    end
    return nil
end
local function GetSortedList(folder)
    if not folder then return {} end
    local list = {}
    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("BasePart") and tonumber(v.Name) then
            table.insert(list, {
                part = v,
                num = tonumber(v.Name)
            })
        end
    end
    table.sort(list, function(a, b) return a.num < b.num end)
    return list
end
local function GetCheckpointValuesFixed()
    local folder = GetFolder()
    local sorted = GetSortedList(folder)
    local maxNum = 261
    if #sorted > 0 then
        local found = sorted[#sorted].num
        if found > maxNum then maxNum = found end
    end
    local values = {}
    for i = 0, maxNum do
        table.insert(values, tostring(i))
    end
    return values
end
local function GetRebirthValues()
    local folder = GetFolder()
    local sorted = GetSortedList(folder)
    local maxNum = 261
    if #sorted > 0 then
        local found = sorted[#sorted].num
        if found > maxNum then maxNum = found end
    end
    local values = {}
    for i = 61, maxNum do
        table.insert(values, tostring(i))
    end
    return values
end
local checkpointValuesCache = GetCheckpointValuesFixed()
local rebirthValuesCache = GetRebirthValues()
local function GetCurrentStageUI()
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local selector = pg:FindFirstChild("Stage Selector")
    if not selector then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "Stage Selector" then selector = v break end
        end
    end
    if not selector then return nil end
    local frame = selector:FindFirstChild("Frame") or selector
    local curObj = frame:FindFirstChild("CurrentStage")
    if not curObj then
        for _, v in ipairs(frame:GetDescendants()) do
            if v.Name == "CurrentStage" then curObj = v break end
        end
    end
    if not curObj then return nil end
    local txt = nil
    if curObj:IsA("TextLabel") or curObj:IsA("TextButton") or curObj:IsA("TextBox") then
        txt = curObj.Text
    elseif curObj:IsA("ValueBase") then
        txt = tostring(curObj.Value)
    else
        local lbl = curObj:FindFirstChildOfClass("TextLabel")
        if lbl then txt = lbl.Text end
    end
    if txt then
        return tonumber(txt:match("%d+")) or tonumber(txt)
    end
    return nil
end
local function GetStageFromLeaderstats()
    local plr = game.Players.LocalPlayer
    local ls = plr:FindFirstChild("leaderstats")
    if not ls then
        for _, v in ipairs(plr:GetChildren()) do
            if v.Name:lower() == "leaderstats" then
                ls = v
                break
            end
        end
    end
    if ls then
        local names = { "Stage", "stage", "Checkpoint", "checkpoint", "Level", "level", "Stat", "stat" }
        for _, n in ipairs(names) do
            local obj = ls:FindFirstChild(n)
            if obj then
                if obj:IsA("ValueBase") then
                    return obj.Value
                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local num = tonumber(tostring(obj.Text):match("%d+"))
                    if num then return num end
                end
            end
        end
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
                local val = v.Value
                if type(val) == "number" then
                    return val
                elseif type(val) == "string" then
                    local num = tonumber(val:match("%d+"))
                    if num then return num end
                end
            end
        end
    end
    return nil
end
local function GetCurrentStageLeaderstats()
    local lsStage = GetStageFromLeaderstats()
    if lsStage then return lsStage end
    return GetCurrentStageUI() or getgenv().CurrentCheckpoint or 0
end
local function FindIndexByNum(sorted, num)
    for i, d in ipairs(sorted) do
        if d.num == num then return i end
    end
    return nil
end
local function FindNextPart(sorted, cur)
    for _, d in ipairs(sorted) do
        if d.num > cur then return d end
    end
    return nil
end
local function SafeTP(hrp, targetCF)
    if not hrp then return end
    if getgenv().BypassTP then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        hrp.CFrame = targetCF
        task.wait(0.01)
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
        end)
    else
        hrp.CFrame = targetCF
    end
end
local function ClickButton(btn)
    if not btn then return false end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end)
    pcall(function()
        if btn:IsA("GuiButton") then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
        end
    end)
    return true
end
local function ClickButtonNoCursor(btn)
    if not btn then return false end
    local fired = false
    pcall(function()
        if btn:IsA("GuiButton") then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() fired = true end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() fired = true end
            if not fired and firesignal then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
                fired = true
            end
        end
    end)
    return fired
end
local function FindButtonByName(buttonName)
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local btn = pg:FindFirstChild(buttonName, true)
    if btn and btn:IsA("GuiButton") then return btn end
    for _, v in ipairs(pg:GetDescendants()) do
        if v.Name:lower() == buttonName:lower() and v:IsA("GuiButton") then
            return v
        end
    end
    return nil
end
local function FindNextButton()
    local btn = FindButtonByName("NextButton")
    if btn then return btn end
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, v in ipairs(pg:GetDescendants()) do
        if v:IsA("TextButton") then
            local txt = v.Text:lower()
            if txt:find("next") or txt == ">" or txt == ">>" then
                return v
            end
        end
    end
    return nil
end
local function FindPreviousButton()
    local btn = FindButtonByName("PreviousButton")
    if btn then return btn end
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, v in ipairs(pg:GetDescendants()) do
        if v:IsA("TextButton") then
            local txt = v.Text:lower()
            if txt:find("prev") or txt == "<" or txt == "<<" then
                return v
            end
        end
    end
    return nil
end
local function FindCurrentStageLabel()
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local label = pg:FindFirstChild("CurrentStage", true)
    if label then return label end
    for _, v in ipairs(pg:GetDescendants()) do
        if v.Name:lower() == "currentstage" then
            return v
        end
    end
    return nil
end
local function GetCurrentStageFromLabel()
    local label = FindCurrentStageLabel()
    if not label then return GetCurrentStageUI() end
    local txt = nil
    if label:IsA("TextLabel") or label:IsA("TextButton") or label:IsA("TextBox") then
        txt = label.Text
    elseif label:IsA("ValueBase") then
        txt = tostring(label.Value)
    else
        local lbl = label:FindFirstChildOfClass("TextLabel")
        if lbl then txt = lbl.Text end
    end
    if txt then
        local num = tonumber(txt:match("%d+"))
        if num then return num end
    end
    return GetCurrentStageUI()
end
local function ClickNextButton()
    local btn = FindNextButton()
    if btn then return ClickButton(btn) else return false end
end
local function HandleErrorUI()
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local errGui = pg:FindFirstChild("Error")
    if not errGui then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "Error" and v:IsA("ScreenGui") then errGui = v break end
        end
    end
    if not errGui then return false end
    local frame = errGui:FindFirstChild("Frame")
    if not frame then
        for _, v in ipairs(errGui:GetDescendants()) do
            if v.Name == "Frame" then frame = v break end
        end
    end
    if not frame then return false end
    local btn = nil
    for _, v in ipairs(frame:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then btn = v break end
    end
    if not btn then
        btn = frame:FindFirstChildOfClass("TextButton") or frame:FindFirstChildOfClass("ImageButton")
    end
    if btn then
        task.wait(0.25)
        ClickButtonNoCursor(btn)
        return true
    end
    return false
end
local function DoAutoRebirthSequence()
    local curStage = GetCurrentStageUI()
    local need = getgenv().RebirthAtCheckpoint or 61
    if not curStage or curStage < need then return false end
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local sideMenu = pg:FindFirstChild("SideMenu")
    if not sideMenu then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "SideMenu" then sideMenu = v break end
        end
    end
    if sideMenu then
        local frame = sideMenu:FindFirstChild("Frame") or sideMenu
        local rebirthBtn = frame:FindFirstChild("0_Rebirth")
        if not rebirthBtn then
            for _, v in ipairs(frame:GetDescendants()) do
                if v.Name == "0_Rebirth" and v:IsA("ImageButton") then rebirthBtn = v break end
            end
        end
        if rebirthBtn then
            task.wait(0.25)
            ClickButtonNoCursor(rebirthBtn)
            task.wait(0.25)
        end
    end
    local rebirthUI = pg:FindFirstChild("Rebirth")
    if not rebirthUI then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "Rebirth" then rebirthUI = v break end
        end
    end
    if rebirthUI then
        local f1 = rebirthUI:FindFirstChild("Frame") or rebirthUI
        local f2 = f1:FindFirstChild("Frame") or f1
        local nowBtn = nil
        for _, v in ipairs(f2:GetDescendants()) do
            if v:IsA("TextButton") and v.Text:lower():find("rebirth now") then nowBtn = v break end
        end
        if nowBtn then
            task.wait(0.25)
            ClickButtonNoCursor(nowBtn)
            task.wait(0.25)
        end
    end
    local conf = pg:FindFirstChild("Confirmation")
    if not conf then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "Confirmation" then conf = v break end
        end
    end
    if conf then
        local frame = conf:FindFirstChild("Frame") or conf
        if not frame.Visible then frame.Visible = true end
        local yesBtn = frame:FindFirstChild("Yes")
        if not yesBtn then
            for _, v in ipairs(frame:GetDescendants()) do
                if v.Name == "Yes" and v:IsA("TextButton") then yesBtn = v break end
            end
        end
        if yesBtn then
            task.wait(0.25)
            ClickButtonNoCursor(yesBtn)
            return true
        end
    end
    return false
end
task.spawn(function()
    local RunService = game:GetService("RunService")
    local last = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - last >= 1 then
            getgenv().CurrentFPS = frames
            frames = 0
            last = now
        end
    end)
    while task.wait(0.5) do
        pcall(function()
            local stats = game:GetService("Stats")
            local item = stats.Network.ServerStatsItem["Data Ping"]
            local ping = 0
            if item then ping = math.floor(item:GetValue()) end
            if ping == 0 then
                ping = math.floor(game.Players.LocalPlayer:GetNetworkPing() * 1000)
            end
            getgenv().CurrentPing = ping
        end)
    end
end)
local statusPrgf = nil
local function EnableAntiKillBrick()
    getgenv().AntiKillBrickEnabled = true
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "KillBrick" and v:IsA("BasePart") then
            pcall(function() v.CanTouch = false end)
        end
    end
    if getgenv().AntiKillBrickConn then
        pcall(function() getgenv().AntiKillBrickConn:Disconnect() end)
    end
    getgenv().AntiKillBrickConn = workspace.DescendantAdded:Connect(function(obj)
        if getgenv().AntiKillBrickEnabled and obj.Name == "KillBrick" and obj:IsA("BasePart") then
            task.wait(0.1)
            pcall(function() obj.CanTouch = false end)
        end
    end)
end
local function DisableAntiKillBrick()
    getgenv().AntiKillBrickEnabled = true
    if getgenv().AntiKillBrickConn then
        pcall(function() getgenv().AntiKillBrickConn:Disconnect() end)
        getgenv().AntiKillBrickConn = nil
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "KillBrick" and v:IsA("BasePart") then
            pcall(function() v.CanTouch = true end)
        end
    end
end
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RECONNECT_URL = "https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/sdco.lua"
local function GetMainCode()
    local ok, code = pcall(function()
        return game:HttpGet(RECONNECT_URL, true)
    end)
    if ok and code and code ~= "" then return code end
    return nil
end
local function QueueCode(code)
    if not code or code == "" then return end
    pcall(function()
        if queue_on_teleport then queue_on_teleport(code) end
        if queueonteleport then queueonteleport(code) end
        if syn and syn.queue_on_teleport then syn.queue_on_teleport(code) end
        if fluxus and fluxus.queue_on_teleport then fluxus.queue_on_teleport(code) end
    end)
end
local function ServerHop()
    local code = GetMainCode()
    if code then QueueCode(code) end
    pcall(function()
        TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end)
end
local function Rejoin()
    local code = GetMainCode()
    if code then QueueCode(code) end
    pcall(function()
        if game.JobId and game.JobId ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    end)
end
local function EnableAutoReconnect()
    if getgenv().AutoReconnectConn then return end
    getgenv().AutoReconnectEnabled = true
    getgenv().AutoReconnectConn = true
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local function handlePrompt(child)
            if not getgenv().AutoReconnectEnabled then return end
            if child.Name == "ErrorPrompt" then
                task.wait(0.8)
                ServerHop()
            end
        end
        local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
        if promptGui then
            local overlay = promptGui:FindFirstChild("promptOverlay")
            if overlay then
                overlay.ChildAdded:Connect(handlePrompt)
                for _, v in ipairs(overlay:GetChildren()) do handlePrompt(v) end
            end
        end
        CoreGui.ChildAdded:Connect(function(c)
            if c.Name == "RobloxPromptGui" then
                task.wait(0.3)
                local ov = c:FindFirstChild("promptOverlay")
                if ov then ov.ChildAdded:Connect(handlePrompt) end
            end
        end)
    end)
end
local function DisableAutoReconnect()
    getgenv().AutoReconnectEnabled = false
    getgenv().AutoReconnectConn = nil
end
if getgenv().AutoReconnectEnabled then
    task.spawn(function()
        task.wait(1)
        EnableAutoReconnect()
    end)
end
local function EnableFarmPhysics()
    if getgenv().FarmPhysicsEnabled then return end
    getgenv().FarmPhysicsEnabled = true
    getgenv().OriginalGravity = workspace.Gravity
    workspace.Gravity = 0
    local RunService = game:GetService("RunService")
    if getgenv().FarmGravityConn then
        pcall(function() getgenv().FarmGravityConn:Disconnect() end)
    end
    getgenv().FarmGravityConn = RunService.Heartbeat:Connect(function()
        if not getgenv().FarmEnabled then return end
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity
        local horizMag = Vector3.new(vel.X, 0, vel.Z).Magnitude
        if horizMag > 80 then
            if workspace.Gravity < 50 then
                workspace.Gravity = math.min(workspace.Gravity + 5, 50)
            end
        else
            if workspace.Gravity > 0 then
                workspace.Gravity = math.max(workspace.Gravity - 2, 0)
            end
        end
        if vel.Y < -50 then
            local newVel = Vector3.new(vel.X * 0.5, -15, vel.Z * 0.5)
            hrp.AssemblyLinearVelocity = newVel
        end
    end)
end
local function DisableFarmPhysics()
    if not getgenv().FarmPhysicsEnabled then return end
    getgenv().FarmPhysicsEnabled = false
    if getgenv().FarmGravityConn then
        pcall(function() getgenv().FarmGravityConn:Disconnect() end)
        getgenv().FarmGravityConn = nil
    end
    pcall(function()
        workspace.Gravity = getgenv().OriginalGravity or 196.2
    end)
end
local function StartFarmLoop()
    local TweenService = game:GetService("TweenService")
    local player = game.Players.LocalPlayer
    task.spawn(function()
        local folder = GetFolder()
        if not folder then getgenv().FarmEnabled = false return end
        local sorted = GetSortedList(folder)
        if #sorted == 0 then getgenv().FarmEnabled = false return end
        if getgenv().TPMode == "Fast" then
            EnableFarmPhysics()
            while getgenv().FarmEnabled do
                pcall(function() AdjustGravityByYDistance() end)
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then task.wait(0.1) continue end
                local curStage = GetCurrentStageUI() or getgenv().CurrentCheckpoint or 0
                local nextData = FindNextPart(sorted, curStage)
                if not nextData then getgenv().FarmEnabled = false break end
                SafeTP(hrp, CFrame.new(nextData.part.Position.X, nextData.part.Position.Y + 3.5, nextData.part.Position.Z))
                task.wait(0.25)
                local t0 = tick()
                local newStage = curStage
                repeat task.wait(0.03) newStage = GetCurrentStageUI() or curStage until (newStage >= nextData.num) or (tick() - t0 > 0.5) or not getgenv().FarmEnabled
                if newStage >= nextData.num then
                    SaveCheckpoint(newStage)
                    if newStage % 10 == 0 then task.wait(2) end
                    local nextNext = FindNextPart(sorted, newStage)
                    if nextNext then
                        hum.Health = 0
                        local newChar = nil
                        local con = player.CharacterAdded:Connect(function(c) newChar = c end)
                        local timeout = 0
                        repeat task.wait(0.1) timeout = timeout + 0.1 until newChar or timeout > 8 or not getgenv().FarmEnabled
                        if con then con:Disconnect() end
                        if not getgenv().FarmEnabled then break end
                        if newChar then
                            newChar:WaitForChild("HumanoidRootPart", 5)
                            task.wait(0.1)
                            local newHrp = newChar:FindFirstChild("HumanoidRootPart")
                            if newHrp then
                                SafeTP(newHrp, CFrame.new(nextNext.part.Position.X, nextNext.part.Position.Y + 3.5, nextNext.part.Position.Z))
                                task.wait(0.1)
                            end
                        end
                    else
                        getgenv().FarmEnabled = false break
                    end
                else
                    task.wait(0.05)
                end
            end
            DisableFarmPhysics()
        else
            EnableFarmPhysics()
            local uiStage = GetCurrentStageUI()
            if uiStage then SaveCheckpoint(uiStage) end
            local startIdx = 1
            for i, d in ipairs(sorted) do
                if d.num >= (getgenv().CurrentCheckpoint or 0) then startIdx = i break end
            end
            local idx = startIdx
            while idx <= #sorted and getgenv().FarmEnabled do
                local data = sorted[idx]
                if not data.part or not data.part.Parent then idx += 1 continue end
                local curUI = GetCurrentStageUI()
                if curUI and (data.num - curUI) > 2 then
                    local curIdx = FindIndexByNum(sorted, curUI)
                    if curIdx then
                        local curPart = sorted[curIdx].part
                        if curPart then
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z)) end
                            task.wait(0.1)
                            idx = curIdx + 1
                            SaveCheckpoint(curUI)
                            continue
                        end
                    end
                end
                local function TweenTo(targetCF, speedOverride)
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return false end
                    if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) end
                    if speedOverride == 0 then SafeTP(hrp, targetCF) return true end
                    local dist = (hrp.Position - targetCF.Position).Magnitude
                    if dist < 3 then return true end
                    local duration = dist / math.max(getgenv().FarmSpeed * 2, 1)
                    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                    getgenv().CurrentTween = tween
                    tween:Play()
                    local done = false
                    local conn = tween.Completed:Connect(function() done = true end)
                    while not done and getgenv().FarmEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do task.wait(0.05) end
                    if conn then conn:Disconnect() end
                    pcall(function() tween:Cancel() end)
                    getgenv().CurrentTween = nil
                    return done
                end
                local targetCF = CFrame.new(data.part.Position.X, data.part.Position.Y + 3, data.part.Position.Z)
                if not TweenTo(targetCF) then break end
                if not getgenv().FarmEnabled then break end
                task.wait(0.4)
                if not getgenv().FarmEnabled then break end
                local curUI2 = GetCurrentStageUI()
                if curUI2 then
                    if curUI2 < data.num then
                        local curIdx = FindIndexByNum(sorted, curUI2)
                        if curIdx then
                            local curPart = sorted[curIdx].part
                            if curPart then
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z)) end
                                task.wait(0.1)
                                idx = curIdx + 1
                                SaveCheckpoint(curUI2)
                                continue
                            end
                        end
                    else
                        SaveCheckpoint(curUI2)
                        if curUI2 % 10 == 0 then task.wait(2) end
                    end
                else
                    SaveCheckpoint(data.num)
                end
                local nextData = sorted[idx + 1]
                if not nextData then getgenv().FarmEnabled = false break end
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
                local newChar = nil
                local con = player.CharacterAdded:Connect(function(c) newChar = c end)
                local timeout = 0
                repeat task.wait(0.1) timeout += 0.1 until newChar or timeout > 8 or not getgenv().FarmEnabled
                if con then con:Disconnect() end
                if not getgenv().FarmEnabled then break end
                if not newChar then idx += 1 continue end
                newChar:WaitForChild("HumanoidRootPart", 5)
                task.wait(0.2)
                if not getgenv().FarmEnabled then break end
                local nextCF = CFrame.new(nextData.part.Position.X, nextData.part.Position.Y + 3, nextData.part.Position.Z)
                TweenTo(nextCF, 0)
                task.wait(0.2)
                idx += 1
            end
        end
        DisableFarmPhysics()
        getgenv().FarmEnabled = false
    end)
end
getgenv().AutoFarmingEnabled = false
getgenv().AutoFarmingFarmEnabled = false
getgenv().AutoFarmingRebirthEnabled = false
farmBox:Addtoggle({
    title = "Auto Farming",
    value = false,
    callback = function(state)
        getgenv().AutoFarmingEnabled = state
        getgenv().AutoFarmingFarmEnabled = state
        getgenv().AutoFarmingRebirthEnabled = state
        if not state then
            getgenv().AutoFarmingRebirthEnabled = false
            if getgenv().CurrentTween then
                pcall(function() getgenv().CurrentTween:Cancel() end)
                getgenv().CurrentTween = nil
            end
            DisableFarmPhysics()
            return
        end
        if getgenv().FarmEnabled then
            getgenv().FarmEnabled = false
            getgenv().AutoRebirth = false
            if getgenv().CurrentTween then
                pcall(function() getgenv().CurrentTween:Cancel() end)
                getgenv().CurrentTween = nil
            end
            DisableFarmPhysics()
            task.wait(0.3)
        end
        StartAutoFarmingLoop()
    end
})
farmBox:AddDivider()
farmBox:Addtoggle({
    title = "Auto Farm",
    value = false,
    callback = function(state)
        getgenv().FarmEnabled = state
        if not state then
            if getgenv().CurrentTween then
                pcall(function() getgenv().CurrentTween:Cancel() end)
                getgenv().CurrentTween = nil
            end
            DisableFarmPhysics()
            return
        end
        StartFarmLoop()
    end
})
farmBox:Addtoggle({
    title = "Auto Rebirth",
    value = false,
    callback = function(state)
        getgenv().AutoRebirth = state
        if not state then return end
        task.spawn(function()
            while getgenv().AutoRebirth do
                pcall(function()
                    HandleErrorUI()
                    local cur = GetCurrentStageUI()
                    local need = getgenv().RebirthAtCheckpoint or 61
                    if cur and cur >= need then
                        if DoAutoRebirthSequence() then
                            local wasFarm = getgenv().FarmEnabled
                            getgenv().FarmEnabled = false
                            SaveCheckpoint(0)
                            task.wait(2)
                            if wasFarm and getgenv().AutoRebirth then
                                getgenv().FarmEnabled = true
                                StartFarmLoop()
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
})
settingBox:AddDropdown({
    Title = "Mode farm",
    Desc = "Default = recomeded | fast = best but stuck",
    Values = { "Default", "Fast" },
    Value = { "Default" },
    Multi = false,
    Search = false,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        getgenv().TPMode = val
    end
})
settingBox:AddDivider()
settingBox:AddDropdown({
    Title = "Set Save checkpoint",
    Desc = "select checkpoint save",
    Values = checkpointValuesCache,
    Value = { tostring(getgenv().CurrentCheckpoint) },
    Multi = false,
    Search = true,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        local num = tonumber(val)
        if num then
            getgenv().SelectedCheckpoint = num
            SaveCheckpoint(num)
        end
    end
})
settingBox:AddDropdown({
    Title = "Rebirth in Checkpoint",
    Values = rebirthValuesCache,
    Value = { tostring(getgenv().RebirthAtCheckpoint) },
    Multi = false,
    Search = true,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        local num = tonumber(val)
        if num then getgenv().RebirthAtCheckpoint = num end
    end
})
manualBox:AddDropdown({
    Title = "select Target Checkpoint",
    Values = checkpointValuesCache,
    Value = { tostring(getgenv().ManualTargetCheckpoint or checkpointValuesCache[1]) },
    Multi = false,
    Search = true,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        local num = tonumber(val)
        if num then getgenv().ManualTargetCheckpoint = num end
    end
})
manualBox:Addbutton({
    title = "farm to selected Checkpoint",
    callback = function()
        local targetNum = tonumber(getgenv().ManualTargetCheckpoint) or 0
        if targetNum <= 0 then return end
        local TweenService = game:GetService("TweenService")
        local player = game.Players.LocalPlayer
        task.spawn(function()
            local folder = GetFolder()
            if not folder then return end
            local sorted = GetSortedList(folder)
            if #sorted == 0 then return end
            local curStage = GetCurrentStageUI() or getgenv().CurrentCheckpoint or 0
            local startIdx = FindIndexByNum(sorted, curStage)
            if not startIdx then
                for i, d in ipairs(sorted) do
                    if d.num >= curStage then startIdx = i break end
                end
                if not startIdx then startIdx = 1 end
            end
            local endIdx = FindIndexByNum(sorted, targetNum)
            if not endIdx then
                for i = #sorted, 1, -1 do
                    if sorted[i].num <= targetNum then endIdx = i break end
                end
                if not endIdx then endIdx = #sorted end
            end
            if startIdx > endIdx then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local tp = sorted[endIdx] and sorted[endIdx].part
                if hrp and tp then
                    SafeTP(hrp, CFrame.new(tp.Position.X, tp.Position.Y + 3, tp.Position.Z))
                end
                return
            end
            local function TweenTo(targetCF, speedOverride)
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return false end
                if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) end
                if speedOverride == 0 then SafeTP(hrp, targetCF) return true end
                local dist = (hrp.Position - targetCF.Position).Magnitude
                if dist < 3 then return true end
                local duration = dist / math.max(getgenv().FarmSpeed, 1)
                local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                getgenv().CurrentTween = tween
                tween:Play()
                local done = false
                local conn = tween.Completed:Connect(function() done = true end)
                local t = 0
                while not done and t < 10 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                    task.wait(0.05) t += 0.05
                end
                if conn then conn:Disconnect() end
                pcall(function() tween:Cancel() end)
                getgenv().CurrentTween = nil
                return done
            end
            local idx = startIdx
            while idx <= endIdx do
                local data = sorted[idx]
                if not data.part or not data.part.Parent then idx += 1 continue end
                local targetCF = CFrame.new(data.part.Position.X, data.part.Position.Y + 3, data.part.Position.Z)
                TweenTo(targetCF)
                task.wait(1.2)
                local newStage = GetCurrentStageUI()
                if newStage then SaveCheckpoint(newStage) else SaveCheckpoint(data.num) end
                if idx >= endIdx then break end
                local nextData = sorted[idx + 1]
                if not nextData then break end
                if nextData.num > targetNum then break end
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
                local newChar = nil
                local con = player.CharacterAdded:Connect(function(c) newChar = c end)
                local timeout = 0
                repeat task.wait(0.1) timeout += 0.1 until newChar or timeout > 8
                if con then con:Disconnect() end
                if not newChar then idx += 1 continue end
                newChar:WaitForChild("HumanoidRootPart", 5)
                task.wait(0.3)
                local nextCF = CFrame.new(nextData.part.Position.X, nextData.part.Position.Y + 3, nextData.part.Position.Z)
                TweenTo(nextCF, 0)
                task.wait(0.3)
                idx += 1
            end
        end)
    end
})
manualBox:Addbutton({
    title = "TP to Checkpoint selected",
    callback = function()
        if getgenv().CurrentTween then
            pcall(function() getgenv().CurrentTween:Cancel() end)
            getgenv().CurrentTween = nil
        end
        local targetNum = getgenv().SelectedCheckpoint or 0
        local folder = GetFolder()
        if not folder then return end
        local sorted = GetSortedList(folder)
        local targetPart = nil
        for _, d in ipairs(sorted) do
            if d.num == targetNum then targetPart = d.part break end
        end
        if not targetPart then
            targetPart = folder:FindFirstChild(tostring(targetNum))
        end
        if targetPart and targetPart:IsA("BasePart") then
            SaveCheckpoint(targetNum)
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                SafeTP(hrp, CFrame.new(targetPart.Position.X, targetPart.Position.Y, targetPart.Position.Z))
            end
        end
    end
})
manualBox:Addbutton({
    title = "Reset Save",
    callback = function()
        if getgenv().CurrentTween then
            pcall(function() getgenv().CurrentTween:Cancel() end)
            getgenv().CurrentTween = nil
        end
        getgenv().CurrentCheckpoint = 0
        getgenv().SelectedCheckpoint = 0
        getgenv().ManualTargetCheckpoint = 0
        pcall(function()
            if delfile and isfile and isfile("RENUX-HUB_save.txt") then
                delfile("RENUX-HUB_save.txt")
            elseif writefile then
                writefile("RENUX-HUB_save.txt", "0")
            end
        end)
    end
})
serverSection:Addtoggle({
    title = "anti KillBrick",
    value = true,
    callback = function(state)
        if state then EnableAntiKillBrick() else DisableAntiKillBrick() end
    end
})
task.spawn(function()
    task.wait(1)
    pcall(function() EnableAntiKillBrick() end)
end)
serverSection:Addtoggle({
    title = "Bypass TP",
    value = false,
    callback = function(state)
        getgenv().BypassTP = state
    end
})
serverSection:Addtoggle({
    title = "auto reconnect",
    value = true,
    callback = function(state)
        getgenv().AutoReconnectEnabled = state
        if state then
            EnableAutoReconnect()
        else
            DisableAutoReconnect()
        end
    end
})
serverSection:Addbutton({
    title = "rejoin",
    callback = function()
        Rejoin()
    end
})
serverSection:Addbutton({
    title = "server hop",
    callback = function()
        ServerHop()
    end
})