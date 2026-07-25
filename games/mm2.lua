local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()
local window = library:window({
    title = "Renux hub",
    desc = "v1.4",
    transparent = 0.15,
    theme = "fire",
    autoshow = false,
    addbacksound = false
})
window:AddTag({ title = "murder mystery 2", icon = "globe", color = Color3.fromRGB(180, 30, 30), getclick = false })
local MainTab = window:AddTab("Main", "home")
local ServerTab = window:AddTab("Server", "server")
local AimTab = window:AddTab("Aim", "user")
local TeleportTab = window:AddTab("Teleport", "globe")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local MurderESP=false
local SheriffESP=false
local InconectESP=false
local ESPDistance=500
local AutoCoin=false
local AvoidMurder=false
local AvoidRadius=25
local AutoKill=false
local AutoTPNoTool=false
local LoopInsideMurder=false
local LoopInsideSheriff=false
local AimbotBody=false
local GunSpinEnabled=false
local FreezeMurder=false
local SelectedAimRoles={"murder"}
local CurrentLockedPlayer=nil
local CurrentLockedPart=nil
local PredictionTime=0.24
local Tracers={}
local Highlights={}
local RED=Color3.fromRGB(255,0,0)
local BLUE=Color3.fromRGB(0,140,255)
local GREEN=Color3.fromRGB(0,255,0)
local Noclip=false
local InfiniteJump=false
local Xray=false
local XrayThread=nil
local AntiLag=false
local AntiVoid=false
local WalkSpeedEnabled=false
local WalkSpeedValue=20
local JumpPowerEnabled=false
local JumpPowerValue=50
local DEFAULT_WALKSPEED=16
local DEFAULT_JUMPPOWER=50
local lastAvoid=0
local InvisiblePart=nil
local CloneChar=nil
local OriginalChar=nil
local InvisLoopConn=nil
local LastCoinY=nil
local LobbyPart=nil
local LastSafeCF=nil
local LastSafePart=nil
local LastSafePartCF=nil
local CoinPlatform=nil
local CoinPlatformConn=nil
local Fullbright=false
local FullbrightConn=nil
local StoredLighting={}
pcall(function() RunService:UnbindFromRenderStep("RenuxESP") end)
pcall(function() RunService:UnbindFromRenderStep("RenuxAimbotBody") end)

local function EnsureLobbyPart()
    local existing = Workspace:FindFirstChild("RenuxLobbyPart")
    if existing then LobbyPart = existing return existing end
    local p = Instance.new("Part")
    p.Name = "RenuxLobbyPart" p.Size = Vector3.new(25, 2, 25) p.Position = Vector3.new(-10000, 0, 10000)
    p.Anchored = true p.CanCollide = true p.Transparency = 0.2
    p.Color = Color3.fromRGB(100, 100, 255) p.Material = Enum.Material.Neon p.Parent = Workspace LobbyPart = p return p
end
EnsureLobbyPart()

local function GetNearestPart(pos)
    local nearest, minDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored and obj.CanCollide and obj.Transparency < 1 and obj.Name ~= "RenuxLobbyPart" and obj.Name ~= "RenuxCoinPlatform" then
            if obj.Parent:FindFirstChildOfClass("Humanoid") then continue end
            if Players:GetPlayerFromCharacter(obj.Parent) then continue end
            local d = (obj.Position - pos).Magnitude
            if d < minDist and d > 5 then minDist = d nearest = obj end
        end
    end
    return nearest
end

-- [ANTI VOID BARU] deteksi part workspace di bawah player
local function GetGroundResult()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    if hum.FloorMaterial == Enum.Material.Air then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0,-7,0), params)
    if result and result.Instance then
        if not result.Instance.CanCollide then return nil end
        if not result.Instance.Anchored then return nil end
        if result.Instance.Parent:FindFirstChildOfClass("Humanoid") then return nil end
        if Players:GetPlayerFromCharacter(result.Instance.Parent) then return nil end
        if result.Instance.Transparency >= 1 then return nil end
        return result
    end
    return nil
end

-- [ANTI VOID BARU] save terus menerus kalo nginjak part, kalo ga injak berhenti save
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp.Position.Y < -130 then return end -- jangan save kalo udah deket void
    local ground = GetGroundResult()
    if ground then
        LastSafeCF = hrp.CFrame
        LastSafePart = ground.Instance
        LastSafePartCF = ground.Instance.CFrame
    end
    -- kalo ground == nil, auto save berhenti sampai nginjak lagi
end)

local function GetSpawnPart()
    for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("SpawnLocation") then return obj end end
    for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("spawn") then return obj end end
    return nil
end

local function EnsureCoinPlatform()
    if CoinPlatform and CoinPlatform.Parent then return CoinPlatform end
    local p = Instance.new("Part") p.Name = "RenuxCoinPlatform" p.Size = Vector3.new(10, 1, 10)
    p.Transparency = 1 p.Anchored = true p.CanCollide = true p.Parent = Workspace CoinPlatform = p return p
end

local function StartCoinPlatformFollow()
    if CoinPlatformConn then return end
    local platform = EnsureCoinPlatform()
    CoinPlatformConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and AutoCoin and platform.Parent then
            pcall(function() platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z) end)
        end
    end)
end

local function StopCoinPlatform()
    if CoinPlatformConn then CoinPlatformConn:Disconnect() CoinPlatformConn=nil end
    if CoinPlatform then pcall(function() CoinPlatform:Destroy() end) CoinPlatform=nil end
end

local function SetFullbright(state)
    if state then
        StoredLighting.Brightness = Lighting.Brightness
        StoredLighting.ClockTime = Lighting.ClockTime
        StoredLighting.FogEnd = Lighting.FogEnd
        StoredLighting.GlobalShadows = Lighting.GlobalShadows
        StoredLighting.Ambient = Lighting.Ambient
        StoredLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        FullbrightConn = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        end)
    else
        if FullbrightConn then FullbrightConn:Disconnect() FullbrightConn=nil end
        if StoredLighting.Brightness then
            Lighting.Brightness = StoredLighting.Brightness
            Lighting.ClockTime = StoredLighting.ClockTime
            Lighting.FogEnd = StoredLighting.FogEnd
            Lighting.GlobalShadows = StoredLighting.GlobalShadows
            Lighting.Ambient = StoredLighting.Ambient
            if StoredLighting.OutdoorAmbient then
                Lighting.OutdoorAmbient = StoredLighting.OutdoorAmbient
            end
        end
    end
end

local function StartAntiVoid()
    task.spawn(function()
        while AntiVoid do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -150 then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hrp.Velocity = Vector3.new(0,0,0)
                end)
                -- TP ke koordinat save terakhir sebelum auto save berhenti
                if LastSafeCF then
                    pcall(function()
                        hrp.CFrame = LastSafeCF + Vector3.new(0,5,0)
                    end)
                elseif LastSafePart and LastSafePart.Parent and LastSafePartCF then
                    pcall(function()
                        hrp.CFrame = LastSafePartCF + Vector3.new(0,5,0)
                    end)
                else
                    local nearest = GetNearestPart(hrp.Position)
                    if nearest then
                        pcall(function() hrp.CFrame = nearest.CFrame + Vector3.new(0,5,0) end)
                    else
                        local lp = EnsureLobbyPart()
                        pcall(function() hrp.CFrame = lp.CFrame + Vector3.new(0,5,0) end)
                    end
                end
                task.wait(0.5)
            end
            task.wait(0.1)
        end
    end)
end

local function SetInvisible(enable)
    if enable then
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        OriginalChar = LocalPlayer.Character local savedCF = OriginalChar.HumanoidRootPart.CFrame
        if InvisiblePart then InvisiblePart:Destroy() end
        InvisiblePart = Instance.new("Part") InvisiblePart.Name = "RenuxAnchor" InvisiblePart.Size = Vector3.new(10, 1, 10) InvisiblePart.Position = Vector3.new(0, 10000, 0)
        InvisiblePart.Anchored = true InvisiblePart.CanCollide = true InvisiblePart.Transparency = 1 InvisiblePart.Parent = Workspace
        OriginalChar.Archivable = true CloneChar = OriginalChar:Clone() CloneChar.Name = LocalPlayer.Name.. "_Clone" CloneChar.Parent = Workspace
        for _, v in pairs(CloneChar:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = (v.Name ~= "HumanoidRootPart") and 0.75 or 1 v.CanCollide = true v.Anchored = false elseif v:IsA("Decal") then v.Transparency = 0.75 end end
        if CloneChar:FindFirstChild("HumanoidRootPart") then CloneChar.HumanoidRootPart.CFrame = savedCF end
        task.wait(0.1) LocalPlayer.Character = CloneChar Workspace.CurrentCamera.CameraSubject = CloneChar:FindFirstChildOfClass("Humanoid")
        if InvisLoopConn then InvisLoopConn:Disconnect() end
        InvisLoopConn = RunService.Heartbeat:Connect(function()
            pcall(function() if OriginalChar and OriginalChar:FindFirstChild("HumanoidRootPart") and InvisiblePart then OriginalChar.HumanoidRootPart.CFrame = InvisiblePart.CFrame + Vector3.new(0, 3, 0) OriginalChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end end)
        end)
    else
        if InvisLoopConn then InvisLoopConn:Disconnect() InvisLoopConn = nil end
        if OriginalChar and CloneChar and CloneChar:FindFirstChild("HumanoidRootPart") then
            local targetCF = CloneChar.HumanoidRootPart.CFrame
            if OriginalChar:FindFirstChild("HumanoidRootPart") then OriginalChar.HumanoidRootPart.CFrame = targetCF end
            task.wait(0.1) LocalPlayer.Character = OriginalChar Workspace.CurrentCamera.CameraSubject = OriginalChar:FindFirstChildOfClass("Humanoid")
            task.wait(0.2) if OriginalChar:FindFirstChild("HumanoidRootPart") then OriginalChar.HumanoidRootPart.CFrame = targetCF end
        end
        if CloneChar then CloneChar:Destroy() CloneChar = nil end if InvisiblePart then InvisiblePart:Destroy() InvisiblePart = nil end OriginalChar = nil
    end
end

local function HasTool(c,n) if not c then return false end for _,t in pairs(c:GetChildren()) do if t:IsA("Tool") and string.find(t.Name:lower(),n:lower()) then return true end end return false end
local function IsInPlayerChar(obj) for _,plr in pairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then return true end end return false end
local function IsPlayerAlive(p) if not p.Character then return false end local hum=p.Character:FindFirstChildOfClass("Humanoid") if not hum then return false end return hum.Health>0 end
local function GetCurrentRole(p) local sg=p:FindFirstChild("StarterGear") local bp=p:FindFirstChild("Backpack") local char=p.Character if HasTool(sg,"Knife") or HasTool(bp,"Knife") or HasTool(char,"Knife") then return "Murder" elseif HasTool(sg,"Gun") or HasTool(bp,"Gun") or HasTool(char,"Gun") then return "Sheriff" end return nil end
local function HasKnife(p) return GetCurrentRole(p) == "Murder" end
local function HasWeapon(plr) local sg=plr:FindFirstChild("StarterGear") local bp=plr:FindFirstChild("Backpack") local char=plr.Character return HasTool(sg,"Knife") or HasTool(bp,"Knife") or HasTool(char,"Knife") or HasTool(sg,"Gun") or HasTool(bp,"Gun") or HasTool(char,"Gun") end
local function IsGameStarted() for _,plr in pairs(Players:GetPlayers()) do if plr~=LocalPlayer then local r=GetCurrentRole(plr) if r=="Murder" or r=="Sheriff" then return true end end end return false end
local function GetTracer(p) if Tracers[p] then return Tracers[p] end local t=Drawing.new("Line") t.Visible=false t.Thickness=2 t.Transparency=1 Tracers[p]=t return t end
local function GetHighlight(p) if Highlights[p] then return Highlights[p] end local h=Instance.new("Highlight") h.FillTransparency=0.5 h.OutlineTransparency=0 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop h.Enabled=false h.Parent=workspace Highlights[p]=h return h end
local function GetRoleHRP(r) for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)==r and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then return plr.Character.HumanoidRootPart end end return nil end
local function GetMurderChar() for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)=="Murder" and plr.Character then return plr.Character end end return nil end
local function ClickLeft() pcall(function() if mouse1click then mouse1click() else VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) task.wait(0.05) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) end end) end
local function FindSafeSpot(origin,minDist,maxDist,ignoreMurderPos)
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Blacklist params.FilterDescendantsInstances={LocalPlayer.Character}
    for i=1,25 do
        local angle=math.random()*math.pi*2 local dist=math.random(minDist,maxDist) local offset=Vector3.new(math.cos(angle)*dist,0,math.sin(angle)*dist)
        local startPos=origin+offset+Vector3.new(0,60,0) local dir=Vector3.new(0,-150,0) local result=workspace:Raycast(startPos,dir,params)
        if result and result.Instance and result.Instance.CanCollide then
            local pos=result.Position+Vector3.new(0,3,0)
            if ignoreMurderPos then if (pos-ignoreMurderPos).Magnitude < AvoidRadius+5 then continue end end
            if result.Position.Y < origin.Y-25 then continue end
            return CFrame.new(pos)
        end
    end
    return nil
end
UserInputService.JumpRequest:Connect(function() if InfiniteJump then local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
RunService:BindToRenderStep("RenuxESP",1,function()
    local cam=workspace.CurrentCamera if not cam then return end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        local tracer=GetTracer(plr) local highlight=GetHighlight(plr) local role=GetCurrentRole(plr) local alive=IsPlayerAlive(plr)
        if not alive then tracer.Visible=false highlight.Enabled=false continue end
        local show=false local col=RED
        if role=="Murder" and MurderESP then show=true col=RED elseif role=="Sheriff" and SheriffESP then show=true col=BLUE elseif role==nil and InconectESP and IsGameStarted() then show=true col=GREEN end
        local char=plr.Character local head=char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not show or not head or not char then tracer.Visible=false highlight.Enabled=false continue end
        local dist=(head.Position-cam.CFrame.Position).Magnitude if dist>ESPDistance then tracer.Visible=false highlight.Enabled=false continue end
        local pos,onScreen=cam:WorldToViewportPoint(head.Position)
        if not onScreen then tracer.Visible=false else tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y) tracer.To=Vector2.new(pos.X,pos.Y) tracer.Color=col tracer.Visible=true end
        highlight.Adornee=char highlight.FillColor=col highlight.OutlineColor=col highlight.Enabled=true
    end
end)

RunService:BindToRenderStep("RenuxAimbotBody",Enum.RenderPriority.Camera.Value+1,function()
    if not AimbotBody then CurrentLockedPlayer=nil CurrentLockedPart=nil return end
    local cam=workspace.CurrentCamera local myChar=LocalPlayer.Character if not cam or not myChar then return end
    local hrp=myChar:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local ignoreList={} for _,p in pairs(Players:GetPlayers()) do if p.Character then table.insert(ignoreList,p.Character) end end
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Blacklist params.FilterDescendantsInstances=ignoreList
    if CurrentLockedPlayer and CurrentLockedPlayer.Character then
        local plr=CurrentLockedPlayer local char=plr.Character
        local tHum=char:FindFirstChildOfClass("Humanoid") local tHrp=char:FindFirstChild("HumanoidRootPart")
        if tHum and tHum.Health>0 and tHrp then
            local role=GetCurrentRole(plr) local allowed=false
            for _,sel in ipairs(SelectedAimRoles) do local s=string.lower(sel) if s=="murder" and role=="Murder" then allowed=true end if s=="sheriff" and role=="Sheriff" then allowed=true end if (s=="inconect" or s=="inocent" or s=="innocent") and role==nil then allowed=true end end
            if allowed then
                local part=CurrentLockedPart
                if not part or not part.Parent then part=char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or tHrp CurrentLockedPart=part end
                if part then
                    local origin = cam.CFrame.Position local dir = part.Position - origin
                    local wallCheck = workspace:Raycast(origin, dir, params)
                    if wallCheck then CurrentLockedPlayer=nil CurrentLockedPart=nil return end
                    local vel=tHrp.AssemblyLinearVelocity if vel.Magnitude<1 then vel=tHrp.Velocity end
                    local predicted=part.Position + vel * PredictionTime
                    cam.CFrame=CFrame.new(cam.CFrame.Position,predicted) return
                end
            end
        end
        CurrentLockedPlayer=nil CurrentLockedPart=nil
    end
    local best=nil local bestDist=math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        local char=plr.Character local tHrp=char and char:FindFirstChild("HumanoidRootPart") local tHum=char and char:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHum or tHum.Health<=0 then continue end
        local role=GetCurrentRole(plr) local allowed=false
        for _,sel in ipairs(SelectedAimRoles) do local s=string.lower(sel) if s=="murder" and role=="Murder" then allowed=true end if s=="sheriff" and role=="Sheriff" then allowed=true end if (s=="inconect" or s=="inocent" or s=="innocent") and role==nil then allowed=true end end
        if not allowed then continue end
        local part=char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or tHrp
        local origin=cam.CFrame.Position local dir=part.Position-origin
        local rayResult=workspace:Raycast(origin,dir,params) if rayResult then continue end
        local dist=dir.Magnitude if dist < bestDist then bestDist=dist best={plr=plr, part=part, hrp=tHrp} end
    end
    if best then
        CurrentLockedPlayer=best.plr CurrentLockedPart=best.part
        local vel=best.hrp.AssemblyLinearVelocity if vel.Magnitude<1 then vel=best.hrp.Velocity end
        local predicted=best.part.Position + vel * PredictionTime
        cam.CFrame=CFrame.new(cam.CFrame.Position,predicted)
        library:Notification({title="aimbot",desc=best.plr.Name.." locked ["..best.part.Name.."] + 0.24 pred",duration=2})
    end
end)

RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide=false end end end
    local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then if WalkSpeedEnabled then hum.WalkSpeed=WalkSpeedValue end if JumpPowerEnabled then hum.UseJumpPower=true hum.JumpPower=JumpPowerValue end end
end)
local function SetXray(s)
    if XrayThread then task.cancel(XrayThread) XrayThread=nil end
    if not s then for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Parent~=LocalPlayer.Character then obj.LocalTransparencyModifier=0 end end return end
    XrayThread=task.spawn(function()
        local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local parts={} for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Parent~=LocalPlayer.Character then table.insert(parts,obj) end end
        table.sort(parts,function(a,b) return (a.Position-hrp.Position).Magnitude < (b.Position-hrp.Position).Magnitude end)
        for i,part in ipairs(parts) do if not Xray then break end pcall(function() part.LocalTransparencyModifier=0.7 end) if i%30==0 then task.wait(0.05) end end
    end)
end
local function DoAntiLag()
    task.spawn(function()
        for _,v in ipairs(workspace:GetDescendants()) do if not AntiLag then break end pcall(function()
            if v:IsA("BasePart") then if not v.Parent:FindFirstChildOfClass("Humanoid") then v.Material=Enum.Material.SmoothPlastic v.Reflectance=0 if v.Size.Magnitude<2.5 and v.Anchored==false and not IsInPlayerChar(v) then v:Destroy() end end
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then v:Destroy() end end)
        end
        for _,plr in pairs(Players:GetPlayers()) do local char=plr.Character if char then for _,acc in ipairs(char:GetChildren()) do if acc:IsA("Accessory") or acc:IsA("Hat") then acc:Destroy() end end end end
        Lighting.GlobalShadows=false Lighting.FogEnd=100000
    end)
end

local function GetCoinTweenTime(dist)
    if dist < 12 then return 1.2
    elseif dist < 25 then return 1.6
    else return 2.2 end
end

local function StiffCoinTween(hrp, targetPos, isSameY)
    local murderHRP=GetRoleHRP("Murder") if murderHRP and (targetPos-murderHRP.Position).Magnitude<30 then return false end
    local startPos = hrp.Position local endPos = targetPos
    if not isSameY and endPos.Y < startPos.Y - 3 then
        local downPos = Vector3.new(startPos.X, endPos.Y + 1.5, startPos.Z)
        local distDown = (startPos - downPos).Magnitude
        local tDown = GetCoinTweenTime(distDown)
        local tweenDown = TweenService:Create(hrp, TweenInfo.new(tDown, Enum.EasingStyle.Linear), {CFrame = CFrame.new(downPos)})
        tweenDown:Play() tweenDown.Completed:Wait() task.wait(0.05)
    end
    murderHRP=GetRoleHRP("Murder") if murderHRP and (endPos-murderHRP.Position).Magnitude<30 then return false end
    local finalPos = endPos + Vector3.new(0, -2.5, 0)
    local dist = (hrp.Position - finalPos).Magnitude
    local tFinal = GetCoinTweenTime(dist)
    local tween = TweenService:Create(hrp, TweenInfo.new(tFinal, Enum.EasingStyle.Linear), {CFrame = CFrame.new(finalPos)})
    tween:Play()
    local aborted=false local conn=RunService.Heartbeat:Connect(function() local mHRP=GetRoleHRP("Murder") if mHRP and (hrp.Position-mHRP.Position).Magnitude<20 then aborted=true tween:Cancel() end end)
    tween.Completed:Wait() conn:Disconnect() if aborted then return false end return true
end

local function StartCoinTP()
    task.spawn(function()
        while AutoCoin do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            local allCoins={} for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("coin") and not obj.Name:lower():find("visual") and not IsInPlayerChar(obj) then table.insert(allCoins,obj) end end
            if #allCoins==0 then StopCoinPlatform() task.wait(1) continue end
            StartCoinPlatformFollow()
            table.sort(allCoins,function(a,b) return (hrp.Position-a.Position).Magnitude < (hrp.Position-b.Position).Magnitude end)
            local center=allCoins[1] local lahan={} for _,c in ipairs(allCoins) do if (c.Position-center.Position).Magnitude<=65 then table.insert(lahan,c) end end
            for _,coin in ipairs(lahan) do
                if not AutoCoin then break end if not coin.Parent or not hrp.Parent then continue end
                local mHRP=GetRoleHRP("Murder") if mHRP and (coin.Position-mHRP.Position).Magnitude<30 then continue end
                local isSameY = LastCoinY and math.abs(coin.Position.Y - LastCoinY) < 2
                local ok=StiffCoinTween(hrp, coin.Position, isSameY)
                if ok then LastCoinY = coin.Position.Y end
                if not ok then task.wait(0.1) continue end task.wait(0.08)
            end
            task.wait(0.25)
        end
        StopCoinPlatform()
    end)
end

local function StartAvoidMurder()
    task.spawn(function()
        while AvoidMurder do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then task.wait(0.3) continue end
            if tick()-lastAvoid < 1.1 then task.wait(0.15) continue end
            local shouldAvoid=false local murderPos=nil
            for _,plr in pairs(Players:GetPlayers()) do if plr==LocalPlayer then continue end if not HasKnife(plr) then continue end local tChar=plr.Character local tHrp=tChar and tChar:FindFirstChild("HumanoidRootPart") if not tHrp then continue end local dist=(tHrp.Position-hrp.Position).Magnitude if dist<=AvoidRadius then shouldAvoid=true murderPos=tHrp.Position break end end
            if shouldAvoid then
                local sheriffHRP=GetRoleHRP("Sheriff") local targetCF=nil
                if sheriffHRP and sheriffHRP.Parent then
                    local off=CFrame.new(sheriffHRP.Position+Vector3.new(0,3,2))
                    if murderPos and (off.Position-murderPos).Magnitude < AvoidRadius then targetCF=FindSafeSpot(hrp.Position,AvoidRadius+12,AvoidRadius+40,murderPos) if not targetCF then targetCF=off end else targetCF=off end
                else targetCF=FindSafeSpot(hrp.Position,AvoidRadius+15,AvoidRadius+45,murderPos) end
                if targetCF then pcall(function() hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) hrp.Velocity=Vector3.new(0,0,0) end) hrp.CFrame=targetCF lastAvoid=tick() task.wait(1.2) end
            end
            task.wait(0.12)
        end
    end)
end

local function StartAutoTPNoTool()
    task.spawn(function()
        while AutoTPNoTool do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then if not HasWeapon(LocalPlayer) and IsGameStarted() then local lp = EnsureLobbyPart() if (hrp.Position - lp.Position).Magnitude > 8 then pcall(function() hrp.CFrame = lp.CFrame + Vector3.new(0,5,0) end) end end end
            task.wait(0.5)
        end
    end)
end

local function StartAutoKill()
    task.spawn(function()
        while AutoKill do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then task.wait(0.3) continue end
            local knife=LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") if not knife then task.wait(0.5) continue end
            if knife.Parent~=char then hum:EquipTool(knife) task.wait(0.2) end
            local candidates={} for _,plr in pairs(Players:GetPlayers()) do if plr==LocalPlayer then continue end local tChar=plr.Character local tHrp=tChar and tChar:FindFirstChild("HumanoidRootPart") local tHum=tChar and tChar:FindFirstChildOfClass("Humanoid") if tHrp and tHum and tHum.Health>0 then local dist=(hrp.Position-tHrp.Position).Magnitude if dist<=500 then table.insert(candidates,{plr=plr,hrp=tHrp,hum=tHum,char=tChar,dist=dist}) end end end
            if #candidates==0 then task.wait(0.5) continue end
            table.sort(candidates,function(a,b) return a.dist<b.dist end)
            for _,data in ipairs(candidates) do
                if not AutoKill then break end if not data.hum or data.hum.Health<=0 or not data.char.Parent then continue end
                local tHrp=data.hrp local tHum=data.hum local loopCount=0
                while AutoKill and tHum and tHum.Health>0 and tHrp.Parent and data.char.Parent do
                    if not char or not hrp.Parent then break end
                    local behindPos=tHrp.Position - tHrp.CFrame.LookVector*2.8 + Vector3.new(0,0.5,0) hrp.CFrame=CFrame.new(behindPos,tHrp.Position)
                    local kTool=char:FindFirstChild("Knife") if kTool then kTool:Activate() ClickLeft() end task.wait(0.07) loopCount+=1 if loopCount>150 then break end
                end
                task.wait(0.08)
            end
            task.wait(0.1)
        end
    end)
end
local function StartLoopInside(role)
    task.spawn(function()
        local stuck=0 local lastPos=nil
        while (role=="Murder" and LoopInsideMurder) or (role=="Sheriff" and LoopInsideSheriff) do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid") local targetHRP=GetRoleHRP(role)
            if not hrp or not hum or not targetHRP or not targetHRP.Parent then task.wait(0.5) continue end
            local velMag=targetHRP.AssemblyLinearVelocity.Magnitude if velMag<1 then velMag=targetHRP.Velocity.Magnitude end
            if velMag>=38 or hrp.AssemblyLinearVelocity.Magnitude>=38 then task.wait(0.3) if (role=="Murder" and not LoopInsideMurder) or (role=="Sheriff" and not LoopInsideSheriff) then break end if velMag>=38 then library:Notification({title="Fling Filter",desc=role.." >=38 -> pause 1s",duration=2}) task.wait(1) continue end end
            pcall(function() hum.PlatformStand=true hum.Sit=true hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) hrp.Velocity=Vector3.new(0,0,0) end)
            local r=Vector3.new(math.random(-1,1)*0.3, math.random(0,1)*0.5, math.random(-1,1)*0.3) hrp.CFrame=targetHRP.CFrame * CFrame.new(r) * CFrame.Angles(math.rad(90),0,0) task.wait(0.09) hrp.CFrame=targetHRP.CFrame * CFrame.new(0,-0.6,0) * CFrame.Angles(math.rad(90),0,0) task.wait(0.09)
            if lastPos and (hrp.Position-lastPos).Magnitude<0.2 then stuck+=1 if stuck>20 then hrp.CFrame=targetHRP.CFrame * CFrame.new(0,2,0) stuck=0 task.wait(0.15) end else stuck=0 end lastPos=hrp.Position
        end
        local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand=false hum.Sit=false end
    end)
end
local function StartGunSpin()
    task.spawn(function()
        while GunSpinEnabled do
            local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") local murderHRP=GetRoleHRP("Murder")
            if not hrp or not murderHRP then task.wait(0.3) continue end
            local behindPos = murderHRP.Position - murderHRP.CFrame.LookVector * 35 + Vector3.new(0,2,0)
            pcall(function() hrp.CFrame = CFrame.new(behindPos, murderHRP.Position) end) task.wait(0.22)
        end
    end)
end
local function StartFreezeMurder()
    task.spawn(function()
        while FreezeMurder do
            local mChar=GetMurderChar() local mHRP=mChar and mChar:FindFirstChild("HumanoidRootPart") local mHum=mChar and mChar:FindFirstChildOfClass("Humanoid")
            if mHRP and mHum then pcall(function() mHRP.Anchored=true mHRP.AssemblyLinearVelocity=Vector3.new(0,0,0) mHRP.Velocity=Vector3.new(0,0,0) mHum.PlatformStand=true mHum.AutoRotate=false end) end
            task.wait(0.1)
        end
        local mChar=GetMurderChar() local mHRP=mChar and mChar:FindFirstChild("HumanoidRootPart") local mHum=mChar and mChar:FindFirstChildOfClass("Humanoid")
        if mHRP then pcall(function() mHRP.Anchored=false end) end if mHum then pcall(function() mHum.PlatformStand=false mHum.AutoRotate=true end) end
    end)
end

MainTab:Addtoggle({title="ESP Murder",value=false,callback=function(v) MurderESP=v end})
MainTab:Addtoggle({title="ESP Sheriff",value=false,callback=function(v) SheriffESP=v end})
MainTab:Addtoggle({title="ESP Inconect",value=false,callback=function(v) InconectESP=v end})
MainTab:AddInput({Title="ESP Distance",Value="500",Callback=function(t) local n=tonumber(t) if n then ESPDistance=n end end})
MainTab:AddDivider()
MainTab:Addtoggle({title="Auto Collect Coin (kick risk)",value=false,callback=function(v) AutoCoin=v if v then StartCoinTP() else StopCoinPlatform() end end})
MainTab:Addtoggle({title="Avoid Murder",value=false,callback=function(v) AvoidMurder=v if v then StartAvoidMurder() end end})
MainTab:AddInput({Title="Avoid Radius",Value="25",Callback=function(t) local n=tonumber(t) if n then AvoidRadius=n end end})
MainTab:AddDivider()
MainTab:Addtoggle({title="Auto Kill All",value=false,callback=function(v) AutoKill=v if v then StartAutoKill() end end})
MainTab:Addtoggle({title="TP save zone",value=false,callback=function(v) AutoTPNoTool=v if v then StartAutoTPNoTool() end end})

AimTab:Addtoggle({title="Aimbot",value=false,callback=function(v) AimbotBody=v if not v then CurrentLockedPlayer=nil CurrentLockedPart=nil end end})
AimTab:Addtoggle({title="tween bihind murder",value=false,callback=function(v) GunSpinEnabled=v if v then StartGunSpin() end end})
AimTab:AddDropdown({Title="selected player",Values={"murder","sheriff","inconect"},Value={"murder"},Multi=true,Search=false,Callback=function(selected) SelectedAimRoles=selected end})

ServerTab:Addtoggle({title="Noclip",value=false,callback=function(v) Noclip=v end})
ServerTab:Addtoggle({title="Infinite Jump",value=false,callback=function(v) InfiniteJump=v end})
ServerTab:AddDivider()
ServerTab:Addtoggle({title="X-ray",value=false,callback=function(v) Xray=v SetXray(v) end})
ServerTab:Addtoggle({title="Fullbright",value=false,callback=function(v) Fullbright=v SetFullbright(v) end})
ServerTab:Addtoggle({title="Invisible",value=false,callback=function(v) SetInvisible(v) end})
ServerTab:AddDivider()
ServerTab:Addtoggle({title="Anti Lag",value=false,callback=function(v) AntiLag=v if v then DoAntiLag() library:Notification({title="Anti Lag",desc="small parts, textures, effects, accessories removed",duration=3}) end end})
ServerTab:Addtoggle({title="Anti Void",value=false,callback=function(v) AntiVoid=v if v then StartAntiVoid() end end})
ServerTab:AddDivider()
ServerTab:Addtoggle({title="Freeze Murder (visual)",value=false,callback=function(v) FreezeMurder=v if v then StartFreezeMurder() end end})
ServerTab:AddDivider()
ServerTab:Addtoggle({title="Walk Speed",value=false,callback=function(v) WalkSpeedEnabled=v local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if not v and hum then hum.WalkSpeed=DEFAULT_WALKSPEED end end})
ServerTab:AddInput({Title="Walk Speed",Value="20",Callback=function(t) local n=tonumber(t) if n then WalkSpeedValue=n end end})
ServerTab:Addtoggle({title="Jump Power",value=false,callback=function(v) JumpPowerEnabled=v local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if not v and hum then hum.UseJumpPower=true hum.JumpPower=DEFAULT_JUMPPOWER end end})
ServerTab:AddInput({Title="Jump Power",Value="50",Callback=function(t) local n=tonumber(t) if n then JumpPowerValue=n end end})

TeleportTab:Addbutton({title="TP to Murder",callback=function() for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)=="Murder" and plr.Character:FindFirstChild("HumanoidRootPart") then local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0) end break end end end})
TeleportTab:Addbutton({title="TP to Sheriff",callback=function() for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)=="Sheriff" and plr.Character:FindFirstChild("HumanoidRootPart") then local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0) end break end end end})
TeleportTab:AddDivider()
TeleportTab:Addbutton({title="TP lobby",callback=function()
    local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local spawnPart = GetSpawnPart()
    if hrp then if spawnPart then hrp.CFrame = spawnPart.CFrame + Vector3.new(0,5,0) else hrp.CFrame = EnsureLobbyPart().CFrame + Vector3.new(0,5,0) end end
end})
TeleportTab:AddDivider()
TeleportTab:Addbutton({title="Execute foxname hub",desc="this script not my script",callback=function() loadstring(game:HttpGet("https://foxname.top/loader"))() end})
TeleportTab:AddDivider()
TeleportTab:Addbutton({title="Execute Fling",callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))() end})
TeleportTab:Addtoggle({title="Loop TP Fling Murder",value=false,callback=function(v) LoopInsideMurder=v if v then StartLoopInside("Murder") end end})
TeleportTab:Addtoggle({title="Loop TP Fling Sheriff",value=false,callback=function(v) LoopInsideSheriff=v if v then StartLoopInside("Sheriff") end end})
