-- ============================================================
--   Godz Hub | Booga Booga Reborn
--   WindUI-based script hub
-- ============================================================

local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")

local cloneref = (cloneref or clonereference or function(i) return i end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService       = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- Load WindUI
-- ============================================================
local WindUI
do
	local ok, result = pcall(function() return require("./src/Init") end)
	if ok then
		WindUI = result
	else
		if cloneref(RunService):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

-- ============================================================
-- Load Godz Hub backend
-- ============================================================
local GodzHub = nil
pcall(function()
	GodzHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/boogag0dz-glitch/Godz-hub/main/main.lua"))()
end)

-- ============================================================
-- Global State Table
-- ============================================================
_G.GH = {
	-- Autofarm
	AutofarmEnabled    = false,
	AutoCollectEnabled = false,
	-- Pathfinding
	PathfindEnabled    = false,
	PathfindTarget     = nil,
	PathfindInterval   = 1,
	-- Speed
	SpeedLockEnabled   = false,
	LockedSpeed        = 16,
	LockedJump         = 50,
	-- ESP
	ESPEnabled         = false,
	MobESPEnabled      = false,
	NameTagsEnabled    = false,
	ChamsEnabled       = false,
	ESPFillColor       = Color3.fromRGB(255, 50, 50),
	ESPOutlineColor    = Color3.fromRGB(255, 255, 255),
	ESPHighlights      = {},
}

-- ============================================================
-- Helpers
-- ============================================================
local function notify(title, content, duration)
	WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

local function getChar()
	return LocalPlayer.Character
end

local function getHumanoid()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function applySpeed(speed, jump)
	local hum = getHumanoid()
	if hum then
		if speed then hum.WalkSpeed = speed end
		if jump  then hum.JumpPower = jump  end
	end
end

-- Re-apply speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if _G.GH.SpeedLockEnabled then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = _G.GH.LockedSpeed
			hum.JumpPower = _G.GH.LockedJump
		end
	end
end)

-- ============================================================
-- AUTOFARM CORE
-- ============================================================
local function autofarmLoop()
	while _G.GH.AutofarmEnabled do
		local root = getRoot()
		local hum  = getHumanoid()
		if root and hum then
			local nearest, nearestDist, nearestPrompt = nil, math.huge, nil
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					local part = obj.Parent
					if part and part:IsA("BasePart") then
						local dist = (root.Position - part.Position).Magnitude
						if dist < nearestDist then
							nearest       = part
							nearestDist   = dist
							nearestPrompt = obj
						end
					end
				end
			end
			if nearestPrompt then
				local maxDist = nearestPrompt.MaxActivationDistance or 10
				if nearestDist > maxDist then
					hum:MoveTo(nearest.Position)
					local moved, conn = false, nil
					conn = hum.MoveToFinished:Connect(function()
						moved = true
						conn:Disconnect()
					end)
					local t = tick()
					while not moved and tick() - t < 5 do task.wait(0.1) end
					if conn then pcall(function() conn:Disconnect() end) end
				end
				pcall(function() fireproximityprompt(nearestPrompt) end)
			end
		end
		task.wait(0.6)
	end
end

-- ============================================================
-- AUTO COLLECT DROPS CORE
-- ============================================================
local function autoCollectLoop()
	while _G.GH.AutoCollectEnabled do
		local root = getRoot()
		if root then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					local n = obj.Name:lower()
					if n:find("drop") or n:find("item") or n:find("pickup") or n:find("loot") then
						local dist = (root.Position - obj.Position).Magnitude
						if dist < 30 then
							root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
							task.wait(0.05)
						end
					end
				end
			end
		end
		task.wait(0.4)
	end
end

-- ============================================================
-- PATHFINDING CORE
-- ============================================================
local function pathfindLoop()
	while _G.GH.PathfindEnabled do
		local target  = _G.GH.PathfindTarget and Players:FindFirstChild(_G.GH.PathfindTarget)
		local myRoot  = getRoot()
		local hum     = getHumanoid()

		if target and target.Character and myRoot and hum then
			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				if dist > 5 then
					local path = PathfindingService:CreatePath({
						AgentHeight    = 5,
						AgentRadius    = 2,
						AgentCanJump   = true,
						AgentCanClimb  = true,
						WaypointSpacing = 4,
					})

					local ok = pcall(function()
						path:ComputeAsync(myRoot.Position, targetRoot.Position)
					end)

					if ok and path.Status == Enum.PathStatus.Success then
						for _, wp in ipairs(path:GetWaypoints()) do
							if not _G.GH.PathfindEnabled then break end
							if not (target.Character and target.Character:FindFirstChild("HumanoidRootPart")) then break end

							hum:MoveTo(wp.Position)
							if wp.Action == Enum.PathWaypointAction.Jump then
								hum.Jump = true
							end

							local moved, conn = false, nil
							conn = hum.MoveToFinished:Connect(function()
								moved = true
								conn:Disconnect()
							end)
							local t0 = tick()
							while not moved and tick() - t0 < 2 do task.wait(0.1) end
							if conn then pcall(function() conn:Disconnect() end) end
						end
					end
				end
			end
		end

		task.wait(_G.GH.PathfindInterval)
	end
end

-- ============================================================
-- ESP CORE
-- ============================================================
local function clearHighlightFor(player)
	local h = _G.GH.ESPHighlights[player.Name]
	if h and h.Parent then h:Destroy() end
	_G.GH.ESPHighlights[player.Name] = nil
end

local function addHighlight(player)
	if player == LocalPlayer then return end
	local char = player.Character
	if not char then return end
	if _G.GH.ESPHighlights[player.Name] and _G.GH.ESPHighlights[player.Name].Parent then return end

	local h = Instance.new("Highlight")
	h.FillColor           = _G.GH.ESPFillColor
	h.OutlineColor        = _G.GH.ESPOutlineColor
	h.FillTransparency    = 0.45
	h.OutlineTransparency = 0
	h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	h.Adornee             = char
	h.Parent              = char
	_G.GH.ESPHighlights[player.Name] = h
end

local function removeAllESP()
	for _, h in pairs(_G.GH.ESPHighlights) do
		if h and h.Parent then h:Destroy() end
	end
	_G.GH.ESPHighlights = {}
end

local function espLoop()
	while _G.GH.ESPEnabled do
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				if p.Character then
					addHighlight(p)
					local h = _G.GH.ESPHighlights[p.Name]
					if h and h.Parent then
						h.FillColor    = _G.GH.ESPFillColor
						h.OutlineColor = _G.GH.ESPOutlineColor
					end
				else
					clearHighlightFor(p)
				end
			end
		end
		task.wait(1.5)
	end
	removeAllESP()
end

Players.PlayerRemoving:Connect(function(p)
	clearHighlightFor(p)
end)

-- ============================================================
-- MOB ESP CORE
-- ============================================================
local function mobEspLoop()
	while _G.GH.MobESPEnabled do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not obj:FindFirstChildOfClass("Highlight") then
				local isPlayer = false
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Character == obj then isPlayer = true break end
				end
				if not isPlayer then
					local h = Instance.new("Highlight")
					h.FillColor           = Color3.fromRGB(255, 140, 0)
					h.OutlineColor        = Color3.fromRGB(255, 220, 0)
					h.FillTransparency    = 0.4
					h.OutlineTransparency = 0
					h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
					h.Adornee             = obj
					h.Parent              = obj
				end
			end
		end
		task.wait(3)
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			local h = obj:FindFirstChildOfClass("Highlight")
			if h then h:Destroy() end
		end
	end
end

-- ============================================================
-- NAME TAGS CORE
-- ============================================================
local function addNameTag(player)
	if player == LocalPlayer then return end
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head or head:FindFirstChild("GH_NameTag") then return end

	local bb = Instance.new("BillboardGui")
	bb.Name        = "GH_NameTag"
	bb.Size        = UDim2.new(0, 130, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent      = head

	local frame = Instance.new("Frame")
	frame.Size                   = UDim2.new(1, 0, 0.75, 0)
	frame.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel        = 0
	frame.Parent                 = bb

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size                   = UDim2.new(1, -8, 1, 0)
	label.Position               = UDim2.new(0, 4, 0, 0)
	label.BackgroundTransparency = 1
	label.Text                   = player.Name
	label.TextColor3             = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.5
	label.Font                   = Enum.Font.GothamBold
	label.TextScaled             = true
	label.Parent                 = frame

	-- Health bar background
	local hbBg = Instance.new("Frame")
	hbBg.Size                   = UDim2.new(1, 0, 0.2, 0)
	hbBg.Position               = UDim2.new(0, 0, 0.8, 0)
	hbBg.BackgroundColor3       = Color3.fromRGB(60, 0, 0)
	hbBg.BackgroundTransparency = 0
	hbBg.BorderSizePixel        = 0
	hbBg.Parent                 = bb
	Instance.new("UICorner", hbBg).CornerRadius = UDim.new(0, 4)

	-- Health bar fill
	local hbFill = Instance.new("Frame")
	hbFill.Size                   = UDim2.new(1, 0, 1, 0)
	hbFill.BackgroundColor3       = Color3.fromRGB(50, 205, 50)
	hbFill.BackgroundTransparency = 0
	hbFill.BorderSizePixel        = 0
	hbFill.Parent                 = hbBg
	Instance.new("UICorner", hbFill).CornerRadius = UDim.new(0, 4)

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local function updateBar()
			local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			hbFill.Size = UDim2.new(pct, 0, 1, 0)
			hbFill.BackgroundColor3 = pct > 0.5
				and Color3.fromRGB(50, 205, 50)
				or  Color3.fromRGB(220, 60, 60)
		end
		updateBar()
		hum:GetPropertyChangedSignal("Health"):Connect(updateBar)
	end
end

local function removeAllNameTags()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head then
				local tag = head:FindFirstChild("GH_NameTag")
				if tag then tag:Destroy() end
			end
		end
	end
end

local function nameTagLoop()
	while _G.GH.NameTagsEnabled do
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then addNameTag(p) end
		end
		task.wait(2)
	end
	removeAllNameTags()
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
local Window = WindUI:CreateWindow({
	Title         = "Godz Hub  |  Booga Booga Reborn",
	Folder        = "GodzHub",
	Icon          = "solar:folder-2-bold-duotone",
	NewElements   = true,
	HideSearchBar = false,
	OpenButton = {
		Title           = "Godz Hub",
		CornerRadius    = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled         = true,
		Draggable       = true,
		OnlyMobile      = false,
		Scale           = 0.5,
		Color = ColorSequence.new(
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height      = 44,
		ButtonsType = "Mac",
	},
})

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green  = Color3.fromHex("#10C550")
local Grey   = Color3.fromHex("#83889E")
local Blue   = Color3.fromHex("#257AF7")
local Red    = Color3.fromHex("#EF4F1D")

local BoogaSection = Window:Section({ Title = "Booga Booga Reborn" })

-- ============================================================
-- TAB: AUTOFARM
-- ============================================================
local AutofarmTab = BoogaSection:Tab({
	Title     = "Autofarm",
	Icon      = "solar:check-square-bold",
	IconColor = Green,
	IconShape = "Square",
	Border    = true,
})

do
	AutofarmTab:Section({ Title = "Resource Farming" })

	AutofarmTab:Toggle({
		Title = "Enable Autofarm",
		Desc  = "Scans workspace for the nearest ProximityPrompt. Walks to it if out of range, then fires it automatically.",
		Value = false,
		Callback = function(state)
			_G.GH.AutofarmEnabled = state
			if state then task.spawn(autofarmLoop) end
			notify("Autofarm", state and "Autofarm started!" or "Autofarm stopped.")
		end,
	})

	AutofarmTab:Space()

	AutofarmTab:Toggle({
		Title = "Auto Collect Drops",
		Desc  = "Scans for dropped items (named Drop/Item/Pickup/Loot) within 30 studs and teleports your character to them.",
		Value = false,
		Callback = function(state)
			_G.GH.AutoCollectEnabled = state
			if state then task.spawn(autoCollectLoop) end
			notify("Auto Collect", state and "Now collecting drops!" or "Stopped collecting drops.")
		end,
	})

	AutofarmTab:Space()

	AutofarmTab:Section({ Title = "Info" })

	AutofarmTab:Paragraph({
		Title = "How Autofarm Works",
		Desc  = "The autofarm finds the nearest ProximityPrompt in the entire workspace every 0.6 seconds. If it is further than its MaxActivationDistance, your character walks to it first using Humanoid:MoveTo(), then fires it with fireproximityprompt().",
	})

	AutofarmTab:Space()

	AutofarmTab:Paragraph({
		Title = "How Auto Collect Works",
		Desc  = "Every 0.4 seconds, the script searches for BaseParts whose name contains 'drop', 'item', 'pickup', or 'loot' within 30 studs of your character and teleports you directly on top of them to trigger pickup.",
	})

	AutofarmTab:Space()

	AutofarmTab:Section({ Title = "Manual Controls" })

	AutofarmTab:Button({
		Title   = "Manual Farm Trigger",
		Desc    = "Fires a single farm cycle right now regardless of whether autofarm is toggled on.",
		Icon    = "star",
		Justify = "Center",
		Callback = function()
			local root = getRoot()
			if not root then notify("Error", "No character found.") return end
			local nearest, nearestDist, nearestPrompt = nil, math.huge, nil
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					local part = obj.Parent
					if part and part:IsA("BasePart") then
						local dist = (root.Position - part.Position).Magnitude
						if dist < nearestDist then
							nearest       = part
							nearestDist   = dist
							nearestPrompt = obj
						end
					end
				end
			end
			if nearestPrompt then
				pcall(function() fireproximityprompt(nearestPrompt) end)
				notify("Manual Farm", "Triggered prompt " .. math.floor(nearestDist) .. " studs away.")
			else
				notify("Manual Farm", "No ProximityPrompt found nearby.")
			end
		end,
	})
end

-- ============================================================
-- TAB: PATHFINDING
-- ============================================================
local PathfindTab = BoogaSection:Tab({
	Title     = "Pathfinding",
	Icon      = "solar:cursor-square-bold",
	IconColor = Blue,
	IconShape = "Square",
	Border    = true,
})

do
	PathfindTab:Section({ Title = "Player-Controlled Pathfinding" })

	PathfindTab:Paragraph({
		Title = "How to Use",
		Desc  = "1) Select a player from the dropdown below.\n2) Adjust the recalculation interval if needed.\n3) Flip the Enable Pathfinding toggle. Your character will continuously walk toward the selected player using Roblox PathfindingService, jumping over obstacles automatically.\n4) Use Teleport to Target for an instant warp instead.",
	})

	PathfindTab:Space()

	local function getPlayerNames()
		local names = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then table.insert(names, p.Name) end
		end
		return names
	end

	local PathDropdown = PathfindTab:Dropdown({
		Title     = "Target Player",
		Desc      = "The player your character will walk toward",
		Values    = getPlayerNames(),
		AllowNone = true,
		Callback  = function(value)
			_G.GH.PathfindTarget = value
		end,
	})

	PathfindTab:Space()

	PathfindTab:Button({
		Title   = "Refresh Player List",
		Icon    = "refresh-cw",
		Justify = "Center",
		Desc    = "Updates the dropdown with players currently in the server.",
		Callback = function()
			PathDropdown:Refresh(getPlayerNames())
			notify("Pathfinding", "Player list refreshed.")
		end,
	})

	PathfindTab:Space()

	PathfindTab:Section({ Title = "Settings" })

	PathfindTab:Slider({
		Title = "Recalculation Interval (seconds)",
		Desc  = "How often the path is recomputed. Lower values are more responsive but heavier on performance.",
		Step  = 0.5,
		Value = { Min = 0.5, Max = 6, Default = 1 },
		Callback = function(value)
			_G.GH.PathfindInterval = value
		end,
	})

	PathfindTab:Space()

	PathfindTab:Toggle({
		Title = "Enable Pathfinding",
		Desc  = "Start continuously walking toward the selected player.",
		Value = false,
		Callback = function(state)
			_G.GH.PathfindEnabled = state
			if state then
				if not _G.GH.PathfindTarget then
					_G.GH.PathfindEnabled = false
					notify("Pathfinding", "Select a target player first!")
					return
				end
				task.spawn(pathfindLoop)
				notify("Pathfinding", "Now following: " .. _G.GH.PathfindTarget)
			else
				local hum = getHumanoid()
				local root = getRoot()
				if hum and root then hum:MoveTo(root.Position) end
				notify("Pathfinding", "Pathfinding stopped.")
			end
		end,
	})

	PathfindTab:Space()

	PathfindTab:Section({ Title = "Instant Teleport" })

	PathfindTab:Paragraph({
		Title = "Teleport to Target",
		Desc  = "Skips the pathfinding walk entirely and instantly warps your character directly behind the selected player.",
	})

	PathfindTab:Space()

	PathfindTab:Button({
		Title   = "Teleport to Target",
		Desc    = "Instantly warps you to the selected player. No walking required.",
		Icon    = "zap",
		Justify = "Center",
		Color   = Color3.fromHex("#305dff"),
		Callback = function()
			local target = _G.GH.PathfindTarget and Players:FindFirstChild(_G.GH.PathfindTarget)
			if not target then notify("Teleport", "No target selected or player not found.") return end
			local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			local myRoot     = getRoot()
			if targetRoot and myRoot then
				myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
				notify("Teleport", "Teleported to " .. target.Name .. "!")
			else
				notify("Teleport", "Target or your character not loaded.")
			end
		end,
	})
end

-- ============================================================
-- TAB: SPEED
-- ============================================================
local SpeedTab = BoogaSection:Tab({
	Title     = "Speed",
	Icon      = "solar:square-transfer-horizontal-bold",
	IconColor = Yellow,
	IconShape = "Square",
	Border    = true,
})

do
	SpeedTab:Section({ Title = "Walk Speed" })

	SpeedTab:Paragraph({
		Title = "Speed Info",
		Desc  = "Default Roblox WalkSpeed is 16. The slider is capped at 21 to keep movement natural in Booga Booga Reborn. Toggle Speed Lock to keep your speed after respawning.",
	})

	SpeedTab:Space()

	SpeedTab:Slider({
		Title = "Walk Speed",
		Desc  = "Slide to adjust how fast your character walks. Default is 16.",
		Step  = 1,
		Value = { Min = 1, Max = 21, Default = 16 },
		Callback = function(value)
			_G.GH.LockedSpeed = value
			applySpeed(value, nil)
		end,
	})

	SpeedTab:Space()

	SpeedTab:Section({ Title = "Jump Power" })

	SpeedTab:Slider({
		Title = "Jump Power",
		Desc  = "Slide to adjust your character's jump height. Default is 50.",
		Step  = 1,
		Value = { Min = 1, Max = 200, Default = 50 },
		Callback = function(value)
			_G.GH.LockedJump = value
			applySpeed(nil, value)
		end,
	})

	SpeedTab:Space()

	SpeedTab:Section({ Title = "Persistence" })

	SpeedTab:Toggle({
		Title = "Speed Lock (Keep on Respawn)",
		Desc  = "Re-applies your WalkSpeed and JumpPower every time your character respawns.",
		Value = false,
		Callback = function(state)
			_G.GH.SpeedLockEnabled = state
			notify("Speed Lock", state and "Speed will persist on respawn." or "Speed lock disabled.")
		end,
	})

	SpeedTab:Space()

	SpeedTab:Section({ Title = "Quick Presets" })

	local SpeedGroup = SpeedTab:Group({})

	SpeedGroup:Button({
		Title   = "Default",
		Desc    = "WalkSpeed 16 / Jump 50",
		Justify = "Center",
		Icon    = "",
		Callback = function()
			_G.GH.LockedSpeed = 16
			_G.GH.LockedJump  = 50
			applySpeed(16, 50)
			notify("Speed", "Reset to default (16 / 50).")
		end,
	})

	SpeedGroup:Space()

	SpeedGroup:Button({
		Title   = "Max Speed",
		Desc    = "WalkSpeed 21",
		Color   = Color3.fromHex("#30ff6a"),
		Justify = "Center",
		Icon    = "",
		Callback = function()
			_G.GH.LockedSpeed = 21
			applySpeed(21, nil)
			notify("Speed", "Walk speed set to 21.")
		end,
	})

	SpeedGroup:Space()

	SpeedGroup:Button({
		Title   = "High Jump",
		Desc    = "JumpPower 120",
		Color   = Color3.fromHex("#305dff"),
		Justify = "Center",
		Icon    = "",
		Callback = function()
			_G.GH.LockedJump = 120
			applySpeed(nil, 120)
			notify("Speed", "Jump power set to 120.")
		end,
	})

	SpeedTab:Space()

	SpeedTab:Button({
		Title   = "Reset All Speed Settings",
		Desc    = "Sets WalkSpeed back to 16 and JumpPower back to 50.",
		Icon    = "refresh-cw",
		Color   = Color3.fromHex("#ff4830"),
		Justify = "Center",
		Callback = function()
			_G.GH.LockedSpeed = 16
			_G.GH.LockedJump  = 50
			applySpeed(16, 50)
			notify("Speed", "All speed settings reset to default.")
		end,
	})
end

-- ============================================================
-- TAB: ESP
-- ============================================================
local EspTab = BoogaSection:Tab({
	Title     = "ESP",
	Icon      = "solar:info-square-bold",
	IconColor = Red,
	IconShape = "Square",
	Border    = true,
})

do
	EspTab:Section({ Title = "Player ESP" })

	EspTab:Toggle({
		Title = "Player Highlight ESP",
		Desc  = "Renders a colored Highlight on every player character, visible through walls at all times.",
		Value = false,
		Callback = function(state)
			_G.GH.ESPEnabled = state
			if state then
				task.spawn(espLoop)
			else
				removeAllESP()
			end
			notify("ESP", state and "Player ESP enabled!" or "Player ESP disabled.")
		end,
	})

	EspTab:Space()

	EspTab:Colorpicker({
		Title   = "ESP Fill Color",
		Desc    = "The fill/body color of the player highlights.",
		Default = Color3.fromRGB(255, 50, 50),
		Callback = function(color)
			_G.GH.ESPFillColor = color
			for _, h in pairs(_G.GH.ESPHighlights) do
				if h and h.Parent then h.FillColor = color end
			end
		end,
	})

	EspTab:Space()

	EspTab:Colorpicker({
		Title   = "ESP Outline Color",
		Desc    = "The outline/border color of the player highlights.",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			_G.GH.ESPOutlineColor = color
			for _, h in pairs(_G.GH.ESPHighlights) do
				if h and h.Parent then h.OutlineColor = color end
			end
		end,
	})

	EspTab:Space()

	EspTab:Section({ Title = "Mob / Entity ESP" })

	EspTab:Toggle({
		Title = "Mob Highlight ESP",
		Desc  = "Highlights all NPC and mob models that have a Humanoid in orange/yellow.",
		Value = false,
		Callback = function(state)
			_G.GH.MobESPEnabled = state
			if state then task.spawn(mobEspLoop) end
			notify("Mob ESP", state and "Mob ESP enabled!" or "Mob ESP disabled.")
		end,
	})

	EspTab:Space()

	EspTab:Section({ Title = "Name Tags" })

	EspTab:Toggle({
		Title = "Player Name Tags",
		Desc  = "Shows a stylized BillboardGui name tag above every player's head, including a live health bar that changes color based on HP percentage.",
		Value = false,
		Callback = function(state)
			_G.GH.NameTagsEnabled = state
			if state then
				task.spawn(nameTagLoop)
			else
				removeAllNameTags()
			end
			notify("Name Tags", state and "Name tags enabled!" or "Name tags disabled.")
		end,
	})

	EspTab:Space()

	EspTab:Section({ Title = "Chams" })

	EspTab:Toggle({
		Title = "Force Transparency (Chams)",
		Desc  = "Makes all enemy character parts 40% transparent so you can see and track them through thin surfaces and terrain.",
		Value = false,
		Callback = function(state)
			_G.GH.ChamsEnabled = state
			task.spawn(function()
				while _G.GH.ChamsEnabled do
					for _, p in ipairs(Players:GetPlayers()) do
						if p ~= LocalPlayer and p.Character then
							for _, part in ipairs(p.Character:GetDescendants()) do
								if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
									part.LocalTransparencyModifier = 0.4
								end
							end
						end
					end
					task.wait(0.5)
				end
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						for _, part in ipairs(p.Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.LocalTransparencyModifier = 0
							end
						end
					end
				end
			end)
			notify("Chams", state and "Chams enabled!" or "Chams disabled.")
		end,
	})

	EspTab:Space()

	EspTab:Section({ Title = "Cleanup" })

	EspTab:Button({
		Title   = "Remove All ESP & Visuals",
		Desc    = "Disables and clears every ESP highlight, name tag, and cham effect immediately.",
		Icon    = "trash",
		Color   = Color3.fromHex("#ff4830"),
		Justify = "Center",
		Callback = function()
			_G.GH.ESPEnabled      = false
			_G.GH.MobESPEnabled   = false
			_G.GH.NameTagsEnabled = false
			_G.GH.ChamsEnabled    = false
			removeAllESP()
			removeAllNameTags()
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end
			end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					for _, part in ipairs(p.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.LocalTransparencyModifier = 0
						end
					end
				end
			end
			notify("ESP", "All visuals cleared.")
		end,
	})
end
