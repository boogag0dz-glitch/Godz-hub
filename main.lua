local success, WindUI = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)

if not success or not WindUI then
    warn("WindUI failed to load")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Blossom UI",
    Folder = "BlossomTest",
    HideSearchBar = true,

    OpenButton = {
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromRGB(255, 210, 225),
            Color3.fromRGB(255, 170, 200)
        )
    },

    Topbar = {
        Height = 35,
        ButtonsType = "Mac"
    }
})

pcall(function()
    WindUI:SetTheme({
        Accent = Color3.fromRGB(255, 182, 193),
        Outline = Color3.fromRGB(255, 220, 230),
        Text = Color3.fromRGB(255, 240, 245),
        Placeholder = Color3.fromRGB(220, 180, 195),
        Background = Color3.fromRGB(35, 25, 35)
    })
end)

Window:Tag({
    Title = "Blossom",
    Color = Color3.fromRGB(255, 182, 193),
    Border = true
})

local Main = Window:Section({
    Title = "Main"
})

local Tab = Main:Tab({
    Title = "Home",
    Icon = "star"
})

Tab:Paragraph({
    Title = "Loaded Successfully",
    Desc = "Blossom theme applied."
})

Tab:Button({
    Title = "Test Notification",
    Callback = function()
        WindUI:Notify({
            Title = "Blossom UI",
            Content = "Theme is working!",
            Duration = 3
        })
    end
})
