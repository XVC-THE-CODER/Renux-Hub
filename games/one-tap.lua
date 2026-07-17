local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlaceId = game.PlaceId

local function CopyToClipboard(text)
	if setclipboard then
		setclipboard(tostring(text))
	elseif toclipboard then
		tostring(text)
	end
end

local function doServerHop()
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if success and result and result.data then
		local servers = {}
		for _, s in ipairs(result.data) do
			if type(s) == "table" and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
				table.insert(servers, s.id)
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
		else
			TeleportService:Teleport(PlaceId, LocalPlayer)
		end
	else
		TeleportService:Teleport(PlaceId, LocalPlayer)
	end
end

local function doRejoin()
	TeleportService:TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
end

local Window = Library:CreateWindow({
	Title = "Renux Hub",
	Footer = "version: 1.0",
	AutoShow = false,
	Icon = "snowflake",
	NotifySide = "Right",
})

local DraggableLabel = Library:AddDraggableLabel("Renux Hub | one tap")

local Tab = Window:AddTab("support", "info")
local infoGroupBox = Tab:AddLeftGroupbox("info", "info")
local gameid = Tab:AddRightGroupbox("game id", "info")
local MainTab = Window:AddTab("Main", "laptop")
local PlayerTab = Window:AddTab("Player", "user")
local ESP = MainTab:AddLeftTabbox("ESP")
local Aimbot = MainTab:AddRightTabbox("Aimbot")
local EspMainTab = ESP:AddTab("Main", "laptop")
local EspSettingsTab = ESP:AddTab("Settings", "settings")
local AimbotMainTab = Aimbot:AddTab("Main", "laptop")
local AimbotSettingsTab = Aimbot:AddTab("Settings", "settings")
local PlayerTabbox = PlayerTab:AddLeftTabbox("Player Modifications")
local PlayerModTab = PlayerTabbox:AddTab("Player", "user")
local PlayerSettingTab = PlayerTabbox:AddTab("Setting", "settings")
local BotsTabbox = PlayerTab:AddRightTabbox("Bots Configuration")
local BotsMainTab = BotsTabbox:AddTab("Bots", "laptop")
local BotsSettingTab = BotsTabbox:AddTab("Setting", "settings")
local MiscTab = Window:AddTab("Misc", "list")
local MiscLeftTabbox = MiscTab:AddLeftTabbox("Misc Left")
local MiscRightTabbox = MiscTab:AddRightTabbox("Misc Right")
local LeftSettingsTab = MiscLeftTabbox:AddTab("", "settings")
local LeftLaptopTab = MiscLeftTabbox:AddTab("", "laptop")
local RightServerTab = MiscRightTabbox:AddTab("", "server")
local RightSettingsTab = MiscRightTabbox:AddTab("", "settings")
local SettingTab = Window:AddTab("Setting", "settings")
local setGroupBox = SettingTab:AddLeftGroupbox("Setting", "settings")
local seGroupBox = SettingTab:AddRightGroupbox("credits", "clipboard")

local Options = Library.Options
local Toggles = Library.Toggles

local CrosshairDot = Drawing.new("Circle")
CrosshairDot.Radius = 2
CrosshairDot.Filled = true
CrosshairDot.Visible = false

local CrosshairLeft = Drawing.new("Line")
CrosshairLeft.Thickness = 2
CrosshairLeft.Visible = false

local CrosshairRight = Drawing.new("Line")
CrosshairRight.Thickness = 2
CrosshairRight.Visible = false

local CrosshairTop = Drawing.new("Line")
CrosshairTop.Thickness = 2
CrosshairTop.Visible = false

local CrosshairBottom = Drawing.new("Line")
CrosshairBottom.Thickness = 2
CrosshairBottom.Visible = false

local CrosshairPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local TargetInfoGui = Instance.new("ScreenGui")
TargetInfoGui.Name = "TargetInfoSystem"
TargetInfoGui.Parent = CoreGui

local TargetInfoFrame = Instance.new("Frame")
TargetInfoFrame.Size = UDim2.new(0, 190, 0, 60)
TargetInfoFrame.Position = UDim2.new(1, -210, 0, 15)
TargetInfoFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
TargetInfoFrame.BorderSizePixel = 0
TargetInfoFrame.Visible = false
TargetInfoFrame.Parent = TargetInfoGui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 8)
TargetCorner.Parent = TargetInfoFrame

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Color = Color3.fromRGB(140, 0, 255)
TargetStroke.Thickness = 1.5
TargetStroke.Parent = TargetInfoFrame

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -20, 0, 20)
TargetName.Position = UDim2.new(0, 10, 0, 6)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.fromRGB(240, 230, 255)
TargetName.TextSize = 12
TargetName.Font = Enum.Font.GothamBold
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetInfoFrame

local TargetExtra = Instance.new("TextLabel")
TargetExtra.Size = UDim2.new(1, -20, 0, 15)
TargetExtra.Position = UDim2.new(0, 10, 0, 24)
TargetExtra.BackgroundTransparency = 1
TargetExtra.TextColor3 = Color3.fromRGB(185, 160, 225)
TargetExtra.TextSize = 10
TargetExtra.Font = Enum.Font.Gotham
TargetExtra.TextXAlignment = Enum.TextXAlignment.Left
TargetExtra.Parent = TargetInfoFrame

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -20, 0, 4)
HealthBarBg.Position = UDim2.new(0, 10, 1, -10)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
HealthBarBg.BorderSizePixel = 0
HealthBarBg.Parent = TargetInfoFrame

local HealthBarBgCorner = Instance.new("UICorner")
HealthBarBgCorner.CornerRadius = UDim.new(0, 2)
HealthBarBgCorner.Parent = HealthBarBg

local HealthBarFill = Instance.new("Frame")
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
HealthBarFill.BorderSizePixel = 0
HealthBarFill.Parent = HealthBarBg

local HealthBarFillCorner = Instance.new("UICorner")
HealthBarFillCorner.CornerRadius = UDim.new(0, 2)
HealthBarFillCorner.Parent = HealthBarFill

local ESP_Cache = {}
local Backup_Cache = {}
local CurrentTarget = nil
local PlayerRerolls = {}
local ChosenParts = {}
local lastPathComputed = 0
local currentWaypoints = {}
local currentWaypointIndex = 1
local lastPosition = Vector3.new()
local stuckTime = 0
local BotBlacklist = {}
local lastPeekJump = 0
local lastCloseJump = 0
local hiddenParts = {}
local lastFpsUpdate = 0
local frameCount = 0
local lastClickTime = 0
local canAim = true
local npcIds = {}
local CachedNPCs = {}

local BackupGui = CoreGui:FindFirstChild("ESP_Backup_Sys") or Instance.new("ScreenGui")
BackupGui.Name = "ESP_Backup_Sys"
BackupGui.ResetOnSpawn = false
if not BackupGui.Parent then
	BackupGui.Parent = CoreGui
end

local Label = infoGroupBox:AddLabel("support my discord")
infoGroupBox:AddButton({Text = "Copy Discord", Func = function()
	local link = "https://discord.gg/mjhqEMRr"
	CopyToClipboard(link)
end})

gameid:AddLabel("Place ID : " .. tostring(PlaceId))
gameid:AddButton({Text="Copy Place ID", Func=function()
	CopyToClipboard(PlaceId)
end})

EspMainTab:AddToggle("Tracers", { Text = "Tracers", Default = false })
EspMainTab:AddToggle("TwoDBox", { Text = "2D Box", Default = false })
EspMainTab:AddToggle("ThreeDBox", { Text = "3D Box", Default = false })
EspMainTab:AddToggle("Skeleton", { Text = "Skeleton", Default = false })
EspMainTab:AddToggle("Name", { Text = "Name", Default = false })
EspMainTab:AddToggle("HealthNumber", { Text = "Health Number", Default = false })
EspMainTab:AddToggle("Distance", { Text = "Distance", Default = false })
EspMainTab:AddToggle("Highlight", { Text = "Highlight", Default = false })

EspSettingsTab:AddDropdown("TracerOrigin", { Text = "Tracer Position", Values = { "Top", "Center", "Bottom" }, Default = 3 })
EspSettingsTab:AddToggle("RainbowESP", { Text = "Rainbow ESP", Default = false })
EspSettingsTab:AddSlider("RainbowSpeed", { Text = "Rainbow Speed", Default = 2, Min = 1, Max = 10, Rounding = 0, Suffix = "" })
EspSettingsTab:AddSlider("ESPThickness", { Text = "ESP Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0, Suffix = "px" })
EspSettingsTab:AddSlider("MaxEspDistance", { Text = "Max Distance", Default = 500, Min = 50, Max = 2000, Rounding = 0, Suffix = " studs" })
EspSettingsTab:AddToggle("UseBackupUI", { Text = "Force Backup ScreenUI", Default = false })

AimbotMainTab:AddToggle("AimbotToggle", { Text = "Enable Aimbot", Default = false })
AimbotMainTab:AddDropdown("AutoLookPart", { Text = "Look Target", Values = { "Head", "Body", "Full Body", "Random" }, Default = 3 })
AimbotMainTab:AddDivider()
AimbotMainTab:AddToggle("SuperRadarAim", { Text = "360° Aimbot", Default = true })
AimbotMainTab:AddToggle("AimPrediction", { Text = "Aim Prediction", Default = false })

AimbotSettingsTab:AddSlider("AimbotSmoothness", { Text = "Aimbot Smoothness", Default = 0, Min = 0, Max = 20, Rounding = 0, Suffix = "" })
AimbotSettingsTab:AddSlider("PredictionVelocity", { Text = "Prediction Scale", Default = 0.2, Min = 0, Max = 15, Rounding = 2, Suffix = "" })
AimbotSettingsTab:AddDivider()
AimbotSettingsTab:AddToggle("DisableCrosshair", { Text = "Disable Crosshair", Default = false })
AimbotSettingsTab:AddToggle("ShowTargetUI", { Text = "Show Target Info UI", Default = true })

PlayerModTab:AddToggle("EnableWalkSpeed", { Text = "Enable WalkSpeed", Default = false })
PlayerModTab:AddToggle("EnableJumpPower", { Text = "Enable Jump Power", Default = false })
PlayerModTab:AddDivider()
PlayerModTab:AddToggle("BhopToggle", { Text = "Bunny Hop Loop Jump", Default = false })

PlayerSettingTab:AddSlider("WalkSpeedPower", { Text = "WalkSpeed Power", Default = 16, Min = 16, Max = 250, Rounding = 0, Suffix = " studs" })
PlayerSettingTab:AddDivider()
PlayerSettingTab:AddSlider("JumpPowerPower", { Text = "Jump Power", Default = 50, Min = 50, Max = 500, Rounding = 0, Suffix = " power" })

BotsMainTab:AddToggle("AutoWalkToClosest", { Text = "Auto Walk To Closest Player", Default = false })

BotsSettingTab:AddDropdown("BotMovementStyle", { Text = "Movement Style", Values = { "Analyse", "Junius", "Ban", "Mythic" }, Default = 4 })
BotsSettingTab:AddSlider("BotCameraSmoothness", { Text = "Bot Camera Smoothness", Default = 5, Min = 0, Max = 20, Rounding = 0, Suffix = "" })

LeftSettingsTab:AddToggle("CullSmallParts", { Text = "Cull Small Outside Parts", Default = false })
LeftSettingsTab:AddToggle("CleanTexturesShadows", { Text = "Remove Textures & Shadows", Default = false })

local FpsLabel = LeftLaptopTab:AddLabel("FPS: Calculating...")
local MsLabel = LeftLaptopTab:AddLabel("Ping: Calculating...")

RightServerTab:AddToggle("TriggerBot", { Text = "Auto Click on Target", Default = false })
RightServerTab:AddDivider()
RightServerTab:AddToggle("TargetPlayers", { Text = "Target Players", Default = true })
RightServerTab:AddToggle("TargetNPCs", { Text = "Target NPCs", Default = false })

RightSettingsTab:AddSlider("TriggerClickDelay", { Text = "Click Delay (ms)", Default = 75, Min = 0, Max = 1000, Rounding = 0, Suffix = " ms" })

setGroupBox:AddLabel("setting ui")
setGroupBox:AddButton({Text = "restart ui", Func = function()
	if Library then Library:Unload() end
	task.spawn(function()
		task.wait()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRIPTHUB-dev-god/king-icarus/refs/heads/script/main/game.lua",true))()
	end)
end})
setGroupBox:AddButton({Text = "delete ui", Func = function() Library:Unload() end})
setGroupBox:AddDivider()
setGroupBox:AddButton({Text = "Server Hop", Func = doServerHop})
setGroupBox:AddButton({Text = "Rejoin", Func = doRejoin})

seGroupBox:AddLabel("credits by")
seGroupBox:AddLabel("• ICARUS hub")
seGroupBox:AddLabel("• mspaint")
seGroupBox:AddLabel("• others")
seGroupBox:AddDivider()
seGroupBox:AddLabel("logs update")
seGroupBox:AddLabel("• add Movement Style")
seGroupBox:AddLabel("• add tab")
seGroupBox:AddLabel("• new fueture")

local function GetNpcId(char)
	if not npcIds[char] then
		npcIds[char] = math.random(1000000, 9900000)
	end
	return npcIds[char]
end

local function GetPotentialTargets()
	local targets = {}
	if Toggles.TargetPlayers and Toggles.TargetPlayers.Value then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(targets, p)
			end
		end
	end
	if Toggles.TargetNPCs and Toggles.TargetNPCs.Value then
		for _, char in ipairs(CachedNPCs) do
			if char and char.Parent then
				table.insert(targets, {
					Character = char,
					Name = char.Name,
					UserId = GetNpcId(char),
					IsNPC = true
				})
			end
		end
	end
	return targets
end

local function GetESPColor()
	if Toggles.RainbowESP.Value then
		return Color3.fromHSV((tick() * (Options.RainbowSpeed.Value / 10)) % 1, 1, 1)
	end
	return Color3.fromRGB(140, 0, 255)
end

local function CreateDrawingESP(player)
	if ESP_Cache[player] then return end
	ESP_Cache[player] = {
		Tracer = Drawing.new("Line"),
		Box = Drawing.new("Square"),
		Name = Drawing.new("Text"),
		Health = Drawing.new("Text"),
		Distance = Drawing.new("Text"),
		Skeleton = {}
	}
	local d = ESP_Cache[player]
	d.Box.Filled = false
	d.Name.Center = true
	d.Name.Outline = true
	d.Name.Size = 14
	d.Health.Outline = true
	d.Health.Size = 14
	d.Distance.Center = true
	d.Distance.Outline = true
	d.Distance.Size = 12
	for i = 1, 20 do
		local line = Drawing.new("Line")
		line.Thickness = 1.5
		line.Visible = false
		table.insert(d.Skeleton, line)
	end
end

local function CreateBackupESP(player)
	if Backup_Cache[player] then return end
	local char = player.Character
	if not char then return end
	local bGui = Instance.new("BillboardGui")
	bGui.Name = player.Name .. "_BGui"
	bGui.AlwaysOnTop = true
	bGui.Size = UDim2.new(4, 0, 5.5, 0)
	bGui.Adornee = char:FindFirstChild("HumanoidRootPart")
	bGui.Parent = BackupGui
	local boxFrame = Instance.new("Frame")
	boxFrame.Name = "BoxFrame"
	boxFrame.BackgroundTransparency = 1
	boxFrame.Size = UDim2.new(1, 0, 1, 0)
	boxFrame.BorderSizePixel = 1
	boxFrame.Parent = bGui
	local infoList = Instance.new("Frame")
	infoList.Size = UDim2.new(1, 0, 1, 0)
	infoList.BackgroundTransparency = 1
	infoList.Parent = bGui
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Position = UDim2.new(0, 0, -0.3, 0)
	nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = infoList
	local healthLabel = Instance.new("TextLabel")
	healthLabel.Position = UDim2.new(-0.4, 0, 0, 0)
	healthLabel.Size = UDim2.new(0.3, 0, 1, 0)
	healthLabel.BackgroundTransparency = 1
	healthLabel.TextColor3 = Color3.fromRGB(160, 30, 255)
	healthLabel.TextStrokeTransparency = 0
	healthLabel.Parent = infoList
	local distLabel = Instance.new("TextLabel")
	distLabel.Position = UDim2.new(0, 0, 1, 0)
	distLabel.Size = UDim2.new(1, 0, 0.2, 0)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	distLabel.TextStrokeTransparency = 0
	distLabel.Parent = infoList
	local sBox = Instance.new("SelectionBox")
	sBox.Adornee = char
	sBox.Color3 = Color3.fromRGB(140, 0, 255)
	sBox.Parent = BackupGui
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillTransparency = 0.5
	hl.Parent = BackupGui
	Backup_Cache[player] = {
		Gui = bGui,
		Box = boxFrame,
		Name = nameLabel,
		Health = healthLabel,
		Distance = distLabel,
		Box3D = sBox,
		Highlight = hl
	}
end

local function RemoveESP(player)
	if ESP_Cache[player] then
		for _, obj in pairs(ESP_Cache[player]) do
			if type(obj) == "table" then
				for _, line in pairs(obj) do
					line:Remove()
				end
			else
				obj:Remove()
			end
		end
		ESP_Cache[player] = nil
	end
	if Backup_Cache[player] then
		if Backup_Cache[player].Gui then Backup_Cache[player].Gui:Destroy() end
		if Backup_Cache[player].Box3D then Backup_Cache[player].Box3D:Destroy() end
		if Backup_Cache[player].Highlight then Backup_Cache[player].Highlight:Destroy() end
		Backup_Cache[player] = nil
	end
end

local function IsAlive(player)
	if not player or not player.Character then return false end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if player.Character.Parent ~= Workspace then return false end
	return true
end

local function IsVisible(player, part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = part.Position - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character, Camera}
	local result = Workspace:Raycast(origin, direction, raycastParams)
	if result then
		return false
	end
	return true
end

local function GetBestPart(player, mode)
	if not IsAlive(player) then
		PlayerRerolls[player.UserId] = nil
		ChosenParts[player.UserId] = nil
		return nil
	end
	local char = player.Character
	if mode == "Head" then
		return char:FindFirstChild("Head")
	elseif mode == "Body" then
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	elseif mode == "Full Body" then
		local primary = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if primary and IsVisible(player, primary) then return primary end
		local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
		for _, partName in pairs(parts) do
			local p = char:FindFirstChild(partName)
			if p and IsVisible(player, p) then return p end
		end
		return primary
	elseif mode == "Random" then
		if not PlayerRerolls[player.UserId] or ChosenParts[player.UserId] == nil or not ChosenParts[player.UserId].Parent or not ChosenParts[player.UserId]:IsDescendantOf(char) then
			PlayerRerolls[player.UserId] = true
			if math.random(1, 100) <= 30 then
				ChosenParts[player.UserId] = char:FindFirstChild("Head")
			else
				ChosenParts[player.UserId] = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
			end
		end
		return ChosenParts[player.UserId]
	end
	return nil
end

local function ValidateTarget(player)
	if not IsAlive(player) then
		if player then
			PlayerRerolls[player.UserId] = nil
			ChosenParts[player.UserId] = nil
		end
		return false
	end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local targetPart = GetBestPart(player, Options.AutoLookPart.Value)
	if not targetPart or not IsVisible(player, targetPart) then return false end
	if not Toggles.SuperRadarAim.Value then
		local _, onScreen = Camera:WorldToViewportPoint(root.Position)
		if not onScreen then return false end
	end
	return true
end

local function GetClosestPlayer()
	local closest = nil
	local shortestDistance = math.huge
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	for _, player in pairs(GetPotentialTargets()) do
		if IsAlive(player) and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local targetPart = GetBestPart(player, Options.AutoLookPart.Value)
			if targetPart and IsVisible(player, targetPart) then
				local valid = false
				if Toggles.SuperRadarAim.Value then
					valid = true
				else
					local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
					if onScreen then valid = true end
				end
				if valid then
					local dist
					if Toggles.SuperRadarAim.Value and myRoot then
						dist = (targetPart.Position - myRoot.Position).Magnitude
					else
						local screenPos, _ = Camera:WorldToViewportPoint(targetPart.Position)
						local mousePos = CrosshairPosition
						dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					end
					if dist < shortestDistance then
						closest = player
						shortestDistance = dist
					end
				end
			end
		else
			PlayerRerolls[player.UserId] = nil
			ChosenParts[player.UserId] = nil
		end
	end
	return closest
end

local function onCharacterSetup(char)
	canAim = false
	task.spawn(function()
		task.wait(0.5)
		canAim = true
	end)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		hum.Died:Connect(function()
			canAim = false
			CurrentTarget = nil
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			task.spawn(function()
				for i = 1, 8 do
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
					task.wait(0.05)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
					task.wait(0.05)
				end
			end)
		end)
	end
end

if LocalPlayer.Character then
	task.spawn(onCharacterSetup, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterSetup)

task.spawn(function()
	while task.wait(0.1) do
		if Toggles.CullSmallParts and Toggles.CullSmallParts.Value then
			for _, part in ipairs(Workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) and not part.Parent:FindFirstChildOfClass("Humanoid") then
					if part.Size.X * part.Size.Y * part.Size.Z < 125 then
						local _, onScreen = Camera:WorldToViewportPoint(part.Position)
						if not onScreen then
							if not hiddenParts[part] then
								hiddenParts[part] = {Transparency = part.Transparency, CanCollide = part.CanCollide}
								part.Transparency = 1
								part.CanCollide = false
							end
						else
							if hiddenParts[part] then
								part.Transparency = hiddenParts[part].Transparency
								part.CanCollide = hiddenParts[part].CanCollide
								hiddenParts[part] = nil
							end
						end
					end
				end
			end
		else
			for part, data in pairs(hiddenParts) do
				if part and part.Parent then
					part.Transparency = data.Transparency
					part.CanCollide = data.CanCollide
				end
			end
			table.clear(hiddenParts)
		end
	end
end)

task.spawn(function()
	while task.wait(1.5) do
		if Toggles.CleanTexturesShadows and Toggles.CleanTexturesShadows.Value then
			Lighting.GlobalShadows = false
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CastShadow = false
					if v:IsA("Part") or v:IsA("MeshPart") then
						v.Material = Enum.Material.SmoothPlastic
					end
				elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ShirtGraphic") then
					v:Destroy()
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		if Toggles.TargetNPCs and Toggles.TargetNPCs.Value then
			local temp = {}
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("Humanoid") and v.Parent and v.Parent:IsA("Model") and v.Parent ~= LocalPlayer.Character then
					if not Players:GetPlayerFromCharacter(v.Parent) then
						table.insert(temp, v.Parent)
					end
				end
			end
			CachedNPCs = temp
			if #temp == 0 then
				Toggles.TargetNPCs:SetValue(false)
			end
		else
			table.clear(CachedNPCs)
		end
		task.wait(1)
	end
end)

RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	if tick() - lastFpsUpdate >= 0.5 then
		local fps = math.floor(frameCount / (tick() - lastFpsUpdate))
		FpsLabel:SetText("FPS: " .. tostring(fps))
		frameCount = 0
		lastFpsUpdate = tick()
		local ping = math.floor(game:GetService("Stats").PerformanceStats.Ping:GetValue())
		MsLabel:SetText("Ping: " .. tostring(ping) .. " ms")

		if fps < 20 then
			if Toggles.CullSmallParts and not Toggles.CullSmallParts.Value then
				Toggles.CullSmallParts:SetValue(true)
			end
			if Toggles.CleanTexturesShadows and not Toggles.CleanTexturesShadows.Value then
				Toggles.CleanTexturesShadows:SetValue(true)
			end
		end
	end

	CrosshairPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
	local myAlive = myHum and myHum.Health > 0 and canAim

	local validTargets = GetPotentialTargets()
	local currentTargetMap = {}
	for _, t in ipairs(validTargets) do
		currentTargetMap[t] = true
	end
	for p, _ in pairs(ESP_Cache) do
		if not currentTargetMap[p] then
			RemoveESP(p)
		end
	end

	if Toggles.AimbotToggle.Value and CurrentTarget and ValidateTarget(CurrentTarget) and myAlive then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	local isCrosshairVisible = Toggles.AimbotToggle.Value and not Toggles.DisableCrosshair.Value and myAlive
	local crossColor = GetESPColor()
	local crossGap = 5
	local crossLen = 8

	CrosshairDot.Position = CrosshairPosition
	CrosshairDot.Color = crossColor
	CrosshairDot.Visible = isCrosshairVisible

	CrosshairLeft.From = Vector2.new(CrosshairPosition.X - crossGap - crossLen, CrosshairPosition.Y)
	CrosshairLeft.To = Vector2.new(CrosshairPosition.X - crossGap, CrosshairPosition.Y)
	CrosshairLeft.Color = crossColor
	CrosshairLeft.Visible = isCrosshairVisible

	CrosshairRight.From = Vector2.new(CrosshairPosition.X + crossGap, CrosshairPosition.Y)
	CrosshairRight.To = Vector2.new(CrosshairPosition.X + crossGap + crossLen, CrosshairPosition.Y)
	CrosshairRight.Color = crossColor
	CrosshairRight.Visible = isCrosshairVisible

	CrosshairTop.From = Vector2.new(CrosshairPosition.X, CrosshairPosition.Y - crossGap - crossLen)
	CrosshairTop.To = Vector2.new(CrosshairPosition.X, CrosshairPosition.Y - crossGap)
	CrosshairTop.Color = crossColor
	CrosshairTop.Visible = isCrosshairVisible

	CrosshairBottom.From = Vector2.new(CrosshairPosition.X, CrosshairPosition.Y + crossGap)
	CrosshairBottom.To = Vector2.new(CrosshairPosition.X, CrosshairPosition.Y + crossGap + crossLen)
	CrosshairBottom.Color = crossColor
	CrosshairBottom.Visible = isCrosshairVisible

	local color = GetESPColor()
	local thickness = Options.ESPThickness.Value
	local useBackup = Toggles.UseBackupUI.Value or (Drawing == nil)
	local maxDistance = Options.MaxEspDistance.Value

	if myAlive and myRoot then
		local currentStyle = Options.BotMovementStyle.Value
		local isBotActive = Toggles.AutoWalkToClosest.Value

		if Toggles.EnableWalkSpeed.Value then
			myHum.WalkSpeed = Options.WalkSpeedPower.Value
		else
			if isBotActive and currentStyle == "Junius" then
				myHum.WalkSpeed = 24
			elseif not isBotActive or currentStyle == "Analyse" then
				myHum.WalkSpeed = 16
			end
		end

		if Toggles.EnableJumpPower.Value then
			myHum.UseJumpPower = true
			myHum.JumpPower = Options.JumpPowerPower.Value
		else
			if myHum.JumpPower ~= 50 and Options.JumpPowerPower.Value ~= 50 then
				myHum.JumpPower = 50
			end
		end

		if Toggles.BhopToggle.Value then
			if myHum.FloorMaterial ~= Enum.Material.Air then
				myHum.Jump = true
			end
		end

		if Toggles.AutoWalkToClosest.Value then
			local botTarget = nil
			local shortestBotDist = math.huge

			for _, player in pairs(validTargets) do
				if IsAlive(player) and player.Character:FindFirstChild("HumanoidRootPart") then
					if not BotBlacklist[player] or tick() > BotBlacklist[player] then
						local tRoot = player.Character.HumanoidRootPart
						local currentDist = (tRoot.Position - myRoot.Position).Magnitude
						if currentDist < shortestBotDist then
							shortestBotDist = currentDist
							botTarget = player
						end
					end
				end
			end

			if botTarget then
				local targetRoot = botTarget.Character.HumanoidRootPart
				local finalTargetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -5)
				local distToTarget = (targetRoot.Position - myRoot.Position).Magnitude
				local botSmooth = Options.BotCameraSmoothness.Value
				local baseLookCFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
				local cameraSway = math.sin(tick() * 2.5) * 14
				local finalLookCFrame = baseLookCFrame * CFrame.Angles(0, math.rad(cameraSway), 0)

				if distToTarget < 12 and tick() - lastCloseJump > 2.5 then
					myHum.Jump = true
					lastCloseJump = tick()
				end

				if botSmooth > 0 then
					Camera.CFrame = Camera.CFrame:Lerp(finalLookCFrame, 1 / (botSmooth + 1))
				else
					Camera.CFrame = finalLookCFrame
				end

				if currentStyle == "Analyse" then
					finalTargetPos = finalTargetPos + Vector3.new(math.sin(tick() * 2) * 1.5, 0, math.cos(tick() * 2) * 1.5)
				elseif currentStyle == "Junius" then
					local t = tick()
					local jx = math.sin(t * 14) * 6.5
					local jz = math.cos(t * 8) * 6.5
					finalTargetPos = finalTargetPos + Vector3.new(jx, 0, jz)
				elseif currentStyle == "Ban" then
					local t = tick()
					local isBeingWatched = false
					for _, p in pairs(validTargets) do
						if IsAlive(p) then
							local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
							if eRoot then
								local toMe = (myRoot.Position - eRoot.Position).Unit
								if eRoot.CFrame.LookVector:Dot(toMe) > 0.72 then
									isBeingWatched = true
									break
								end
							end
						end
					end

					if not Toggles.EnableWalkSpeed.Value then
						if isBeingWatched then
							myHum.WalkSpeed = 28
							local bx = math.sin(t * 24) * 9.5
							local bz = math.cos(t * 16) * 9.5
							finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
						else
							local speedOsc = math.sin(t * 4)
							myHum.WalkSpeed = 19 + (speedOsc + 1) * 4.5
							local bx = math.sin(t * 18) * 8
							local bz = math.cos(t * 11) * 8
							finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
						end
					else
						local bx = math.sin(t * 18) * 8
						local bz = math.cos(t * 11) * 8
						finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
					end

					local noiseX = math.noise(t * 22, 0, 0) * 3.5
					local noiseZ = math.noise(0, t * 22, 0) * 3.5
					finalTargetPos = finalTargetPos + Vector3.new(noiseX, 0, noiseZ)

					local enemyLookToMe = targetRoot.CFrame.LookVector:Dot((myRoot.Position - targetRoot.Position).Unit)
					if distToTarget < 18 and enemyLookToMe < 0.25 then
						finalTargetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -6) + (targetRoot.CFrame.RightVector * (math.sin(t * 11) * 9))
					else
						local feint = Vector3.new(0, 0, 0)
						if distToTarget < 35 then
							if math.random(1, 100) > 92 then
								feint = targetRoot.CFrame.RightVector * (math.random(1, 2) == 1 and 14 or -14)
							elseif math.random(1, 100) > 94 then
								feint = targetRoot.CFrame.LookVector * -12
							end
						end
						finalTargetPos = finalTargetPos + feint
					end

					if not IsVisible(botTarget, targetRoot) then
						if t - lastPeekJump > 0.45 then
							local startPos = myRoot.Position + Vector3.new(0, 6.5, 0)
							local castPoints = {startPos, targetRoot.Position}
							local ignoreList = {myChar, botTarget.Character}
							local parts = Camera:GetPartsObscuringTarget(castPoints, ignoreList)
							if #parts == 0 then
								myHum.Jump = true
								lastPeekJump = t
							end
						end
					end
				elseif currentStyle == "Mythic" then
					local t = tick()
					local isBeingWatched = false
					for _, p in pairs(validTargets) do
						if IsAlive(p) then
							local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
							if eRoot then
								local toMe = (myRoot.Position - eRoot.Position).Unit
								if eRoot.CFrame.LookVector:Dot(toMe) > 0.72 then
									isBeingWatched = true
									break
								end
							end
						end
					end

					if not Toggles.EnableWalkSpeed.Value then
						if isBeingWatched then
							myHum.WalkSpeed = 28
							local bx = math.sin(t * 24) * 13.5
							local bz = math.cos(t * 16) * 13.5
							finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
						else
							local speedOsc = math.sin(t * 4)
							myHum.WalkSpeed = 19 + (speedOsc + 1) * 4.5
							local bx = math.sin(t * 18) * 12
							local bz = math.cos(t * 11) * 12
							finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
						end
					else
						local bx = math.sin(t * 18) * 12
						local bz = math.cos(t * 11) * 12
						finalTargetPos = finalTargetPos + Vector3.new(bx, 0, bz)
					end

					local noiseX = math.noise(t * 22, 0, 0) * 7.5
					local noiseZ = math.noise(0, t * 22, 0) * 7.5
					finalTargetPos = finalTargetPos + Vector3.new(noiseX, 0, noiseZ)

					local enemyLookToMe = targetRoot.CFrame.LookVector:Dot((myRoot.Position - targetRoot.Position).Unit)
					if distToTarget < 18 and enemyLookToMe < 0.25 then
						finalTargetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -6) + (targetRoot.CFrame.RightVector * (math.sin(t * 11) * 13))
					else
						local feint = Vector3.new(0, 0, 0)
						if distToTarget < 35 then
							if math.random(1, 100) > 92 then
								feint = targetRoot.CFrame.RightVector * (math.random(1, 2) == 1 and 18 or -18)
							elseif math.random(1, 100) > 94 then
								feint = targetRoot.CFrame.LookVector * -16
							end
						end
						finalTargetPos = finalTargetPos + feint
					end

					local radarDirections = {
						myRoot.CFrame.LookVector,
						myRoot.CFrame.RightVector,
						-myRoot.CFrame.RightVector,
						(myRoot.CFrame.LookVector + myRoot.CFrame.RightVector).Unit,
						(myRoot.CFrame.LookVector - myRoot.CFrame.RightVector).Unit
					}
					local rayParamsRadar = RaycastParams.new()
					rayParamsRadar.FilterDescendantsInstances = {myChar, botTarget.Character}
					rayParamsRadar.FilterType = Enum.RaycastFilterType.Exclude

					local avoidVector = Vector3.new()
					local bestGapDir = nil
					local maxGapDist = 0

					for _, dir in ipairs(radarDirections) do
						local castRes = Workspace:Raycast(myRoot.Position, dir * 15, rayParamsRadar)
						if castRes then
							if castRes.Distance < 7 then
								avoidVector = avoidVector - (dir * (7 - castRes.Distance))
							end
						else
							if 15 > maxGapDist then
								maxGapDist = 15
								bestGapDir = dir
							end
						end
					end

					if avoidVector.Magnitude > 0 then
						finalTargetPos = finalTargetPos + avoidVector * 2
					end

					if bestGapDir and math.random(1, 100) > 50 then
						finalTargetPos = finalTargetPos + bestGapDir * 4
					end

					if not IsVisible(botTarget, targetRoot) then
						if t - lastPeekJump > 0.45 then
							local startPos = myRoot.Position + Vector3.new(0, 6.5, 0)
							local castPoints = {startPos, targetRoot.Position}
							local ignoreList = {myChar, botTarget.Character}
							local parts = Camera:GetPartsObscuringTarget(castPoints, ignoreList)
							if #parts == 0 then
								myHum.Jump = true
								lastPeekJump = t
							end
						end
					end
				end

				if (myRoot.Position - lastPosition).Magnitude < 0.15 then
					stuckTime = stuckTime + 0.015
					if stuckTime > 0.4 then
						BotBlacklist[botTarget] = tick() + 5
						stuckTime = 0
						lastPathComputed = 0
						CurrentTarget = nil
					end
				else
					stuckTime = 0
				end
				lastPosition = myRoot.Position

				if tick() - lastPathComputed > 0.25 then
					lastPathComputed = tick()
					task.spawn(function()
						local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
						path:ComputeAsync(myRoot.Position, finalTargetPos)
						if path.Status == Enum.PathStatus.Success then
							currentWaypoints = path:GetWaypoints()
							currentWaypointIndex = 2
						else
							currentWaypoints = {}
						end
					end)
				end

				local rayDirection = myRoot.CFrame.LookVector * 4
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {myChar}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				local legBlock = Workspace:Raycast(myRoot.Position - Vector3.new(0, 1.5, 0), rayDirection, rayParams)
				local headBlock = Workspace:Raycast(myRoot.Position + Vector3.new(0, 1.5, 0), rayDirection, rayParams)

				if legBlock and not headBlock and currentStyle ~= "Mythic" then
					myHum.Jump = true
				end

				if #currentWaypoints > 0 and currentWaypointIndex <= #currentWaypoints then
					local currentWaypoint = currentWaypoints[currentWaypointIndex]
					local waypointPos = currentWaypoint.Position
					if (myRoot.Position - waypointPos).Magnitude < 4 then
						currentWaypointIndex = currentWaypointIndex + 1
					end
					if currentWaypointIndex <= #currentWaypoints then
						local nextWaypoint = currentWaypoints[currentWaypointIndex]
						myHum:MoveTo(nextWaypoint.Position)
						local nextDistY = nextWaypoint.Position.Y - myRoot.Position.Y
						local frontBlockage = Workspace:Raycast(myRoot.Position - Vector3.new(0, 1, 0), rayDirection, rayParams)
						if currentStyle == "Mythic" then
							if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
								myHum.Jump = true
							end
						else
							if nextWaypoint.Action == Enum.PathWaypointAction.Jump or nextDistY > 2 or frontBlockage then
								myHum.Jump = true
							end
						end
					end
				else
					myHum:MoveTo(finalTargetPos)
					if currentStyle ~= "Mythic" then
						local closeBlockage = Workspace:Raycast(myRoot.Position - Vector3.new(0, 1, 0), rayDirection, rayParams)
						if closeBlockage then
							myHum.Jump = true
						end
					end
				end

				local lookDirection = myRoot.CFrame.LookVector
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {myChar}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local ladderCheckResult = Workspace:Raycast(myRoot.Position, lookDirection * 2.5, raycastParams)
				local isLadderPart = false
				if ladderCheckResult and ladderCheckResult.Instance then
					local hitObj = ladderCheckResult.Instance
					if hitObj:IsA("TrussPart") or string.find(string.lower(hitObj.Name), "ladder") or string.find(string.lower(hitObj.Name), "tangga") then
						isLadderPart = true
					end
				end
				if myHum:GetState() == Enum.HumanoidStateType.Climbing or isLadderPart then
					myHum:ChangeState(Enum.HumanoidStateType.Climbing)
					myHum:Move(Vector3.new(0, 1, 0.1), true)
				end
			end
		end
	end

	local tracerSelection = Options.TracerOrigin and Options.TracerOrigin.Value or "Bottom"
	local tracerFromPos = CrosshairPosition
	if tracerSelection == "Top" then
		tracerFromPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
	elseif tracerSelection == "Center" then
		tracerFromPos = CrosshairPosition
	elseif tracerSelection == "Bottom" then
		tracerFromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	end

	for _, player in pairs(validTargets) do
		if IsAlive(player) and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local hum = player.Character.Humanoid
			local distance = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
			if distance <= maxDistance then
				local rootCFrame = root.CFrame
				local topPos, topOn = Camera:WorldToViewportPoint((rootCFrame * CFrame.new(0, 3.2, 0)).Position)
				local botPos, botOn = Camera:WorldToViewportPoint((rootCFrame * CFrame.new(0, -3.6, 0)).Position)
				local onScreen = topOn or botOn

				if useBackup then
					if ESP_Cache[player] then
						for _, obj in pairs(ESP_Cache[player]) do
							if type(obj) == "table" then
								for _, line in pairs(obj) do
									line.Visible = false
								end
							else
								obj.Visible = false
							end
						end
					end
					CreateBackupESP(player)
					local b = Backup_Cache[player]
					if b then
						b.Gui.Enabled = onScreen
						b.Gui.Adornee = root
						b.Box.Visible = Toggles.TwoDBox.Value
						b.Box.BorderColor3 = color
						b.Box.BorderSizePixel = thickness
						b.Name.Visible = Toggles.Name.Value
						b.Name.Text = player.Name
						b.Name.TextColor3 = color
						b.Health.Visible = Toggles.HealthNumber.Value
						b.Health.Text = "[" .. tostring(math.floor(hum.Health)) .. "]"
						b.Distance.Visible = Toggles.Distance.Value
						b.Distance.Text = tostring(distance) .. " studs"
						b.Distance.TextColor3 = color
						b.Box3D.Visible = Toggles.ThreeDBox.Value
						b.Box3D.Adornee = player.Character
						b.Box3D.Color3 = color
						b.Box3D.LineThickness = thickness
						b.Highlight.Enabled = Toggles.Highlight.Value
						b.Highlight.Adornee = player.Character
						b.Highlight.FillColor = color
						b.Highlight.OutlineColor = color
					end
				else
					if Backup_Cache[player] then
						if Backup_Cache[player].Gui then Backup_Cache[player].Gui.Enabled = false end
						if Backup_Cache[player].Box3D then Backup_Cache[player].Box3D.Visible = false end
						if Backup_Cache[player].Highlight then Backup_Cache[player].Highlight.Enabled = false end
					end
					CreateDrawingESP(player)
					local d = ESP_Cache[player]
					if d and onScreen then
						local height = math.abs(topPos.Y - botPos.Y)
						local width = height * 0.60
						local xPos = topPos.X - (width / 2)
						local yPos = topPos.Y

						d.Box.Visible = Toggles.TwoDBox.Value
						d.Box.Size = Vector2.new(width, height)
						d.Box.Position = Vector2.new(xPos, yPos)
						d.Box.Color = color
						d.Box.Thickness = thickness
						d.Box.Filled = false

						d.Tracer.Visible = Toggles.Tracers.Value
						d.Tracer.From = tracerFromPos
						d.Tracer.To = Vector2.new(topPos.X, botPos.Y - (height/2))
						d.Tracer.Color = color
						d.Tracer.Thickness = thickness

						d.Name.Visible = Toggles.Name.Value
						d.Name.Text = player.Name
						d.Name.Position = Vector2.new(topPos.X, yPos - 16)
						d.Name.Color = color

						d.Health.Visible = Toggles.HealthNumber.Value
						d.Health.Text = tostring(math.floor(hum.Health))
						d.Health.Position = Vector2.new(xPos - 25, yPos + (height / 2) - 7)
						d.Health.Color = Color3.fromRGB(160, 30, 255)

						d.Distance.Visible = Toggles.Distance.Value
						d.Distance.Text = tostring(distance) .. " studs"
						d.Distance.Position = Vector2.new(topPos.X, yPos + height + 4)
						d.Distance.Color = color

						local skeletonLinesUsed = 0
						if Toggles.Skeleton.Value then
							local char = player.Character
							local connections = {
								{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
								{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
								{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
								{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
								{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
								{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
							}
							for _, pair in ipairs(connections) do
								local part1 = char:FindFirstChild(pair[1])
								local part2 = char:FindFirstChild(pair[2])
								if part1 and part2 then
									local p1Pos, p1On = Camera:WorldToViewportPoint(part1.Position)
									local p2Pos, p2On = Camera:WorldToViewportPoint(part2.Position)
									if p1On or p2On then
										skeletonLinesUsed = skeletonLinesUsed + 1
										local line = d.Skeleton[skeletonLinesUsed]
										if line then
											line.From = Vector2.new(p1Pos.X, p1Pos.Y)
											line.To = Vector2.new(p2Pos.X, p2Pos.Y)
											line.Color = color
											line.Thickness = thickness
											line.Visible = true
										end
									end
								end
							end
						end
						for i = skeletonLinesUsed + 1, #d.Skeleton do
							d.Skeleton[i].Visible = false
						end

						CreateBackupESP(player)
						if Backup_Cache[player] then
							Backup_Cache[player].Highlight.Enabled = Toggles.Highlight.Value
							Backup_Cache[player].Highlight.FillColor = color
							Backup_Cache[player].Highlight.OutlineColor = color
							Backup_Cache[player].Box3D.Visible = Toggles.ThreeDBox.Value
							Backup_Cache[player].Box3D.Color3 = color
						end
					else
						if d then
							d.Box.Visible = false
							d.Tracer.Visible = false
							d.Name.Visible = false
							d.Health.Visible = false
							d.Distance.Visible = false
							for _, line in pairs(d.Skeleton) do
								line.Visible = false
							end
						end
					end
				end
			else
				RemoveESP(player)
			end
		else
			RemoveESP(player)
			PlayerRerolls[player.UserId] = nil
			ChosenParts[player.UserId] = nil
		end
	end

	if Toggles.AimbotToggle.Value and myAlive then
		if CurrentTarget and not ValidateTarget(CurrentTarget) then
			PlayerRerolls[CurrentTarget.UserId] = nil
			ChosenParts[CurrentTarget.UserId] = nil
			CurrentTarget = nil
		end

		if not CurrentTarget then
			CurrentTarget = GetClosestPlayer()
		end

		if CurrentTarget and IsAlive(CurrentTarget) then
			local targetPart = GetBestPart(CurrentTarget, Options.AutoLookPart.Value)
			if targetPart and IsVisible(CurrentTarget, targetPart) then
				local finalTargetPos = targetPart.Position
				if Toggles.AimPrediction.Value then
					local targetVelocity = Vector3.new()
					pcall(function()
						if targetPart:IsA("BasePart") then
							targetVelocity = targetPart.AssemblyLinearVelocity
						end
					end)
					finalTargetPos = finalTargetPos + (targetVelocity * (Options.PredictionVelocity.Value / 10))
				end

				local targetCFrame = CFrame.new(Camera.CFrame.Position, finalTargetPos)
				local smoothness = Options.AimbotSmoothness.Value
				if smoothness > 0 then
					Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / (smoothness + 1))
				else
					Camera.CFrame = targetCFrame
				end

				if Toggles.TriggerBot and Toggles.TriggerBot.Value then
					local currentDelay = Options.TriggerClickDelay and Options.TriggerClickDelay.Value or 100
					if tick() - lastClickTime >= (currentDelay / 1000) then
						lastClickTime = tick()
						local screenPoint, visible = Camera:WorldToViewportPoint(targetPart.Position)
						if visible then
							VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, true, game, 0)
							task.wait()
							VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, false, game, 0)
						end
					end
				end

				if Toggles.ShowTargetUI.Value then
					local displayedPartName = (targetPart.Name == "HumanoidRootPart") and "Body" or targetPart.Name
					local tHum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
					local health = tHum and tHum.Health or 0
					local maxHealth = tHum and tHum.MaxHealth or 100

					TargetName.Text = CurrentTarget.Name
					TargetExtra.Text = "Target: " .. displayedPartName .. " | Dist: " .. math.floor((Camera.CFrame.Position - targetPart.Position).Magnitude) .. "s"
					HealthBarFill.Size = UDim2.new(math.clamp(health / maxHealth, 0, 1), 0, 1, 0)
					TargetInfoFrame.Visible = true
				else
					TargetInfoFrame.Visible = false
				end
			else
				TargetInfoFrame.Visible = false
			end
		else
			TargetInfoFrame.Visible = false
		end
	else
		CurrentTarget = nil
		TargetInfoFrame.Visible = false
	end
end)

Players.PlayerRemoving:Connect(function(player)
	RemoveESP(player)
	PlayerRerolls[player.UserId] = nil
	ChosenParts[player.UserId] = nil
	BotBlacklist[player] = nil
end)
