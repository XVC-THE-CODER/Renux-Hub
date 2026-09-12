loadstring(game:HttpGet("https://github.com/SCRIPTHUB-dev-god/User-Interface/releases/download/loader/fire-ui.lua"))()
local library = GetLibrary("latest")

library:CreateTheme({
    name = "Ametis",
    MainBG = Color3.fromRGB(25, 18, 38),
    HeaderBG = Color3.fromRGB(18, 13, 28),
    Stroke = Color3.fromRGB(90, 50, 130),
    ButtonBG = Color3.fromRGB(48, 32, 75),
    SectionBG = Color3.fromRGB(35, 24, 58),
    Accent = Color3.fromRGB(168, 85, 247),
    IconCl = Color3.fromRGB(216, 180, 254)
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
    title = "v1.0",
    icon = "globe",
    color = Color3.fromRGB(84, 15, 153),
    getclick = false,
})

window:AddTag({
    title = "keyless",
    icon = "key",
    color = Color3.fromRGB(84, 15, 153),
    getclick = false,
})

window:SetToggleUi({ title = "Renux Hub", icon = "moon" })

local suptab = window:AddTab("support", "info")

suptab:Addbutton({
    title = "copy discord",
    callback = function()
        setclipboard("https://discord.gg/mXnTVYYYsy")
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
        if writefile then writefile("RENUX-HUB_save.txt", tostring(i)) end
    end)
end

local function GetFolder()
    local f = workspace:FindFirstChild("Checkpoints")
    if f then return f end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower() == "checkpoints" then return v end
    end
    return nil
end

local function GetSortedList(folder)
    if not folder then return {} end
    local list = {}
    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("BasePart") and tonumber(v.Name) then
            table.insert(list, { part = v, num = tonumber(v.Name) })
        end
    end
    table.sort(list, function(a,b) return a.num < b.num end)
    return list
end

local function GetCheckpointValuesFixed()
    local folder = GetFolder()
    local sorted = GetSortedList(folder)
    local values = {}
    if #sorted > 0 then
        local maxNum = sorted[#sorted].num
        for i = 0, maxNum do
            table.insert(values, tostring(i))
        end
    else
        for i = 0, 100 do table.insert(values, tostring(i)) end
    end
    return values
end

local function GetRebirthValues()
    local folder = GetFolder()
    local sorted = GetSortedList(folder)
    local values = {}
    if #sorted > 0 then
        local maxNum = sorted[#sorted].num
        if maxNum < 61 then maxNum = 100 end
        for i = 61, maxNum do
            table.insert(values, tostring(i))
        end
    else
        for i = 61, 100 do table.insert(values, tostring(i)) end
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
    if txt then return tonumber(txt:match("%d+")) or tonumber(txt) end
    return nil
end

local function FindIndexByNum(sorted, num)
    for i, d in ipairs(sorted) do if d.num == num then return i end end
    return nil
end

local function FindNextPart(sorted, cur)
    for _, d in ipairs(sorted) do if d.num > cur then return d end end
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
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
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
    if not btn then btn = frame:FindFirstChildOfClass("TextButton") or frame:FindFirstChildOfClass("ImageButton") end
    if btn then
        task.wait(0.25)
        ClickButton(btn)
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
        if rebirthBtn then task.wait(0.25) ClickButton(rebirthBtn) task.wait(0.25) end
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
        if nowBtn then task.wait(0.25) ClickButton(nowBtn) task.wait(0.25) end
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
        if yesBtn then task.wait(0.25) ClickButton(yesBtn) return true end
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
            if ping == 0 then ping = math.floor(game.Players.LocalPlayer:GetNetworkPing()*1000) end
            getgenv().CurrentPing = ping
        end)
    end
end)

local statusPrgf = nil
local function StartFarmLoop()
    local TweenService = game:GetService("TweenService")
    local player = game.Players.LocalPlayer

    task.spawn(function()
        local folder = GetFolder()
        if not folder then getgenv().FarmEnabled = false return end
        local sorted = GetSortedList(folder)
        if #sorted == 0 then getgenv().FarmEnabled = false return end

        if getgenv().TPMode == "Fast" then
            while getgenv().FarmEnabled do
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
                    local nextNext = FindNextPart(sorted, newStage)
                    if nextNext then
                        hum.Health = 0
                        local newChar = nil
                        local con = player.CharacterAdded:Connect(function(c) newChar = c end)
                        local timeout = 0
                        repeat task.wait(0.1) timeout += 0.1 until newChar or timeout > 8 or not getgenv().FarmEnabled
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
        else
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
                            task.wait(0.3)
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
                    local duration = dist / math.max(getgenv().FarmSpeed, 1)
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
                task.wait(1.2)
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
                                task.wait(0.3)
                                idx = curIdx + 1
                                SaveCheckpoint(curUI2)
                                continue
                            end
                        end
                    else
                        SaveCheckpoint(curUI2)
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
        getgenv().FarmEnabled = false
    end)
end

farmBox:Addtoggle({
    title = "Auto Farm",
    value = false,
    callback = function(state)
        getgenv().FarmEnabled = state
        local player = game.Players.LocalPlayer
        if not state then
            if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) getgenv().CurrentTween = nil end
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then SafeTP(hrp, CFrame.new(hrp.Position.X, hrp.Position.Y + 5, hrp.Position.Z)) end
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
        if num then getgenv().SelectedCheckpoint = num SaveCheckpoint(num) end
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
                for i, d in ipairs(sorted) do if d.num >= curStage then startIdx = i break end end
                if not startIdx then startIdx = 1 end
            end
            local endIdx = FindIndexByNum(sorted, targetNum)
            if not endIdx then
                for i = #sorted, 1, -1 do if sorted[i].num <= targetNum then endIdx = i break end end
                if not endIdx then endIdx = #sorted end
            end
            if startIdx > endIdx then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local tp = sorted[endIdx] and sorted[endIdx].part
                if hrp and tp then SafeTP(hrp, CFrame.new(tp.Position.X, tp.Position.Y + 3, tp.Position.Z)) end
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
                getgenv().CurrentTween = tween tween:Play()
                local done = false
                local conn = tween.Completed:Connect(function() done = true end)
                local t = 0
                while not done and t < 10 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do task.wait(0.05) t += 0.05 end
                if conn then conn:Disconnect() end
                pcall(function() tween:Cancel() end) getgenv().CurrentTween = nil
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
                        if hrp and curPart then SafeTP(hrp, CFrame.new(curPart.Position.X, curPart.Position.Y + 3, curPart.Position.Z)) task.wait(0.4) idx = curIdx + 1 continue end
                    end
                end
                local targetCF = CFrame.new(data.part.Position.X, data.part.Position.Y + 3, data.part.Position.Z)
                TweenTo(targetCF) task.wait(1.2)
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
                TweenTo(nextCF, 0) task.wait(0.3)
                idx += 1
            end
        end)
    end
})

manualBox:Addbutton({
    title = "TP to Checkpoint selected",
    callback = function()
        if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) getgenv().CurrentTween = nil end
        local targetNum = getgenv().SelectedCheckpoint or 0
        local folder = GetFolder()
        if not folder then return end
        local sorted = GetSortedList(folder)
        local targetPart = nil
        for _, d in ipairs(sorted) do if d.num == targetNum then targetPart = d.part break end end
        if not targetPart then targetPart = folder:FindFirstChild(tostring(targetNum)) end
        if targetPart and targetPart:IsA("BasePart") then
            SaveCheckpoint(targetNum)
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then SafeTP(hrp, CFrame.new(targetPart.Position.X, targetPart.Position.Y, targetPart.Position.Z)) end
        end
    end
})

manualBox:Addbutton({
    title = "Reset Save",
    callback = function()
        if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) getgenv().CurrentTween = nil end
        getgenv().CurrentCheckpoint = 0
        getgenv().SelectedCheckpoint = 0
        getgenv().ManualTargetCheckpoint = 0
        pcall(function()
            if delfile and isfile and isfile("RENUX-HUB_save.txt") then delfile("RENUX-HUB_save.txt")
            elseif writefile then writefile("RENUX-HUB_save.txt", "0") end
        end)
    end
})

serverSection:Addtoggle({
    title = "anti KillBrick",
    value = false,
    callback = function(state)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "KillBrick" and v:IsA("BasePart") then v.CanTouch = not state end
        end
    end
})

serverSection:Addtoggle({
    title = "Bypass TP",
    value = false,
    callback = function(state) getgenv().BypassTP = state end
})

localPlayerSection:Addtoggle({
    title = "Infinite Jump",
    value = false,
    callback = function(state)
        getgenv().InfiniteJumpEnabled = state
        if getgenv().InfiniteJumpConn then pcall(function() getgenv().InfiniteJumpConn:Disconnect() end) getgenv().InfiniteJumpConn = nil end
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
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
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
        if getgenv().NoclipConn then pcall(function() getgenv().NoclipConn:Disconnect() end) getgenv().NoclipConn = nil end
        if state then
            getgenv().NoclipConn = game:GetService("RunService").Stepped:Connect(function()
                if getgenv().NoclipEnabled and game.Players.LocalPlayer.Character then
                    for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
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
        if p.Name ~= game.Players.LocalPlayer.Name then table.insert(list, p.Name) end
    end
    table.sort(list)
    if #list == 0 then return { "No Players" } end
    return list
end

local spyDropdown = playerSection:AddDropdown({
    Title = "select Player",
    Values = GetPlayerNames(),
    Value = { GetPlayerNames()[1] or "No Players" },
    Multi = false,
    Search = true,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        getgenv().SelectedSpyPlayer = val
        if getgenv().SpectatorEnabled then
            local target = game.Players:FindFirstChild(val)
            if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            end
        end
    end
})

playerSection:Addtoggle({
    title = "Spectator",
    value = false,
    callback = function(state)
        getgenv().SpectatorEnabled = state
        if getgenv().SpectatorConn then pcall(function() getgenv().SpectatorConn:Disconnect() end) getgenv().SpectatorConn = nil end
        if state then
            local targetName = getgenv().SelectedSpyPlayer
            if targetName and targetName ~= "No Players" then
                local target = game.Players:FindFirstChild(targetName)
                if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
                end
            end
            getgenv().SpectatorConn = game:GetService("RunService").Heartbeat:Connect(function()
                if not getgenv().SpectatorEnabled then return end
                local tName = getgenv().SelectedSpyPlayer
                if not tName or tName == "No Players" then return end
                local tPlayer = game.Players:FindFirstChild(tName)
                if tPlayer and tPlayer.Character then
                    local hum = tPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and workspace.CurrentCamera.CameraSubject ~= hum then
                        workspace.CurrentCamera.CameraSubject = hum
                    end
                end
            end)
        else
            local myHum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then workspace.CurrentCamera.CameraSubject = myHum end
        end
    end
})

playerSection:Addbutton({
    title = "TP to player",
    callback = function()
        local targetName = getgenv().SelectedSpyPlayer
        if not targetName or targetName == "No Players" then return end
        local targetPlayer = game.Players:FindFirstChild(targetName)
        if not targetPlayer or not targetPlayer.Character then return end
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        SafeTP(hrp, CFrame.new(targetHRP.Position.X, targetHRP.Position.Y + 3, targetHRP.Position.Z))
    end
})

task.spawn(function()
    local lastList = table.concat(GetPlayerNames(), ",")
    while task.wait(2) do
        pcall(function()
            local newList = GetPlayerNames()
            local newStr = table.concat(newList, ",")
            if newStr ~= lastList then
                lastList = newStr
                if spyDropdown and spyDropdown.SetValues then spyDropdown:SetValues(newList) end
            end
        end)
    end
end)

game.Players.PlayerAdded:Connect(function()
    task.wait(1)
    pcall(function()
        local newList = GetPlayerNames()
        if spyDropdown and spyDropdown.SetValues then spyDropdown:SetValues(newList) end
    end)
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(1)
    pcall(function()
        local newList = GetPlayerNames()
        if spyDropdown and spyDropdown.SetValues then spyDropdown:SetValues(newList) end
    end)
end)

settingUISection:Addbutton({
    title = "Reload UI",
    callback = function()
        getgenv().FarmEnabled = false
        getgenv().AutoRebirth = false
        getgenv().SpectatorEnabled = false
        getgenv().InfiniteJumpEnabled = false
        getgenv().FullbrightEnabled = false
        getgenv().NoclipEnabled = false
        getgenv().SpeedEnabled = false
        getgenv().JumpEnabled = false

        if getgenv().CurrentTween then pcall(function() getgenv().CurrentTween:Cancel() end) end
        if getgenv().SpectatorConn then pcall(function() getgenv().SpectatorConn:Disconnect() end) end
        if getgenv().InfiniteJumpConn then pcall(function() getgenv().InfiniteJumpConn:Disconnect() end) end
        if getgenv().NoclipConn then pcall(function() getgenv().NoclipConn:Disconnect() end) end

        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
                for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
            end
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            local myHum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then workspace.CurrentCamera.CameraSubject = myHum end
        end)

        task.wait(0.3)
        loadstring(game:HttpGet("https://github.com/XVC-THE-CODER/Renux-Hub/releases/latest/download/loaders.lua", true))()
    end
})

statusPrgf = statusBox:AddParagraph({
    Title = "Status",
    Desc = "• stage : ".. tostring(GetCurrentStageUI() or getgenv().CurrentCheckpoint).. "\n• mode : ".. string.lower(getgenv().TPMode).. "\n• ping : 0 ms\n• fps : 60",
    Color = "Blue",
    Button = {
        Title = "Refresh",
        Callback = function()
            checkpointValuesCache = GetCheckpointValuesFixed()
            rebirthValuesCache = GetRebirthValues()
            if statusPrgf then
                statusPrgf:SetDesc("• stage : ".. tostring(GetCurrentStageUI() or getgenv().CurrentCheckpoint).. "\n• mode : ".. string.lower(getgenv().TPMode).. "\n• ping : ".. getgenv().CurrentPing.. " ms\n• fps : ".. getgenv().CurrentFPS)
            end
        end
    }
})

task.spawn(function()
    while task.wait(0.5) do
        if statusPrgf then
            pcall(function()
                statusPrgf:SetDesc(
                    "• stage : ".. tostring(GetCurrentStageUI() or getgenv().CurrentCheckpoint).. "\n"..
                    "• mode : ".. string.lower(getgenv().TPMode).. (getgenv().BypassTP and " + bypass" or "").. "\n"..
                    "• ping : ".. getgenv().CurrentPing.. " ms\n"..
                    "• fps : ".. getgenv().CurrentFPS
                )
            end)
        end
    end
end)
