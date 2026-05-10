-- WindUI test loader for Xeno

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
    Title = "WindUI Test",
    Folder = "WindUITest",
    Icon = "star",
    HideSearchBar = false,
    OpenButton = {
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac"
    }
})

local MainSection = Window:Section({
    Title = "Main"
})

local TestTab = MainSection:Tab({
    Title = "Test",
    Icon = "check"
})

TestTab:Paragraph({
    Title = "Success",
    Desc = "WindUI loaded successfully on Xeno."
})

TestTab:Button({
    Title = "Test Notification",
    Callback = function()
        WindUI:Notify({
            Title = "Success",
            Content = "Button works!",
            Duration = 3
        })
    end
})

print("WindUI loaded successfully")
