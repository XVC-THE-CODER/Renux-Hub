local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()

local window = library:window({
    title = "Renux hub",
    desc = "v1.1",
    transparent = 0.15,
    theme = "fire",
    autoshow = true,
    addbacksound = false
})

window:AddTag({ title = "mm2", icon = "globe", color = Color3.fromRGB(180, 30, 30), getclick = false })

local MainTab = window:AddTab("Main", "home")
local ServerTab = window:AddTab("Server", "server")
local TeleportTab = window:AddTab("Teleport", "user")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local MurderESP = false
local SheriffESP = false
local AimbotMurder = false
local AutoCoin = false
local AutoKill = false
local LoopInsideMurder = false
local LoopInsideSheriff = false

local Tracers = {}
local RED = Color3.fromRGB(255, 0, 0)
local BLUE = Color3.fromRGB(0, 140, 255)

local Noclip = false
local InfiniteJump = false
local Xray = false
local WalkSpeedEnabled = false
local WalkSpeedValue = 20
local JumpPowerEnabled = false
local JumpPowerValue = 50
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

pcall(function() RunService:UnbindFromRenderStep("RenuxESP") end)
pcall(function() RunService:UnbindFromRenderStep("RenuxAimbot") end)

local function HasTool(container, nameFind)
    if not container then return false end
    for _, t in pairs(container:GetChildren()) do
        if t:IsA("Tool") and string.find(t.Name:lower(), nameFind:lower()) then return true end
    end
    return false
end

local function GetCurrentRole(player)
    local sg = player:FindFirstChild("StarterGear")
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if HasTool(sg, "Knife") or HasTool(bp, "Knife") or HasTool(char, "Knife") then return "Murder"
    elseif HasTool(sg, "Gun") or HasTool(bp, "Gun") or HasTool(char, "Gun") then return "Sheriff" end
    return nil
end

local function GetTracer(p)
    if Tracers[p] then return Tracers[p] end
    local t = Drawing.new("Line") t.Visible = false t.Thickness = 2 t.Transparency = 1
    Tracers[p] = t return t
end

local function GetRoleHRP(roleName)
    for _, plr in pairs(Players:GetPlayers()) do
        if GetCurrentRole(plr) == roleName and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            return plr.Character.HumanoidRootPart
        end
    end
    return nil
end

-- INFINITE JUMP LOGIC
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService:BindToRenderStep("RenuxESP", 1, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local tracer = GetTracer(plr)
        local role = GetCurrentRole(plr)
        local show = false
        local col = RED
        if role == "Murder" and MurderESP then show = true col = RED
        elseif role == "Sheriff" and SheriffESP then show = true col = BLUE end
        if not show then tracer.Visible = false continue end
        local head = plr.Character and (plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart"))
        if not head then tracer.Visible = false continue end
        local pos, onScreen = cam:WorldToViewportPoint(head.Position)
        if not onScreen then tracer.Visible = false continue end
        tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y * 0.75)
        tracer.To = Vector2.new(pos.X, pos.Y)
        tracer.Color = col
        tracer.Visible = true
    end
end)

RunService:BindToRenderStep("RenuxAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not AimbotMurder then return end
    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    if not cam or not myChar then return end
    local ignoreList = {}
    for _, p in pairs(Players:GetPlayers()) do if p.Character then table.insert(ignoreList, p.Character) end end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = ignoreList
    local bestTarget = nil
    local bestDist = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if GetCurrentRole(plr) ~= "Murder" then continue end
        local char = plr.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not head then continue end
        if workspace:Raycast(cam.CFrame.Position, head.Position - cam.CFrame.Position, params) then continue end
        local dist = (head.Position - cam.CFrame.Position).Magnitude
        if dist < bestDist then bestDist = dist bestTarget = head end
    end
    if bestTarget then cam.CFrame = CFrame.new(cam.CFrame.Position, bestTarget.Position) end
end)

RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if WalkSpeedEnabled then hum.WalkSpeed = WalkSpeedValue end
        if JumpPowerEnabled then hum.UseJumpPower = true hum.JumpPower = JumpPowerValue end
    end
end)

local function SetXray(state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Parent ~= LocalPlayer.Character then
            obj.LocalTransparencyModifier = state and 0.7 or 0
        end
    end
end

local function StartCoinTP()
    task.spawn(function()
        while AutoCoin do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            local coin = nil
            local closestDist = math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name:lower(), "coin") then
                    local d = (hrp.Position - obj.Position).Magnitude
                    if d < closestDist then closestDist = d coin = obj end
                end
            end
            if coin then hrp.CFrame = coin.CFrame + Vector3.new(0, 0.5, 0) task.wait(0.38) else task.wait(1) end
        end
    end)
end

local function StartAutoKill()
    task.spawn(function()
        while AutoKill do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then task.wait(0.5) continue end
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            if not knife then task.wait(0.5) continue end
            if knife.Parent ~= char then hum:EquipTool(knife) task.wait(0.25) end
            local targets = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local tChar = plr.Character
                local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local dist = (hrp.Position - tHrp.Position).Magnitude
                    if dist <= 150 then table.insert(targets, {hrp = tHrp, dist = dist}) end
                end
            end
            table.sort(targets, function(a,b) return a.dist < b.dist end)
            for _, data in ipairs(targets) do
                if not AutoKill then break end
                hrp.CFrame = data.hrp.CFrame * CFrame.new(0, 0, 2.8)
                task.wait(0.15)
                local kTool = char:FindFirstChild("Knife")
                if kTool then for i=1,6 do kTool:Activate() task.wait(0.07) end end
                task.wait(0.12)
            end
            task.wait(0.2)
        end
    end)
end

local function StartLoopInside(role)
    task.spawn(function()
        while (role == "Murder" and LoopInsideMurder) or (role == "Sheriff" and LoopInsideSheriff) do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local targetHRP = GetRoleHRP(role)
            if not hrp or not targetHRP then task.wait(0.5) continue end

            local targetVel = targetHRP.Velocity.Magnitude
            local myVel = hrp.Velocity.Magnitude
            if targetVel >= 40 or myVel >= 40 then
                if role == "Murder" then LoopInsideMurder = false else LoopInsideSheriff = false end
                library:Notification({ title = "Fling Filter", desc = role.." velocity "..math.floor(targetVel).." -> OFF", duration = 3 })
                break
            end

            if hum then hum.PlatformStand = true hum.Sit = true end
            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            task.wait(0.12)
            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, -0.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
            task.wait(0.12)
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false hum.Sit = false end
    end)
end

-- MAIN
MainTab:Addtoggle({ title = "ESP Murder", value = false, callback = function(v) MurderESP = v end })
MainTab:Addtoggle({ title = "ESP Sheriff", value = false, callback = function(v) SheriffESP = v end })
MainTab:AddDivider()
MainTab:Addtoggle({ title = "Aimbot Murder Only", value = false, callback = function(v) AimbotMurder = v end })
MainTab:AddDivider()
MainTab:Addtoggle({ title = "Auto Collect Coin (Slow)", value = false, callback = function(v) AutoCoin = v if v then StartCoinTP() end end })
MainTab:AddDivider()
MainTab:Addtoggle({ title = "Auto Kill All", value = false, callback = function(v) AutoKill = v if v then StartAutoKill() end end })

-- SERVER - Noclip + Infinite Jump dibawahnya
ServerTab:Addtoggle({ title = "Noclip", value = false, callback = function(v) Noclip = v end })
ServerTab:Addtoggle({ title = "Infinite Jump", value = false, callback = function(v) InfiniteJump = v end })
ServerTab:Addtoggle({ title = "X-ray", value = false, callback = function(v) Xray = v SetXray(v) end })
ServerTab:AddDivider()
ServerTab:Addtoggle({
    title = "Walk Speed",
    value = false,
    callback = function(v)
        WalkSpeedEnabled = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not v and hum then hum.WalkSpeed = DEFAULT_WALKSPEED end
    end
})
ServerTab:AddInput({ Title = "Walk Speed", Value = "20", Callback = function(text) local n=tonumber(text) if n then WalkSpeedValue=n end end })
ServerTab:Addtoggle({
    title = "Jump Power",
    value = false,
    callback = function(v)
        JumpPowerEnabled = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not v and hum then hum.UseJumpPower=true hum.JumpPower=DEFAULT_JUMPPOWER end
    end
})
ServerTab:AddInput({ Title = "Jump Power", Value = "50", Callback = function(text) local n=tonumber(text) if n then JumpPowerValue=n end end })

-- TELEPORT
TeleportTab:Addbutton({
    title = "TP to Murder",
    callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if GetCurrentRole(plr) == "Murder" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
                break
            end
        end
    end
})
TeleportTab:Addbutton({
    title = "TP to Sheriff",
    callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if GetCurrentRole(plr) == "Sheriff" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
                break
            end
        end
    end
})
TeleportTab:AddDivider()
TeleportTab:Addbutton({
    title = "TP to Lobby",
    callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(13, 505, -61) end
    end
})
TeleportTab:AddDivider()
TeleportTab:Addbutton({
    title = "Execute Fling",
    desc = "Touch Fling Script",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))()
    end
})
TeleportTab:Addtoggle({
    title = "Loop TP Fling Murder",
    value = false,
    callback = function(v) LoopInsideMurder = v if v then StartLoopInside("Murder") end end
})
TeleportTab:Addtoggle({
    title = "Loop TP Fling Sheriff",
    value = false,
    callback = function(v) LoopInsideSheriff = v if v then StartLoopInside("Sheriff") end end
})
