local plr = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local ws = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HS = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")

local isPC = false
pcall(function()
    local pf = UIS:GetPlatform()
    if pf == Enum.Platform.Windows or pf == Enum.Platform.OSX or pf == Enum.Platform.Linux or pf == Enum.Platform.UWP then
        isPC = true
    end
end)
if not isPC and UIS.KeyboardEnabled and UIS.MouseEnabled and not UIS.TouchEnabled then
    isPC = true
end
local SC = isPC and 2.5 or 1

local function saveAuto(v)
    pcall(function()
        if writefile then
            writefile("rnx-joj.json", HS:JSONEncode({auto = v}))
        end
    end)
end

local function loadAuto()
    local ok, data = pcall(function()
        if readfile and isfile and isfile("rnx-joj.json") then
            return HS:JSONDecode(readfile("rnx-joj.json"))
        end
        return nil
    end)
    if ok and data and data.auto then
        return true
    end
    return false
end

local isRunning = loadAuto()

local function getWins()
    local ls = plr:FindFirstChild("leaderstats")
    if not ls then
        return 0
    end
    local w = ls:FindFirstChild("Wins")
    if not w then
        for _, v in ipairs(ls:GetChildren()) do
            if string.lower(v.Name) == "wins" then
                w = v
                break
            end
        end
    end
    if w and typeof(w.Value) == "number" then
        return w.Value
    end
    return 0
end

local winsBefore = getWins()

local executorName = "Unknown"
pcall(function()
    if typeof(identifyexecutor) == "function" then
        local result = identifyexecutor()
        if type(result) == "string" then
            executorName = result
        elseif type(result) == "table" and result[1] then
            executorName = tostring(result[1])
        end
    elseif typeof(getexecutorname) == "function" then
        executorName = getexecutorname()
    end
end)

if plr.PlayerGui:FindFirstChild("Renux") then
    plr.PlayerGui.Renux:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Renux"
gui.ResetOnSpawn = false
gui.Parent = plr.PlayerGui

local function tw(o, p, t)
    TS:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function twPop(o, p, t)
    TS:Create(o, TweenInfo.new(t or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 200 * SC, 0, 76 * SC)
main.Position = UDim2.new(0, 24 * SC, 0, 24 * SC)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
main.BackgroundTransparency = 0.08
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14 * SC)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1 * SC
stroke.Transparency = 0.2

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 22 * SC)
top.BackgroundTransparency = 1

local function dot(col, order)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.new(0, 11 * SC, 0, 11 * SC)
    b.Position = UDim2.new(1, -(10 * SC + order * 16 * SC + 11 * SC), 0, 6 * SC)
    b.BackgroundColor3 = col
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    b.MouseEnter:Connect(function()
        twPop(b, {Size = UDim2.new(0, 14 * SC, 0, 14 * SC)}, 0.18)
    end)
    b.MouseLeave:Connect(function()
        tw(b, {Size = UDim2.new(0, 11 * SC, 0, 11 * SC)}, 0.18)
    end)
    return b
end

local btnR = dot(Color3.fromRGB(255, 70, 70), 0)
local btnY = dot(Color3.fromRGB(255, 200, 0), 1)
local btnG = dot(Color3.fromRGB(0, 210, 90), 2)

local title = Instance.new("TextLabel", main)
title.Position = UDim2.new(0, 14 * SC, 0, 24 * SC)
title.Size = UDim2.new(1, -60 * SC, 0, 22 * SC)
title.BackgroundTransparency = 1
title.Text = "Renux"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

local sub = Instance.new("TextLabel", main)
sub.Position = UDim2.new(0, 14 * SC, 0, 48 * SC)
sub.Size = UDim2.new(1, -28 * SC, 0, 14 * SC)
sub.BackgroundTransparency = 1
sub.Text = "Executor: " .. executorName
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 11 * SC
sub.TextColor3 = Color3.fromRGB(180, 180, 180)
sub.TextXAlignment = Enum.TextXAlignment.Left

local stopBtn = Instance.new("TextButton", main)
stopBtn.Size = UDim2.new(0, 40 * SC, 0, 40 * SC)
stopBtn.Position = UDim2.new(1, -48 * SC, 0, 18 * SC + 5)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "START"
stopBtn.Font = Enum.Font.GothamBlack
stopBtn.TextScaled = true
stopBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
stopBtn.AutoButtonColor = false
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 10 * SC)
local stopStroke = Instance.new("UIStroke", stopBtn)
stopStroke.Color = Color3.fromRGB(255, 255, 255)
stopStroke.Thickness = 1 * SC
stopStroke.Transparency = 0.2
stopBtn.MouseEnter:Connect(function()
    twPop(stopBtn, {Size = UDim2.new(0, 44 * SC, 0, 44 * SC)}, 0.18)
end)
stopBtn.MouseLeave:Connect(function()
    tw(stopBtn, {Size = UDim2.new(0, 40 * SC, 0, 40 * SC)}, 0.18)
end)
if isRunning then
    stopBtn.Text = "STOP"
end

local orb = Instance.new("Frame", gui)
orb.Size = UDim2.new(0, 46 * SC, 0, 46 * SC)
orb.Position = UDim2.new(0, 24 * SC, 0, 24 * SC)
orb.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
orb.Visible = false
orb.Active = true
orb.Draggable = true
Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
local oStroke = Instance.new("UIStroke", orb)
oStroke.Color = Color3.fromRGB(255, 255, 255)
oStroke.Thickness = 1.8 * SC
local oTxt = Instance.new("TextLabel", orb)
oTxt.Size = UDim2.new(1, 0, 1, 0)
oTxt.BackgroundTransparency = 1
oTxt.Text = "RX"
oTxt.Font = Enum.Font.GothamBlack
oTxt.TextScaled = false
oTxt.TextSize = 14 * SC
oTxt.TextColor3 = Color3.new(1, 1, 1)
local oBtn = Instance.new("TextButton", orb)
oBtn.Size = UDim2.new(1, 0, 1, 0)
oBtn.BackgroundTransparency = 1
oBtn.Text = ""

main.Size = UDim2.new(0, 0, 0, 0)
main.BackgroundTransparency = 1
stroke.Transparency = 1
title.TextTransparency = 1
sub.TextTransparency = 1
btnR.BackgroundTransparency = 1
btnY.BackgroundTransparency = 1
btnG.BackgroundTransparency = 1
stopBtn.BackgroundTransparency = 1
stopBtn.TextTransparency = 1
stopStroke.Transparency = 1
task.spawn(function()
    task.wait(0.05)
    twPop(main, {Size = UDim2.new(0, 200 * SC, 0, 76 * SC), BackgroundTransparency = 0.08}, 0.45)
    tw(stroke, {Transparency = 0.2}, 0.4)
    tw(title, {TextTransparency = 0}, 0.3)
    tw(sub, {TextTransparency = 0}, 0.3)
    tw(btnR, {BackgroundTransparency = 0}, 0.3)
    tw(btnY, {BackgroundTransparency = 0}, 0.3)
    tw(btnG, {BackgroundTransparency = 0}, 0.3)
    tw(stopBtn, {BackgroundTransparency = 0}, 0.3)
    tw(stopBtn, {TextTransparency = 0}, 0.3)
    tw(stopStroke, {Transparency = 0.2}, 0.3)
end)

local spawnY = nil
local defaultGravity = ws.Gravity
local tweeningUp = false
local currentUpTween = nil
local hitCooldown = false
local isArrived = false
local arrivedStart = 0

stopBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    tw(stopBtn, {Size = UDim2.new(0, 36 * SC, 0, 36 * SC)}, 0.1)
    task.wait(0.1)
    twPop(stopBtn, {Size = UDim2.new(0, 40 * SC, 0, 40 * SC)}, 0.18)
    if isRunning then
        stopBtn.Text = "STOP"
        saveAuto(true)
        hitCooldown = false
        isArrived = false
        winsBefore = getWins()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            spawnY = plr.Character.HumanoidRootPart.Position.Y
        end
    else
        stopBtn.Text = "START"
        saveAuto(false)
        spawnY = nil
        ws.Gravity = defaultGravity
    end
end)

RunService.Heartbeat:Connect(function()
    if not isRunning then
        if ws.Gravity ~= defaultGravity then
            ws.Gravity = defaultGravity
        end
        return
    end
    if hitCooldown then return end
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not spawnY then
        spawnY = hrp.Position.Y
    end
    local nearest = nil
    local nearestDist = 1e9
    for _, obj in ipairs(ws:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "WinsBrick" then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = obj
            end
        end
    end
    if not nearest then return end
    if nearestDist > 10 then
        winsBefore = getWins()
        isArrived = false
    end
    if nearestDist < 4 then
        if not isArrived then
            isArrived = true
            arrivedStart = os.clock()
        end
        if os.clock() - arrivedStart < 2 then
            ws.Gravity = defaultGravity
            if currentUpTween then
                pcall(function()
                    currentUpTween:Cancel()
                end)
            end
            tweeningUp = false
            return
        end
        hitCooldown = true
        isArrived = false
        if currentUpTween then
            pcall(function()
                currentUpTween:Cancel()
            end)
        end
        tweeningUp = false
        ws.Gravity = defaultGravity
        local before = winsBefore
        local after = getWins()
        if after > before then
            winsBefore = after
            isRunning = false
            stopBtn.Text = "START"
            saveAuto(true)
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.Health = 0
                end
            end)
            task.wait(0.6)
            pcall(function()
                TPS:Teleport(game.PlaceId, plr)
            end)
        else
            winsBefore = after
            hitCooldown = false
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
        end
        return
    end
    local targetY = nearest.Position.Y
    local yDiff = hrp.Position.Y - targetY
    if yDiff > 2 then
        local extra = yDiff * 12
        local newGrav = 200 + extra
        if newGrav > 900 then
            newGrav = 900
        end
        ws.Gravity = newGrav
        hrp.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
    else
        ws.Gravity = 8
        local horizDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(nearest.Position.X, 0, nearest.Position.Z)).Magnitude
        if horizDist > 3 then
            local horizTarget = CFrame.new(nearest.Position.X, spawnY, nearest.Position.Z)
            hrp.CFrame = hrp.CFrame:Lerp(horizTarget, 0.12)
        else
            if not tweeningUp then
                tweeningUp = true
                currentUpTween = TS:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = nearest.CFrame + Vector3.new(0, 3, 0)})
                currentUpTween:Play()
                currentUpTween.Completed:Connect(function()
                    tweeningUp = false
                    currentUpTween = nil
                end)
            end
        end
    end
end)

local closing = false
local function closeUI()
    if closing then return end
    closing = true
    isRunning = false
    saveAuto(false)
    ws.Gravity = defaultGravity
    btnR.Active = false
    btnY.Active = false
    btnG.Active = false
    stopBtn.Active = false
    tw(btnR, {BackgroundTransparency = 1}, 0.2)
    tw(btnY, {BackgroundTransparency = 1}, 0.2)
    tw(btnG, {BackgroundTransparency = 1}, 0.2)
    tw(stopBtn, {BackgroundTransparency = 1}, 0.2)
    tw(stopBtn, {TextTransparency = 1}, 0.2)
    tw(stopStroke, {Transparency = 1}, 0.2)
    tw(title, {TextTransparency = 1}, 0.22)
    tw(sub, {TextTransparency = 1}, 0.22)
    tw(stroke, {Transparency = 1}, 0.3)
    tw(main, {BackgroundTransparency = 1, Size = UDim2.new(0, 170 * SC, 0, 55 * SC)}, 0.3)
    task.wait(0.32)
    tw(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.28)
    task.wait(0.28)
    gui:Destroy()
end

local minimized = false
btnY.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        twPop(main, {Size = UDim2.new(0, 200 * SC, 0, 28 * SC)}, 0.3)
        tw(sub, {TextTransparency = 1}, 0.15)
        tw(title, {Position = UDim2.new(0, 14 * SC, 0, 3 * SC)}, 0.25)
        tw(stopBtn, {BackgroundTransparency = 1}, 0.15)
        tw(stopBtn, {TextTransparency = 1}, 0.15)
        tw(stopStroke, {Transparency = 1}, 0.15)
        task.wait(0.15)
        sub.Visible = false
        stopBtn.Visible = false
    else
        sub.Visible = true
        stopBtn.Visible = true
        twPop(main, {Size = UDim2.new(0, 200 * SC, 0, 76 * SC)}, 0.3)
        tw(sub, {TextTransparency = 0}, 0.2)
        tw(title, {Position = UDim2.new(0, 14 * SC, 0, 24 * SC)}, 0.25)
        tw(stopBtn, {BackgroundTransparency = 0}, 0.2)
        tw(stopBtn, {TextTransparency = 0}, 0.2)
        tw(stopStroke, {Transparency = 0.2}, 0.2)
    end
end)
btnG.MouseButton1Click:Connect(function()
    btnG.Active = false
    tw(btnR, {BackgroundTransparency = 1}, 0.2)
    tw(btnY, {BackgroundTransparency = 1}, 0.2)
    tw(btnG, {BackgroundTransparency = 1}, 0.2)
    tw(stopBtn, {BackgroundTransparency = 1}, 0.2)
    tw(stopBtn, {TextTransparency = 1}, 0.2)
    tw(stopStroke, {Transparency = 1}, 0.2)
    tw(title, {TextTransparency = 1}, 0.18)
    tw(sub, {TextTransparency = 1}, 0.18)
    tw(stroke, {Transparency = 1}, 0.22)
    tw(main, {BackgroundTransparency = 1, Size = UDim2.new(0, 180 * SC, 0, 65 * SC)}, 0.22)
    task.wait(0.23)
    orb.Position = main.Position
    main.Visible = false
    orb.Visible = true
    orb.Size = UDim2.new(0, 0, 0, 0)
    oStroke.Transparency = 1
    oTxt.TextTransparency = 1
    twPop(orb, {Size = UDim2.new(0, 46 * SC, 0, 46 * SC)}, 0.35)
    tw(oStroke, {Transparency = 0}, 0.3)
    tw(oTxt, {TextTransparency = 0}, 0.3)
end)
oBtn.MouseButton1Click:Connect(function()
    tw(orb, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    tw(oStroke, {Transparency = 1}, 0.2)
    tw(oTxt, {TextTransparency = 1}, 0.2)
    task.wait(0.2)
    orb.Visible = false
    main.Position = orb.Position
    main.Visible = true
    main.Size = UDim2.new(0, 0, 0, 0)
    main.BackgroundTransparency = 1
    stroke.Transparency = 1
    title.TextTransparency = 1
    sub.TextTransparency = 1
    btnR.BackgroundTransparency = 1
    btnY.BackgroundTransparency = 1
    btnG.BackgroundTransparency = 1
    stopBtn.BackgroundTransparency = 1
    stopBtn.TextTransparency = 1
    stopStroke.Transparency = 1
    twPop(main, {Size = UDim2.new(0, 200 * SC, 0, 76 * SC), BackgroundTransparency = 0.08}, 0.35)
    tw(stroke, {Transparency = 0.2}, 0.3)
    tw(title, {TextTransparency = 0}, 0.25)
    tw(sub, {TextTransparency = 0}, 0.25)
    tw(btnR, {BackgroundTransparency = 0}, 0.25)
    tw(btnY, {BackgroundTransparency = 0}, 0.25)
    tw(btnG, {BackgroundTransparency = 0}, 0.25)
    tw(stopBtn, {BackgroundTransparency = 0}, 0.25)
    tw(stopBtn, {TextTransparency = 0}, 0.25)
    tw(stopStroke, {Transparency = 0.2}, 0.25)
    task.wait(0.35)
    btnG.Active = true
end)
btnR.MouseButton1Click:Connect(closeUI)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if main.Visible then
            btnG:Activate()
        else
            oBtn:Activate()
        end
    end
end)