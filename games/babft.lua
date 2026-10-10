pcall(function()
    if setfpscap then
        setfpscap(120)
    end
end)

pcall(function()
    if set_fps_cap then
        set_fps_cap(120)
    end
end)

repeat
    task.wait()
until game:IsLoaded()

local library

local function loadLibrary()
    local url = "https://github.com/SCRIPTHUB-dev-god/User-Interface/releases/download/loader/fire-ui.lua"
    local code

    pcall(function()
        code = game:HttpGet(url)
    end)

    if not code or #code < 100 then
        local req = request or http_request or (syn and syn.request) or (http and http.request)
        if req then
            pcall(function()
                local res = req({
                    Url = url,
                    Method = "GET"
                })
                code = res.Body or res.body
            end)
        end
    end

    if code and #code > 100 then
        local ok, err = pcall(function()
            loadstring(code)()
        end)

        if ok then
            for i = 1, 10 do
                task.wait(0.2)
                if GetLibrary then
                    local suc, lib = pcall(function()
                        return GetLibrary("latest")
                    end)

                    if suc and lib then
                        library = lib
                        break
                    end
                end
            end
        else
            warn("fire-ui load error:", err)
        end
    end

    return library
end

library = loadLibrary()

if not library then
    task.wait(1)
    library = loadLibrary()
end

if not library then
    warn("Renux: library failed to load, retrying...")
    task.wait(2)
    library = loadLibrary()
end

assert(library, "Failed to load Fire UI Library")

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

local window
local ok, err = pcall(function()
    window = library:window({
        title = "Renux hub",
        desc = "build a boat",
        transparent = 0.15,
        icon = "moon",
        theme = "Ametis",
        autoshow = true,
        addbacksound = false
    })
end)

if not ok or not window then
    task.wait(0.5)
    window = library:window({
        title = "Renux hub",
        desc = "build a boat",
        transparent = 0.15,
        icon = "moon",
        theme = "Ametis",
        autoshow = true,
        addbacksound = false
    })
end

pcall(function()
    if window and window.SetVisible then
        window:SetVisible(true)
    end

    if library and library.ToggleUI then
        library:ToggleUI(true)
    end
end)

window:AddTag({
    title = "v1.3",
    icon = "globe",
    color = Color3.fromRGB(55, 55, 60),
    getclick = false
})

window:AddTag({
    title = "keyless",
    icon = "key",
    color = Color3.fromRGB(55, 55, 60),
    getclick = false
})

window:SetToggleUi({
    title = "Renux hub",
    icon = "moon"
})

local supporttab = window:AddTab("support", "info")
local Tab = window:AddTab("Main farm", "house")
local ServerTab = window:AddTab("Server", "server")
local MiscTab = window:AddTab("misc", "box")
local settTab = window:AddTab("setting", "settings")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local autoFarmEnabled = false
local autoFarmGoldBlockEnabled = false
local hasReachedTrigger = false
local tpDelay = 0.75
local maxTpParts = 9
local farmMode = "teleport"
local darknessTpParts = {}
local farmingThread = nil
local farmingBlockThread = nil

local waterNoDamageEnabled = false
local waterConn = nil

local deleteObstacleEnabled = false
local deleteObstacleConn = nil

local targetPos = Vector3.new(-56, -359, 9485)

local SOUND_CHECK_DURATION = 2
local SOUND_AT_TARGET_DIST = 150

_G.Renux_TargetSoundData = _G.Renux_TargetSoundData or {
    savedIds = {},
    hasEverHadSound = false
}

local soundCheckActive = false
local soundDetected = false
local soundConns = {}
local soundAddedConn = nil

local originalGravity = workspace.Gravity
local DEFAULT_GRAVITY = 196.2

local speedEnabled = false
local currentSpeed = 16

local jumpEnabled = false
local currentJump = 50

local freecamEnabled = false
local freecamSpeed = 10
local freecamPart = nil
local freecamConn = nil
local freecamSaved = {}
local freecamCtrl = nil
local freecamOriginalHRPAnchored = false

local flyEnabled = false
local flySpeed = 15
local flyConn = nil
local flyCtrl = nil
local flySaved = {}

local function applyMovement()
    pcall(function()
        if freecamEnabled then
            return
        end

        if flyEnabled then
            return
        end

        local char = player.Character
        if not char then
            return
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return
        end

        if speedEnabled then
            hum.WalkSpeed = currentSpeed
        end

        if jumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = currentJump
            hum.JumpHeight = currentJump / 2
        end
    end)
end

local function enableFreecam()
    pcall(function()
        local char = player.Character
        if not char then
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum then
            return
        end

        if freecamPart and freecamPart.Parent then
            freecamPart:Destroy()
        end

        freecamPart = Instance.new("Part")
        freecamPart.Name = "Renux_FreecamPart"
        freecamPart.Size = Vector3.new(1, 1, 1)
        freecamPart.Transparency = 1
        freecamPart.Anchored = true
        freecamPart.CanCollide = false
        freecamPart.CanQuery = false
        freecamPart.CanTouch = false
        freecamPart.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
        freecamPart.Parent = workspace

        freecamSaved.WalkSpeed = hum.WalkSpeed
        freecamSaved.JumpPower = hum.JumpPower
        freecamSaved.JumpHeight = hum.JumpHeight
        freecamSaved.AutoRotate = hum.AutoRotate
        freecamSaved.PlatformStand = hum.PlatformStand
        freecamSaved.CameraType = workspace.CurrentCamera.CameraType
        freecamSaved.CameraSubject = workspace.CurrentCamera.CameraSubject
        freecamSaved.CameraMaxZoom = player.CameraMaxZoomDistance
        freecamSaved.CameraMinZoom = player.CameraMinZoomDistance
        freecamSaved.FieldOfView = workspace.CurrentCamera.FieldOfView

        freecamOriginalHRPAnchored = hrp.Anchored

        pcall(function()
            local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
            freecamCtrl = playerModule:GetControls()
        end)

        hum.PlatformStand = true
        hum.AutoRotate = false
        hrp.Anchored = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)

        player.CameraMaxZoomDistance = 0
        player.CameraMinZoomDistance = 0

        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.CameraSubject = freecamPart
        workspace.CurrentCamera.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + workspace.CurrentCamera.CFrame.LookVector)

        if freecamConn then
            freecamConn:Disconnect()
        end

        freecamConn = RunService.RenderStepped:Connect(function(dt)
            if not freecamEnabled then
                return
            end

            if not freecamPart then
                return
            end

            if not freecamPart.Parent then
                return
            end

            local cam = workspace.CurrentCamera
            if not cam then
                return
            end

            local moveVector = Vector3.new(0, 0, 0)

            if freecamCtrl then
                pcall(function()
                    moveVector = freecamCtrl:GetMoveVector()
                end)
            end

            if moveVector.Magnitude < 0.1 then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + Vector3.new(0, 0, -1)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector + Vector3.new(0, 0, 1)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector + Vector3.new(-1, 0, 0)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + Vector3.new(1, 0, 0)
                end
            end

            local upDown = 0

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
                upDown = 1
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                upDown = -1
            end

            local rightVec = cam.CFrame.RightVector
            local lookVec = cam.CFrame.LookVector
            local upVec = Vector3.new(0, 1, 0)

            local finalMove = (rightVec * moveVector.X) + (lookVec * -moveVector.Z) + (upVec * upDown)

            if finalMove.Magnitude > 0 then
                finalMove = finalMove.Unit * freecamSpeed * dt * 12
                freecamPart.CFrame = freecamPart.CFrame + finalMove
            end

            player.CameraMaxZoomDistance = 0
            player.CameraMinZoomDistance = 0
            cam.CameraSubject = freecamPart

            if cam.CameraType ~= Enum.CameraType.Custom then
                cam.CameraType = Enum.CameraType.Custom
            end
        end)
    end)
end

local function disableFreecam()
    pcall(function()
        freecamEnabled = false

        if freecamConn then
            freecamConn:Disconnect()
            freecamConn = nil
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp then
            hrp.Anchored = freecamOriginalHRPAnchored or false
        end

        if hum then
            hum.PlatformStand = freecamSaved.PlatformStand or false
            hum.AutoRotate = freecamSaved.AutoRotate == nil and true or freecamSaved.AutoRotate
            hum.WalkSpeed = freecamSaved.WalkSpeed or 16
            hum.JumpPower = freecamSaved.JumpPower or 50
            hum.JumpHeight = freecamSaved.JumpHeight or 7.2
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        player.CameraMaxZoomDistance = freecamSaved.MaxZoom or 20
        player.CameraMinZoomDistance = freecamSaved.MinZoom or 0.5

        if freecamSaved.CameraType then
            workspace.CurrentCamera.CameraType = freecamSaved.CameraType
        end

        if hum then
            workspace.CurrentCamera.CameraSubject = hum
        else
            workspace.CurrentCamera.CameraSubject = freecamSaved.CameraSubject
        end

        if freecamPart and freecamPart.Parent then
            freecamPart:Destroy()
        end

        freecamPart = nil
        freecamCtrl = nil
    end)
end

local flyPart = nil
local flyOriginalHRPAnchored = false
local flySavedAnimate = nil
local flySavedTracks = {}
local function enableFly()
    pcall(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum then
            return
        end

        if flyPart and flyPart.Parent then
            flyPart:Destroy()
        end

        flyPart = Instance.new("Part")
        flyPart.Name = "Renux_FlyPart"
        flyPart.Size = Vector3.new(1, 1, 1)
        flyPart.Transparency = 1
        flyPart.Anchored = true
        flyPart.CanCollide = false
        flyPart.CanQuery = false
        flyPart.CanTouch = false
        flyPart.Massless = true
        flyPart.CFrame = hrp.CFrame
        flyPart.Parent = workspace

        flySaved.WalkSpeed = hum.WalkSpeed
        flySaved.JumpPower = hum.JumpPower
        flySaved.Gravity = workspace.Gravity
        flySaved.PlatformStand = hum.PlatformStand
        flySaved.AutoRotate = hum.AutoRotate
        flySaved.CameraMaxZoom = player.CameraMaxZoomDistance
        flySaved.CameraMinZoom = player.CameraMinZoomDistance
        flySaved.GettingUp = hum:GetStateEnabled(Enum.HumanoidStateType.GettingUp)

        flyOriginalHRPAnchored = hrp.Anchored

        pcall(function()
            local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
            flyCtrl = playerModule:GetControls()
        end)

        local animate = char:FindFirstChild("Animate")
        if animate then
            flySavedAnimate = animate
            flySavedAnimate.Disabled = true
        end

        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            table.insert(flySavedTracks, track)
            track:Stop()
        end

        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum.PlatformStand = true
        hum.AutoRotate = false
        workspace.Gravity = 50
        hum:ChangeState(Enum.HumanoidStateType.Physics)

        player.CameraMaxZoomDistance = 20
        player.CameraMinZoomDistance = 0.5

        if flyConn then
            flyConn:Disconnect()
        end

        flyConn = RunService.RenderStepped:Connect(function(dt)
            if not flyEnabled then
                return
            end

            if not flyPart or not flyPart.Parent then
                return
            end

            local char2 = player.Character
            local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
            local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")

            if not hrp2 or not hum2 then
                return
            end

            local cam = workspace.CurrentCamera
            if not cam then
                return
            end

            local mv = Vector3.new(0, 0, 0)

            if flyCtrl then
                pcall(function()
                    mv = flyCtrl:GetMoveVector()
                end)
            end

            if mv.Magnitude < 0.1 then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    mv = mv + Vector3.new(0, 0, -1)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    mv = mv + Vector3.new(0, 0, 1)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    mv = mv + Vector3.new(-1, 0, 0)
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    mv = mv + Vector3.new(1, 0, 0)
                end
            end

            local up = 0

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
                up = 1
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                up = -1
            end

            local rightVec = cam.CFrame.RightVector
            local lookVec = cam.CFrame.LookVector
            local upVec = Vector3.new(0, 1, 0)

            local move = (rightVec * mv.X) + (lookVec * -mv.Z) + (upVec * up)

            local lerpAlpha = math.clamp(dt * flySpeed * 0.35, 0, 1)
            local velocityFactor = flySpeed * 12

            if move.Magnitude > 0 then
                local dir = move.Unit
                local targetPos = flyPart.Position + dir * velocityFactor * dt
                local targetCF = CFrame.lookAt(targetPos, targetPos + lookVec)

                flyPart.CFrame = flyPart.CFrame:Lerp(targetCF, lerpAlpha)
            else
                local look = cam.CFrame.LookVector
                local targetCF = CFrame.lookAt(flyPart.Position, flyPart.Position + look)
                flyPart.CFrame = flyPart.CFrame:Lerp(targetCF, lerpAlpha)
            end

            hrp2.CFrame = flyPart.CFrame
            hrp2.Velocity = Vector3.new(0, 0, 0)
            hrp2.RotVelocity = Vector3.new(0, 0, 0)

            hum2.PlatformStand = true
            hum2:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

            for _, tr in ipairs(hum2:GetPlayingAnimationTracks()) do
                tr:Stop()
            end


        end)
    end)
end

local function disableFly()
    pcall(function()
        flyEnabled = false

        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp then
            hrp.Anchored = flyOriginalHRPAnchored or false
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end

        if hum then
            hum.PlatformStand = flySaved.PlatformStand or false
            hum.AutoRotate = flySaved.AutoRotate == nil and true or flySaved.AutoRotate
            hum.WalkSpeed = flySaved.WalkSpeed or 16
            hum.JumpPower = flySaved.JumpPower or 50
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, flySaved.GettingUp == nil and true or flySaved.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)

            for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
                tr:Stop()
            end
        end

        if flySavedAnimate and flySavedAnimate.Parent then
            flySavedAnimate.Disabled = false
        end

        table.clear(flySavedTracks)
        flySavedAnimate = nil
        workspace.Gravity = flySaved.Gravity or DEFAULT_GRAVITY
        player.CameraMaxZoomDistance = flySaved.MaxZoom or 20
        player.CameraMinZoomDistance = flySaved.MinZoom or 0.5

        if flyPart and flyPart.Parent then
            flyPart:Destroy()
        end

        flyPart = nil
        flyCtrl = nil
    end)
end

local function rejoinServer()
    task.spawn(function()
        if #Players:GetPlayers() > 1 then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end)
            task.wait(1)
        end

        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

local function hopServer()
    task.spawn(function()
        library:Notification({
            title = "Server Hop",
            desc = "Finding best server...",
            duration = 3
        })

        local function getServers(cursor)
            local url = "https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

            if cursor then
                url = url .. "&cursor=" .. cursor
            end

            local req = request or http_request or (syn and syn.request) or (http and http.request)
            local success, result

            if req then
                success, result = pcall(function()
                    return req({
                        Url = url,
                        Method = "GET"
                    }).Body
                end)
            else
                success, result = pcall(function()
                    return game:HttpGet(url)
                end)
            end

            if success and result then
                local ok, data = pcall(function()
                    return HttpService:JSONDecode(result)
                end)

                if ok then
                    return data
                end
            end

            return nil
        end

        local cursor = nil
        local validServers = {}

        for _ = 1, 3 do
            local data = getServers(cursor)

            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 0 then
                        table.insert(validServers, s)
                    end
                end

                cursor = data.nextPageCursor

                if not cursor then
                    break
                end
            else
                break
            end

            task.wait(0.3)
        end

        if #validServers > 0 then
            for attempt = 1, 3 do
                local pick = validServers[math.random(1, #validServers)]
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player)
                end)

                if ok then
                    return
                end

                task.wait(1)
            end
        end

        library:Notification({
            title = "Server Hop",
            desc = "No server found, rejoining...",
            duration = 3
        })

        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

local function clearTpParts()
    for _, p in ipairs(darknessTpParts) do
        if p and p.Parent then
            p:Destroy()
        end
    end

    table.clear(darknessTpParts)
end

local function findDarknessParts()
    local list = {}

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("darkness") then
            table.insert(list, v)
        end
    end

    local filtered = {}

    for _, part in ipairs(list) do
        local tooClose = false

        for _, kept in ipairs(filtered) do
            if (part.Position - kept.Position).Magnitude < 8 then
                tooClose = true
                break
            end
        end

        if not tooClose then
            table.insert(filtered, part)
        end
    end

    if #filtered > 1 then
        local sorted = {}
        local remaining = table.clone(filtered)

        local charPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)

        table.sort(remaining, function(a, b)
            return (a.Position - charPos).Magnitude < (b.Position - charPos).Magnitude
        end)

        local current = table.remove(remaining, 1)
        table.insert(sorted, current)

        while #remaining > 0 do
            local closestIndex = 1
            local closestDist = math.huge

            for i, p in ipairs(remaining) do
                local dist = (p.Position - current.Position).Magnitude

                if dist < closestDist then
                    closestDist = dist
                    closestIndex = i
                end
            end

            current = table.remove(remaining, closestIndex)
            table.insert(sorted, current)
        end

        return sorted
    end

    return filtered
end

local function getWhiteTeamLowestBaseplate()
    local teamsFolder = nil

    for _, v in ipairs(workspace:GetChildren()) do
        local n = v.Name:lower()

        if n:find("union") and n:find("team") then
            teamsFolder = v
            break
        end
    end

    if not teamsFolder then
        teamsFolder = workspace:FindFirstChild("Teams") or workspace:FindFirstChild("UnionTeams") or workspace:FindFirstChild("Union Teams") or workspace:FindFirstChild("Team")
    end

    if not teamsFolder then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name:lower() == "whiteteam" or v.Name:lower() == "white team" then
                teamsFolder = v.Parent
                break
            end
        end
    end

    if not teamsFolder then
        return nil
    end

    local whiteTeam = nil

    for _, v in ipairs(teamsFolder:GetChildren()) do
        local n = v.Name:lower()

        if n:find("white") and n:find("team") then
            whiteTeam = v
            break
        end
    end

    if not whiteTeam then
        whiteTeam = teamsFolder:FindFirstChild("WhiteTeam") or teamsFolder:FindFirstChild("White Team") or teamsFolder:FindFirstChild("whiteteam")

        if not whiteTeam then
            for _, v in ipairs(teamsFolder:GetDescendants()) do
                if v.Name:lower():find("white") and v.Name:lower():find("team") then
                    whiteTeam = v
                    break
                end
            end
        end
    end

    if not whiteTeam then
        return nil
    end

    local flagPole = nil

    for _, v in ipairs(whiteTeam:GetChildren()) do
        if v.Name:lower():find("flagpole") or v.Name:lower():find("flag") then
            flagPole = v
            break
        end
    end

    if not flagPole then
        flagPole = whiteTeam:FindFirstChild("FlagPole") or whiteTeam:FindFirstChild("Flagpole") or whiteTeam:FindFirstChild("Flag")

        if not flagPole then
            for _, v in ipairs(whiteTeam:GetDescendants()) do
                if v.Name:lower():find("flagpole") then
                    flagPole = v
                    break
                end
            end
        end
    end

    if not flagPole then
        return nil
    end

    local pole = nil

    for _, v in ipairs(flagPole:GetChildren()) do
        if v.Name:lower() == "pole" or v.Name:lower():find("pole") then
            if v.Name:lower() ~= "flagpole" then
                pole = v
                break
            end
        end
    end

    if not pole then
        for _, v in ipairs(flagPole:GetDescendants()) do
            if v.Name:lower() == "pole" then
                pole = v
                break
            end
        end
    end

    if not pole then
        pole = flagPole
    end

    local baseplates = {}

    for _, v in ipairs(pole:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("baseplate") then
            table.insert(baseplates, v)
        end
    end

    if #baseplates == 0 then
        for _, v in ipairs(pole:GetChildren()) do
            if v:IsA("BasePart") and v.Name:lower():find("base") then
                table.insert(baseplates, v)
            end
        end
    end

    if #baseplates == 0 then
        return nil
    end

    table.sort(baseplates, function(a, b)
        return a.Position.Y > b.Position.Y
    end)

    return baseplates[1]
end

local function teleportTo(pos)
    local char = player.Character

    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function tweenPart(part, targetPos, duration)
    if not part or not part.Parent then
        return
    end

    local tween = TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = targetPos
    })

    tween:Play()
    tween.Completed:Wait()
end

local function setWaterNoDamage(state)
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("water") then
                pcall(function()
                    v.CanTouch = not state
                end)
            end
        end
    end)
end

local function deleteRocks()
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("rock") then
                pcall(function()
                    v:Destroy()
                end)
            end
        end
    end)
end

local function resetCharacterNow()
    pcall(function()
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if hum then
                hum.Health = 0
            else
                player.Character:BreakJoints()
            end
        end
    end)
end

local function clearSoundListeners()
    for _, c in ipairs(soundConns) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(soundConns)

    if soundAddedConn then
        pcall(function()
            soundAddedConn:Disconnect()
        end)

        soundAddedConn = nil
    end
end

local function getSoundPos(soundObj)
    local p = soundObj.Parent

    if not p then
        return nil
    end

    if p:IsA("BasePart") then
        return p.Position
    end

    if p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then
        return p.Parent.Position
    end

    local cur = p

    for i = 1, 4 do
        if not cur then
            break
        end

        if cur:IsA("BasePart") then
            return cur.Position
        end

        cur = cur.Parent
    end

    return nil
end

local function isSoundAtTarget(soundObj)
    local pos = getSoundPos(soundObj)

    if not pos then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if hrp and (hrp.Position - targetPos).Magnitude <= 120 then
            return true
        end

        return false
    end

    return (pos - targetPos).Magnitude <= SOUND_AT_TARGET_DIST
end

local function isSkyboxDark()
    local amb = Lighting.Ambient
    local outAmb = Lighting.OutdoorAmbient
    local avgAmb = (amb.R + amb.G + amb.B) / 3
    local avgOut = (outAmb.R + outAmb.G + outAmb.B) / 3
    local brightness = Lighting.Brightness
    local clock = Lighting.ClockTime
    local fogColor = Lighting.FogColor
    local avgFog = (fogColor.R + fogColor.G + fogColor.B) / 3

    if brightness <= 1.5 and avgAmb < 0.5 and avgOut < 0.5 then
        return true
    end

    if clock < 6.5 or clock > 18.5 then
        return true
    end

    if avgFog < 0.25 then
        return true
    end

    local sky = Lighting:FindFirstChildOfClass("Sky")

    if sky then
        local bk = sky.SkyboxBk and sky.SkyboxBk:lower() or ""

        if bk:find("dark") or bk:find("night") or bk:find("moon") then
            return true
        end

        if sky.SkyboxUp == "" and sky.SkyboxBk == "" then
            return false
        end
    end

    return false
end

local function hookSound(soundObj)
    if not soundObj:IsA("Sound") then
        return
    end

    if soundObj.IsPlaying and isSoundAtTarget(soundObj) then
        soundDetected = true
        local id = soundObj.SoundId ~= "" and soundObj.SoundId or soundObj.Name

        if id ~= "" then
            _G.Renux_TargetSoundData.savedIds[id] = true
            _G.Renux_TargetSoundData.hasEverHadSound = true
        end
    end

    table.insert(soundConns, soundObj.Played:Connect(function()
        if isSoundAtTarget(soundObj) then
            soundDetected = true
            local id = soundObj.SoundId ~= "" and soundObj.SoundId or soundObj.Name

            if id ~= "" then
                _G.Renux_TargetSoundData.savedIds[id] = true
                _G.Renux_TargetSoundData.hasEverHadSound = true
            end
        end
    end))
end

local function startPostTriggerAntiStuckCheck()
    if soundCheckActive then
        return
    end

    soundCheckActive = true
    soundDetected = false
    clearSoundListeners()

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") then
            hookSound(v)
        end
    end

    for _, v in ipairs(SoundService:GetDescendants()) do
        if v:IsA("Sound") then
            hookSound(v)
        end
    end

    soundAddedConn = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Sound") then
            task.wait(0.05)
            hookSound(v)
        end
    end)

    task.spawn(function()
        local elapsed = 0

        while elapsed < SOUND_CHECK_DURATION do
            task.wait(0.1)
            elapsed = elapsed + 0.1

            if not soundDetected then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Sound") and v.IsPlaying and isSoundAtTarget(v) then
                        soundDetected = true
                        local id = v.SoundId ~= "" and v.SoundId or v.Name

                        if id ~= "" then
                            _G.Renux_TargetSoundData.savedIds[id] = true
                            _G.Renux_TargetSoundData.hasEverHadSound = true
                        end

                        break
                    end
                end
            end

            if soundDetected or isSkyboxDark() then
                break
            end

            if not hasReachedTrigger then
                clearSoundListeners()
                soundCheckActive = false
                return
            end
        end

        if hasReachedTrigger then
            if not soundDetected and not isSkyboxDark() then
                resetCharacterNow()
            end
        end

        task.wait(0.5)
        clearSoundListeners()
        soundCheckActive = false
    end)
end

local function startFarm()
    if farmingThread then
        task.cancel(farmingThread)
    end

    farmingThread = task.spawn(function()
        while autoFarmEnabled do
            if hasReachedTrigger then
                break
            end

            local darknessParts = findDarknessParts()

            if #darknessParts == 0 then
                task.wait(2)
                continue
            end

            clearTpParts()

            if farmMode == "tween" then
                local whiteBase = getWhiteTeamLowestBaseplate()
                local firstPart = darknessParts[1]
                local lastPart = darknessParts[#darknessParts]

                local platform = Instance.new("Part")
                platform.Name = "Renux_TWEEN_Platform"
                platform.Size = Vector3.new(14, 1, 14)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 1
                platform.Parent = workspace
                table.insert(darknessTpParts, platform)

                local speedVal

                if tpDelay >= 1.2 then
                    speedVal = 50
                elseif tpDelay >= 0.7 then
                    speedVal = 100
                else
                    speedVal = 175
                end

                local durationToLast

                if tpDelay >= 1.2 then
                    durationToLast = 35
                elseif tpDelay >= 0.7 then
                    durationToLast = 25
                else
                    durationToLast = 16
                end

                if whiteBase then
                    platform.Position = whiteBase.Position + Vector3.new(0, 6, 0)
                    teleportTo(whiteBase.Position + Vector3.new(0, 6, 0))
                    task.wait(0.6)

                    local keepFollowing = true
                    local followConn

                    followConn = RunService.Heartbeat:Connect(function()
                        if not keepFollowing or not autoFarmEnabled or not platform.Parent or hasReachedTrigger then
                            if followConn then
                                followConn:Disconnect()
                            end
                            return
                        end

                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                        if hrp and (hrp.Position - platform.Position).Magnitude > 4 then
                            hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
                        end
                    end)

                    local distToFirst = (platform.Position - (firstPart.Position + Vector3.new(0, 6, 0))).Magnitude
                    local durToFirst = math.clamp(distToFirst / speedVal, 0.5, 5)

                    tweenPart(platform, firstPart.Position + Vector3.new(0, 6, 0), durToFirst)

                    keepFollowing = false

                    if followConn then
                        followConn:Disconnect()
                    end
                else
                    platform.Position = firstPart.Position + Vector3.new(0, 6, 0)
                    teleportTo(firstPart.Position + Vector3.new(0, 6, 0))
                    task.wait(0.2)
                end

                if not autoFarmEnabled or hasReachedTrigger then
                    continue
                end

                local keepFollowing2 = true
                local followConn2

                followConn2 = RunService.Heartbeat:Connect(function()
                    if not keepFollowing2 or not autoFarmEnabled or not platform.Parent or hasReachedTrigger then
                        if followConn2 then
                            followConn2:Disconnect()
                        end
                        return
                    end

                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                    if hrp and (hrp.Position - platform.Position).Magnitude > 4 then
                        hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
                    end
                end)

                tweenPart(platform, lastPart.Position + Vector3.new(0, 6, 0), durationToLast)

                keepFollowing2 = false

                if followConn2 then
                    followConn2:Disconnect()
                end

                if not autoFarmEnabled or hasReachedTrigger then
                    continue
                end

                task.wait(0.2)
                clearTpParts()

                if autoFarmEnabled then
                    for j = 1, 3 do
                        teleportTo(targetPos + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                    end

                    hasReachedTrigger = true
                    break
                end
            else
                workspace.Gravity = 25

                if #darknessParts > maxTpParts then
                    local limited = {}

                    for i = 1, maxTpParts do
                        table.insert(limited, darknessParts[i])
                    end

                    darknessParts = limited
                end

                for i, dp in ipairs(darknessParts) do
                    local tpPart = Instance.new("Part")
                    tpPart.Name = "Renux_TP_" .. i
                    tpPart.Size = Vector3.new(14, 1, 14)
                    tpPart.Position = dp.Position + Vector3.new(0, -30, 0)
                    tpPart.Anchored = true
                    tpPart.CanCollide = true
                    tpPart.Transparency = 1
                    tpPart.Parent = workspace
                    table.insert(darknessTpParts, tpPart)
                end

                for _, dp in ipairs(darknessParts) do
                    if not autoFarmEnabled or hasReachedTrigger then
                        break
                    end

                    teleportTo(dp.Position + Vector3.new(0, 6, 0))
                    task.wait(tpDelay + 0.65)
                end

                if not autoFarmEnabled or hasReachedTrigger then
                    continue
                end

                for j = 1, 3 do
                    teleportTo(targetPos + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                end

                workspace.Gravity = originalGravity
                hasReachedTrigger = true
                break
            end
        end
    end)
end

local function startFarmGoldBlock()
    if farmingBlockThread then
        task.cancel(farmingBlockThread)
    end

    farmingBlockThread = task.spawn(function()
        while autoFarmGoldBlockEnabled do
            if hasReachedTrigger then
                break
            end

            local darknessParts = findDarknessParts()

            if #darknessParts == 0 then
                task.wait(2)
                continue
            end

            clearTpParts()

            if farmMode == "teleport" then
                workspace.Gravity = 25

                local goldBlockDelay

                if tpDelay >= 1.5 then
                    goldBlockDelay = 3.2
                elseif tpDelay >= 1 then
                    goldBlockDelay = 2.4
                else
                    goldBlockDelay = 2
                end

                goldBlockDelay = goldBlockDelay + 0.65

                local first = darknessParts[1]
                local last = darknessParts[#darknessParts]

                local positions = {}
                local partPositions = {}

                if first then
                    table.insert(positions, first.Position + Vector3.new(0, 6, -15))
                    table.insert(partPositions, first.Position + Vector3.new(0, -30, -15))
                end

                if last and last ~= first then
                    table.insert(positions, last.Position + Vector3.new(0, 6, -15))
                    table.insert(partPositions, last.Position + Vector3.new(0, -30, -15))
                end

                for i, partPos in ipairs(partPositions) do
                    local tpPart = Instance.new("Part")
                    tpPart.Name = "Renux_TP_Block_" .. i
                    tpPart.Size = Vector3.new(14, 1, 14)
                    tpPart.Position = partPos
                    tpPart.Anchored = true
                    tpPart.CanCollide = true
                    tpPart.Transparency = 1
                    tpPart.Parent = workspace
                    table.insert(darknessTpParts, tpPart)
                end

                for _, pos in ipairs(positions) do
                    if not autoFarmGoldBlockEnabled or hasReachedTrigger then
                        break
                    end

                    teleportTo(pos)
                    task.wait(goldBlockDelay)
                end

                if not autoFarmGoldBlockEnabled or hasReachedTrigger then
                    continue
                end

                for j = 1, 3 do
                    teleportTo(targetPos + Vector3.new(0, 3, 0))
                    task.wait(0.8)
                end

                workspace.Gravity = originalGravity
                hasReachedTrigger = true
                break
            else
                local whiteBase = getWhiteTeamLowestBaseplate()
                local firstPart = darknessParts[1]

                if whiteBase then
                    teleportTo(whiteBase.Position + Vector3.new(0, 6, 0))
                    task.wait(0.6)
                end

                local platform = Instance.new("Part")
                platform.Name = "Renux_TWEEN_Platform"
                platform.Size = Vector3.new(14, 1, 14)
                platform.Position = (whiteBase and whiteBase.Position or darknessParts[1].Position) + Vector3.new(0, 6, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 1
                platform.Parent = workspace
                table.insert(darknessTpParts, platform)

                local speed

                if tpDelay >= 1.2 then
                    speed = 50
                elseif tpDelay >= 0.7 then
                    speed = 100
                else
                    speed = 175
                end

                local keepFollowing = true
                local followConn

                followConn = RunService.Heartbeat:Connect(function()
                    if not keepFollowing or not autoFarmGoldBlockEnabled or not platform.Parent or hasReachedTrigger then
                        if followConn then
                            followConn:Disconnect()
                        end
                        return
                    end

                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
                    end
                end)

                for i = 2, #darknessParts do
                    if not autoFarmGoldBlockEnabled or hasReachedTrigger then
                        break
                    end

                    local target = darknessParts[i].Position + Vector3.new(0, 6, 0)
                    local dist = (platform.Position - target).Magnitude
                    local dur = math.clamp(dist / speed, 0.05, 1.2)

                    tweenPart(platform, target, dur)
                end

                keepFollowing = false

                if followConn then
                    followConn:Disconnect()
                end

                clearTpParts()

                if autoFarmGoldBlockEnabled and not hasReachedTrigger then
                    for j = 1, 3 do
                        teleportTo(targetPos + Vector3.new(0, 3, 0))
                        task.wait(0.8)
                    end

                    hasReachedTrigger = true
                    break
                end
            end

            task.wait(0.2)
        end
    end)
end

local function joindc()
    local invite = "https://discord.gg/dbE59H6grJ"

    if setclipboard then
        setclipboard(invite)
    elseif toclipboard then
        toclipboard(invite)
    else
        library:Notification({
            title = "Clipboard",
            desc = "Clipboard not supported",
            duration = 3
        })
        return
    end

    library:Notification({
        title = "Clipboard",
        desc = "Discord invite copied!",
        duration = 3
    })
end

supporttab:Addbutton({
    title = "join discord for support",
    callback = function()
        joindc()
    end
})

Tab:AddDropdown({
    Title = "Mode",
    Desc = "Choose farming movement method",
    Values = { "tween", "teleport" },
    Value = { "teleport" },
    Multi = false,
    Search = false,
    Callback = function(s)
        farmMode = type(s) == "table" and s[1] or s
    end
})

Tab:AddDropdown({
    Title = "Speed",
    Desc = "Choose teleport speed and delay",
    Values = { "slow (all gold But slow)", "normal (recommend)", "fast (low gold)" },
    Value = { "normal (recommend)" },
    Multi = false,
    Search = false,
    Callback = function(s)
        local m = type(s) == "table" and s[1] or s

        if m:find("slow") then
            tpDelay = 1.25
        elseif m:find("fast") then
            tpDelay = 0.35
        else
            tpDelay = 0.75
        end
    end
})

Tab:AddDivider()

Tab:Addtoggle({
    title = "Auto Farm Gold",
    desc = "Automatically farm gold best",
    value = false,
    callback = function(state)
        autoFarmEnabled = state

        if state then
            if farmMode == "teleport" then
                originalGravity = workspace.Gravity
                workspace.Gravity = 25
            end

            if autoFarmGoldBlockEnabled then
                autoFarmGoldBlockEnabled = false

                if farmingBlockThread then
                    task.cancel(farmingBlockThread)
                end
            end

            if not hasReachedTrigger then
                startFarm()
            end
        else
            clearTpParts()

            if farmingThread then
                task.cancel(farmingThread)
                farmingThread = nil
            end

            workspace.Gravity = DEFAULT_GRAVITY
        end
    end
})

Tab:Addtoggle({
    title = "Auto Farm Gold Block",
    desc = "Farm gold blocks and skip gold",
    value = false,
    callback = function(state)
        autoFarmGoldBlockEnabled = state

        if state then
            if farmMode == "teleport" then
                originalGravity = workspace.Gravity
                workspace.Gravity = 25
            end

            if autoFarmEnabled then
                autoFarmEnabled = false

                if farmingThread then
                    task.cancel(farmingThread)
                end
            end

            if not hasReachedTrigger then
                startFarmGoldBlock()
            end
        else
            clearTpParts()

            if farmingBlockThread then
                task.cancel(farmingBlockThread)
                farmingBlockThread = nil
            end

            workspace.Gravity = DEFAULT_GRAVITY
        end
    end
})

ServerTab:Addbutton({
    title = "Rejoin Server",
    desc = "Reconnect to current server",
    callback = function()
        rejoinServer()
    end
})

ServerTab:Addbutton({
    title = "Server Hop",
    desc = "Find and hop to a new public server",
    callback = function()
        hopServer()
    end
})

ServerTab:AddDivider()

ServerTab:Addtoggle({
    title = "Water No Damage",
    desc = "Disable water damage by making water untouchable",
    value = false,
    callback = function(state)
        waterNoDamageEnabled = state
        setWaterNoDamage(state)

        if state then
            if waterConn then
                waterConn:Disconnect()
            end

            waterConn = workspace.DescendantAdded:Connect(function(v)
                if waterNoDamageEnabled and v:IsA("BasePart") and v.Name:lower():find("water") then
                    task.wait(0.1)
                    pcall(function()
                        v.CanTouch = false
                    end)
                end
            end)
        else
            if waterConn then
                waterConn:Disconnect()
                waterConn = nil
            end

            setWaterNoDamage(false)
        end
    end
})

ServerTab:Addtoggle({
    title = "Delete Obstacle",
    desc = "Remove rock obstacles in workspace",
    value = false,
    callback = function(state)
        deleteObstacleEnabled = state

        if state then
            deleteRocks()

            if deleteObstacleConn then
                deleteObstacleConn:Disconnect()
            end

            deleteObstacleConn = workspace.DescendantAdded:Connect(function(v)
                if deleteObstacleEnabled and v:IsA("BasePart") and v.Name:lower():find("rock") then
                    task.wait(0.1)
                    pcall(function()
                        v:Destroy()
                    end)
                end
            end)
        else
            if deleteObstacleConn then
                deleteObstacleConn:Disconnect()
                deleteObstacleConn = nil
            end
        end
    end
})

MiscTab:Addtoggle({
    title = "Enable Speed",
    value = false,
    callback = function(state)
        speedEnabled = state

        if state then
            applyMovement()
        else
            pcall(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum.WalkSpeed = 16
                end
            end)
        end
    end
})

MiscTab:AddSlider({
    Title = "Character Speed",
    Step = 1,
    Value = {Min = 16, Max = 250, Default = 16},
    Callback = function(value)
        currentSpeed = value

        if speedEnabled then
            applyMovement()
        end
    end
})

MiscTab:Addtoggle({
    title = "Enable JumpPower",
    value = false,
    callback = function(state)
        jumpEnabled = state

        if state then
            applyMovement()
        else
            pcall(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum.JumpPower = 50
                    hum.JumpHeight = 7.2
                end
            end)
        end
    end
})

MiscTab:AddSlider({
    Title = "Character JumpPower",
    Step = 1,
    Value = {Min = 50, Max = 300, Default = 50},
    Callback = function(value)
        currentJump = value

        if jumpEnabled then
            applyMovement()
        end
    end
})

MiscTab:AddDivider()

MiscTab:Addtoggle({
    title = "Freecam",
    value = false,
    callback = function(state)
        freecamEnabled = state

        if state then
            if flyEnabled then
                flyEnabled = false
                disableFly()
            end

            enableFreecam()
        else
            disableFreecam()
        end
    end
})

MiscTab:AddSlider({
    Title = "Freecam Speed",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = 10},
    Callback = function(value)
        freecamSpeed = value
    end
})

MiscTab:AddDivider()

MiscTab:Addtoggle({
    title = "Fly",
    value = false,
    callback = function(state)
        flyEnabled = state

        if state then
            if freecamEnabled then
                freecamEnabled = false
                disableFreecam()
            end

            enableFly()
        else
            disableFly()
        end
    end
})

MiscTab:AddSlider({
    Title = "Fly Speed",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = 25},
    Callback = function(value)
        flySpeed = value
    end
})

local sec = settTab:section({
    title = "script setting",
    icon = "settings",
    opened = true
})
sec:Addbutton({
    title = "reload script",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XVC-THE-CODER/Renux-Hub/refs/heads/main/games/babft.lua"))()
    end
})

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(1)

    if hasReachedTrigger then
        hasReachedTrigger = false
    end

    if freecamEnabled then
        disableFreecam()
        freecamEnabled = false
    end

    if flyEnabled then
        disableFly()
        flyEnabled = false
    end

    applyMovement()

    if autoFarmEnabled then
        task.wait(1)
        startFarm()
    end

    if autoFarmGoldBlockEnabled then
        task.wait(1)
        startFarmGoldBlock()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)

        if (autoFarmEnabled or autoFarmGoldBlockEnabled) and not hasReachedTrigger and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if (player.Character.HumanoidRootPart.Position - targetPos).Magnitude < 15 then
                hasReachedTrigger = true
                clearTpParts()
            end
        end

        if (speedEnabled or jumpEnabled) and not freecamEnabled and not flyEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            applyMovement()
        end
    end
end)

task.spawn(function()
    local wasTriggered = hasReachedTrigger

    while true do
        task.wait(0.15)

        if hasReachedTrigger and not wasTriggered then
            wasTriggered = true
            startPostTriggerAntiStuckCheck()
        elseif not hasReachedTrigger and wasTriggered then
            wasTriggered = false
            clearSoundListeners()
            soundCheckActive = false
        end
    end
end)
