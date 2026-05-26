-- Cherry Blossom Hub | Booga Booga Reborn

local ok, WindUI = pcall(function()
    if not loadstring then error("loadstring unavailable") end
    local source = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
    if not source or source == "" then error("HttpGet returned empty response") end
    return loadstring(source)()
end)
if not ok then warn("[CherryHub] WindUI failed:", tostring(WindUI)) return end
print("[CherryHub] WindUI loaded.")

local HttpService = game:GetService("HttpService")

local KeySystem = {
    FileName    = "CherryBlossomKeyV2.json",
    Discord     = "https://discord.gg/aaJfDTFu",
    Lootlabs   = "https://lootdest.org/s?dFqzcoYK",
    KeyLinks    = {
        "https://link-hub.net/5922287/4cjB3yH9UKrl",
        "https://link-target.net/5922287/Ua3l85mHsUrX",
        "https://link-center.net/5922287/AoMhDFSEPbpg",
        "https://link-hub.net/5922287/cOxXb3ZcMgJg",
        "https://link-center.net/5922287/4TDRS4HEPDHL",
    },
    KeysURL     = "https://raw.githubusercontent.com/boogag0dz-glitch/Godz-hub/refs/heads/main/keys.txt",
    ExpireHours = 24,
}

local function saveKey(key)
    if writefile then
        writefile(KeySystem.FileName, HttpService:JSONEncode({ key = key, time = os.time() }))
    end
end

local function loadKey()
    if isfile and isfile(KeySystem.FileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(KeySystem.FileName))
        end)
        if success and data.key and data.time then
            if (os.time() - data.time) < (KeySystem.ExpireHours * 3600) then
                return data.key
            end
        end
    end
    return nil
end

local function cleanKey(key)
    return tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function checkKey(inputKey)
    inputKey = cleanKey(inputKey)
    if inputKey == "" then return false end

    local url = KeySystem.KeysURL .. "?t=" .. tostring(os.time())
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not response then return false end

    for line in response:gmatch("[^\r\n]+") do
        if cleanKey(line) ~= "" and inputKey == cleanKey(line) then
            return true
        end
    end
    return false
end

local Verified = false
local SavedKey = loadKey()

if SavedKey and checkKey(SavedKey) then
    Verified = true
    WindUI:Notify({ Title = "Cherry Blossom", Content = "Auto verified saved key", Duration = 3 })
else
    local Window = WindUI:CreateWindow({
        Title = "Cherry Blossom Key System",
        Folder = "CherryKeys",
        Icon = "key",
        Topbar = { Height = 40 },
        Size = UDim2.fromOffset(520, 360),
        Transparent = true,
        Theme = "Dark",
    })

    local Tab = Window:Tab({ Title = "Verify", Icon = "shield" })
    Tab:Paragraph({ Title = "Verification Required", Desc = "Complete Linkvertise or Lootlabs then enter your key." })

    Tab:Button({
        Title = "Get Key (Lootlabs)",
        Callback = function()
            if setclipboard then setclipboard(KeySystem.Lootlabs) end
            WindUI:Notify({ Title = "Lootlabs", Content = "Link copied to clipboard", Duration = 3 })
        end,
    })

    Tab:Button({
        Title = "Get Key (Linkvertise)",
        Callback = function()
            local links = KeySystem.KeyLinks
            if not links or #links == 0 then
                WindUI:Notify({ Title = "Error", Content = "No key links found", Duration = 3 })
                return
            end

            local randomLink = links[math.random(1, #links)]
            if setclipboard then
                setclipboard(randomLink)
                WindUI:Notify({ Title = "Linkvertise", Content = "Random key link copied", Duration = 3 })
            else
                WindUI:Notify({ Title = "Clipboard Error", Content = randomLink, Duration = 8 })
            end
        end,
    })

    Tab:Button({
        Title = "Join Discord",
        Callback = function()
            if setclipboard then setclipboard(KeySystem.Discord) end
            WindUI:Notify({ Title = "Discord", Content = "Invite copied to clipboard", Duration = 3 })
        end,
    })

    local InputKey = ""
    Tab:Input({
        Title = "Enter Key",
        Placeholder = "Paste your key here",
        Callback = function(text) InputKey = text end,
    })

    Tab:Button({
        Title = "Verify Key",
        Callback = function()
            if checkKey(InputKey) then
                saveKey(InputKey)
                Verified = true
                WindUI:Notify({ Title = "Success", Content = "Key verified! Loading hub...", Duration = 3 })
                Window:Destroy()
            else
                WindUI:Notify({ Title = "Invalid", Content = "Wrong key", Duration = 3 })
            end
        end,
    })

    repeat task.wait() until Verified
end

print("[CherryHub] Verified, loading main script...")

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer

local packetsModule = ReplicatedStorage:WaitForChild("Modules", 30)
    and ReplicatedStorage.Modules:WaitForChild("Packets", 30)
if not packetsModule then
    warn("[Cherry Blossom Hub] Packets module not found.")
    return
end
local Packets = require(packetsModule)

local Blossom = {
    Pink   = Color3.fromRGB(255, 183, 197),
    Soft   = Color3.fromRGB(247, 198, 208),
    Light  = Color3.fromRGB(255, 209, 220),
    Green  = Color3.fromRGB(134, 239, 172),
    Blue   = Color3.fromRGB(147, 197, 253),
    Yellow = Color3.fromRGB(253, 224, 132),
    Red    = Color3.fromRGB(252, 165, 165),
    Purple = Color3.fromRGB(196, 181, 253),
}

local FRUIT_LIST = {
    "Bloodfruit","Fruitcake","Cooked Meat","Cooked Fish",
    "Berry","Cloudberry","Frostfruit","Blossom",
    "Mango","Watermelon","Orange","Lemon",
    "Apple","Strawberry","Bluefruit","Yellowfruit","Pinefruit",
}

local WALL_LIST = {
    "Wood Wall","Iron Wall","Stone Wall","Ice Wall",
    "Adurite Wall","Crystal Wall","Magnetite Wall",
    "Emerald Wall","Carrot Crystal Wall",
}

local PICKUP_ITEM_LIST = {
    "Log","Wood","Leaves","Stone","Ice Cubes","Obsidian","Rubble","Coal",
    "Iron","Silver","Gold","Crystal","Magnetite","Emerald","Adurite",
    "Uncut Iron","Uncut Silver","Uncut Gold","Uncut Crystal","Uncut Magnetite",
    "Uncut Emerald","Uncut Adurite","Carrot Crystal","Ice Crystal",
    "Berry","Bloodfruit","Cloudberry","Frostfruit","Blossom","Mango",
    "Watermelon","Orange","Lemon","Apple","Strawberry","Bluefruit",
    "Yellowfruit","Pinefruit","Fruitcake",
    "Raw Meat","Cooked Meat","Raw Fish","Cooked Fish",
    "Bone","Wool","Feather","Egg","Honey","Milk","Hide","Leather",
    "Rock","Club","Mace","Spear","Battle Axe","Bow","Arrow","Crossbow",
    "Wood Axe","Wood Pick","Stone Axe","Stone Pick","Iron Axe","Iron Pick",
    "Coin","Coins","Spirit","Bag","Leaf Bag","Spirit Bag",
}

local Keybinds = {
    ToggleUI  = Enum.KeyCode.RightShift,
    AutoHeal  = Enum.KeyCode.F2,
    AutoPinch = Enum.KeyCode.F4,
    KillAura  = Enum.KeyCode.F5,
}

local function keyName(kc)
    return kc and kc.Name or "None"
end

local function toKeyCode(str)
    local okKey, kc = pcall(function()
        return Enum.KeyCode[str]
    end)
    return (okKey and kc) or nil
end

local State = {
    AutoHealOn           = false,
    HealPercent          = 99,
    CpsSpeed             = 500,
    SelectedFruit        = "Bloodfruit",
    AutoCollectOn        = false,
    SpeedLock            = false,
    Speed                = 16,
    Jump                 = 50,
    ESPOn                = false,
    TagsOn               = false,
    ChamsOn              = false,
    ESPFill              = Color3.fromRGB(255, 150, 170),
    ESPOutline           = Color3.fromRGB(255, 255, 255),
    ESPCache             = {},
    AutoPinchOn          = false,
    PinchTarget          = nil,
    PinchWall            = "Wood Wall",
    PinchInterval        = 0.5,
    PinchMode            = "Nearest",
    KillAuraOn           = false,
    KillAuraRange        = 15,
    KillAuraCooldown     = 0.1,
    KillAuraTargets      = 1,
    ResourceAuraOn       = false,
    ResourceRange        = 20,
    ResourceCooldown     = 0.75,
    ResourceTargets      = 3,
    ResourceRequireTool  = true,
    ResourceEquipPause   = 2,
    PickupFilterOn       = true,
    PickupWhitelistAll   = false,
    PickupWhitelist      = {},
    PickupRange          = 40,
}

local LoopRunning = {
    AutoCollect  = false,
    AutoPinch    = false,
    KillAura     = false,
    ResourceAura = false,
    ESP          = false,
    NameTags     = false,
    Chams        = false,
}

local UiToggles = {}

local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getEquippedTool()
    local char = getChar()
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return child end
    end
    return nil
end

local function notify(title, msg, dur)
    pcall(function()
        WindUI:Notify({ Title = title, Content = msg, Duration = dur or 3 })
    end)
end

local function setUiToggle(key, value)
    local el = UiToggles[key]
    if not el then return end
    pcall(function()
        if el.Set then
            el:Set(value)
        elseif el.SetValue then
            el:SetValue(value)
        end
    end)
end

local function startLoop(name, fn)
    if LoopRunning[name] then return end
    LoopRunning[name] = true
    task.spawn(function()
        fn()
        LoopRunning[name] = false
    end)
end

local function getEntityID(inst)
    if not inst then return nil end
    local id = inst:GetAttribute("EntityID")
    if id ~= nil then return id end

    local current = inst.Parent
    while current and current ~= workspace do
        id = current:GetAttribute("EntityID")
        if id ~= nil then return id end
        current = current.Parent
    end
    return nil
end

local function getEntityPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart
            or inst:FindFirstChild("HumanoidRootPart")
            or inst:FindFirstChild("Item")
            or inst:FindFirstChildWhichIsA("BasePart")
    end
    return inst:FindFirstChildWhichIsA("BasePart")
end

local function isPlayerEntity(inst)
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder and inst:IsDescendantOf(playersFolder) then return true end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and inst:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local resourceAuraPauseUntil = 0

local function pauseResourceAura(seconds)
    resourceAuraPauseUntil = os.clock() + (seconds or State.ResourceEquipPause)
end

local function swingencode(ids)
    if typeof(ids) ~= "table" then ids = { ids } end
    local count = #ids
    local out = { string.char(0x00, 0x11, count, 0x00) }

    for i = 1, count do
        local num = ids[i]
        out[#out + 1] = string.char(
            num % 256,
            math.floor(num / 256) % 256,
            math.floor(num / 65536) % 256,
            0x00
        )
    end

    return table.concat(out)
end

local function swingAtEntityIDs(idList)
    local okSwing = pcall(function()
        local packet = swingencode(idList)
        ReplicatedStorage:WaitForChild("ByteNetReliable"):FireServer(buffer.fromstring(packet))
    end)
    if okSwing then return end

    for _, id in ipairs(idList) do
        pcall(function()
            Packets.SwingTool.send(id)
        end)
    end
end

local function addSwingTarget(targets, seen, part, entityID, origin, maxRange)
    if not part or not entityID then return end
    local key = tostring(entityID)
    if seen[key] then return end

    local dist = (part.Position - origin).Magnitude
    if dist > maxRange then return end

    seen[key] = true
    table.insert(targets, { eid = entityID, dist = dist })
end

local function getPlayerSwingTargets(origin, maxRange)
    local targets, seen = {}, {}
    local playersFolder = workspace:FindFirstChild("Players")

    if playersFolder then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local entity = playersFolder:FindFirstChild(player.Name)
                if entity then
                    local part = getEntityPart(entity)
                    local entityID = getEntityID(entity) or (part and getEntityID(part))
                    addSwingTarget(targets, seen, part, entityID, origin, maxRange)
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = getEntityPart(player.Character)
            local entityID = getEntityID(player.Character) or (part and getEntityID(part))
            addSwingTarget(targets, seen, part, entityID, origin, maxRange)
        end
    end

    table.sort(targets, function(a, b)
        return a.dist < b.dist
    end)
    return targets
end

local function getResourceSwingTargets(origin, maxRange)
    local targets, seen = {}, {}

    for _, folderName in ipairs({ "Resources", "Harvest", "Nodes", "Plants" }) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, desc in ipairs(folder:GetDescendants()) do
                if not isPlayerEntity(desc) then
                    local entityID = getEntityID(desc)
                    local part = getEntityPart(desc)
                    if entityID and part then
                        addSwingTarget(targets, seen, part, entityID, origin, maxRange)
                        if #targets >= State.ResourceTargets * 4 then
                            break
                        end
                    end
                end
            end
        end
    end

    table.sort(targets, function(a, b)
        return a.dist < b.dist
    end)
    return targets
end

local function swingOnTargets(targets, maxCount)
    local ids = {}
    for i = 1, math.min(maxCount, #targets) do
        table.insert(ids, targets[i].eid)
    end
    if #ids > 0 then
        swingAtEntityIDs(ids)
    end
end

local pinchParams = RaycastParams.new()
pinchParams.FilterType = Enum.RaycastFilterType.Blacklist

local function getPinchTarget()
    local myRoot = getRoot()
    if not myRoot then return nil end

    if State.PinchMode == "Selected" then
        local t = State.PinchTarget and Players:FindFirstChild(State.PinchTarget)
        if t and t.Character then
            return t.Character:FindFirstChild("HumanoidRootPart")
        end
    elseif State.PinchMode == "Nearest" then
        local nearest, nearestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                if hr then
                    local d = (hr.Position - myRoot.Position).Magnitude
                    if d < nearestDist then
                        nearest = hr
                        nearestDist = d
                    end
                end
            end
        end
        return nearest
    elseif State.PinchMode == "Cursor" then
        local camera = workspace.CurrentCamera
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local closest, closestDist = nil, math.huge

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                if hr then
                    local screenPos, onScreen = camera:WorldToScreenPoint(hr.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if d < closestDist then
                            closest = hr
                            closestDist = d
                        end
                    end
                end
            end
        end

        return closest
    end

    return nil
end

local function doPinch(targetHRP, wallName)
    local targetChar = targetHRP.Parent
    pinchParams.FilterDescendantsInstances = targetChar and { targetChar } or {}

    for _, v in pairs({ 2, -2 }) do
        local pos = targetHRP.Position + (targetHRP.CFrame.RightVector * v)
        local ray = workspace:Raycast(pos + Vector3.new(0, 8, 0), Vector3.new(0, -25, 0), pinchParams)

        if ray then
            pcall(function()
                Packets.PlaceStructure.send({
                    buildingName = wallName,
                    cframe       = CFrame.new(ray.Position),
                })
            end)
        end

        task.wait(0.2)
    end
end

local function autoPinchLoop()
    while State.AutoPinchOn do
        local targetHRP = getPinchTarget()
        if targetHRP then
            doPinch(targetHRP, State.PinchWall)
        end
        task.wait(State.PinchInterval)
    end
end

local function killAuraLoop()
    while State.KillAuraOn do
        local root = getRoot()
        if root then
            local targets = getPlayerSwingTargets(root.Position, State.KillAuraRange)
            swingOnTargets(targets, State.KillAuraTargets)
        end
        task.wait(State.KillAuraCooldown)
    end
end

local function resourceAuraLoop()
    while State.ResourceAuraOn do
        local canSwing = os.clock() >= resourceAuraPauseUntil

        if canSwing and State.ResourceRequireTool and not getEquippedTool() then
            canSwing = false
            task.wait(0.2)
        elseif not canSwing then
            task.wait(0.1)
        end

        if canSwing then
            local root = getRoot()
            if root then
                local targets = getResourceSwingTargets(root.Position, State.ResourceRange)
                swingOnTargets(targets, State.ResourceTargets)
            end
            task.wait(State.ResourceCooldown)
        end
    end
end

local function shouldPickupItem(itemName)
    if not State.PickupFilterOn then return true end
    if State.PickupWhitelistAll then return true end
    return State.PickupWhitelist[itemName] == true
end

local function pickupDrop(drop)
    local entityID = getEntityID(drop)
    if not entityID then return false end

    local picked = false
    picked = pcall(function()
        Packets.Pickup.send(entityID)
    end) or picked

    if not picked then
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events then
            local pickupItem = events:FindFirstChild("PickupItem")
            local pickup = events:FindFirstChild("Pickup")

            if pickupItem then
                picked = pcall(function()
                    pickupItem:InvokeServer(drop)
                end) or picked
            elseif pickup then
                local part = drop:FindFirstChild("Item") or getEntityPart(drop)
                if part then
                    picked = pcall(function()
                        pickup:FireServer(part)
                    end) or picked
                end
            end
        end
    end

    return picked
end

local function getPickupListText()
    if State.PickupWhitelistAll then return "Picking up: ALL items" end

    local names = {}
    for name in pairs(State.PickupWhitelist) do
        table.insert(names, name)
    end
    table.sort(names)

    if #names == 0 then return "No items selected" end
    if #names <= 6 then return "Picking up: " .. table.concat(names, ", ") end
    return "Picking up " .. #names .. " items"
end

local function mergePickupNamesFromGame()
    local seen, merged = {}, {}

    for _, name in ipairs(PICKUP_ITEM_LIST) do
        if not seen[name] then
            seen[name] = true
            table.insert(merged, name)
        end
    end

    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, drop in ipairs(itemsFolder:GetChildren()) do
            if not seen[drop.Name] then
                seen[drop.Name] = true
                table.insert(merged, drop.Name)
            end
        end
    end

    table.sort(merged)
    return merged
end

local function updatePickupStatus(paragraph)
    if not paragraph then return end
    pcall(function()
        if paragraph.SetDesc then
            paragraph:SetDesc(getPickupListText())
        elseif paragraph.Set then
            paragraph:Set({ Desc = getPickupListText() })
        end
    end)
end

local function bindToolEquipPause(char)
    local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
    if not backpack then return end

    local function onEquip()
        pauseResourceAura(State.ResourceEquipPause)
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then onEquip() end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then onEquip() end
    end)
    backpack.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then pauseResourceAura(State.ResourceEquipPause + 0.5) end
    end)
end

local function applySpeed()
    local h = getHum()
    if h then
        h.WalkSpeed = State.Speed
        h.JumpPower = State.Jump
    end
end

local healHumanoid = nil
local cachedFruit = nil
local lastUseTime = 0

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    bindToolEquipPause(char)
    if State.SpeedLock then applySpeed() end
end)

if LocalPlayer.Character then
    bindToolEquipPause(LocalPlayer.Character)
end

local UIEnabled = true
local HubGui = nil
local knownGameGuis = {
    MainGui=true, RegionUI=true, SecondaryGui=true, SpawnGui=true,
    Toast=true, TradeUI=true, ClanUI=true, Topbar=true,
    vignette=true, Calendar=true, CrateUI=true, RobloxGui=true,
}

local function bindHubGui()
    if HubGui and HubGui.Parent then return end
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not knownGameGuis[gui.Name] then
            HubGui = gui
            return
        end
    end
end

local function toggleUI()
    bindHubGui()
    if HubGui and HubGui.Parent then
        UIEnabled = not UIEnabled
        HubGui.Enabled = UIEnabled
    end
end

local function autoCollectLoop()
    while State.AutoCollectOn do
        local root = getRoot()
        if root then
            local itemFolder = workspace:FindFirstChild("Items")
            if itemFolder then
                for _, drop in ipairs(itemFolder:GetChildren()) do
                    if shouldPickupItem(drop.Name) then
                        local part = getEntityPart(drop)
                        if part then
                            local dist = (part.Position - root.Position).Magnitude
                            if dist <= State.PickupRange and getEntityID(drop) then
                                pickupDrop(drop)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.4)
    end
end

local function setupCharacter(char)
    healHumanoid = char:WaitForChild("Humanoid")
    cachedFruit = nil
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

task.spawn(function()
    while task.wait(0.05) do
        if State.AutoHealOn and healHumanoid and healHumanoid.Health > 0 then
            local hp = (healHumanoid.Health / healHumanoid.MaxHealth) * 100
            if hp <= State.HealPercent then
                local now = os.clock()
                if now - lastUseTime >= (1 / State.CpsSpeed) then
                    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
                    if mainGui then
                        local inventory = mainGui:FindFirstChild("RightPanel")
                            and mainGui.RightPanel:FindFirstChild("Inventory")
                            and mainGui.RightPanel.Inventory:FindFirstChild("List")

                        if inventory then
                            if not cachedFruit or not cachedFruit.Parent then
                                cachedFruit = nil
                                for _, item in ipairs(inventory:GetChildren()) do
                                    if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then
                                        cachedFruit = item
                                        break
                                    end
                                end
                            end

                            if cachedFruit then
                                local success = pcall(function()
                                    Packets.UseBagItem.send(cachedFruit.LayoutOrder)
                                end)
                                if success then
                                    lastUseTime = os.clock()
                                else
                                    cachedFruit = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function clearESP(p)
    local h = State.ESPCache[p.Name]
    if h and h.Parent then h:Destroy() end
    State.ESPCache[p.Name] = nil
end

function clearAllESP()
    for _, h in pairs(State.ESPCache) do
        if h and h.Parent then h:Destroy() end
    end
    State.ESPCache = {}
end

local function addESP(p)
    if p == LocalPlayer or not p.Character then return end
    if State.ESPCache[p.Name] and State.ESPCache[p.Name].Parent then return end

    local h = Instance.new("Highlight")
    h.FillColor = State.ESPFill
    h.OutlineColor = State.ESPOutline
    h.FillTransparency = 0.45
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Name = "CB_PlayerESP"
    h.Adornee = p.Character
    h.Parent = p.Character
    State.ESPCache[p.Name] = h
end

local function espLoop()
    while State.ESPOn do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character then
                    addESP(p)
                    local h = State.ESPCache[p.Name]
                    if h and h.Parent then
                        h.FillColor = State.ESPFill
                        h.OutlineColor = State.ESPOutline
                    end
                else
                    clearESP(p)
                end
            end
        end
        task.wait(1.5)
    end
    clearAllESP()
end

local function addNameTag(p)
    if p == LocalPlayer then return end

    local char = p.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_Tag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CB_Tag"
    bb.Size = UDim2.new(0, 130, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0.72, 0)
    frame.BackgroundColor3 = Blossom.Pink
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = bb
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 1, 0)
    label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = p.Name
    label.TextColor3 = Color3.fromRGB(80, 30, 40)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = frame

    local hbBg = Instance.new("Frame")
    hbBg.Size = UDim2.new(1, 0, 0.22, 0)
    hbBg.Position = UDim2.new(0, 0, 0.78, 0)
    hbBg.BackgroundColor3 = Color3.fromRGB(180, 80, 100)
    hbBg.BorderSizePixel = 0
    hbBg.Parent = bb
    Instance.new("UICorner", hbBg).CornerRadius = UDim.new(0, 4)

    local hbFill = Instance.new("Frame")
    hbFill.Size = UDim2.new(1, 0, 1, 0)
    hbFill.BackgroundColor3 = Blossom.Green
    hbFill.BorderSizePixel = 0
    hbFill.Parent = hbBg
    Instance.new("UICorner", hbFill).CornerRadius = UDim.new(0, 4)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function upd()
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            hbFill.Size = UDim2.new(pct, 0, 1, 0)
            hbFill.BackgroundColor3 = pct > 0.5 and Blossom.Green or Blossom.Red
        end

        upd()
        hum:GetPropertyChangedSignal("Health"):Connect(upd)
    end
end

function clearAllTags()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local t = head:FindFirstChild("CB_Tag")
                if t then t:Destroy() end
            end
        end
    end
end

local function nameTagLoop()
    while State.TagsOn do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                addNameTag(p)
            end
        end
        task.wait(2)
    end
    clearAllTags()
end

function resetChams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

local function chamsLoop()
    while State.ChamsOn do
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
    resetChams()
end

Players.PlayerRemoving:Connect(clearESP)

local function shutdownAll()
    State.AutoHealOn = false
    State.AutoCollectOn = false
    State.AutoPinchOn = false
    State.KillAuraOn = false
    State.ResourceAuraOn = false
    State.ESPOn = false
    State.TagsOn = false
    State.ChamsOn = false
    cachedFruit = nil
    clearAllESP()
    clearAllTags()
    resetChams()
end

local function toggleAutoHeal(on)
    State.AutoHealOn = on
    cachedFruit = nil
    setUiToggle("AutoHeal", on)
    notify("Auto Heal [" .. keyName(Keybinds.AutoHeal) .. "]", on and "Active!" or "Stopped.")
end

local function toggleAutoPinch(on)
    if on and State.PinchMode == "Selected" and not State.PinchTarget then
        notify("Auto Pinch", "Select a target player first!")
        return
    end

    State.AutoPinchOn = on
    setUiToggle("AutoPinch", on)

    if on then
        startLoop("AutoPinch", autoPinchLoop)
        notify("Auto Pinch", "Active! Mode: " .. State.PinchMode)
    else
        notify("Auto Pinch", "Stopped.")
    end
end

local function toggleKillAura(on)
    State.KillAuraOn = on
    setUiToggle("KillAura", on)

    if on then
        startLoop("KillAura", killAuraLoop)
    end

    notify("Kill Aura [" .. keyName(Keybinds.KillAura) .. "]", on and "Active!" or "Stopped.")
end

local Window = WindUI:CreateWindow({
    Title  = "Cherry Blossom Hub",
    Folder = "BlossomUI",
    Icon   = "sparkles",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton = {
        Title     = "Open Hub",
        Draggable = true,
        Scale     = 0.55,
        Color     = ColorSequence.new(Blossom.Pink, Blossom.Soft, Blossom.Light),
    },
    Topbar = { Height = 44, ButtonsType = "Mac", BackgroundColor = Blossom.Pink },
})

task.defer(bindHubGui)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    local key = input.KeyCode
    if key == Keybinds.ToggleUI  then toggleUI() end
    if key == Keybinds.AutoHeal  then toggleAutoHeal(not State.AutoHealOn) end
    if key == Keybinds.AutoPinch then toggleAutoPinch(not State.AutoPinchOn) end
    if key == Keybinds.KillAura  then toggleKillAura(not State.KillAuraOn) end
end)

local S_Main   = Window:Section({ Title = "Main"     })
local S_Farm   = Window:Section({ Title = "Farming"  })
local S_Combat = Window:Section({ Title = "Combat"   })
local S_Move   = Window:Section({ Title = "Movement" })
local S_Vis    = Window:Section({ Title = "Visuals"  })
local S_Set    = Window:Section({ Title = "Settings" })

local function getPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(t, p.Name)
        end
    end
    return t
end

local HomeTab = S_Main:Tab({ Title = "Home", Icon = "home", IconColor = Blossom.Pink })
HomeTab:Paragraph({
    Title = "Cherry Blossom Hub",
    Desc  = "Autofarm, Pathfinding, and Mob ESP were removed for better FPS.",
})
HomeTab:Paragraph({
    Title = "Default Hotkeys",
    Desc  = "RightShift - Toggle UI\nF2 - Auto Heal\nF4 - Auto Pinch\nF5 - Kill Aura\n\nChange all in Settings.",
})
HomeTab:Button({
    Title = "Show Notification",
    Icon = "sparkles",
    Justify = "Center",
    Callback = function()
        notify("Cherry Blossom Hub", "Ready!", 4)
    end,
})

local ResTab = S_Farm:Tab({ Title = "Resource Aura", Icon = "pickaxe", IconColor = Blossom.Yellow })
ResTab:Paragraph({ Title = "Resource Aura Info", Desc = "SwingTool hit on resources. Equip a tool first. Pauses while swapping tools." })
ResTab:Toggle({
    Title = "Require Equipped Tool",
    Value = true,
    Callback = function(v)
        State.ResourceRequireTool = v
        notify("Resource Aura", v and "Needs equipped tool." or "Swing without tool.")
    end,
})
UiToggles.ResourceAura = ResTab:Toggle({
    Title = "Enable Resource Aura",
    Value = false,
    Callback = function(v)
        State.ResourceAuraOn = v
        if v then startLoop("ResourceAura", resourceAuraLoop) end
        notify("Resource Aura", v and "Active!" or "Stopped.")
    end,
})
ResTab:Slider({ Title = "Range (studs)", Step = 1, Value = { Min = 1, Max = 50, Default = 20 }, Callback = function(v) State.ResourceRange = v end })
ResTab:Slider({ Title = "Cooldown (s)", Step = 0.05, Value = { Min = 0.5, Max = 2, Default = 0.75 }, Callback = function(v) State.ResourceCooldown = v end })
ResTab:Slider({ Title = "Equip Pause (s)", Step = 0.1, Value = { Min = 0.5, Max = 5, Default = 2 }, Callback = function(v) State.ResourceEquipPause = v end })
ResTab:Slider({ Title = "Max Targets", Step = 1, Value = { Min = 1, Max = 10, Default = 3 }, Callback = function(v) State.ResourceTargets = v end })

local PickupTab = S_Farm:Tab({ Title = "Auto Pickup", Icon = "package", IconColor = Blossom.Blue })
local pickupListValues = mergePickupNamesFromGame()
local lastPickupPick = pickupListValues[1] or "Log"
local PickupStatus = PickupTab:Paragraph({ Title = "Selected Items", Desc = getPickupListText() })
PickupTab:Paragraph({ Title = "Auto Pickup Info", Desc = "Add item names below. Only those drops get picked up." })
PickupTab:Toggle({
    Title = "Only Pick Selected Items",
    Value = true,
    Callback = function(v)
        State.PickupFilterOn = v
        updatePickupStatus(PickupStatus)
        notify("Auto Pickup", v and "Whitelist on." or "Picking up everything.")
    end,
})
PickupTab:Toggle({
    Title = "Pickup All Items (ignore list)",
    Value = false,
    Callback = function(v)
        State.PickupWhitelistAll = v
        updatePickupStatus(PickupStatus)
        notify("Auto Pickup", v and "All items." or "Using your list.")
    end,
})
local PickupDrop = PickupTab:Dropdown({
    Title = "Add Item To Pickup List",
    Values = pickupListValues,
    Value = 1,
    Callback = function(v)
        lastPickupPick = v
        State.PickupWhitelist[v] = true
        updatePickupStatus(PickupStatus)
        notify("Auto Pickup", "Added: " .. v)
    end,
})
PickupTab:Button({
    Title = "Remove Selected Item",
    Icon = "minus",
    Justify = "Center",
    Callback = function()
        if lastPickupPick and State.PickupWhitelist[lastPickupPick] then
            State.PickupWhitelist[lastPickupPick] = nil
            updatePickupStatus(PickupStatus)
            notify("Auto Pickup", "Removed: " .. lastPickupPick)
        else
            notify("Auto Pickup", "Item not in your list.")
        end
    end,
})
PickupTab:Button({
    Title = "Clear Pickup List",
    Icon = "trash",
    Color = Blossom.Red,
    Justify = "Center",
    Callback = function()
        State.PickupWhitelist = {}
        updatePickupStatus(PickupStatus)
        notify("Auto Pickup", "List cleared.")
    end,
})
PickupTab:Button({
    Title = "Refresh Item Names (in-game)",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        pickupListValues = mergePickupNamesFromGame()
        PickupDrop:Refresh(pickupListValues)
        notify("Auto Pickup", "Refreshed " .. #pickupListValues .. " item names.")
    end,
})
PickupTab:Slider({ Title = "Pickup Range (studs)", Step = 1, Value = { Min = 5, Max = 80, Default = 40 }, Callback = function(v) State.PickupRange = v end })
UiToggles.AutoCollect = PickupTab:Toggle({
    Title = "Enable Auto Pickup",
    Value = false,
    Callback = function(v)
        State.AutoCollectOn = v
        if v then
            if State.PickupFilterOn and not State.PickupWhitelistAll then
                local count = 0
                for _ in pairs(State.PickupWhitelist) do count = count + 1 end
                if count == 0 then
                    State.AutoCollectOn = false
                    notify("Auto Pickup", "Add items to your list first!")
                    return
                end
            end
            startLoop("AutoCollect", autoCollectLoop)
        end
        notify("Auto Pickup", v and "On!" or "Off.")
    end,
})

local HealTab = S_Combat:Tab({ Title = "Auto Heal", Icon = "heart", IconColor = Blossom.Red })
HealTab:Paragraph({ Title = "Auto Heal Info", Desc = "Uses Packets.UseBagItem to heal from inventory.\nDefault hotkey: F2" })
HealTab:Dropdown({
    Title = "Heal Fruit",
    Values = FRUIT_LIST,
    Value = 1,
    Callback = function(v)
        State.SelectedFruit = v
        cachedFruit = nil
        notify("Auto Heal", "Fruit: " .. v)
    end,
})
HealTab:Slider({ Title = "Heal When HP Below (%)", Step = 1, Value = { Min = 1, Max = 99, Default = 99 }, Callback = function(v) State.HealPercent = v end })
HealTab:Slider({ Title = "Heal Speed (CPS)", Step = 50, Value = { Min = 50, Max = 1000, Default = 500 }, Callback = function(v) State.CpsSpeed = v end })
UiToggles.AutoHeal = HealTab:Toggle({ Title = "Enable Auto Heal", Value = false, Callback = function(v) toggleAutoHeal(v) end })
HealTab:Paragraph({ Title = "Fruit Guide", Desc = "Bloodfruit - 4 HP (best PvP)\nFruitcake - 4 HP + 35 food\nCooked Meat - 1 HP + 35 food\nBerry - 1.5 HP" })
HealTab:Button({
    Title = "Heal Now",
    Icon = "heart",
    Justify = "Center",
    Color = Blossom.Red,
    Callback = function()
        if not healHumanoid then return end
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        if not mainGui then return end

        local inventory = mainGui:FindFirstChild("RightPanel")
            and mainGui.RightPanel:FindFirstChild("Inventory")
            and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then return end

        local found = nil
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then
                found = item
                break
            end
        end

        if found then
            pcall(function()
                Packets.UseBagItem.send(found.LayoutOrder)
            end)
            notify("Heal", "Used: " .. State.SelectedFruit)
        else
            notify("Heal", State.SelectedFruit .. " not in inventory!")
        end
    end,
})

local KATab = S_Combat:Tab({ Title = "Kill Aura", Icon = "sword", IconColor = Blossom.Red })
UiToggles.KillAura = KATab:Toggle({ Title = "Enable Kill Aura", Value = false, Callback = function(v) toggleKillAura(v) end })
KATab:Slider({ Title = "Range (studs)", Step = 1, Value = { Min = 1, Max = 30, Default = 15 }, Callback = function(v) State.KillAuraRange = v end })
KATab:Slider({ Title = "Attack Cooldown (s)", Step = 0.01, Value = { Min = 0.01, Max = 1, Default = 0.1 }, Callback = function(v) State.KillAuraCooldown = v end })
KATab:Slider({ Title = "Max Targets", Step = 1, Value = { Min = 1, Max = 6, Default = 1 }, Callback = function(v) State.KillAuraTargets = v end })

local PinchTab = S_Combat:Tab({ Title = "Auto Pinch", Icon = "zap", IconColor = Blossom.Purple })
PinchTab:Paragraph({
    Title = "Auto Pinch Info",
    Desc  = "Raycasts left and right of target and places walls at ground level.\nNearest - closest player to you.\nCursor - player closest to your crosshair.\nSelected - pick from list.\nDefault hotkey: F4",
})
PinchTab:Dropdown({
    Title = "Target Mode",
    Values = { "Nearest", "Cursor", "Selected" },
    Value = 1,
    Callback = function(v)
        State.PinchMode = v
        notify("Auto Pinch", "Mode: " .. v)
    end,
})
local PinchDrop = PinchTab:Dropdown({
    Title = "Target Player",
    Desc = "Only used when mode is Selected.",
    Values = getPlayerList(),
    AllowNone = true,
    Callback = function(v) State.PinchTarget = v end,
})
PinchTab:Button({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        PinchDrop:Refresh(getPlayerList())
        notify("Auto Pinch", "Refreshed.")
    end,
})
PinchTab:Dropdown({
    Title = "Wall Type",
    Values = WALL_LIST,
    Value = 1,
    Callback = function(v)
        State.PinchWall = v
        notify("Auto Pinch", "Wall: " .. v)
    end,
})
PinchTab:Slider({ Title = "Re-place Interval (s)", Step = 0.1, Value = { Min = 0.1, Max = 2, Default = 0.5 }, Callback = function(v) State.PinchInterval = v end })
UiToggles.AutoPinch = PinchTab:Toggle({ Title = "Enable Auto Pinch", Value = false, Callback = function(v) toggleAutoPinch(v) end })

local SpeedTab = S_Move:Tab({ Title = "Speed", Icon = "wind", IconColor = Blossom.Yellow })
SpeedTab:Slider({
    Title = "Walk Speed",
    Desc = "Default: 16 / Max: 21",
    Step = 1,
    Value = { Min = 1, Max = 21, Default = 16 },
    Callback = function(v)
        State.Speed = v
        local h = getHum()
        if h then h.WalkSpeed = v end
    end,
})
SpeedTab:Slider({
    Title = "Jump Power",
    Desc = "Default: 50",
    Step = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(v)
        State.Jump = v
        local h = getHum()
        if h then h.JumpPower = v end
    end,
})
SpeedTab:Toggle({
    Title = "Speed Lock",
    Desc = "Re-applies speed after every respawn.",
    Value = false,
    Callback = function(v)
        State.SpeedLock = v
        notify("Speed Lock", v and "Active." or "Disabled.")
    end,
})
local PG = SpeedTab:Group({})
PG:Button({ Title = "Default", Justify = "Center", Icon = "", Callback = function() State.Speed = 16 State.Jump = 50 applySpeed() notify("Speed", "Reset.") end })
PG:Space()
PG:Button({ Title = "Max (21)", Color = Blossom.Green, Justify = "Center", Icon = "", Callback = function() State.Speed = 21 local h = getHum() if h then h.WalkSpeed = 21 end notify("Speed", "21.") end })
PG:Space()
PG:Button({ Title = "High Jump", Color = Blossom.Blue, Justify = "Center", Icon = "", Callback = function() State.Jump = 120 local h = getHum() if h then h.JumpPower = 120 end notify("Speed", "Jump 120.") end })
SpeedTab:Button({ Title = "Reset All", Icon = "refresh-cw", Color = Blossom.Red, Justify = "Center", Callback = function() State.Speed = 16 State.Jump = 50 applySpeed() notify("Speed", "All reset.") end })

local EspTab = S_Vis:Tab({ Title = "ESP", Icon = "eye", IconColor = Blossom.Pink })
EspTab:Paragraph({ Title = "ESP Info", Desc = "Mob ESP was removed to prevent whole-map scan lag." })
UiToggles.ESP = EspTab:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(v)
        State.ESPOn = v
        if v then startLoop("ESP", espLoop) else clearAllESP() end
        notify("ESP", v and "On!" or "Off.")
    end,
})
EspTab:Colorpicker({
    Title = "Fill Color",
    Default = State.ESPFill,
    Callback = function(c)
        State.ESPFill = c
        for _, h in pairs(State.ESPCache) do
            if h and h.Parent then h.FillColor = c end
        end
    end,
})
EspTab:Colorpicker({
    Title = "Outline Color",
    Default = State.ESPOutline,
    Callback = function(c)
        State.ESPOutline = c
        for _, h in pairs(State.ESPCache) do
            if h and h.Parent then h.OutlineColor = c end
        end
    end,
})
UiToggles.Tags = EspTab:Toggle({
    Title = "Name Tags",
    Value = false,
    Callback = function(v)
        State.TagsOn = v
        if v then startLoop("NameTags", nameTagLoop) else clearAllTags() end
        notify("Name Tags", v and "On!" or "Off.")
    end,
})
UiToggles.Chams = EspTab:Toggle({
    Title = "Chams",
    Desc = "Makes enemy parts 40% transparent.",
    Value = false,
    Callback = function(v)
        State.ChamsOn = v
        if v then startLoop("Chams", chamsLoop) else resetChams() end
        notify("Chams", v and "On!" or "Off.")
    end,
})
EspTab:Button({
    Title = "Clear All Visuals",
    Icon = "trash",
    Color = Blossom.Red,
    Justify = "Center",
    Callback = function()
        State.ESPOn = false
        State.TagsOn = false
        State.ChamsOn = false
        setUiToggle("ESP", false)
        setUiToggle("Tags", false)
        setUiToggle("Chams", false)
        clearAllESP()
        clearAllTags()
        resetChams()
        notify("Visuals", "All cleared.")
    end,
})

local SetTab = S_Set:Tab({ Title = "Settings", Icon = "settings", IconColor = Blossom.Soft })
SetTab:Paragraph({ Title = "Keybinds", Desc = "Click a box then press any key.\nWorks even when UI is closed." })
SetTab:Keybind({
    Title = "Toggle UI",
    Desc = "Default: RightShift",
    Value = "RightShift",
    Callback = function(v)
        local kc = toKeyCode(v)
        if kc then
            Keybinds.ToggleUI = kc
            notify("Keybind", "Toggle UI: " .. v)
        end
    end,
})
SetTab:Keybind({
    Title = "Auto Heal",
    Desc = "Default: F2",
    Value = "F2",
    Callback = function(v)
        local kc = toKeyCode(v)
        if kc then
            Keybinds.AutoHeal = kc
            notify("Keybind", "Auto Heal: " .. v)
        end
    end,
})
SetTab:Keybind({
    Title = "Auto Pinch",
    Desc = "Default: F4",
    Value = "F4",
    Callback = function(v)
        local kc = toKeyCode(v)
        if kc then
            Keybinds.AutoPinch = kc
            notify("Keybind", "Auto Pinch: " .. v)
        end
    end,
})
SetTab:Keybind({
    Title = "Kill Aura",
    Desc = "Default: F5",
    Value = "F5",
    Callback = function(v)
        local kc = toKeyCode(v)
        if kc then
            Keybinds.KillAura = kc
            notify("Keybind", "Kill Aura: " .. v)
        end
    end,
})
SetTab:Button({
    Title = "Credits",
    Icon = "heart",
    Justify = "Center",
    Callback = function()
        notify("Credits", "Cherry Blossom Hub\nUI: WindUI by Footagesus\nLaggy modules removed: Autofarm, Pathfinding, Mob ESP", 5)
    end,
})
SetTab:Button({
    Title = "Close UI",
    Icon = "x",
    Color = Blossom.Red,
    Justify = "Center",
    Callback = function()
        shutdownAll()
        Window:Destroy()
    end,
})

print("[Cherry Blossom Hub] Loaded. Removed: Autofarm, Pathfinding, Mob ESP.")
