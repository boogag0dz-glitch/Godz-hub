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
            Color3.fromRGB(255, 183, 197),
            Color3.fromRGB(255, 145, 175)
        )
    },

    Topbar = {
        Height = 35,
        ButtonsType = "Mac"
    }
})

Window:Tag({
    Title = "Blossom",
    Color = Color3.fromRGB(255, 183, 197),
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
    Desc = "Minimal Blossom-themed WindUI loaded."
})

Tab:Button({
    Title = "Test Notification",
    Callback = function()
        WindUI:Notify({
            Title = "Blossom UI",
            Content = "Everything is working!",
            Duration = 3
        })
    end
})
