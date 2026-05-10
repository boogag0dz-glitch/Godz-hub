--[[ 
    ╔═══════════════════════════════════════════╗
    ║         GODZ HUB - BOOGA BOOGA REBORN    ║
    ║         CHERRY BLOSSOM UI UPDATE 🌸       ║
    ╚═══════════════════════════════════════════╝
]]

-- ============================================================
-- SERVICES
-- ============================================================
local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService   = game:GetService("UserInputService")
local Workspace          = game:GetService("Workspace")

local cloneref          = (cloneref or clonereference or function(i) return i end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local LocalPlayer       = Players.LocalPlayer

-- ============================================================
-- WINDUI LOAD
-- ============================================================
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then WindUI = result end
end

-- ============================================================
-- GLOBAL STATE
-- ============================================================
_G.GH = _G.GH or {
    Autofarm = false,
    CurrentSpeed = 16,
    CurrentJump = 50,
    Connections = {}
}

-- ============================================================
-- UTILS
-- ============================================================
local function getChar() return LocalPlayer.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- 🌸 CHERRY BLOSSOM THEME (FIXED COLORS)
local Blossom = {
    Primary   = Color3.fromRGB(255, 183, 197), -- soft pink
    Secondary = Color3.fromRGB(247, 198, 208), -- lighter pink
    Accent    = Color3.fromRGB(255, 209, 220), -- blush
    Text      = Color3.fromRGB(255, 255, 255),
    DarkText  = Color3.fromRGB(60, 60, 60),
}

-- ============================================================
-- WINDOW (REPLACED UI CORE)
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "🌸 Godz Hub • Cherry Blossom Edition",
    Folder = "GodzHub",
    Icon = "sparkles",
    NewElements = true,
    HideSearchBar = false,

    OpenButton = {
        Title = "Godz Hub",
        Draggable = true,
        Scale = 0.55,
        Color = ColorSequence.new(
            Blossom.Primary,
            Blossom.Secondary,
            Blossom.Accent
        )
    },

    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
        BackgroundColor = Blossom.Primary
    }
})

Window:Tag({
    Title = "Cherry Blossom UI",
    Color = Blossom.Primary,
    Border = true
})

-- ============================================================
-- SECTIONS
-- ============================================================
local FarmSection   = Window:Section({ Title = "🌸 Farming" })
local MoveSection   = Window:Section({ Title = "⚔ Movement & Combat" })
local VisualSection = Window:Section({ Title = "👁 Visuals" })
local MiscSection   = Window:Section({ Title = "✨ Misc" })

-- ============================================================
-- AUTO APPLY SPEED (FIXED PERFORMANCE)
-- ============================================================
local function applySpeed()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = _G.GH.CurrentSpeed
        hum.JumpPower = _G.GH.CurrentJump
    end
end

-- ============================================================
-- CLEANER LOOP HANDLING (LESS LAG)
-- ============================================================
local function loopWhile(flag, fn, delay)
    task.spawn(function()
        while _G.GH[flag] do
            fn()
            task.wait(delay or 0.5)
        end
    end)
end

-- ============================================================
-- FARM TAB (EXAMPLE CLEAN COLOR FIX)
-- ============================================================
local AutofarmTab = FarmSection:Tab({
    Title = "Autofarm",
    Icon = "leaf",
    IconColor = Blossom.Primary
})

AutofarmTab:Toggle({
    Title = "Enable Autofarm",
    Value = false,
    Callback = function(state)
        _G.GH.Autofarm = state

        if state then
            loopWhile("Autofarm", function()
                local root = getRoot()
                if root then
                    root.CFrame = root.CFrame + Vector3.new(0,0,1)
                end
            end, 0.3)
        end
    end
})

-- ============================================================
-- MOVEMENT TAB (COLOR FIX APPLIED)
-- ============================================================
local SpeedTab = MoveSection:Tab({
    Title = "Movement",
    Icon = "dash",
    IconColor = Blossom.Primary
})

SpeedTab:Slider({
    Title = "Walk Speed",
    Value = {Min = 1, Max = 100, Default = 16},
    Callback = function(v)
        _G.GH.CurrentSpeed = v
        applySpeed()
    end
})

SpeedTab:Slider({
    Title = "Jump Power",
    Value = {Min = 1, Max = 200, Default = 50},
    Callback = function(v)
        _G.GH.CurrentJump = v
        applySpeed()
    end
})

-- ============================================================
-- VISUAL FIX (NO GREY DEFAULT ANYMORE)
-- ============================================================
local EspTab = VisualSection:Tab({
    Title = "ESP",
    Icon = "eye",
    IconColor = Blossom.Primary
})

EspTab:Toggle({
    Title = "Blossom ESP Glow",
    Value = false,
    Callback = function(state)
        _G.GH.ESP = state

        if state then
            loopWhile("ESP", function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        if not p.Character:FindFirstChild("BloomESP") then
                            local h = Instance.new("Highlight")
                            h.Name = "BloomESP"
                            h.FillColor = Blossom.Primary
                            h.OutlineColor = Blossom.Accent
                            h.Parent = p.Character
                        end
                    end
                end
            end, 2)
        end
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
local MiscTab = MiscSection:Tab({
    Title = "Misc",
    Icon = "sparkles",
    IconColor = Blossom.Primary
})

MiscTab:Toggle({
    Title = "Anti AFK",
    Callback = function(state)
        _G.GH.AFK = state

        if state then
            _G.GH.Connections.AFK = LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                game:GetService("VirtualUser"):Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

MiscTab:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})
