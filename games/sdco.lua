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
        library:Notification({title = "copy discord link", desc = "copy link discord valid", duration = 5})
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
        local names = {"Stage", "stage", "Checkpoint", "checkpoint", "Level", "level", "Stat", "stat"}
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

local function AdjustGravityByYDistance()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local farmPos = nil
    local folder = GetFolder()
    if folder then
        local sorted = GetSortedList(folder)
        local cur = GetCurrentStageLeaderstats()
        for _, d in ipairs(sorted) do
            if d.num == cur + 1 then
                farmPos = d.part.Position
                break
            end
        end
        if not farmPos and #sorted > 0 then
            farmPos = sorted[1].part.Position
        end
    end
    if not farmPos then return end
    local yDist = hrp.Position.Y - farmPos.Y
    local absY = math.abs(yDist)
    local gravityVal = 196.2 + (absY * 0.5)
    if gravityVal > 500 then gravityVal = 500 end
    if gravityVal < 50 then gravityVal = 50 end
    if yDist < 0 then
        local cf = hrp.CFrame
        hrp.CFrame = cf + Vector3.new(0, math.abs(yDist) * 0.1, 0)
    else
        workspace.Gravity = gravityVal
    end
end

local function GetCurrentStageLeaderstats()
    local lsStage = GetStageFromLeaderstats()
    if lsStage then
        return lsStage
    end
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
                if v.Name:lower():find("next") or true then
                    return v
                end
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
    if btn then
        return ClickButton(btn)
    else
        return false
    end
end

local function ClickPreviousButton()
    local btn = FindPreviousButton()
    if btn then
        return ClickButton(btn)
    else
        return false
    end
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
            if v:IsA("TextButton") and v.Text:lower():find("rebirth now") then
                nowBtn = v break
            end
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

local function FindNext10Checkpoint(sorted, cur)
    for _, d in ipairs(sorted) do
        if d.num > cur and d.num % 10 == 0 then
            return d
        end
    end
    local target = math.floor(cur / 10) * 10 + 10
    for _, d in ipairs(sorted) do
        if d.num >= target then
            return d
        end
    end
    return nil
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
                repeat
                    task.wait(0.03)
                    newStage = GetCurrentStageUI() or curStage
                until (newStage >= nextData.num) or (tick() - t0 > 0.5) or not getgenv().FarmEnabled
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
                            if hrp then
                                SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z))
                            end
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
                    while not done and getgenv().FarmEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                        task.wait(0.05)
                    end
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
                                if hrp then
                                    SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z))
                                end
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

local function StartAutoFarmingLoop()
    local player = game.Players.LocalPlayer
    task.spawn(function()
        local folder = GetFolder()
        if not folder then getgenv().AutoFarmingFarmEnabled = false return end
        local sorted = GetSortedList(folder)
        if #sorted == 0 then getgenv().AutoFarmingFarmEnabled = false return end
        EnableFarmPhysics()
        while getgenv().AutoFarmingFarmEnabled do
            pcall(function() AdjustGravityByYDistance() end)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then task.wait(0.1) continue end
            local curStage = GetCurrentStageUI() or getgenv().CurrentCheckpoint or 0
            local nextData = FindNextPart(sorted, curStage)
            if not nextData then getgenv().AutoFarmingFarmEnabled = false break end
            SafeTP(hrp, CFrame.new(nextData.part.Position.X, nextData.part.Position.Y + 3.5, nextData.part.Position.Z))
            task.wait(0.25)
            local t0 = tick()
            local newStage = curStage
            repeat
                task.wait(0.03)
                newStage = GetCurrentStageUI() or curStage
            until (newStage >= nextData.num) or (tick() - t0 > 0.5) or not getgenv().AutoFarmingFarmEnabled
            if newStage >= nextData.num then
                SaveCheckpoint(newStage)
                if newStage % 10 == 0 then task.wait(2) end
                local nextNext = FindNextPart(sorted, newStage)
                if nextNext then
                    hum.Health = 0
                    local newChar = nil
                    local con = player.CharacterAdded:Connect(function(c) newChar = c end)
                    local timeout = 0
                    repeat task.wait(0.1) timeout = timeout + 0.1 until newChar or timeout > 8 or not getgenv().AutoFarmingFarmEnabled
                    if con then con:Disconnect() end
                    if not getgenv().AutoFarmingFarmEnabled then break end
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
                    getgenv().AutoFarmingFarmEnabled = false break
                end
            else
                task.wait(0.05)
            end
        end
        DisableFarmPhysics()
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
        task.spawn(function()
            while getgenv().AutoFarmingEnabled and getgenv().AutoFarmingRebirthEnabled do
                pcall(function()
                    HandleErrorUI()
                    local cur = GetCurrentStageUI()
                    if cur and cur >= 100 then
                        if DoAutoRebirthSequence() then
                            local wasFarm = getgenv().AutoFarmingFarmEnabled
                            getgenv().AutoFarmingFarmEnabled = false
                            SaveCheckpoint(0)
                            task.wait(2)
                            if wasFarm and getgenv().AutoFarmingEnabled then
                                getgenv().AutoFarmingFarmEnabled = true
                                StartAutoFarmingLoop()
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
})

farmBox:AddDivider()

farmBox:Addtoggle({
    title = "Auto Farm",
    value = false,
    callback = function(state)
        if state and getgenv().AutoFarmingEnabled then
            getgenv().AutoFarmingEnabled = false
            getgenv().AutoFarmingFarmEnabled = false
            getgenv().AutoFarmingRebirthEnabled = false
            if getgenv().CurrentTween then
                pcall(function() getgenv().CurrentTween:Cancel() end)
                getgenv().CurrentTween = nil
            end
            DisableFarmPhysics()
        end
        getgenv().FarmEnabled = state
        if not state then
            if getgenv().CurrentTween then
                pcall(function() getgenv().CurrentTween:Cancel() end)
                getgenv().CurrentTween = nil
            end
            DisableFarmPhysics()
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    SafeTP(hrp, CFrame.new(hrp.Position.X, hrp.Position.Y + 5, hrp.Position.Z))
                end
            end)
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
                local curStageNow = GetCurrentStageUI() or getgenv().CurrentCheckpoint or 0
                if (data.num - curStageNow) > 2 then
                    local curIdx = FindIndexByNum(sorted, curStageNow)
                    if curIdx then
                        local curPart = sorted[curIdx].part
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and curPart then
                            SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z))
                            task.wait(0.4)
                            idx = curIdx + 1
                            continue
                        end
                    end
                end
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
        if state then
            EnableAntiKillBrick()
        else
            DisableAntiKillBrick()
        end
    end
})

task.spawn(function()
    task.wait(1)
    pcall(function()
        EnableAntiKillBrick()
    end)
end)

serverSection:Addtoggle({
    title = "Bypass TP",
    value = false,
    callback = function(state)
        getgenv().BypassTP = state
    end
})

localPlayerSection:Addtoggle({
    title = "Infinite Jump",
    value = false,
    callback = function(state)
        getgenv().InfiniteJumpEnabled = state
        if getgenv().InfiniteJumpConn then
            pcall(function() getgenv().InfiniteJumpConn:Disconnect() end)
            getgenv().InfiniteJumpConn = nil
        end
        if state then
            getgenv().InfiniteJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if getgenv().InfiniteJumpEnabled then
                    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end
})

localPlayerSection:Addtoggle({
    title = "Fullbright",
    value = false,
    callback = function(state)
        getgenv().FullbrightEnabled = state
        local Lighting = game:GetService("Lighting")
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

localPlayerSection:Addtoggle({
    title = "Noclip",
    value = false,
    callback = function(state)
        getgenv().NoclipEnabled = state
        if getgenv().NoclipConn then
            pcall(function() getgenv().NoclipConn:Disconnect() end)
            getgenv().NoclipConn = nil
        end
        if state then
            getgenv().NoclipConn = game:GetService("RunService").Stepped:Connect(function()
                if getgenv().NoclipEnabled and game.Players.LocalPlayer.Character then
                    for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if game.Players.LocalPlayer.Character then
                for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end
    end
})

localPlayerSection:AddDivider()

localPlayerSection:Addtoggle({
    title = "Speed",
    value = false,
    callback = function(state)
        getgenv().SpeedEnabled = state
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = state and (getgenv().SpeedValue or 16) or 16 end
    end
})

localPlayerSection:AddSlider({
    Title = "Speed Power",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        getgenv().SpeedValue = val
        if getgenv().SpeedEnabled then
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
})

localPlayerSection:Addtoggle({
    title = "Jump Power",
    value = false,
    callback = function(state)
        getgenv().JumpEnabled = state
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = state and (getgenv().JumpValue or 50) or 50
        end
    end
})

localPlayerSection:AddSlider({
    Title = "Jump Power Strength",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(val)
        getgenv().JumpValue = val
        if getgenv().JumpEnabled then
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end
})

local function GetPlayerNames()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Name ~= game.Players.LocalPlayer.Name then
            table.insert(list, p.Name)
        end
    end
    table.sort(list, function(a,b) return a < b end)
    return list
end

local function GetPlayerNamesEmptyInitial()
    return {}
end

local function GetStageFromLeaderstatsForPlayer(playerName)
    if not playerName or playerName == "None" or playerName == "No Players" then
        return nil
    end
    local plr = game.Players:FindFirstChild(playerName)
    if not plr then return nil end
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
        local names = {"Stage", "stage", "Checkpoint", "checkpoint", "Level", "level"}
        for _, n in ipairs(names) do
            local obj = ls:FindFirstChild(n)
            if obj and obj:IsA("ValueBase") then
                return obj.Value
            end
        end
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                return v.Value
            elseif v:IsA("StringValue") then
                local num = tonumber(tostring(v.Value):match("%d+"))
                if num then return num end
            end
        end
    end
    return nil
end

local function GetNearestCheckpointForPlayer(playerName)
    if not playerName or playerName == "None" or playerName == "No Players" then
        return nil
    end
    local plr = game.Players:FindFirstChild(playerName)
    if not plr or not plr.Character then
        return GetStageFromLeaderstatsForPlayer(playerName)
    end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return GetStageFromLeaderstatsForPlayer(playerName)
    end
    local folder = GetFolder()
    if not folder then
        return GetStageFromLeaderstatsForPlayer(playerName)
    end
    local sorted = GetSortedList(folder)
    if #sorted == 0 then
        return GetStageFromLeaderstatsForPlayer(playerName)
    end
    local nearest = nil
    local minDist = math.huge
    for _, data in ipairs(sorted) do
        if data.part and data.part.Parent then
            local dist = (data.part.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = data
            end
        end
    end
    if nearest then
        return nearest.num, nearest.part
    end
    return GetStageFromLeaderstatsForPlayer(playerName)
end

local function FindSelectedStageInPlayerFolder()
    local plr = game.Players.LocalPlayer
    local obj = plr:FindFirstChild("SelectedStage")
    if obj and obj:IsA("ValueBase") then return obj end
    for _, v in ipairs(plr:GetDescendants()) do
        if v.Name == "SelectedStage" and v:IsA("ValueBase") then
            return v
        end
    end
    local pg = plr:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "SelectedStage" and v:IsA("ValueBase") then
                return v
            end
        end
    end
    for _, v in ipairs(game:GetDescendants()) do
        if v.Name == "SelectedStage" and v:IsA("ValueBase") then
            local parent = v.Parent
            local found = false
            while parent do
                if parent == plr then found = true break end
                parent = parent.Parent
            end
            if found then return v end
        end
    end
    for _, v in ipairs(plr:GetDescendants()) do
        if (v.Name:lower():find("selected") and v.Name:lower():find("stage")) or v.Name == "SelectedCheckpoint" then
            if v:IsA("ValueBase") then return v end
        end
    end
    return nil
end

local function SetSelectedStageValue(targetCheckpoint)
    local selectedStageObj = FindSelectedStageInPlayerFolder()
    if not selectedStageObj then
        local myselfFolder = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == game.Players.LocalPlayer.Name and v:FindFirstChild("SelectedStage") then
                myselfFolder = v
                break
            end
        end
        if myselfFolder then
            selectedStageObj = myselfFolder:FindFirstChild("SelectedStage")
        end
    end
    
    if selectedStageObj then
        local newVal = targetCheckpoint - 1
        pcall(function()
            selectedStageObj.Value = newVal
        end)
        return true, selectedStageObj
    else
        return false, nil
    end
end

local function ScannerWorkspaceNearPlayer(playerName)
    local plr = game.Players:FindFirstChild(playerName)
    if not plr or not plr.Character then return nil end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearestNum, nearestPart = GetNearestCheckpointForPlayer(playerName)
    if nearestNum and nearestPart then
        return nearestNum, nearestPart
    end
    return nil, nil
end

getgenv().TPToPlayerRunning = false
getgenv().TPToPlayerTarget = nil

local function Levenshtein(s, t)
    local m, n = #s, #t
    if m == 0 then return n end
    if n == 0 then return m end
    local d = {}
    for i = 0, m do d[i] = {[0]=i} end
    for j = 0, n do d[0][j] = j end
    for i = 1, m do
        for j = 1, n do
            local cost = s:sub(i,i) == t:sub(j,j) and 0 or 1
            d[i][j] = math.min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost)
        end
    end
    return d[m][n]
end

local function FindSimilarPlayer(inputText)
    if not inputText or inputText == "" then return nil end
    local low = inputText:lower()
    local best, bestScore = nil, math.huge
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Name ~= game.Players.LocalPlayer.Name then
            local nameLow = p.Name:lower()
            if nameLow:find(low, 1, true) or low:find(nameLow, 1, true) then
                return p.Name, 0
            end
            local dist = Levenshtein(low, nameLow)
            local maxLen = math.max(#low, #nameLow)
            local sim = maxLen > 0 and dist / maxLen or 1
            if sim < 0.5 and dist < bestScore then
                bestScore = dist
                best = p.Name
            end
        end
    end
    return best, bestScore
end

local playerStatusPrgf = nil
getgenv().AutoCurrentSimilar = nil

playerSection:AddInput({
    Title = "select Player",
    Value = "",
    Callback = function(text)
        if not text or text == "" then
            getgenv().SelectedSpyPlayer = nil
            getgenv().AutoCurrentSimilar = nil
            if playerStatusPrgf then
                playerStatusPrgf:SetDesc("• auto current : -\n• selected : -\n• stage : -")
            end
            return
        end
        local exact = game.Players:FindFirstChild(text)
        if exact then
            getgenv().SelectedSpyPlayer = exact.Name
            getgenv().AutoCurrentSimilar = exact.Name
        else
            local similar, score = FindSimilarPlayer(text)
            if similar then
                getgenv().SelectedSpyPlayer = similar
                getgenv().AutoCurrentSimilar = similar
            else
                getgenv().SelectedSpyPlayer = nil
                getgenv().AutoCurrentSimilar = "tidak ada yang mirip"
            end
        end
        if playerStatusPrgf then
            local sel = getgenv().SelectedSpyPlayer or "-"
            local autoCur = getgenv().AutoCurrentSimilar or "-"
            local stage = "-"
            if sel ~= "-" then
                local st = GetStageFromLeaderstatsForPlayer(sel) or GetNearestCheckpointForPlayer(sel)
                if st then stage = tostring(st) end
            end
            playerStatusPrgf:SetDesc("• auto current : "..autoCur.."\n• selected : "..sel.."\n• stage : "..stage)
        end
        if getgenv().SpectatorEnabled and getgenv().SelectedSpyPlayer then
            local target = game.Players:FindFirstChild(getgenv().SelectedSpyPlayer)
            if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            end
        end
    end
})

playerStatusPrgf = playerSection:AddParagraph({
    Title = "Player Status",
    Desc = "• auto current : -\n• selected : -\n• stage : -",
    Color = "Grey"
})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not playerStatusPrgf then return end
            local sel = getgenv().SelectedSpyPlayer
            if not sel or sel == "" then
                local autoCur = getgenv().AutoCurrentSimilar or "-"
                playerStatusPrgf:SetDesc("• auto current : "..autoCur.."\n• selected : -\n• stage : -")
            else
                local autoCur = getgenv().AutoCurrentSimilar or sel
                local stage = GetStageFromLeaderstatsForPlayer(sel) or GetNearestCheckpointForPlayer(sel)
                playerStatusPrgf:SetDesc("• auto current : "..autoCur.."\n• selected : "..tostring(sel).."\n• stage : "..tostring(stage or "-"))
            end
        end)
    end
end)

playerSection:Addtoggle({
    title = "Spectator (Fixed)",
    value = false,
    callback = function(state)
        getgenv().SpectatorEnabled = state
        if getgenv().SpectatorConn then
            pcall(function() getgenv().SpectatorConn:Disconnect() end)
            getgenv().SpectatorConn = nil
        end
        local function ResetToSelf()
            local myChar = game.Players.LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if myHum then workspace.CurrentCamera.CameraSubject = myHum end
        end
        if state then
            local targetName = getgenv().SelectedSpyPlayer
            if targetName then
                local target = game.Players:FindFirstChild(targetName)
                if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
                end
            end
            getgenv().SpectatorConn = game:GetService("RunService").Heartbeat:Connect(function()
                if not getgenv().SpectatorEnabled then return end
                local tName = getgenv().SelectedSpyPlayer
                if not tName then return end
                local tPlayer = game.Players:FindFirstChild(tName)
                if tPlayer and tPlayer.Character then
                    local hum = tPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if workspace.CurrentCamera.CameraSubject ~= hum then
                            workspace.CurrentCamera.CameraSubject = hum
                        end
                    else
                        ResetToSelf()
                    end
                end
            end)
        else
            ResetToSelf()
        end
    end
})

playerSection:Addbutton({
    title = "TP to player",
    callback = function()
        local targetName = getgenv().SelectedSpyPlayer
        if not targetName or targetName == "" then return end
        local myStage = GetStageFromLeaderstats() or GetCurrentStageFromLabel() or 0
        local selectStage = GetStageFromLeaderstatsForPlayer(targetName) or GetNearestCheckpointForPlayer(targetName) or 0
        if selectStage > myStage then
            return
        end
        if myStage <= selectStage then
            return
        end
        if getgenv().TPToPlayerRunning then
            getgenv().TPToPlayerRunning = false
            task.wait(0.3)
        end
        task.spawn(function()
            getgenv().TPToPlayerRunning = true
            getgenv().TPToPlayerTarget = targetName
            local nearestNum, nearestPart = ScannerWorkspaceNearPlayer(targetName)
            if not nearestNum then
                nearestNum = GetNearestCheckpointForPlayer(targetName) or GetStageFromLeaderstatsForPlayer(targetName)
            end
            if not nearestNum then
                getgenv().TPToPlayerRunning = false
                return
            end
            local myStage2 = GetStageFromLeaderstats() or GetCurrentStageFromLabel() or 0
            local selectStage2 = GetStageFromLeaderstatsForPlayer(targetName) or nearestNum
            if selectStage2 > myStage2 then
                getgenv().TPToPlayerRunning = false
                getgenv().TPToPlayerTarget = nil
                return
            end
            if myStage2 <= selectStage2 then
                getgenv().TPToPlayerRunning = false
                getgenv().TPToPlayerTarget = nil
                return
            end
            local success = SetSelectedStageValue(nearestNum)
            task.wait(0.2)
            ClickNextButton()
            local maxWait, waited = 20, 0
            local reached = false
            while getgenv().TPToPlayerRunning and waited < maxWait do
                task.wait(0.3)
                waited = waited + 0.3
                local curStage = GetStageFromLeaderstats() or GetCurrentStageFromLabel() or 0
                if curStage == nearestNum then
                    reached = true
                    break
                end
                if curStage < nearestNum and waited % 1 < 0.35 then
                    ClickNextButton()
                end
            end
            if reached then
                task.wait(0.2)
                local tPlayer = game.Players:FindFirstChild(targetName)
                local tHrp = tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and myHrp then
                    SafeTP(myHrp, CFrame.new(tHrp.Position.X, tHrp.Position.Y + 3, tHrp.Position.Z))
                end
            end
            getgenv().TPToPlayerRunning = false
            getgenv().TPToPlayerTarget = nil
        end)
    end
})

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local sel = getgenv().SelectedSpyPlayer
            if sel and not game.Players:FindFirstChild(sel) then
                getgenv().SelectedSpyPlayer = nil
                getgenv().AutoCurrentSimilar = "player left"
                if playerStatusPrgf then
                    playerStatusPrgf:SetDesc("• auto current : player left\n• selected : -\n• stage : -")
                end
            end
        end)
    end
end)

game.Players.PlayerAdded:Connect(function(newPlr)
end)

game.Players.PlayerRemoving:Connect(function(remPlr)
    task.wait(0.5)
    if getgenv().SelectedSpyPlayer == remPlr.Name then
        getgenv().SelectedSpyPlayer = nil
        getgenv().AutoCurrentSimilar = "player left"
        if playerStatusPrgf then
            pcall(function() playerStatusPrgf:SetDesc("• auto current : player left\n• selected : -\n• stage : -") end)
        end
    end
end)

settingUISection:Addbutton({
    title = "reload script",
    callback = function()
        getgenv().FarmEnabled = false
        getgenv().AutoRebirth = false
        getgenv().SpectatorEnabled = false
        getgenv().InfiniteJumpEnabled = false
        getgenv().FullbrightEnabled = false
        getgenv().NoclipEnabled = false
        getgenv().SpeedEnabled = false
        getgenv().JumpEnabled = false
        getgenv().BypassTP = false

        if getgenv().CurrentTween then
            pcall(function() getgenv().CurrentTween:Cancel() end)
            getgenv().CurrentTween = nil
        end
        if getgenv().SpectatorConn then
            pcall(function() getgenv().SpectatorConn:Disconnect() end)
            getgenv().SpectatorConn = nil
        end
        if getgenv().InfiniteJumpConn then
            pcall(function() getgenv().InfiniteJumpConn:Disconnect() end)
            getgenv().InfiniteJumpConn = nil
        end
        if getgenv().NoclipConn then
            pcall(function() getgenv().NoclipConn:Disconnect() end)
            getgenv().NoclipConn = nil
        end

        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "KillBrick" and v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    hum.UseJumpPower = true
                    workspace.CurrentCamera.CameraSubject = hum
                end
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end)

        task.wait(0.3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/setting/filter.lua", true))()
    end
})

statusPrgf = statusBox:AddParagraph({
    Title = "Status",
    Desc = "• stage : ".. tostring(GetStageFromLeaderstats() or GetCurrentStageUI() or getgenv().CurrentCheckpoint).. "\n• mode : ".. string.lower(getgenv().TPMode).. "\n• ping : 0 ms\n• fps : 60\n• executor : ".. ExecutorName.. "\n• player in server : ".. #game.Players:GetPlayers().. "/".. game.Players.MaxPlayers,
    Color = "Grey"
})

task.spawn(function()
    while task.wait(0.5) do
        if statusPrgf then
            pcall(function()
                statusPrgf:SetDesc(
                    "• stage : ".. tostring(GetStageFromLeaderstats() or GetCurrentStageUI() or getgenv().CurrentCheckpoint).. "\n"..
                    "• mode : ".. string.lower(getgenv().TPMode).. (getgenv().BypassTP and " + bypass" or "").. "\n"..
                    "• ping : ".. getgenv().CurrentPing.. " ms\n"..
                    "• fps : ".. getgenv().CurrentFPS.. "\n"..
                    "• executor : ".. ExecutorName.. "\n"..
                    "• player in server : ".. #game.Players:GetPlayers().. "/".. game.Players.MaxPlayers
                )
            end)
        end
    end
end)
