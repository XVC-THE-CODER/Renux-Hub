
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local library = loadstring(game:HttpGet("https://github.com/SCRIPTHUB-dev-god/User-Interface/releases/latest/download/wave-ui.lua"))()
local window = library:CreateWindow({
	title = "Renux hub",
	desc = "Murder Mystery 2",
	opened = true,
	info = false,
	transparency = 0.12
})
window:AddTag({title = "keyless", canclicked = false, callback = function() end})
window:AddTag({title = "made in indonesia", canclicked = false, callback = function() end})
window:SetMovingText("script version 1.1")
local InfoTab = library:CreateTab("Information")
local Tab = library:CreateTab("Main")
local MiscTab = library:CreateTab("Misc")
local AimbotTab = library:CreateTab("Aimbot")
local TrollTab = library:CreateTab("Troll")
local SettingTab = library:CreateTab("Setting")
local infoLeftGroup = InfoTab:CreateGroupBox("Invite", "left", "open")
local infoRightGroup = InfoTab:CreateGroupBox("Information", "right", "open")
local espGroup = Tab:CreateGroupBox("ESP", "left", "close")
local killGroup = Tab:CreateGroupBox("Kill All", "right", "close")
local coinGroup = Tab:CreateGroupBox("Coin Farm", "left", "close")
local sheriffCounterGroup = Tab:CreateGroupBox("Sheriff Counter", "right", "close")
local avoidGroup = Tab:CreateGroupBox("Avoid", "left", "close")
local miscGroup = MiscTab:CreateGroupBox("Option", "left", "close")
local movementGroup = MiscTab:CreateGroupBox("Movement", "right", "close")
local teleportGroup = MiscTab:CreateGroupBox("Teleport", "left", "close")
local utilityGroup = MiscTab:CreateGroupBox("Utility", "right", "close")
local aimbotGroup = AimbotTab:CreateGroupBox("Aimbot", "allside", "close")
local trollGroup = TrollTab:CreateGroupBox("Fling Player", "allside", "close")
local uiGroup = SettingTab:CreateGroupBox("UI", "allside", "close")
local murderEnabled, sheriffEnabled, innocentEnabled = false, false, false
local espGunEnabled = false
local killMode = "TP"
local killAuraEnabled = false
local currentTarget = nil
local tpConn = nil
local TP_RADIUS = 185
local farmEnabled = false
local farmPart, platformPart, farmConn = nil, nil, nil
local farmSpeed = 3
local savedParts, farmAddConn = {}, nil
local farmPausedByMurder = false
local lastSafeHeight = 45
local mapHREnabled = false
local mapHRGui, mapHRAutoSaveConn, mapHRSavedCFrame, mapHRTPing = nil, nil, nil, false
local mapHRList = {"Pier","Beach Resort","Yacht","Bank 2","Bio Lab","Factory","Hospital 3","Hotel 2","House 2","Mansion 2","Military Base","nStudio","NSOffice","Office 3","Police Station","Research Facility","Workplace","Bank 1","Hospital 1","Hospital 2","Hotel 1","House 1","Mansion 1","Office 1","Office 2","Research Facility 1","Haunted House","Log Cabin","Workshop"}
local function normalizeMapName(s)
	return string.lower(tostring(s)):gsub("_",""):gsub(" ",""):gsub("-","")
end
local mapHRSet = {}
for _, n in ipairs(mapHRList) do mapHRSet[normalizeMapName(n)] = true end
local avoidEnabled, avoidDistance, avoidConn = false, 40, nil
local antiVoidEnabled, antiVoidConn, lastSafePos = false, nil, nil
local safePlatformPart = nil
local walkSpeedEnabled, walkSpeedValue = false, 16
local jumpEnabled, jumpValue = false, 50
local movementConn = nil
local noclipEnabled = false
local noclipConnection = nil
local infJumpEnabled, infJumpConn = false, nil
local xrayEnabled, xrayConn, xrayOriginal, xrayLoop = false, nil, {}, nil
local fullbrightEnabled, fullbrightConn = false, nil
local oldLighting = {}
local espData = {}
local espGunHL, espGunLoop, espGunWasFound, espGunLastHrp = nil, nil, false, nil
local aimbotMurderEnabled, aimbotSheriffEnabled, aimbotInnocentEnabled = false, false, false
local aimbotPrediction = 0
local aimbotEnabled = false
local aimbotConn = nil
local aimbotInfoGui = nil
local aimbotInfoName, aimbotInfoDist = nil, nil
local aimbotInfoConn = nil
local aimbotCurrentTarget = nil
local aimbotRadarPart = nil
local aimbotRadarConn = nil
local aimbotRadarAngle = 0
local flingExecuted = false
local trollMurderEnabled = false
local trollMurderConn = nil
local trollSheriffEnabled = false
local trollSheriffConn = nil
local startTime = tick()
local fps = 0
local frameCount = 0
local lastFpsTick = tick()
RunService.RenderStepped:Connect(function()
	frameCount += 1
	if tick() - lastFpsTick >= 1 then
		fps = frameCount
		frameCount = 0
		lastFpsTick = tick()
	end
end)
local function setNoclip(state)
	if state ~= nil then noclipEnabled = state else noclipEnabled = not noclipEnabled end
	if noclipEnabled then
		if not noclipConnection then
			noclipConnection = RunService.Stepped:Connect(function()
				local character = LocalPlayer.Character
				if character then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end)
		end
	else
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					if part.Parent and part.Parent:IsA("Accessory") then part.CanCollide = false else part.CanCollide = true end
				end
			end
		end
	end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.N then setNoclip() end
end)
getgenv().ToggleNoclip = setNoclip
local function startNoclip() setNoclip(true) end
local function stopNoclip() setNoclip(false) end
local function hasTool(plr, keyword)
	keyword = string.lower(keyword)
	local bp = plr:FindFirstChild("Backpack")
	local ch = plr.Character
	if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and string.find(string.lower(t.Name), keyword) then return true end end end
	if ch then for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") and string.find(string.lower(t.Name), keyword) then return true end end end
	return false
end
local function isAlive(plr)
	local ch = plr and plr.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	return hum and hrp and hum.Health > 0
end
local function hasKnifeInBackpack() return hasTool(LocalPlayer, "knife") end
local function hasGunInBackpack() return hasTool(LocalPlayer, "gun") end
local function isKnifeEquipped()
	local ch = LocalPlayer.Character
	if not ch then return false end
	for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then return true end end
	return false
end
local function isGunEquipped()
	local ch = LocalPlayer.Character
	if not ch then return false end
	for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") and string.find(string.lower(t.Name), "gun") then return true end end
	return false
end
local function getAnyAliveInTP()
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHrp then return nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - myHrp.Position).Magnitude <= TP_RADIUS then return plr end
		end
	end
	return nil
end
local function getNearestPlayer()
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHrp then return nil end
	local near, md = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then local d = (hrp.Position - myHrp.Position).Magnitude if d < md then md = d near = plr end end
		end
	end
	return near
end
local function getMurderPlayer()
	for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and isAlive(plr) and hasTool(plr, "knife") then return plr end end
	return nil
end
local function getSheriffPlayer()
	for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and isAlive(plr) and hasTool(plr, "gun") then return plr end end
	return nil
end
local function getInnocentPlayers()
	local arr = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) and not hasTool(plr, "knife") and not hasTool(plr, "gun") then table.insert(arr, plr) end
	end
	return arr
end
local function getAimbotTargets()
	local arr = {}
	if aimbotMurderEnabled then
		local m = getMurderPlayer()
		if m then table.insert(arr, m) end
	end
	if aimbotSheriffEnabled then
		local s = getSheriffPlayer()
		if s then table.insert(arr, s) end
	end
	if aimbotInnocentEnabled then
		for _, p in ipairs(getInnocentPlayers()) do table.insert(arr, p) end
	end
	return arr
end
local function getNearestAimbotTarget()
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHrp then return nil end
	local list = getAimbotTargets()
	local near, md = nil, math.huge
	for _, plr in ipairs(list) do
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		if hrp then local d = (hrp.Position - myHrp.Position).Magnitude if d < md then md = d near = plr end end
	end
	return near
end
local function hasWallBetween(origin, targetPos, ignoreChar)
	local dir = targetPos - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local list = {LocalPlayer.Character}
	if ignoreChar then table.insert(list, ignoreChar) end
	params.FilterDescendantsInstances = list
	params.IgnoreWater = true
	local result = Workspace:Raycast(origin, dir, params)
	if result then
		if result.Instance and ignoreChar and result.Instance:IsDescendantOf(ignoreChar) then return false end
		return true
	end
	return false
end
		end
	end
	return true
end
local function pressOne()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
	task.wait(0.06)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
	task.wait(0.1)
end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local list = {LocalPlayer.Character}
	if ignoreChar then table.insert(list, ignoreChar) end
	params.FilterDescendantsInstances = list
	params.IgnoreWater = true
	local result = Workspace:Raycast(fromPos, dir, params)
	if result and result.Instance then if result.Instance.CanCollide and result.Instance.Transparency < 0.8 then return true end end
	return false
end
	params.FilterDescendantsInstances = list
	params.IgnoreWater = true
	local result = Workspace:Raycast(fromPos, dir, params)
	if not result then return true end
	if result.Instance and result.Instance:IsDescendantOf(ignoreChar) then return true end
	return false
end
		end
	end
	return murderHrp.Position + Vector3.new(0,15,0), 15
end
local function createESP(plr)
	if espData[plr] then return end
	local hl = Instance.new("Highlight")
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.Enabled = false
	hl.Parent = Workspace
	pcall(function() hl.Parent = game:GetService("CoreGui") end)
	local txt = Drawing.new("Text")
	txt.Visible = false
	txt.Center = true
	txt.Outline = true
	txt.Size = 14
	txt.Font = 2
	espData[plr] = {hl = hl, txt = txt}
end
local function removeESP(plr)
	local d = espData[plr]
	if d then if d.hl then d.hl:Destroy() end if d.txt then d.txt:Remove() end espData[plr] = nil end
end
RunService.RenderStepped:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if not espData[plr] then createESP(plr) end
			local d = espData[plr]
			local ch = plr.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if d and hrp and hum and hum.Health > 0 then
				local hasKnife = hasTool(plr, "knife")
				local hasGun = hasTool(plr, "gun")
				local show, col = false, Color3.fromRGB(255,255,255)
				local label = plr.Name
				if murderEnabled and hasKnife then show = true col = Color3.fromRGB(255,0,0) label = "[MURDER] "..plr.Name
				elseif sheriffEnabled and hasGun then show = true col = Color3.fromRGB(0,140,255) label = "[SHERIFF] "..plr.Name
				elseif innocentEnabled and not hasKnife and not hasGun then show = true col = Color3.fromRGB(0,255,0) label = "[INNOCENT] "..plr.Name end
				if show then
					d.hl.Adornee = ch d.hl.FillColor = col d.hl.OutlineColor = col d.hl.Enabled = true
					local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
					if onScreen then d.txt.Visible = true d.txt.Position = Vector2.new(pos.X, pos.Y - 22) d.txt.Text = label d.txt.Color = col else d.txt.Visible = false end
				else d.hl.Enabled = false d.txt.Visible = false end
			else if d then d.hl.Enabled = false d.txt.Visible = false end end
		end
	end
end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)
local function findCoins()
	local arr = {}
	for _, o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and string.find(string.lower(o.Name), "coin") and o.Parent and o.Transparency < 0.9 then table.insert(arr, o) end end
	return arr
end
local function getNearestCoin(fromPos)
	local coins = findCoins()
	local near, md = nil, math.huge
	for _, c in ipairs(coins) do if c and c.Parent and c.Transparency < 0.9 then local d = (c.Position - fromPos).Magnitude if d < md then md = d near = c end end end
	return near
end
local function getContestingPlayer(coin)
	if not coin or not coin.Parent then return nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) then
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - coin.Position).Magnitude < 18 then return plr end
		end
	end
	return nil
end
local function isCoinContested(coin) return getContestingPlayer(coin) ~= nil end
local function getThirdFarFromPlayer(contestedCoin)
	local contestPlr = getContestingPlayer(contestedCoin)
	if not contestPlr then return nil end
	local hrp = contestPlr.Character and contestPlr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local pPos = hrp.Position
	local coins = findCoins()
	local filtered = {}
	for _, c in ipairs(coins) do if c and c.Parent and c.Transparency < 0.5 and c ~= contestedCoin then table.insert(filtered, c) end end
	table.sort(filtered, function(a,b) return (a.Position - pPos).Magnitude > (b.Position - pPos).Magnitude end)
	if #filtered >= 3 then return filtered[3] elseif #filtered >= 1 then return filtered[1] end
	return nil
end
local function getFarthestUncontested(fromPos)
	local coins = findCoins()
	local far, md = nil, -1
	for _, c in ipairs(coins) do if c and c.Parent and c.Transparency < 0.5 and not isCoinContested(c) then local d = (c.Position - fromPos).Magnitude if d > md then md = d far = c end end end
	return far
end
local function getNearestUncontested(fromPos)
	local coins = findCoins()
	local near, md = nil, math.huge
	for _, c in ipairs(coins) do if c and c.Parent and c.Transparency < 0.5 and not isCoinContested(c) then local d = (c.Position - fromPos).Magnitude if d < md then md = d near = c end end end
	return near
end
local function enableNoClipTransparent()
	savedParts = {}
	for _, o in ipairs(Workspace:GetDescendants()) do
		if o:IsA("BasePart") then
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and o:IsDescendantOf(plr.Character) then isChar = true break end end
			if not isChar and o ~= farmPart and o ~= platformPart and o.CanCollide then table.insert(savedParts, {part = o, canCollide = o.CanCollide, trans = o.Transparency}) o.CanCollide = false o.Transparency = 1 end
		end
	end
	if farmAddConn then farmAddConn:Disconnect() end
	farmAddConn = Workspace.DescendantAdded:Connect(function(obj)
		if not farmEnabled or farmPausedByMurder then return end
		if obj:IsA("BasePart") and obj.CanCollide and obj ~= farmPart and obj ~= platformPart then
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isChar = true break end end
			if not isChar then table.insert(savedParts, {part = obj, canCollide = obj.CanCollide, trans = obj.Transparency}) obj.CanCollide = false obj.Transparency = 1 end
		end
	end)
end
local function restoreParts()
	if farmAddConn then farmAddConn:Disconnect() farmAddConn = nil end
	for _, d in ipairs(savedParts) do if d.part and d.part.Parent then pcall(function() d.part.CanCollide = d.canCollide d.part.Transparency = d.trans end) end end
	savedParts = {}
end
local function createFarmPart()
	if farmPart then farmPart:Destroy() end
	if platformPart then platformPart:Destroy() end
	farmPart = Instance.new("Part")
	farmPart.Size = Vector3.new(1,1,1)
	farmPart.Anchored = true
	farmPart.CanCollide = false
	farmPart.Transparency = 1
	farmPart.Name = "FarmPart"
	farmPart.Parent = Workspace
	platformPart = Instance.new("Part")
	platformPart.Size = Vector3.new(10,1,10)
	platformPart.Anchored = true
	platformPart.CanCollide = false
	platformPart.Transparency = 1
	platformPart.Name = "FarmPlatform"
	platformPart.Parent = Workspace
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then farmPart.CFrame = hrp.CFrame platformPart.CFrame = hrp.CFrame * CFrame.new(0,-1,0) end
	return farmPart
end
local function stopFarm()
	farmEnabled = false
	farmPausedByMurder = false
	if farmConn then farmConn:Disconnect() farmConn = nil end
	if farmPart then farmPart:Destroy() farmPart = nil end
	if platformPart then platformPart:Destroy() platformPart = nil end
	restoreParts()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		hum.Sit = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.05)
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end
local function ragdollAndFarm()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.FallingDown) task.wait(0.05) hum:ChangeState(Enum.HumanoidStateType.Physics) hum.PlatformStand = false hum.AutoRotate = false end) end
end
local function ensureRagdoll()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.FallingDown) task.wait(0.05) hum:ChangeState(Enum.HumanoidStateType.Physics) end)
	end
end
local function findLobbySpawn()
	for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("SpawnLocation") then return obj end end
	for _, name in ipairs({"Spawn","SpawnPoint","SpawnPart","LobbySpawn","SpawnLocation"}) do
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and string.lower(obj.Name) == string.lower(name) then return obj end
		end
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "spawn") then return obj end end
	return nil
end
local function startFarm()
	if farmPausedByMurder then return end
	if farmConn then farmConn:Disconnect() end
	ragdollAndFarm()
	createFarmPart()
	enableNoClipTransparent()
	farmConn = RunService.Heartbeat:Connect(function()
		if not farmEnabled or farmPausedByMurder then return end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then ensureRagdoll() end
		if hrp and farmPart then hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero hrp.CFrame = farmPart.CFrame * CFrame.Angles(math.rad(90),0,0) end
		if platformPart and farmPart then platformPart.CFrame = farmPart.CFrame * CFrame.new(0,-1,0) end
	end)
	task.spawn(function()
		while farmEnabled and not farmPausedByMurder do
			ensureRagdoll()
			local origin = farmPart and farmPart.Position or Vector3.new(0,0,0)
			local target = getNearestCoin(origin)
			if not target or not target.Parent or target.Transparency >= 0.5 then
				local spawn = findLobbySpawn()
				if spawn and farmPart then
					local idlePos = spawn.Position + Vector3.new(0, -45, 0)
					farmPart.CFrame = CFrame.new(idlePos)
				else
					if farmPart then farmPart.CFrame = CFrame.new(0, -45, 0) end
				end
				task.wait(1)
			else
				local isContested = isCoinContested(target)
				if isContested then
					task.wait(0.45)
					local alt = getThirdFarFromPlayer(target) or getFarthestUncontested(origin) or getNearestUncontested(origin)
					if alt and alt.Parent and alt.Transparency < 0.5 then target = alt end
				end
				local dest = target.Position + Vector3.new(0, -3.85, 0)
				local initialDist = (farmPart.Position - dest).Magnitude
				local stuckTime, lastDist = 0, initialDist
				while farmEnabled and not farmPausedByMurder and target.Parent and farmPart and (farmPart.Position - dest).Magnitude > 1.2 do
					if target.Transparency >= 0.5 then break end
					local contestedNow = isCoinContested(target)
					if contestedNow then
						task.wait(0.45)
						local alt2 = getThirdFarFromPlayer(target) or getFarthestUncontested(farmPart.Position) or getNearestUncontested(farmPart.Position)
						if alt2 and alt2 ~= target and alt2.Transparency < 0.5 then target = alt2 dest = target.Position + Vector3.new(0, -3.85, 0) end
					end
					local curDist = (farmPart.Position - dest).Magnitude
					if curDist < 4 then break end
					if math.abs(curDist - lastDist) < 0.1 then stuckTime += task.wait() if stuckTime > 0.8 then break end else stuckTime = 0 end
					lastDist = curDist
					local distSpeedMult = curDist > 40 and 0.45 or 1.0
					local factor = 0.55 + 0.45 * math.clamp(curDist / 90, 0, 1)
					local slowMult = contestedNow and 0.3 or 1.0
					local alpha = math.clamp((farmSpeed * 0.032 * factor) * slowMult * distSpeedMult, 0.008, 0.18)
					farmPart.CFrame = farmPart.CFrame:Lerp(CFrame.new(dest), alpha)
					task.wait(contestedNow and 0.045 or 0.012)
				end
				if farmEnabled and not farmPausedByMurder and farmPart then
					for a = 0, 360, 25 do
						if not farmEnabled or farmPausedByMurder or not farmPart then break end
						farmPart.CFrame = CFrame.new(dest) * CFrame.Angles(math.rad(a),0,0)
						task.wait(0.018)
					end
				end
				local nextCoin = getNearestCoin(farmPart.Position)
				local distNext = nextCoin and (nextCoin.Position - farmPart.Position).Magnitude or 999
				local extraFarDelay = distNext > 40 and 0.45 or 0
				if distNext >= 1 and distNext <= 15 then
					if farmPart then farmPart.CFrame = CFrame.new(dest) end
					task.wait(0.25 + extraFarDelay)
				else
					if farmPart then farmPart.CFrame = CFrame.new(dest) end
					task.wait(0.85 + extraFarDelay)
				end
			end
		end
	end)
end
local function findMediumFloorFromMurder(murderPos)
	local candidates = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj.Parent and obj ~= farmPart and obj ~= platformPart then
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isChar = true break end end
			if not isChar and obj.Size.X > obj.Size.Y and obj.Size.Z > obj.Size.Y and obj.Size.X >= 8 and obj.Size.Z >= 8 then
				local d = (obj.Position - murderPos).Magnitude
				if d >= 25 and d <= 90 then table.insert(candidates, {part = obj, dist = d}) end
			end
		end
	end
	table.sort(candidates, function(a,b) return a.dist < b.dist end)
	if #candidates == 0 then return nil end
	local mid = math.clamp(math.floor(#candidates/2),1,#candidates)
	return candidates[mid].part
end
local function startAvoid()
	if avoidConn then avoidConn:Disconnect() end
	avoidConn = RunService.Heartbeat:Connect(function()
		if not avoidEnabled or hasKnifeInBackpack() then return end
		local murderPlr = getMurderPlayer()
		if not murderPlr or not isAlive(murderPlr) then return end
		local mHrp = murderPlr.Character and murderPlr.Character:FindFirstChild("HumanoidRootPart")
		local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not mHrp or not myHrp then return end
		if (mHrp.Position - myHrp.Position).Magnitude <= avoidDistance then
			local part = findMediumFloorFromMurder(mHrp.Position)
			if part then myHrp.CFrame = CFrame.new(part.Position + Vector3.new(0,4,0)) task.wait(0.4) end
		end
	end)
end
local function stopAvoid() if avoidConn then avoidConn:Disconnect() avoidConn = nil end end
local function startTP()
	if tpConn then tpConn:Disconnect() end
	tpConn = RunService.Heartbeat:Connect(function()
		if not killAuraEnabled then return end
		if not hasKnifeInBackpack() then return end
		local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not myHrp then return end
		if not currentTarget or not isAlive(currentTarget) then currentTarget = getNearestPlayer() or getAnyAliveInTP() end
		if currentTarget and isAlive(currentTarget) then
			local th = currentTarget.Character:FindFirstChild("HumanoidRootPart")
			if th then
				if (th.Position - myHrp.Position).Magnitude > TP_RADIUS then currentTarget = getNearestPlayer() or getAnyAliveInTP() return end
				myHrp.CFrame = th.CFrame * CFrame.new(0,0,1.8)
			end
		end
	end)
end
local function stopTP()
	if tpConn then tpConn:Disconnect() tpConn = nil end
	currentTarget = nil
	pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
end
local function clickLoopTP()
	task.spawn(function()
		while killAuraEnabled do
			if hasKnifeInBackpack() and currentTarget and isAlive(currentTarget) then
				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local th = currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart")
				if myHrp and th and (th.Position - myHrp.Position).Magnitude <= TP_RADIUS then
					if not isKnifeEquipped() then pressOne() end
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
					task.wait(0.05)
					VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
				end
			end
			task.wait(0.12)
		end
	end)
end
local function hrpHasParticle(hrp)
	if not hrp or not hrp.Parent then return false end
	for _, c in ipairs(hrp:GetChildren()) do if c:IsA("ParticleEmitter") then return true end end
	for _, c in ipairs(hrp.Parent:GetChildren()) do if c:IsA("ParticleEmitter") then return true end end
	for _, c in ipairs(hrp.Parent:GetDescendants()) do if c:IsA("ParticleEmitter") then return true end end
	return false
end
local function getMapNameFromHRP(hrp)
	if not hrp then return "Unknown Map" end
	local cur = hrp.Parent
	for i=1,12 do
		if not cur then break end
		local norm = normalizeMapName(cur.Name)
		if mapHRSet[norm] then return cur.Name end
		cur = cur.Parent
	end
	return "Unknown Map"
end
local function findMapFolder(normalizedName)
	for _, obj in ipairs(Workspace:GetChildren()) do
		if normalizeMapName(obj.Name) == normalizedName then return obj end
	end
	return nil
end
local function findHRPInMaps()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "HumanoidRootPart" and obj:IsA("BasePart") and obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid") then
			local isPlayer = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isPlayer = true break end end
			if not isPlayer and hrpHasParticle(obj) then
				local cur = obj.Parent
				for i=1,10 do
					if not cur then break end
					if mapHRSet[normalizeMapName(cur.Name)] then return obj end
					cur = cur.Parent
				end
			end
		end
	end
	for _, mapName in ipairs(mapHRList) do
		local norm = normalizeMapName(mapName)
		local folder = findMapFolder(norm) or Workspace:FindFirstChild(mapName)
		if not folder then
			for _, d in ipairs(Workspace:GetChildren()) do if normalizeMapName(d.Name) == norm then folder = d break end end
		end
		if folder then
			for _, d in ipairs(folder:GetDescendants()) do
				if d.Name == "HumanoidRootPart" and d:IsA("BasePart") and hrpHasParticle(d) then
					local isPlayer = false
					for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and d:IsDescendantOf(plr.Character) then isPlayer = true break end end
					if not isPlayer then return d end
				end
			end
		end
	end
	return nil
end
local function startESPGun()
	if espGunLoop then task.cancel(espGunLoop) espGunLoop = nil end
	espGunWasFound = false
	espGunLastHrp = nil
	espGunLoop = task.spawn(function()
		while espGunEnabled do
			local hrp = findHRPInMaps()
			if hrp and hrp.Parent and hrpHasParticle(hrp) then
				if not espGunHL or espGunLastHrp ~= hrp or not espGunHL.Parent then
					if espGunHL then pcall(function() espGunHL:Destroy() end) end
					espGunHL = Instance.new("Highlight")
					espGunHL.Name = "ESP_GUN_HL"
					espGunHL.FillColor = Color3.fromRGB(255,255,0)
					espGunHL.OutlineColor = Color3.fromRGB(255,255,0)
					espGunHL.FillTransparency = 0.4
					espGunHL.OutlineTransparency = 0
					espGunHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					espGunHL.Adornee = hrp.Parent
					espGunHL.Parent = Workspace
				end
				espGunLastHrp = hrp
				if not espGunWasFound then
					espGunWasFound = true
					local mapName = getMapNameFromHRP(hrp)
					library:Addnotification({title = "ESP Gun", desc = "Gun HRP spawned at "..mapName.."!", duration = 5})
				end
				task.wait(0.5)
			else
				if espGunHL then pcall(function() espGunHL:Destroy() end) espGunHL = nil end
				espGunLastHrp = nil
				if espGunWasFound then espGunWasFound = false end
				task.wait(1.5)
			end
		end
	end)
end
local function stopESPGun()
	espGunEnabled = false
	if espGunLoop then task.cancel(espGunLoop) espGunLoop = nil end
	if espGunHL then pcall(function() espGunHL:Destroy() end) espGunHL = nil end
	espGunWasFound = false
	espGunLastHrp = nil
end
local function startMovement()
	if movementConn then movementConn:Disconnect() end
	movementConn = RunService.Heartbeat:Connect(function()
		if not walkSpeedEnabled and not jumpEnabled then return end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			if walkSpeedEnabled then hum.WalkSpeed = walkSpeedValue end
			if jumpEnabled then
				if hum.UseJumpPower then hum.JumpPower = jumpValue else hum.JumpHeight = jumpValue end
			end
		end
	end)
end
local function stopMovement()
	if not walkSpeedEnabled and not jumpEnabled then
		if movementConn then movementConn:Disconnect() movementConn = nil end
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 if hum.UseJumpPower then hum.JumpPower = 50 else hum.JumpHeight = 7.2 end end
	end
end
local function startInfJump()
	if infJumpConn then infJumpConn:Disconnect() end
	infJumpConn = UserInputService.JumpRequest:Connect(function()
		if infJumpEnabled then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)
end
local function stopInfJump()
	if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end
local function startXray()
	if xrayLoop then task.cancel(xrayLoop) xrayLoop = nil end
	xrayOriginal = {}
	xrayLoop = task.spawn(function()
		while xrayEnabled do
			local batch = {}
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if not xrayEnabled then break end
				if obj:IsA("BasePart") and obj.Parent and obj ~= farmPart and obj ~= platformPart and obj ~= safePlatformPart then
					local isChar = false
					for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isChar = true break end end
					if not isChar and not xrayOriginal[obj] then
						if obj.Transparency < 0.75 then
							table.insert(batch, obj)
							if #batch >= 40 then
								for _, p in ipairs(batch) do if p and p.Parent then xrayOriginal[p] = p.Transparency p.Transparency = 0.75 end end
								batch = {}
								task.wait(0.06)
							end
						end
					end
				end
			end
			for _, p in ipairs(batch) do if p and p.Parent then xrayOriginal[p] = p.Transparency p.Transparency = 0.75 end end
			task.wait(1)
		end
	end)
	if xrayConn then xrayConn:Disconnect() end
	xrayConn = Workspace.DescendantAdded:Connect(function(obj)
		if not xrayEnabled then return end
		if obj:IsA("BasePart") and obj.Parent and obj ~= farmPart and obj ~= platformPart and obj ~= safePlatformPart then
			task.wait(0.05)
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isChar = true break end end
			if not isChar and not xrayOriginal[obj] then xrayOriginal[obj] = obj.Transparency obj.Transparency = 0.75 end
		end
	end)
end
local function stopXray()
	if xrayConn then xrayConn:Disconnect() xrayConn = nil end
	if xrayLoop then task.cancel(xrayLoop) xrayLoop = nil end
	for part, old in pairs(xrayOriginal) do if part and part.Parent then pcall(function() part.Transparency = old end) end end
	xrayOriginal = {}
end
local function startFullbright()
	if fullbrightConn then fullbrightConn:Disconnect() end
	oldLighting = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
		GlobalShadows = Lighting.GlobalShadows,
		ExposureCompensation = Lighting.ExposureCompensation
	}
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.ExposureCompensation = 0.2
	fullbrightConn = RunService.RenderStepped:Connect(function()
		if not fullbrightEnabled then return end
		Lighting.Brightness = 2
		Lighting.GlobalShadows = false
	end)
end
local function stopFullbright()
	if fullbrightConn then fullbrightConn:Disconnect() fullbrightConn = nil end
	if oldLighting.Brightness then Lighting.Brightness = oldLighting.Brightness end
	if oldLighting.Ambient then Lighting.Ambient = oldLighting.Ambient end
	if oldLighting.OutdoorAmbient then Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient end
	if oldLighting.ClockTime then Lighting.ClockTime = oldLighting.ClockTime end
	if oldLighting.FogEnd then Lighting.FogEnd = oldLighting.FogEnd end
	if oldLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = oldLighting.GlobalShadows end
	if oldLighting.ExposureCompensation then Lighting.ExposureCompensation = oldLighting.ExposureCompensation end
end
local function createSafePart()
	if safePlatformPart then pcall(function() safePlatformPart:Destroy() end) safePlatformPart = nil end
	local part = Instance.new("Part")
	part.Name = "SafePlatform"
	part.Size = Vector3.new(20,1,20)
	part.Position = Vector3.new(0,500000,0)
	part.Anchored = true
	part.CanCollide = true
	part.Transparency = 0.3
	part.Material = Enum.Material.ForceField
	part.Parent = Workspace
	safePlatformPart = part
	return part
end
local function doAntiLag()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then pcall(function() obj:Destroy() end) end
		if obj:IsA("Animation") or obj:IsA("Animator") then pcall(function() obj:Destroy() end) end
		if obj:IsA("Decal") or obj:IsA("Texture") then pcall(function() obj:Destroy() end) end
		if obj:IsA("BasePart") and obj.Parent and obj ~= farmPart and obj ~= platformPart and obj ~= safePlatformPart then
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then isChar = true break end end
			if not isChar then
				if obj.Size.Magnitude < 3 then pcall(function() obj:Destroy() end) else obj.Material = Enum.Material.SmoothPlastic obj.CastShadow = false if obj:IsA("MeshPart") then obj.TextureID = "" end end
			else obj.CastShadow = false end
		end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			for _, v in ipairs(plr.Character:GetDescendants()) do
				if v:IsA("Accessory") then pcall(function() v:Destroy() end) end
				if v:IsA("BasePart") then v.CastShadow = false end
			end
		end
	end
	Lighting.Shadows = false
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	for _, v in ipairs(Lighting:GetDescendants()) do if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then pcall(function() v:Destroy() end) end end
	for _, v in ipairs(Workspace:GetDescendants()) do if v:IsA("Light") then v.Shadows = false end end
end
local function startAntiVoid()
	if antiVoidConn then antiVoidConn:Disconnect() end
	antiVoidConn = RunService.Heartbeat:Connect(function()
		if not antiVoidEnabled then return end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		if hrp.Position.Y > -50 then
			if hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.FallingDown then
				if not lastSafePos or hrp.Position.Y > -10 then lastSafePos = hrp.Position + Vector3.new(0,5,0) end
			else lastSafePos = hrp.Position end
		end
		if hrp.Position.Y < -200 then
			if lastSafePos then hrp.CFrame = CFrame.new(lastSafePos + Vector3.new(0,5,0)) else hrp.CFrame = CFrame.new(0,50,0) end
			hrp.AssemblyLinearVelocity = Vector3.zero
		end
	end)
end
local function stopAntiVoid() if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end end
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end
local function createAimbotInfoGui()
	if aimbotInfoGui then pcall(function() aimbotInfoGui:Destroy() end) end
	local sg = Instance.new("ScreenGui")
	sg.Name = "AimbotInfoGUI"
	sg.ResetOnSpawn = false
	pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0,120,0,55)
	main.Position = UDim2.new(1,-130,0.5,-27)
	main.BackgroundColor3 = Color3.fromRGB(20,20,20)
	main.BackgroundTransparency = 0.2
	main.BorderSizePixel = 0
	main.Parent = sg
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = main
	local s = Instance.new("UIStroke") s.Thickness = 1 s.Color = Color3.fromRGB(255,255,255) s.Transparency = 0.5 s.Parent = main
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,16)
	title.BackgroundTransparency = 1
	title.Text = "AIMBOT INFO"
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = main
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Name = "NameLabel"
	nameLbl.Size = UDim2.new(1,-6,0,16)
	nameLbl.Position = UDim2.new(0,3,0,18)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = "Target: -"
	nameLbl.TextColor3 = Color3.fromRGB(0,255,0)
	nameLbl.TextSize = 12
	nameLbl.Font = Enum.Font.Gotham
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = main
	local distLbl = Instance.new("TextLabel")
	distLbl.Name = "DistLabel"
	distLbl.Size = UDim2.new(1,-6,0,14)
	distLbl.Position = UDim2.new(0,3,0,34)
	distLbl.BackgroundTransparency = 1
	distLbl.Text = "Dist: 0"
	distLbl.TextColor3 = Color3.fromRGB(255,255,0)
	distLbl.TextSize = 11
	distLbl.Font = Enum.Font.Gotham
	distLbl.TextXAlignment = Enum.TextXAlignment.Left
	distLbl.Parent = main
	aimbotInfoGui = sg
	aimbotInfoName = nameLbl
	aimbotInfoDist = distLbl
	return sg
end
local function start360RadarPart()
	if aimbotRadarPart then pcall(function() aimbotRadarPart:Destroy() end) aimbotRadarPart = nil end
	if aimbotRadarConn then aimbotRadarConn:Disconnect() aimbotRadarConn = nil end
	aimbotRadarAngle = 0
	local part = Instance.new("Part")
	part.Name = "360AimbotRadar"
	part.Size = Vector3.new(1,1,2000)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Material = Enum.Material.ForceField
	part.Parent = Workspace
	aimbotRadarPart = part
	aimbotRadarConn = RunService.Heartbeat:Connect(function(dt)
		if not aimbotEnabled or not aimbotRadarPart then return end
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myHrp then return end
		aimbotRadarAngle = (aimbotRadarAngle + dt * 3600) % 360
		aimbotRadarPart.CFrame = myHrp.CFrame * CFrame.Angles(0, math.rad(aimbotRadarAngle), 0) * CFrame.new(0,0,-1000)
		local target = aimbotCurrentTarget or getNearestAimbotTarget()
		if target and target.Character then
			local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
			if tHrp then
				local toTarget = tHrp.Position - myHrp.Position
				if toTarget.Magnitude > 2 then
					local radarDir = (myHrp.CFrame * CFrame.Angles(0, math.rad(aimbotRadarAngle), 0)).LookVector
					local flatTarget = Vector3.new(toTarget.X,0,toTarget.Z)
					local flatRadar = Vector3.new(radarDir.X,0,radarDir.Z)
					if flatTarget.Magnitude > 0.1 and flatRadar.Magnitude > 0.1 then
						local dot = flatRadar.Unit:Dot(flatTarget.Unit)
						dot = math.clamp(dot,-1,1)
						local angleDiff = math.deg(math.acos(dot))
						if angleDiff < 8 then
							local predTime = aimbotPrediction * 0.1
							local vel = tHrp.AssemblyLinearVelocity
							if vel.Magnitude < 1 then
								local hum = target.Character:FindFirstChildOfClass("Humanoid")
								if hum then vel = hum.MoveDirection * hum.WalkSpeed end
							end
							local predictedPos = tHrp.Position + vel * predTime
							if not hasWallBetween(Camera.CFrame.Position, predictedPos, target.Character) then
								Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
							end
						end
					end
				end
			end
		end
	end)
end
local function stop360RadarPart()
	if aimbotRadarConn then aimbotRadarConn:Disconnect() aimbotRadarConn = nil end
	if aimbotRadarPart then pcall(function() aimbotRadarPart:Destroy() end) aimbotRadarPart = nil end
	aimbotRadarAngle = 0
end
local function startAimbotLoop()
	if aimbotConn then aimbotConn:Disconnect() end
	if aimbotInfoConn then aimbotInfoConn:Disconnect() end
	createAimbotInfoGui()
	start360RadarPart()
	aimbotConn = RunService.RenderStepped:Connect(function()
		if not aimbotEnabled then return end
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myHrp then return end
		local target = getNearestAimbotTarget()
		aimbotCurrentTarget = target
		if not target or not target.Character then return end
		local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not tHrp then return end
		if hasWallBetween(Camera.CFrame.Position, tHrp.Position, target.Character) then return end
		local predTime = aimbotPrediction * 0.1
		local vel = tHrp.AssemblyLinearVelocity
		if vel.Magnitude < 1 then
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if hum then vel = hum.MoveDirection * hum.WalkSpeed end
		end
		local predictedPos = tHrp.Position + vel * predTime
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
	end)
	aimbotInfoConn = RunService.Heartbeat:Connect(function()
		local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not myHrp or not aimbotInfoName then return end
		local target = aimbotCurrentTarget or getNearestAimbotTarget()
		if not target or not target.Character then
			aimbotInfoName.Text = "Target: -"
			aimbotInfoDist.Text = "Dist: 0"
			return
		end
		local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not tHrp then return end
		local dist = (tHrp.Position - myHrp.Position).Magnitude
		aimbotInfoName.Text = "Target: "..target.Name
		aimbotInfoDist.Text = string.format("Dist: %.0f stud", dist)
	end)
end
local function stopAimbotLoop()
	if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
	if aimbotInfoConn then aimbotInfoConn:Disconnect() aimbotInfoConn = nil end
	stop360RadarPart()
	aimbotCurrentTarget = nil
end
local function makeTrollTiduran()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.FallingDown)
			task.wait(0.05)
			hum:ChangeState(Enum.HumanoidStateType.Physics)
			hum.PlatformStand = false
			hum.AutoRotate = false
		end)
	end
end
local function ensureTrollTiduran()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.FallingDown)
			task.wait(0.05)
			hum:ChangeState(Enum.HumanoidStateType.Physics)
		end)
	end
end
local function startTrollMurderLoop()
	if trollMurderConn then trollMurderConn:Disconnect() end
	makeTrollTiduran()
	trollMurderConn = RunService.Heartbeat:Connect(function()
		if not trollMurderEnabled then return end
		local murderPlr = getMurderPlayer()
		if not murderPlr or not isAlive(murderPlr) then return end
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if not myHrp then return end
		if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then ensureTrollTiduran() end
		local tChar = murderPlr.Character
		local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
		if not tHrp then return end
		if tHrp.AssemblyLinearVelocity.Magnitude > 70 then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p ~= murderPlr and isAlive(p) then
					local aHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if aHrp then myHrp.CFrame = aHrp.CFrame * CFrame.new(0,0,2) return end
				end
			end
		end
		local time = tick()
		local upDown = math.sin(time * 18) * 1.2
		local targetPos = tHrp.Position + Vector3.new(0, upDown, 0)
		myHrp.AssemblyLinearVelocity = Vector3.zero
		myHrp.AssemblyAngularVelocity = Vector3.zero
		myHrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.Angles(0, 0, time * 35)
	end)
end
local function stopTrollMurderLoop()
	if trollMurderConn then trollMurderConn:Disconnect() trollMurderConn = nil end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.05)
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end
local function startTrollSheriffLoop()
	if trollSheriffConn then trollSheriffConn:Disconnect() end
	makeTrollTiduran()
	trollSheriffConn = RunService.Heartbeat:Connect(function()
		if not trollSheriffEnabled then return end
		local sheriffPlr = getSheriffPlayer()
		if not sheriffPlr or not isAlive(sheriffPlr) then return end
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if not myHrp then return end
		if hum and hum:GetState() ~= Enum.HumanoidStateType.Physics then ensureTrollTiduran() end
		local tChar = sheriffPlr.Character
		local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
		if not tHrp then return end
		if tHrp.AssemblyLinearVelocity.Magnitude > 70 then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p ~= sheriffPlr and isAlive(p) then
					local aHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if aHrp then myHrp.CFrame = aHrp.CFrame * CFrame.new(0,0,2) return end
				end
			end
		end
		local time = tick()
		local upDown = math.sin(time * 18) * 1.2
		local targetPos = tHrp.Position + Vector3.new(0, upDown, 0)
		myHrp.AssemblyLinearVelocity = Vector3.zero
		myHrp.AssemblyAngularVelocity = Vector3.zero
		myHrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.Angles(0, 0, time * 35)
	end)
end
local function stopTrollSheriffLoop()
	if trollSheriffConn then trollSheriffConn:Disconnect() trollSheriffConn = nil end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.05)
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end
local function startMapHRPButton()
	if mapHRGui then mapHRGui:Destroy() mapHRGui = nil end
	if mapHRAutoSaveConn then mapHRAutoSaveConn:Disconnect() end
	mapHRSavedCFrame = nil
	mapHRTPing = false
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if myHrp then mapHRSavedCFrame = myHrp.CFrame end
	mapHRAutoSaveConn = RunService.Heartbeat:Connect(function()
		if not mapHREnabled or mapHRTPing then return end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp.Position.Y > -50 then mapHRSavedCFrame = hrp.CFrame end
	end)
	local sg = Instance.new("ScreenGui")
	sg.Name = "GetGunGUI"
	sg.ResetOnSpawn = false
	pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,130,0,32)
	btn.Position = UDim2.new(0.5,-65,0.75,0)
	btn.Text = "TP TO GUN"
	btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
	btn.BackgroundTransparency = 0.25
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.Parent = sg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,10)
	corner.Parent = btn
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.2
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Transparency = 0.35
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn
	makeDraggable(btn)
	mapHRGui = sg
	btn.MouseButton1Click:Connect(function()
		if mapHRTPing then return end
		mapHRTPing = true
		local myChar = LocalPlayer.Character
		local myHrp2 = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myHrp2 then mapHRTPing = false return end
		local before = mapHRSavedCFrame or myHrp2.CFrame
		local targetHRP = findHRPInMaps()
		if targetHRP and targetHRP.Parent and hrpHasParticle(targetHRP) then
			myHrp2.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0,3,0))
			task.wait(0.15)
			if myHrp2 and myHrp2.Parent then myHrp2.CFrame = before end
		end
		task.wait(0.1)
		mapHRTPing = false
	end)
end
local function stopMapHRPButton()
	if mapHRAutoSaveConn then mapHRAutoSaveConn:Disconnect() mapHRAutoSaveConn = nil end
	if mapHRGui then mapHRGui:Destroy() mapHRGui = nil end
	mapHRSavedCFrame = nil
	mapHRTPing = false
end
infoLeftGroup:Createinvite({
	name = "Renux hub",
	image = "18751483361",
	link = "https://discord.gg/mXnTVYYYsy",
})
local infoParaFrame = infoRightGroup:CreateParagraph({
	title = "information",
	desc = "fps: 0\nplayer in server: 0\nTime: 00:00:00"
})
local infoDescLabel = nil
task.wait(0.3)
pcall(function()
	for _, v in ipairs(infoParaFrame:GetDescendants()) do
		if v:IsA("TextLabel") and v.TextSize == 10 then
			infoDescLabel = v
			break
		end
	end
	if not infoDescLabel then
		local list = {}
		for _, c in ipairs(infoParaFrame:GetDescendants()) do
			if c:IsA("TextLabel") then table.insert(list, c) end
		end
		if #list >= 2 then infoDescLabel = list[2] end
	end
end)
task.spawn(function()
	while true do
		local elapsed = math.floor(tick() - startTime)
		local hh = math.floor(elapsed / 3600)
		local mm = math.floor((elapsed % 3600) / 60)
		local ss = elapsed % 60
		local timeStr = string.format("%02d:%02d:%02d", hh, mm, ss)
		local plyr = #Players:GetPlayers()
		local newDesc = "fps: "..tostring(fps).."\nplayer in server: "..tostring(plyr).."\nTime: "..timeStr
		if infoDescLabel and infoDescLabel.Parent then
			infoDescLabel.Text = newDesc
		else
			pcall(function()
				for _, lbl in ipairs(infoParaFrame:GetDescendants()) do
					if lbl:IsA("TextLabel") and lbl.TextSize == 10 then
						lbl.Text = newDesc
						infoDescLabel = lbl
						break
					end
				end
			end)
		end
		task.wait(0.1)
	end
end)
espGroup:CreateToggle("ESP Murder", false, function(s) murderEnabled = s end)
espGroup:CreateToggle("ESP Sheriff", false, function(s) sheriffEnabled = s end)
espGroup:CreateToggle("ESP Innocent", false, function(s) innocentEnabled = s end)
espGroup:CreateToggle("ESP Gun", false, function(s)
	espGunEnabled = s
	if s then startESPGun() else stopESPGun() end
end)
killGroup:CreateToggle("Kill All", false, function(state)
	if state then
		if farmEnabled then
			killAuraEnabled = false
			stopTP()
			library:Addnotification({title = "Warning", desc = "Farm Coin is ON! Turn off Farm first before using Kill Aura", duration = 5})
			return
		end
		killAuraEnabled = true
		killMode = "TP"
		if hasKnifeInBackpack() then
			startTP()
			clickLoopTP()
		end
	else killAuraEnabled = false stopTP() end
end)
coinGroup:CreateToggle("Farm Coin", false, function(state)
	if state then
		if killAuraEnabled then
			farmEnabled = false stopFarm()
			library:Addnotification({title = "Warning", desc = "Turn off Kill Aura & Sheriff Loop before farming", duration = 5})
			return
		end
		farmEnabled = true farmPausedByMurder = false startFarm()
	else stopFarm() end
end)
coinGroup:CreateSlider("Tween Speed", 1, 10, 3, function(v) farmSpeed = v end)
sheriffCounterGroup:CreateToggle("Get Gun", false, function(state)
	mapHREnabled = state
	if state then startMapHRPButton() else stopMapHRPButton() end
end)
avoidGroup:CreateToggle("Avoid Murder", false, function(state)
	avoidEnabled = state
	if state then startAvoid() else stopAvoid() end
end)
avoidGroup:CreateInput("Avoid Distance", "40", function(text)
	local num = tonumber(text)
	if num then avoidDistance = num end
end)
miscGroup:CreateButton("Anti Lag", function() doAntiLag() end)
miscGroup:CreateButton("Anti Fling", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/main-scipt/refs/heads/main/byte/anti-fling.lua"))()
end)
miscGroup:CreateToggle("Anti Void", false, function(state)
	antiVoidEnabled = state
	if state then startAntiVoid() else stopAntiVoid() end
end)
movementGroup:CreateToggle("Enable WalkSpeed", false, function(s)
	walkSpeedEnabled = s
	if s then startMovement() else stopMovement() end
end)
movementGroup:CreateInput("Value", "16", function(t)
	local n = tonumber(t)
	if n then walkSpeedValue = math.clamp(n, 1, 500) if walkSpeedEnabled then startMovement() end end
end)
movementGroup:CreateToggle("Enable JumpPower", false, function(s)
	jumpEnabled = s
	if s then startMovement() else stopMovement() end
end)
movementGroup:CreateInput("Value", "50", function(t)
	local n = tonumber(t)
	if n then jumpValue = math.clamp(n, 1, 500) if jumpEnabled then startMovement() end end
end)
utilityGroup:CreateToggle("Noclip", false, function(s)
	if s then startNoclip() else stopNoclip() end
end)
utilityGroup:CreateToggle("Infinite Jump", false, function(s)
	infJumpEnabled = s
	if s then startInfJump() else stopInfJump() end
end)
utilityGroup:CreateToggle("X-Ray", false, function(s)
	xrayEnabled = s
	if s then startXray() else stopXray() end
end)
utilityGroup:CreateToggle("Fullbright", false, function(s)
	fullbrightEnabled = s
	if s then startFullbright() else stopFullbright() end
end)
teleportGroup:CreateButton("TP to Safe Platform", function()
	local part = createSafePart()
	task.wait(0.1)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp and part then
		hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,2,0))
		library:Addnotification({title="Teleport", desc="Teleported to Safe Part at 0,500k,0", duration=3})
	end
end)
teleportGroup:CreateButton("TP to Lobby", function()
	local spawn = findLobbySpawn()
	if spawn then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(spawn.Position + Vector3.new(0,3,0))
			library:Addnotification({title="Teleport", desc="Teleported to Lobby", duration=3})
		end
	else library:Addnotification({title="Teleport", desc="Teleport Failed - Lobby not found", duration=3}) end
end)
teleportGroup:CreateDivider("")
teleportGroup:CreateButton("TP to Murder", function()
	local m = getMurderPlayer()
	if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = m.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2) end
	else library:Addnotification({title="Teleport", desc="Murder not found", duration=3}) end
end)
teleportGroup:CreateButton("TP to Sheriff", function()
	local s = getSheriffPlayer()
	if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = s.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2) end
	else library:Addnotification({title="Teleport", desc="Sheriff not found", duration=3}) end
end)
aimbotGroup:CreateToggle("Aimbot Murder", false, function(s)
	aimbotMurderEnabled = s
end)
aimbotGroup:CreateToggle("Aimbot Sheriff", false, function(s)
	aimbotSheriffEnabled = s
end)
aimbotGroup:CreateToggle("Aimbot Innocent", false, function(s)
	aimbotInnocentEnabled = s
end)
aimbotGroup:CreateSlider("Aim Prediction", 0, 5, 0, function(v)
	aimbotPrediction = v
end)
aimbotGroup:CreateToggle("Enable Aimbot", false, function(s)
	aimbotEnabled = s
	if s then startAimbotLoop() else stopAimbotLoop() if aimbotInfoGui then aimbotInfoGui:Destroy() aimbotInfoGui=nil end end
end)
trollGroup:CreateButton("Execute Touch Fling", function()
	if flingExecuted then
		library:Addnotification({title="Fling", desc="Fling already executed", duration=3})
		return
	end
	flingExecuted = true
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/exploit/refs/heads/main/fling/the-touch-fling.luau",true))()
	library:Addnotification({title="Fling", desc="Touch Fling Executed!", duration=3})
end)
trollGroup:CreateDivider("")
trollGroup:CreateToggle("Fling Murder", false, function(s)
	trollMurderEnabled = s
	if s then
		if trollSheriffEnabled then
			trollSheriffEnabled = false
			stopTrollSheriffLoop()
		end
		library:Addnotification({title="Fling", desc="Fling Murder ON", duration=3})
		startTrollMurderLoop()
	else
		stopTrollMurderLoop()
		library:Addnotification({title="Fling", desc="Fling Murder OFF", duration=2})
	end
end)
trollGroup:CreateToggle("Fling Sheriff", false, function(s)
	trollSheriffEnabled = s
	if s then
		if trollMurderEnabled then
			trollMurderEnabled = false
			stopTrollMurderLoop()
		end
		library:Addnotification({title="Fling", desc="Fling Sheriff ON", duration=3})
		startTrollSheriffLoop()
	else
		stopTrollSheriffLoop()
		library:Addnotification({title="Fling", desc="Fling Sheriff OFF", duration=2})
	end
end)
uiGroup:CreateButton("Reload UI", function()
	pcall(function() stopTP() end)
	pcall(function() stopFarm() end)
		pcall(function() stopAvoid() end)
	pcall(function() stopAntiVoid() end)
	pcall(function() stopMovement() end)
	pcall(function() setNoclip(false) end)
	pcall(function() stopInfJump() end)
	pcall(function() stopXray() end)
	pcall(function() stopFullbright() end)
	pcall(function() stopAimbotLoop() end)
	pcall(function() stopTrollMurderLoop() end)
	pcall(function() stopTrollSheriffLoop() end)
	pcall(function() stopMapHRPButton() end)
	pcall(function() stopESPGun() end)
	for plr,_ in pairs(espData) do pcall(function() removeESP(plr) end) end
	pcall(function() if mapHRGui then mapHRGui:Destroy() mapHRGui=nil end end)
	pcall(function() if aimbotInfoGui then aimbotInfoGui:Destroy() aimbotInfoGui=nil end end)
	pcall(function() if espGunHL then espGunHL:Destroy() espGunHL=nil end end)
	pcall(function() if safePlatformPart then safePlatformPart:Destroy() safePlatformPart=nil end end)
	pcall(function() if farmPart then farmPart:Destroy() farmPart=nil end end)
	pcall(function() if platformPart then platformPart:Destroy() platformPart=nil end end)
	murderEnabled = false sheriffEnabled = false innocentEnabled = false
	killAuraEnabled = false farmEnabled = false 
	mapHREnabled = false avoidEnabled = false antiVoidEnabled = false
	walkSpeedEnabled = false jumpEnabled = false noclipEnabled = false
	infJumpEnabled = false xrayEnabled = false fullbrightEnabled = false
	aimbotEnabled = false trollMurderEnabled = false trollSheriffEnabled = false
	task.wait(0.3)
	loadstring(game:HttpGet("https://github.com/XVC-THE-CODER/Renux-Hub/releases/latest/download/loader.lua",true))()
end)
