local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/User-Interface/refs/heads/main/library/fire-ui.lua"))()
local window = library:window({
    title = "Renux hub",
    desc = "v1.2",
    transparent = 0.15,
    theme = "fire",
    autoshow = false,
    addbacksound = false
})
window:AddTag({ title = "mm2", icon = "globe", color = Color3.fromRGB(180, 30, 30), getclick = false })
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
local LocalPlayer = Players.LocalPlayer
local MurderESP=false
local SheriffESP=false
local ESPDistance=500
local AutoCoin=false
local AvoidMurder=false
local AvoidRadius=25
local AutoKill=false
local AutoTPNoTool=false
local LoopInsideMurder=false
local LoopInsideSheriff=false
local AimbotBody=false
local SelectedAimRoles={"murder"}
local CurrentLockedPlayer=nil
local Tracers={}
local Highlights={}
local RED=Color3.fromRGB(255,0,0)
local BLUE=Color3.fromRGB(0,140,255)
local Noclip=false
local InfiniteJump=false
local Xray=false
local AntiLag=false
local WalkSpeedEnabled=false
local WalkSpeedValue=20
local JumpPowerEnabled=false
local JumpPowerValue=50
local DEFAULT_WALKSPEED=16
local DEFAULT_JUMPPOWER=50
local lastAvoid=0
pcall(function() RunService:UnbindFromRenderStep("RenuxESP") end)
pcall(function() RunService:UnbindFromRenderStep("RenuxAimbotBody") end)
local function HasTool(c,n)
    if not c then return false end
    for _,t in pairs(c:GetChildren()) do
        if t:IsA("Tool") and string.find(t.Name:lower(),n:lower()) then return true end
    end
    return false
end
local function IsInPlayerChar(obj)
    for _,plr in pairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
    end
    return false
end
local function GetCurrentRole(p)
    local sg=p:FindFirstChild("StarterGear")
    local bp=p:FindFirstChild("Backpack")
    local char=p.Character
    if HasTool(sg,"Knife") or HasTool(bp,"Knife") or HasTool(char,"Knife") then return "Murder"
    elseif HasTool(sg,"Gun") or HasTool(bp,"Gun") or HasTool(char,"Gun") then return "Sheriff" end
    return nil
end
local function HasKnife(plr)
    return HasTool(plr:FindFirstChild("StarterGear"),"Knife") or HasTool(plr:FindFirstChild("Backpack"),"Knife") or HasTool(plr.Character,"Knife")
end
local function HasWeapon(plr)
    local sg=plr:FindFirstChild("StarterGear")
    local bp=plr:FindFirstChild("Backpack")
    local char=plr.Character
    return HasTool(sg,"Knife") or HasTool(bp,"Knife") or HasTool(char,"Knife") or HasTool(sg,"Gun") or HasTool(bp,"Gun") or HasTool(char,"Gun")
end
local function IsGameStarted()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then
            local r=GetCurrentRole(plr)
            if r=="Murder" or r=="Sheriff" then return true end
        end
    end
    return false
end
local function GetTracer(p)
    if Tracers[p] then return Tracers[p] end
    local t=Drawing.new("Line")
    t.Visible=false
    t.Thickness=2
    t.Transparency=1
    Tracers[p]=t
    return t
end
local function GetHighlight(p)
    if Highlights[p] then return Highlights[p] end
    local h=Instance.new("Highlight")
    h.FillTransparency=0.5
    h.OutlineTransparency=0
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.Enabled=false
    h.Parent=workspace
    Highlights[p]=h
    return h
end
local function GetRoleHRP(r)
    for _,plr in pairs(Players:GetPlayers()) do
        if GetCurrentRole(plr)==r and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            return plr.Character.HumanoidRootPart
        end
    end
    return nil
end
local function ClickLeft()
    pcall(function()
        if mouse1click then mouse1click()
        else
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        end
    end)
end
local function FindSafeSpot(origin,minDist,maxDist,ignoreMurderPos)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances={LocalPlayer.Character}
    for i=1,25 do
        local angle=math.random()*math.pi*2
        local dist=math.random(minDist,maxDist)
        local offset=Vector3.new(math.cos(angle)*dist,0,math.sin(angle)*dist)
        local startPos=origin+offset+Vector3.new(0,60,0)
        local dir=Vector3.new(0,-150,0)
        local result=workspace:Raycast(startPos,dir,params)
        if result and result.Instance and result.Instance.CanCollide then
            local pos=result.Position+Vector3.new(0,3,0)
            if ignoreMurderPos then
                if (pos-ignoreMurderPos).Magnitude < AvoidRadius+5 then continue end
            end
            if result.Position.Y < origin.Y-25 then continue end
            return CFrame.new(pos)
        end
    end
    return nil
end
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
RunService:BindToRenderStep("RenuxESP",1,function()
    local cam=workspace.CurrentCamera
    if not cam then return end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        local tracer=GetTracer(plr)
        local highlight=GetHighlight(plr)
        local role=GetCurrentRole(plr)
        local show=false
        local col=RED
        if role=="Murder" and MurderESP then show=true col=RED
        elseif role=="Sheriff" and SheriffESP then show=true col=BLUE end
        local char=plr.Character
        local head=char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not show or not head or not char then
            tracer.Visible=false
            highlight.Enabled=false
            continue
        end
        local dist=(head.Position-cam.CFrame.Position).Magnitude
        if dist>ESPDistance then
            tracer.Visible=false
            highlight.Enabled=false
            continue
        end
        local pos,onScreen=cam:WorldToViewportPoint(head.Position)
        if not onScreen then tracer.Visible=false else
            tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
            tracer.To=Vector2.new(pos.X,pos.Y)
            tracer.Color=col
            tracer.Visible=true
        end
        highlight.Adornee=char
        highlight.FillColor=col
        highlight.OutlineColor=col
        highlight.Enabled=true
    end
end)
RunService:BindToRenderStep("RenuxAimbotBody",Enum.RenderPriority.Camera.Value+1,function()
    if not AimbotBody then
        CurrentLockedPlayer=nil
        return
    end
    local cam=workspace.CurrentCamera
    local myChar=LocalPlayer.Character
    if not cam or not myChar then return end
    local hrp=myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ignoreList={}
    for _,p in pairs(Players:GetPlayers()) do if p.Character then table.insert(ignoreList,p.Character) end end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances=ignoreList
    local best=nil
    local bestDist=math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        local char=plr.Character
        local tHrp=char and char:FindFirstChild("HumanoidRootPart")
        local tHum=char and char:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHum or tHum.Health<=0 then continue end
        local role=GetCurrentRole(plr)
        local allowed=false
        for _,sel in ipairs(SelectedAimRoles) do
            local s=string.lower(sel)
            if s=="murder" and role=="Murder" then allowed=true end
            if s=="sheriff" and role=="Sheriff" then allowed=true end
            if (s=="inconect" or s=="inocent" or s=="innocent") and role==nil then allowed=true end
        end
        if not allowed then continue end
        local origin=cam.CFrame.Position
        local targetPos=tHrp.Position
        local dir=targetPos-origin
        local rayResult=workspace:Raycast(origin,dir,params)
        if rayResult then continue end
        local dist=dir.Magnitude
        if dist < bestDist then
            bestDist=dist
            best={plr=plr, hrp=tHrp, pos=targetPos}
        end
    end
    if best then
        cam.CFrame=CFrame.new(cam.CFrame.Position,best.pos)
        if CurrentLockedPlayer ~= best.plr then
            CurrentLockedPlayer=best.plr
            library:Notification({
                title = "aimbot",
                desc = best.plr.Name.." has lock aim",
                duration = 2
            })
        end
    else
        CurrentLockedPlayer=nil
    end
end)
RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide=false end
        end
    end
    local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if WalkSpeedEnabled then hum.WalkSpeed=WalkSpeedValue end
        if JumpPowerEnabled then hum.UseJumpPower=true hum.JumpPower=JumpPowerValue end
    end
end)
local function SetXray(s)
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Parent~=LocalPlayer.Character then
            obj.LocalTransparencyModifier=s and 0.7 or 0
        end
    end
end
local function DoAntiLag()
    task.spawn(function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if not AntiLag then break end
            pcall(function()
                if v:IsA("BasePart") then
                    if not v.Parent:FindFirstChildOfClass("Humanoid") then
                        v.Material=Enum.Material.SmoothPlastic
                        v.Reflectance=0
                        if v.Size.Magnitude<2.5 and v.Anchored==false and not IsInPlayerChar(v) then
                            v:Destroy()
                        end
                    end
                elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
                    v:Destroy()
                end
            end)
        end
        for _,plr in pairs(Players:GetPlayers()) do
            local char=plr.Character
            if char then
                for _,acc in ipairs(char:GetChildren()) do
                    if acc:IsA("Accessory") or acc:IsA("Hat") then
                        acc:Destroy()
                    end
                end
            end
        end
        Lighting.GlobalShadows=false
        Lighting.FogEnd=100000
    end)
end
local function StiffCoinTween(hrp, targetPos)
    local murderHRP=GetRoleHRP("Murder")
    if murderHRP and (targetPos-murderHRP.Position).Magnitude<30 then
        return false
    end
    local startPos = hrp.Position
    local endPos = targetPos
    if endPos.Y < startPos.Y - 3 then
        local downPos = Vector3.new(startPos.X, endPos.Y + 1.5, startPos.Z)
        local distDown = (startPos - downPos).Magnitude
        local infoDown = TweenInfo.new(math.clamp(distDown/10, 0.6, 1.8), Enum.EasingStyle.Linear)
        local tweenDown = TweenService:Create(hrp, infoDown, {CFrame = CFrame.new(downPos)})
        tweenDown:Play()
        tweenDown.Completed:Wait()
        task.wait(0.1)
    end
    murderHRP=GetRoleHRP("Murder")
    if murderHRP and (endPos-murderHRP.Position).Magnitude<30 then
        return false
    end
    local finalPos = endPos + Vector3.new(0, 0.5, 0)
    local dist = (hrp.Position - finalPos).Magnitude
    local info = TweenInfo.new(math.clamp(dist/8, 0.8, 2.2), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(finalPos)})
    tween:Play()
    local aborted=false
    local conn=RunService.Heartbeat:Connect(function()
        local mHRP=GetRoleHRP("Murder")
        if mHRP and (hrp.Position-mHRP.Position).Magnitude<20 then
            aborted=true
            tween:Cancel()
        end
    end)
    tween.Completed:Wait()
    conn:Disconnect()
    if aborted then return false end
    return true
end
local function StartCoinTP()
    task.spawn(function()
        while AutoCoin do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            local allCoins={}
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("coin") and not obj.Name:lower():find("visual") and not IsInPlayerChar(obj) then
                    table.insert(allCoins,obj)
                end
            end
            if #allCoins==0 then task.wait(1) continue end
            table.sort(allCoins,function(a,b) return (hrp.Position-a.Position).Magnitude < (hrp.Position-b.Position).Magnitude end)
            local center=allCoins[1]
            local lahan={}
            for _,c in ipairs(allCoins) do
                if (c.Position-center.Position).Magnitude<=65 then table.insert(lahan,c) end
            end
            for _,coin in ipairs(lahan) do
                if not AutoCoin then break end
                if not coin.Parent or not hrp.Parent then continue end
                local mHRP=GetRoleHRP("Murder")
                if mHRP and (coin.Position-mHRP.Position).Magnitude<30 then
                    continue
                end
                local ok=StiffCoinTween(hrp, coin.Position)
                if not ok then
                    task.wait(0.1)
                    continue
                end
                task.wait(0.15)
            end
            task.wait(0.4)
        end
    end)
end
local function StartAvoidMurder()
    task.spawn(function()
        while AvoidMurder do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.3) continue end
            if tick()-lastAvoid < 1.1 then task.wait(0.15) continue end
            local shouldAvoid=false
            local murderPos=nil
            for _,plr in pairs(Players:GetPlayers()) do
                if plr==LocalPlayer then continue end
                if not HasKnife(plr) then continue end
                local tChar=plr.Character
                local tHrp=tChar and tChar:FindFirstChild("HumanoidRootPart")
                if not tHrp then continue end
                local dist=(tHrp.Position-hrp.Position).Magnitude
                if dist<=AvoidRadius then
                    shouldAvoid=true
                    murderPos=tHrp.Position
                    break
                end
            end
            if shouldAvoid then
                local sheriffHRP=GetRoleHRP("Sheriff")
                local targetCF=nil
                if sheriffHRP and sheriffHRP.Parent then
                    local off=CFrame.new(sheriffHRP.Position+Vector3.new(0,3,2))
                    if murderPos and (off.Position-murderPos).Magnitude < AvoidRadius then
                        targetCF=FindSafeSpot(hrp.Position,AvoidRadius+12,AvoidRadius+40,murderPos)
                        if not targetCF then targetCF=off end
                    else
                        targetCF=off
                    end
                else
                    targetCF=FindSafeSpot(hrp.Position,AvoidRadius+15,AvoidRadius+45,murderPos)
                end
                if targetCF then
                    pcall(function()
                        hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                        hrp.Velocity=Vector3.new(0,0,0)
                    end)
                    hrp.CFrame=targetCF
                    lastAvoid=tick()
                    task.wait(1.2)
                end
            end
            task.wait(0.12)
        end
    end)
end
local function StartAutoTPNoTool()
    task.spawn(function()
        while AutoTPNoTool do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not HasWeapon(LocalPlayer) and IsGameStarted() then
                    if (hrp.Position-Vector3.new(13,505,-60)).Magnitude>15 then
                        hrp.CFrame=CFrame.new(13,505,-60)
                        library:Notification({title="TP Lobby",desc="murder/sheriff udah ada -> TP lobby",duration=2})
                    end
                end
            end
            task.wait(1.2)
        end
    end)
end
local function StartAutoKill()
    task.spawn(function()
        while AutoKill do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then task.wait(0.3) continue end
            local knife=LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            if not knife then task.wait(0.5) continue end
            if knife.Parent~=char then hum:EquipTool(knife) task.wait(0.2) end
            local candidates={}
            for _,plr in pairs(Players:GetPlayers()) do
                if plr==LocalPlayer then continue end
                local tChar=plr.Character
                local tHrp=tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum=tChar and tChar:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health>0 then
                    local dist=(hrp.Position-tHrp.Position).Magnitude
                    if dist<=500 then table.insert(candidates,{plr=plr,hrp=tHrp,hum=tHum,char=tChar,dist=dist}) end
                end
            end
            if #candidates==0 then task.wait(0.5) continue end
            table.sort(candidates,function(a,b) return a.dist<b.dist end)
            for _,data in ipairs(candidates) do
                if not AutoKill then break end
                if not data.hum or data.hum.Health<=0 or not data.char.Parent then continue end
                local tHrp=data.hrp
                local tHum=data.hum
                local loopCount=0
                while AutoKill and tHum and tHum.Health>0 and tHrp.Parent and data.char.Parent do
                    if not char or not hrp.Parent then break end
                    local behindPos=tHrp.Position - tHrp.CFrame.LookVector*2.8 + Vector3.new(0,0.5,0)
                    hrp.CFrame=CFrame.new(behindPos,tHrp.Position)
                    local kTool=char:FindFirstChild("Knife")
                    if kTool then kTool:Activate() ClickLeft() end
                    task.wait(0.07)
                    loopCount+=1
                    if loopCount>150 then break end
                end
                task.wait(0.08)
            end
            task.wait(0.1)
        end
    end)
end
local function StartLoopInside(role)
    task.spawn(function()
        local stuck=0
        local lastPos=nil
        while (role=="Murder" and LoopInsideMurder) or (role=="Sheriff" and LoopInsideSheriff) do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local targetHRP=GetRoleHRP(role)
            if not hrp or not hum or not targetHRP or not targetHRP.Parent then task.wait(0.5) continue end
            local velMag=targetHRP.AssemblyLinearVelocity.Magnitude
            if velMag<1 then velMag=targetHRP.Velocity.Magnitude end
            if velMag>=38 or hrp.AssemblyLinearVelocity.Magnitude>=38 then
                task.wait(0.3)
                if (role=="Murder" and not LoopInsideMurder) or (role=="Sheriff" and not LoopInsideSheriff) then break end
                if velMag>=38 then
                    library:Notification({title="Fling Filter",desc=role.." >=38 -> pause 1s",duration=2})
                    task.wait(1)
                    continue
                end
            end
            pcall(function()
                hum.PlatformStand=true
                hum.Sit=true
                hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                hrp.Velocity=Vector3.new(0,0,0)
            end)
            local r=Vector3.new(math.random(-1,1)*0.3, math.random(0,1)*0.5, math.random(-1,1)*0.3)
            hrp.CFrame=targetHRP.CFrame * CFrame.new(r) * CFrame.Angles(math.rad(90),0,0)
            task.wait(0.09)
            hrp.CFrame=targetHRP.CFrame * CFrame.new(0,-0.6,0) * CFrame.Angles(math.rad(90),0,0)
            task.wait(0.09)
            if lastPos and (hrp.Position-lastPos).Magnitude<0.2 then
                stuck+=1
                if stuck>20 then hrp.CFrame=targetHRP.CFrame * CFrame.new(0,2,0) stuck=0 task.wait(0.15) end
            else stuck=0 end
            lastPos=hrp.Position
        end
        local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false hum.Sit=false end
    end)
end
MainTab:Addtoggle({title="ESP Murder",value=false,callback=function(v) MurderESP=v end})
MainTab:Addtoggle({title="ESP Sheriff",value=false,callback=function(v) SheriffESP=v end})
MainTab:AddInput({Title="ESP Distance",Value="500",Callback=function(t) local n=tonumber(t) if n then ESPDistance=n end end})
MainTab:AddDivider()
MainTab:Addtoggle({title="Auto Collect Coin",value=false,callback=function(v) AutoCoin=v if v then StartCoinTP() end end})
MainTab:Addtoggle({title="Avoid Murder",value=false,callback=function(v) AvoidMurder=v if v then StartAvoidMurder() end end})
MainTab:AddInput({Title="Avoid Radius",Value="25",Callback=function(t) local n=tonumber(t) if n then AvoidRadius=n end end})
MainTab:AddDivider()
MainTab:Addtoggle({title="Auto Kill All",value=false,callback=function(v) AutoKill=v if v then StartAutoKill() end end})
MainTab:Addtoggle({title="TP Lobby If No Tool",value=false,callback=function(v) AutoTPNoTool=v if v then StartAutoTPNoTool() end end})
AimTab:Addtoggle({title="Aimbot",value=false,callback=function(v) AimbotBody=v end})
AimTab:AddDropdown({Title="selected player",Values={"murder","sheriff","inconect"},Value={"murder"},Multi=true,Search=false,Callback=function(selected) SelectedAimRoles=selected end})
ServerTab:Addtoggle({title="Noclip",value=false,callback=function(v) Noclip=v end})
ServerTab:Addtoggle({title="Infinite Jump",value=false,callback=function(v) InfiniteJump=v end})
ServerTab:Addtoggle({title="X-ray",value=false,callback=function(v) Xray=v SetXray(v) end})
ServerTab:Addtoggle({title="Anti Lag",value=false,callback=function(v) AntiLag=v if v then DoAntiLag() library:Notification({title="Anti Lag",desc="small parts, textures, effects, accessories removed",duration=3}) end end})
ServerTab:AddDivider()
ServerTab:Addtoggle({title="Walk Speed",value=false,callback=function(v) WalkSpeedEnabled=v local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if not v and hum then hum.WalkSpeed=DEFAULT_WALKSPEED end end})
ServerTab:AddInput({Title="Walk Speed",Value="20",Callback=function(t) local n=tonumber(t) if n then WalkSpeedValue=n end end})
ServerTab:Addtoggle({title="Jump Power",value=false,callback=function(v) JumpPowerEnabled=v local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if not v and hum then hum.UseJumpPower=true hum.JumpPower=DEFAULT_JUMPPOWER end end})
ServerTab:AddInput({Title="Jump Power",Value="50",Callback=function(t) local n=tonumber(t) if n then JumpPowerValue=n end end})
TeleportTab:Addbutton({title="TP to Murder",callback=function() for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)=="Murder" and plr.Character:FindFirstChild("HumanoidRootPart") then local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0) end break end end end})
TeleportTab:Addbutton({title="TP to Sheriff",callback=function() for _,plr in pairs(Players:GetPlayers()) do if GetCurrentRole(plr)=="Sheriff" and plr.Character:FindFirstChild("HumanoidRootPart") then local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0) end break end end end})
TeleportTab:AddDivider()
TeleportTab:Addbutton({title="TP to Lobby",callback=function() local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=CFrame.new(13,505,-60) end end})
TeleportTab:Addbutton({title="Execute foxname hub",desc="this script not my script",callback=function() loadstring(game:HttpGet("https://foxname.top/loader"))() end})
TeleportTab:AddDivider()
TeleportTab:Addbutton({title="Execute Fling",callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))() end})
TeleportTab:Addtoggle({title="Loop TP Fling Murder",value=false,callback=function(v) LoopInsideMurder=v if v then StartLoopInside("Murder") end end})
TeleportTab:Addtoggle({title="Loop TP Fling Sheriff",value=false,callback=function(v) LoopInsideSheriff=v if v then StartLoopInside("Sheriff") end end})
