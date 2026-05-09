local RunService = game:GetService("RunService")
--[[

    WindUI Example (wip)
    
]]

local cloneref = (cloneref or clonereference or function(instance)
		return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if cloneref(game:GetService("RunService")):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

--[[

WindUI.Creator.AddIcons("solar", {
    ["CheckSquareBold"] = "rbxassetid://132438947521974",
    ["CursorSquareBold"] = "rbxassetid://120306472146156",
    ["FileTextBold"] = "rbxassetid://89294979831077",
    ["FolderWithFilesBold"] = "rbxassetid://74631950400584",
    ["HamburgerMenuBold"] = "rbxassetid://134384554225463",
    ["Home2Bold"] = "rbxassetid://92190299966310",
    ["InfoSquareBold"] = "rbxassetid://119096461016615",
    ["PasswordMinimalisticInputBold"] = "rbxassetid://109919668957167",
    ["SolarSquareTransferHorizontalBold"] = "rbxassetid://125444491429160",
})--]]

function createPopup()
	return WindUI:Popup({
		Title = "Godz Hub!",
		Icon = "Bird",
		Content = "wsp!",
		Buttons = {
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
		},
	})
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
	Title = ".ftgs hub  |  WindUI Example",
	--Author = "by .ftgs • Footagesus",
	Folder = "ftgshub",
	Icon = "solar:folder-2-bold-duotone",
	--Theme = "Mellowsi",
	--IconSize = 22*2,
	NewElements = true,
	--Size = UDim2.fromOffset(700,700),

	HideSearchBar = false,

	OpenButton = {
		Title = "Open .ftgs hub UI", -- can be changed
		CornerRadius = UDim.new(1, 0), -- fully rounded
		StrokeThickness = 3, -- removing outline
		Enabled = true, -- enable or disable openbutton
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,

		Color = ColorSequence.new( -- gradient
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac", -- Default or Mac
	},
})

--createPopup()

--Window:SetUIScale(.8)

-- */  Tags  /* --
do
	Window:Tag({
		Title = "v" .. WindUI.Version,
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

-- */  Colors  /* --
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")

-- */ Other Functions /* --
local function parseJSON(luau_table, indent, level, visited)
	indent = indent or 2
	level = level or 0
	visited = visited or {}

	local currentIndent = string.rep(" ", level * indent)
	local nextIndent = string.rep(" ", (level + 1) * indent)

	if luau_table == nil then
		return "null"
	end

	local dataType = type(luau_table)

	if dataType == "table" then
		if visited[luau_table] then
			return '"[Circular Reference]"'
		end

		visited[luau_table] = true

		local isArray = true
		local maxIndex = 0

		for k, _ in pairs(luau_table) do
			if type(k) == "number" and k > maxIndex then
				maxIndex = k
			end
			if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
				isArray = false
				break
			end
		end

		local count = 0
		for _ in pairs(luau_table) do
			count = count + 1
		end
		if count ~= maxIndex and isArray then
			isArray = false
		end

		if count == 0 then
			return "{}"
		end

		if isArray then
			if count == 0 then
				return "[]"
			end

			local result = "[\n"

			for i = 1, maxIndex do
				result = result .. nextIndent .. parseJSON(luau_table[i], indent, level + 1, visited)
				if i < maxIndex then
					result = result .. ","
				end
				result = result .. "\n"
			end

			result = result .. currentIndent .. "]"
			return result
		else
			local result = "{\n"
			local first = true

			local keys = {}
			for k in pairs(luau_table) do
				table.insert(keys, k)
			end
			table.sort(keys, function(a, b)
				if type(a) == type(b) then
					return tostring(a) < tostring(b)
				else
					return type(a) < type(b)
				end
			end)

			for _, k in ipairs(keys) do
				local v = luau_table[k]
				if not first then
					result = result .. ",\n"
				else
					first = false
				end

				if type(k) == "string" then
					result = result .. nextIndent .. '"' .. k .. '": '
				else
					result = result .. nextIndent .. '"' .. tostring(k) .. '": '
				end

				result = result .. parseJSON(v, indent, level + 1, visited)
			end

			result = result .. "\n" .. currentIndent .. "}"
			return result
		end
	elseif dataType == "string" then
		local escaped = luau_table:gsub("\\", "\\\\")
		escaped = escaped:gsub('"', '\\"')
		escaped = escaped:gsub("\n", "\\n")
		escaped = escaped:gsub("\r", "\\r")
		escaped = escaped:gsub("\t", "\\t")

		return '"' .. escaped .. '"'
	elseif dataType == "number" then
		return tostring(luau_table)
	elseif dataType == "boolean" then
		return luau_table and "true" or "false"
	elseif dataType == "function" then
		return '"function"'
	else
		return '"' .. dataType .. '"'
	end
end

local function tableToClipboard(luau_table, indent)
	indent = indent or 4
	local jsonString = parseJSON(luau_table, indent)
	setclipboard(jsonString)
	return jsonString
end

-- */  About Tab  /* --
do
	local AboutTab = Window:Tab({
		Title = "About WindUI",
		Desc = "Description Example",
		Icon = "solar:info-square-bold",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})

	local AboutSection = AboutTab:Section({
		Title = "About WindUI",
	})

	AboutSection:Image({
		Image = "https://repository-images.githubusercontent.com/880118829/22c020eb-d1b1-4b34-ac4d-e33fd88db38d",
		AspectRatio = "16:9",
		Radius = 9,
	})

	AboutSection:Space({ Columns = 3 })

	AboutSection:Section({
		Title = "What is WindUI?",
		TextSize = 24,
		FontWeight = Enum.FontWeight.SemiBold,
	})

	AboutSection:Space()

	AboutSection:Section({
		Title = "WindUI is a stylish, open-source UI (User Interface) library specifically designed for Roblox Script Hubs.\nDeveloped by Footagesus (.ftgs, Footages).\nIt aims to provide developers with a modern, customizable, and easy-to-use toolkit for creating visually appealing interfaces within Roblox.\nThe project is primarily written in Lua (Luau), the scripting language used in Roblox.",
		TextSize = 18,
		TextTransparency = 0.35,
		FontWeight = Enum.FontWeight.Medium,
	})

	AboutTab:Space({ Columns = 4 })

	-- Default buttons

	AboutTab:Button({
		Title = "Export WindUI JSON (copy)",
		Color = Color3.fromHex("#a2ff30"),
		Justify = "Center",
		IconAlign = "Left",
		Icon = "", -- removing icon
		Callback = function()
			tableToClipboard(WindUI)
			WindUI:Notify({
				Title = "WindUI JSON",
				Content = "Copied to Clipboard!",
			})
		end,
	})
	AboutTab:Space({ Columns = 1 })

	AboutTab:Button({
		Title = "Destroy Window",
		Color = Color3.fromHex("#ff4830"),
		Justify = "Center",
		Icon = "shredder",
		IconAlign = "Left",
		Callback = function()
			Window:Destroy()
		end,
	})
end

-- */  Elements Section  /* --
local ElementsSection = Window:Section({
	Title = "Elements",
})
local ConfigUsageSection = Window:Section({
	Title = "Config Usage",
})
local OtherSection = Window:Section({
	Title = "Other",
})

-- */  Overview Tab  /* --
do
	local OverviewTab = ElementsSection:Tab({
		Title = "Overview",
		Icon = "solar:home-2-bold",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})

	local OverviewSection1 = OverviewTab:Section({
		Title = "Group's Example",
	})

	local OverviewGroup1 = OverviewTab:Group({})

	OverviewGroup1:Button({
		Title = "Button 1",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 1")
		end,
	})
	OverviewGroup1:Space()
	OverviewGroup1:Button({
		Title = "Button 2",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 2")
		end,
	})

	OverviewTab:Space()

	local OverviewGroup2 = OverviewTab:Group({})

	OverviewGroup2:Button({
		Title = "Button 1",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 1")
		end,
	})
	OverviewGroup2:Space()
	OverviewGroup2:Toggle({
		Title = "Toggle 2",
		Callback = function(v)
			print("clicked toggle 2:", v)
		end,
	})
	OverviewGroup2:Space()
	OverviewGroup2:Colorpicker({
		Title = "Colorpicker 3",
		Default = Color3.fromHex("#30ff6a"),
		Callback = function(color)
			print(color)
		end,
	})

	OverviewTab:Space()

	local OverviewGroup3 = OverviewTab:Group({})

	local OverviewSection1 = OverviewGroup3:Section({
		Title = "Section 1",
		Desc = "Section exampleee",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})
	OverviewSection1:Button({
		Title = "Button 1",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 1")
		end,
	})
	OverviewSection1:Space()
	OverviewSection1:Toggle({
		Title = "Toggle 2",
		Callback = function(v)
			print("clicked toggle 2:", v)
		end,
	})

	OverviewGroup3:Space()

	local OverviewSection2 = OverviewGroup3:Section({
		Title = "Section 2",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})
	OverviewSection2:Button({
		Title = "Button 1",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 1")
		end,
	})
	OverviewSection2:Space()
	OverviewSection2:Button({
		Title = "Button 2",
		Justify = "Center",
		Icon = "",
		Callback = function()
			print("clicked button 2")
		end,
	})

	--OverviewTab:Space()
end

-- */  Toggle Tab  /* --
do
	local ToggleTab = ElementsSection:Tab({
		Title = "Toggle",
		Icon = "solar:check-square-bold",
		IconColor = Green,
		IconShape = "Square",
		Border = true,
	})

	ToggleTab:Toggle({
		Title = "Toggle",
	})

	ToggleTab:Space()

	ToggleTab:Toggle({
		Title = "Toggle",
		Desc = "Toggle example",
	})

	ToggleTab:Space()

	local ToggleGroup1 = ToggleTab:Group()
	ToggleGroup1:Toggle({})
	ToggleGroup1:Space()
	ToggleGroup1:Toggle({})

	ToggleTab:Space()

	ToggleTab:Toggle({
		Title = "Checkbox",
		Type = "Checkbox",
	})

	ToggleTab:Space()

	ToggleTab:Toggle({
		Title = "Checkbox",
		Desc = "Checkbox example",
		Type = "Checkbox",
	})

	ToggleTab:Space()

	ToggleTab:Toggle({
		Title = "Toggle",
		Locked = true,
		LockedTitle = "This element is locked",
	})

	ToggleTab:Toggle({
		Title = "Toggle",
		Desc = "Toggle example",
		Locked = true,
		LockedTitle = "This element is locked",
	})
end

-- */  Button Tab  /* --
do
	local ButtonTab = ElementsSection:Tab({
		Title = "Button",
		Icon = "solar:cursor-square-bold",
		IconColor = Blue,
		IconShape = "Square",
		Border = true,
	})

	local HighlightButton
	HighlightButton = ButtonTab:Button({
		Title = "Highlight Button",
		Icon = "mouse",
		Callback = function()
			print("clicked highlight")
			HighlightButton:Highlight()
		end,
	})

	ButtonTab:Space()

	ButtonTab:Button({
		Title = "Blue Button",
		Color = Color3.fromHex("#305dff"),
		Icon = "",
		Callback = function() end,
	})

	ButtonTab:Space()

	ButtonTab:Button({
		Title = "Blue Button",
		Desc = "With description",
		Color = Color3.fromHex("#305dff"),
		Icon = "",
		Callback = function() end,
	})

	ButtonTab:Space()

	ButtonTab:Button({
		Title = "Notify Button",
		--Desc = "Button example",
		Callback = function()
			WindUI:Notify({
				Title = "Hello",
				Content = "Welcome to the WindUI Example!",
				Icon = "solar:bell-bold",
				Duration = 5,
				CanClose = false,
			})
		end,
	})

	ButtonTab:Button({
		Title = "Notify Button 2",
		--Desc = "Button example",
		Callback = function()
			WindUI:Notify({
				Title = "Hello",
				Content = "Welcome to the WindUI Example!",
				--Icon = "solar:bell-bold",
				Duration = 5,
				CanClose = false,
			})
		end,
	})

	ButtonTab:Space()

	ButtonTab:Button({
		Title = "Button",
		Locked = true,
		LockedTitle = "This element is locked",
	})

	ButtonTab:Button({
		Title = "Button",
		Desc = "Button example",
		Locked = true,
		LockedTitle = "This element is locked",
	})
end

-- */  Input Tab  /* --
do
	local InputTab = ElementsSection:Tab({
		Title = "Input",
		Icon = "solar:password-minimalistic-input-bold",
		IconColor = Purple,
		IconShape = "Square",
		Border = true,
	})

	InputTab:Input({
		Title = "Input",
		Icon = "mouse",
	})

	InputTab:Space()

	InputTab:Input({
		Title = "Input Textarea",
		Type = "Textarea",
		Icon = "mouse",
	})

	InputTab:Space()

	InputTab:Input({
		Title = "Input Textarea",
		Type = "Textarea",
		--Icon = "mouse",
	})

	InputTab:Space()

	InputTab:Input({
		Title = "Input",
		Desc = "Input example",
	})

	InputTab:Space()

	InputTab:Input({
		Title = "Input Textarea",
		Desc = "Input example",
		Type = "Textarea",
	})

	InputTab:Space()

	InputTab:Input({
		Title = "Input",
		Locked = true,
		LockedTitle = "This element is locked",
	})

	InputTab:Input({
		Title = "Input",
		Desc = "Input example",
		Locked = true,
		LockedTitle = "This element is locked",
	})
end

-- */  Slider Tab  /* --
do
	local SliderTab = ElementsSection:Tab({
		Title = "Slider",
		Icon = "solar:square-transfer-horizontal-bold",
		IconColor = Green,
		IconShape = "Square",
		Border = true,
	})

	SliderTab:Section({
		Title = "Default Slider with Tooltip and without textbox",
		TextSize = 14,
	})

	SliderTab:Slider({
		Title = "Slider Example",
		Desc = "Hahahahaha hello",
		IsTooltip = true,
		IsTextbox = false,
		Width = 200,
		Step = 1,
		Value = {
			Min = 0,
			Max = 200,
			Default = 100,
		},
		Callback = function(value)
			print(value)
		end,
	})

	SliderTab:Space()

	SliderTab:Section({
		Title = "Slider without description",
		TextSize = 14,
	})

	SliderTab:Slider({
		Title = "Slider Example",
		Step = 1,
		Width = 200,
		Value = {
			Min = 0,
			Max = 200,
			Default = 100,
		},
		Callback = function(value)
			print(value)
		end,
	})

	SliderTab:Space()

	SliderTab:Section({
		Title = "Slider without titles",
		TextSize = 14,
	})

	SliderTab:Slider({
		IsTooltip = true,
		Step = 1,
		Value = {
			Min = 0,
			Max = 200,
			Default = 100,
		},
		Callback = function(value)
			print(value)
		end,
	})

	SliderTab:Space()

	SliderTab:Section({
		Title = "Slider with icons ('from' only)",
		TextSize = 14,
	})

	SliderTab:Slider({
		IsTooltip = true,
		Step = 1,
		Value = {
			Min = 0,
			Max = 200,
			Default = 100,
		},
		Icons = {
			From = "sfsymbols:sunMinFill",
			--To = "sfsymbols:sunMaxFill",
		},
		Callback = function(value)
			print(value)
		end,
	})

	SliderTab:Space()

	SliderTab:Section({
		Title = "Slider with icons (from & to)",
		TextSize = 14,
	})

	SliderTab:Slider({
		IsTooltip = true,
		Step = 1,
		Value = {
			Min = 0,
			Max = 100,
			Default = 50,
		},
		Icons = {
			From = "sfsymbols:sunMinFill",
			To = "sfsymbols:sunMaxFill",
		},
		Callback = function(value)
			print(value)
		end,
	})
end

-- */  Dropdown Tab  /* --
do
	local DropdownTab = ElementsSection:Tab({
		Title = "Dropdown",
		Icon = "solar:hamburger-menu-bold",
		IconColor = Yellow,
		IconShape = "Square",
		Border = true,
	})

	DropdownTab:Dropdown({
		Title = "Advanced Dropdown (example)",
		Values = {
			{
				Title = "New file",
				Desc = "Create a new file",
				Icon = "file-plus",
				Callback = function()
					print("Clicked 'New File'")
				end,
			},
			{
				Title = "Copy link",
				Desc = "Copy the file link",
				Icon = "copy",
				Callback = function()
					print("Clicked 'Copy link'")
				end,
			},
			{
				Title = "Edit file",
				Desc = "Allows you to edit the file",
				Icon = "file-pen",
				Callback = function()
					print("Clicked 'Edit file'")
				end,
			},
			{
				Type = "Divider",
			},
			{
				Title = "Delete file",
				Desc = "Permanently delete the file",
				Icon = "trash",
				Callback = function()
					print("Clicked 'Delete file'")
				end,
			},
		},
	})

	DropdownTab:Space()

	DropdownTab:Dropdown({
		Title = "Multi Dropdown",
		Values = {
			"Привет",
			"Hello",
			"Сәлем",
			"Bonjour",
		},
		Value = nil,
		AllowNone = true,
		Multi = true,
		Callback = function(selectedValue)
			print("Selected: " .. selectedValue)
		end,
	})

	DropdownTab:Space()

	DropdownTab:Dropdown({
		Title = "No Multi Dropdown (default",
		Values = {
			"Привет",
			"Hello",
			"Сәлем",
			"Bonjour",
		},
		Value = 1,
		--AllowNone = true,
		Callback = function(selectedValue)
			print("Selected: " .. selectedValue)
		end,
	})

	DropdownTab:Space()
end

-- */  Config Usage  /* --
if not RunService:IsStudio() and writefile and printidentity() then
	do -- config elements
		local ConfigElementsTab = ConfigUsageSection:Tab({
			Title = "Config Elements",
			Icon = "solar:file-text-bold",
			IconColor = Blue,
			IconShape = nil,
			Border = true,
		})

		-- All elements are taken from the official documentation: https://footagesus.github.io/WindUI-Docs/docs

		-- Saving elements to the config using `Flag`

		ConfigElementsTab:Colorpicker({
			Flag = "ColorpickerTest",
			Title = "Colorpicker",
			Desc = "Colorpicker Description",
			Default = Color3.fromRGB(0, 255, 0),
			Transparency = 0,
			Locked = false,
			Callback = function(color)
				print("Background color: " .. tostring(color))
			end,
		})

		ConfigElementsTab:Space()

		ConfigElementsTab:Dropdown({
			Flag = "DropdownTest",
			Title = "Advanced Dropdown",
			Values = {
				{
					Title = "Category A",
					Icon = "bird",
				},
				{
					Title = "Category B",
					Icon = "house",
				},
				{
					Title = "Category C",
					Icon = "droplet",
				},
			},
			Value = "Category A",
			Callback = function(option)
				print("Category selected: " .. option.Title .. " with icon " .. option.Icon)
			end,
		})
		ConfigElementsTab:Dropdown({
			Flag = "DropdownTest2",
			Title = "Advanced Dropdown 2",
			Values = {
				{
					Title = "Category A",
					Icon = "bird",
				},
				{
					Title = "Category B",
					Icon = "house",
				},
				{
					Title = "Category C",
					Icon = "droplet",
					Locked = true,
				},
			},
			Value = "Category A",
			Multi = true,
			Callback = function(options)
				local titles = {}
				for _, v in ipairs(options) do
					table.insert(titles, v.Title)
				end
				print("Selected: " .. table.concat(titles, ", "))
			end,
		})

		ConfigElementsTab:Space()

		ConfigElementsTab:Input({
			Flag = "InputTest",
			Title = "Input",
			Desc = "Input Description",
			Value = "Default value",
			InputIcon = "bird",
			Type = "Input", -- or "Textarea"
			Placeholder = "Enter text...",
			Callback = function(input)
				print("Text entered: " .. input)
			end,
		})

		ConfigElementsTab:Space()

		ConfigElementsTab:Keybind({
			Flag = "KeybindTest",
			Title = "Keybind",
			Desc = "Keybind to open ui",
			Value = "G",
			Callback = function(v)
				Window:SetToggleKey(Enum.KeyCode[v])
			end,
		})

		ConfigElementsTab:Space()

		ConfigElementsTab:Slider({
			Flag = "SliderTest",
			Title = "Slider",
			Step = 1,
			Value = {
				Min = 20,
				Max = 120,
				Default = 70,
			},
			Callback = function(value)
				print(value)
			end,
		})
		ConfigElementsTab:Slider({
			Flag = "SliderTest2",
			--Title = "Slider",
			Icons = {
				From = "sfsymbols:sunMinFill",
				To = "sfsymbols:sunMaxFill",
			},
			Step = 1,
			IsTooltip = true,
			Value = {
				Min = 0,
				Max = 100,
				Default = 50,
			},
			Callback = function(value)
				print(value)
			end,
		})

		ConfigElementsTab:Space()

		ConfigElementsTab:Toggle({
			Flag = "ToggleTest",
			Title = "Toggle Panel Background",
			--Desc = "Toggle Description",
			--Icon = "house",
			--Type = "Checkbox",
			Value = not Window.HidePanelBackground,
			Callback = function(state)
				Window:SetPanelBackground(state)
			end,
		})

		ConfigElementsTab:Toggle({
			Flag = "ToggleTest",
			Title = "Toggle",
			Desc = "Toggle Description",
			--Icon = "house",
			--Type = "Checkbox",
			Value = false,
			Callback = function(state)
				print("Toggle Activated" .. tostring(state))
			end,
		})
	end

	do -- config panel
		local ConfigTab = ConfigUsageSection:Tab({
			Title = "Config Usage",
			Icon = "solar:folder-with-files-bold",
			IconColor = Purple,
			IconShape = nil,
			Border = true,
		})

		local ConfigManager = Window.ConfigManager
		local ConfigName = "default"

		local ConfigNameInput = ConfigTab:Input({
			Title = "Config Name",
			Icon = "file-cog",
			Callback = function(value)
				ConfigName = value
			end,
		})

		ConfigTab:Space()

		-- local AutoLoadToggle = ConfigTab:Toggle({
		--     Title = "Enable Auto Load to Selected Config",
		--     Value = false,
		--     Callback = function(v)
		--         Window.CurrentConfig:SetAutoLoad(v)
		--     end
		-- })

		-- ConfigTab:Space()

		local AllConfigs = ConfigManager:AllConfigs()
		local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil

		local AllConfigsDropdown = ConfigTab:Dropdown({
			Title = "All Configs",
			Desc = "Select existing configs",
			Values = AllConfigs,
			Value = DefaultValue,
			Callback = function(value)
				ConfigName = value
				ConfigNameInput:Set(value)

				--AutoLoadToggle:Set(ConfigManager:GetConfig(ConfigName).AutoLoad or false)
			end,
		})

		ConfigTab:Space()

		ConfigTab:Button({
			Title = "Save Config",
			Icon = "",
			Justify = "Center",
			Callback = function()
				Window.CurrentConfig = ConfigManager:Config(ConfigName)
				if Window.CurrentConfig:Save() then
					WindUI:Notify({
						Title = "Config Saved",
						Desc = "Config '" .. ConfigName .. "' saved",
						Icon = "check",
					})
				end

				AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
			end,
		})

		ConfigTab:Space()

		ConfigTab:Button({
			Title = "Load Config",
			Icon = "",
			Justify = "Center",
			Callback = function()
				Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
				if Window.CurrentConfig:Load() then
					WindUI:Notify({
						Title = "Config Loaded",
						Desc = "Config '" .. ConfigName .. "' loaded",
						Icon = "refresh-cw",
					})
				end
			end,
		})

		ConfigTab:Space()

		ConfigTab:Button({
			Title = "Print AutoLoad Configs",
			Icon = "",
			Justify = "Center",
			Callback = function()
				print(HttpService:JSONDecode(ConfigManager:GetAutoLoadConfigs()))
			end,
		})
	end
end

-- */  Other  /* --
do
	local InviteCode = "ftgs-development-hub-1300692552005189632"
	local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

	local Response = WindUI.cloneref(game:GetService("HttpService"))
		:JSONDecode(WindUI.Creator.Request and WindUI.Creator.Request({
			Url = DiscordAPI,
			Method = "GET",
			Headers = {
				["User-Agent"] = "WindUI/Example",
				["Accept"] = "application/json",
			},
		}).Body or "{}")

	local DiscordTab = OtherSection:Tab({
		Title = "Discord",
		Border = true,
	})

	if Response and Response.guild then
		DiscordTab:Section({
			Title = "Join our Discord server!",
			TextSize = 20,
		})
		local DiscordServerParagraph = DiscordTab:Paragraph({
			Title = tostring(Response.guild.name),
			Desc = tostring(Response.guild.description),
			Image = "https://cdn.discordapp.com/icons/"
				.. Response.guild.id
				.. "/"
				.. Response.guild.icon
				.. ".png?size=1024",
			Thumbnail = "https://cdn.discordapp.com/banners/1300692552005189632/35981388401406a4b7dffd6f447a64c4.png?size=512",
			ImageSize = 48,
			Buttons = {
				{
					Title = "Copy link",
					Icon = "link",
					Callback = function()
						setclipboard("https://discord.gg/" .. InviteCode)
					end,
				},
			},
		})
	elseif RunService:IsStudio() or not writefile then
		DiscordTab:Paragraph({
			Title = "Discord API is not available in Studio mode.",
			TextSize = 20,
			Justify = "Center",
			Image = "solar:info-circle-bold",
			Color = "Red",
			Buttons = {
				{
					Title = "Get/Copy Invite Link",
					Icon = "link",
					Callback = function()
						if setclipboard then
							setclipboard("https://discord.gg/" .. InviteCode)
						else
							WindUI:Notify({
								Title = "Discord Invite Link",
								Content = "https://discord.gg/" .. InviteCode,
							})
						end
					end,
				},
			},
		})
	else
		DiscordTab:Paragraph({
			Title = "Failed to fetch Discord server info.",
			TextSize = 20,
			Justify = "Center",
			Image = "solar:info-circle-bold",
			Color = "Red",
		})
	end
end

local Tabs = {
	ExampleTab = Window:Tab({
		Title = "Example Tab",
		Icon = "bird",
	}),
}

local dropdownA

local LargeListA = {
	"All",
	"Item A2",
	"Item A3",
	"Item A4",
	"Item A5",
	"Item A6",
	"Item A7",
	"Item A8",
	"Item A9",
	"Item A10",
	"Item A11",
	"Item A12",
	"Item A13",
	"Item A14",
	"Item A15",
	"Item A16",
	"Item A17",
	"Item A18",
	"Item A19",
	"Item A20",
	"Item A21",
	"Item A22",
	"Item A23",
	"Item A24",
	"Item A25",
	"Item A26",
	"Item A27",
	"Item A28",
	"Item A29",
	"Item A30",
	"Item A31",
	"Item A32",
	"Item A33",
	"Item A34",
	"Item A35",
	"Item A36",
	"Item A37",
	"Item A38",
	"Item A39",
	"Item A40",
	"Item A41",
	"Item A42",
	"Item A43",
	"Item A44",
	"Item A45",
	"Item A46",
	"Item A47",
	"Item A48",
	"Item A49",
	"Item A50",
	"Item A51",
	"Item A52",
	"Item A53",
	"Item A54",
	"Item A55",
	"Item A56",
	"Item A57",
	"Item A58",
	"Item A59",
	"Item A60",
	"Item A61",
	"Item A62",
	"Item A63",
	"Item A64",
	"Item A65",
	"Item A66",
	"Item A67",
	"Item A68",
	"Item A69",
	"Item A70",
	"Item A71",
	"Item A72",
	"Item A73",
	"Item A74",
	"Item A75",
	"Item A76",
	"Item A77",
	"Item A78",
	"Item A79",
	"Item A80",
	"Item A81",
	"Item A82",
	"Item A83",
	"Item A84",
	"Item A85",
	"Item A86",
	"Item A87",
	"Item A88",
	"Item A89",
	"Item A90",
	"Item A91",
	"Item A92",
	"Item A93",
	"Item A94",
	"Item A95",
	"Item A96",
	"Item A97",
	"Item A98",
	"Item A99",
	"Item A100",
}

local LargeListB = {
	"Data B1",
	"Data B2",
	"Data B3",
	"Data B4",
	"Data B5",
	"Data B6",
	"Data B7",
	"Data B8",
	"Data B9",
	"Data B10",
}

Tabs.ExampleTab:Dropdown({
	Title = "Main Category",
	Values = { "All", "Other Option" },
	Value = "All",
	Callback = function(option)
		if dropdownA then
			task.spawn(function()
				if option == "All" then
					dropdownA:Refresh(LargeListA)
				else
					dropdownA:Refresh(LargeListB)
				end

				dropdownA:Select({ "All" })
			end)
		end
	end,
})

dropdownA = Tabs.ExampleTab:Dropdown({
	Title = "Target",
	Values = LargeListA,
	Multi = true,
	Value = { "All" },
	Callback = function(option) end,
})
--[[
    ╔═══════════════════════════════════════════╗
    ║         GODZ HUB - BOOGA BOOGA REBORN    ║
    ║         Built on WindUI by Footagesus     ║
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
local HttpService       = cloneref(game:GetService("HttpService"))
local LocalPlayer       = Players.LocalPlayer

-- ============================================================
-- LOAD WINDUI
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
-- LOAD GODZ HUB BACKEND
-- ============================================================
local GodzHub = {}
local ok2, result2 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/boogag0dz-glitch/Godz-hub/main/main.lua"))()
end)
if ok2 and result2 then GodzHub = result2 end

-- ============================================================
-- GLOBAL STATE
-- ============================================================
_G.GH = _G.GH or {
    Autofarm        = false,
    AutoCollect     = false,
    AutoEat         = false,
    AutoChest       = false,
    PathfindEnabled = false,
    PathfindTarget  = nil,
    PathfindInterval= 1,
    PathfindStopDist= 5,
    SpeedLock       = false,
    CurrentSpeed    = 16,
    CurrentJump     = 50,
    InfJump         = false,
    NoFall          = false,
    Noclip          = false,
    KillAura        = false,
    KillAuraRange   = 15,
    KillAuraSpeed   = 0.5,
    AutoParry       = false,
    ESPEnabled      = false,
    MobESP          = false,
    ChestESP        = false,
    NameTags        = false,
    DistTags        = false,
    AlwaysDay       = false,
    AntiAFK         = false,
    FarmRadius      = 100,
    ESPFillColor    = Color3.fromRGB(255, 50, 50),
    ESPOutlineColor = Color3.fromRGB(255, 255, 255),
    ESPHighlights   = {},
    Connections     = {},
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Notify(title, content, duration)
    WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

local function getChar()  return LocalPlayer.Character end
local function getHum()   local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function cleanConnections()
    for k, conn in pairs(_G.GH.Connections) do
        pcall(function() conn:Disconnect() end)
        _G.GH.Connections[k] = nil
    end
end

local function applySpeed()
    local hum = getHum()
    if hum then hum.WalkSpeed = _G.GH.CurrentSpeed; hum.JumpPower = _G.GH.CurrentJump end
end

-- ============================================================
-- ESP HELPERS
-- ============================================================
local function makeHighlight(adornee, fill, outline, fillTrans, outTrans)
    local h = Instance.new("Highlight")
    h.FillColor           = fill      or Color3.fromRGB(255, 50, 50)
    h.OutlineColor        = outline   or Color3.fromRGB(255, 255, 255)
    h.FillTransparency    = fillTrans or 0.5
    h.OutlineTransparency = outTrans  or 0
    h.Adornee             = adornee
    h.Parent              = adornee
    return h
end

local function removeAllESP()
    for k, h in pairs(_G.GH.ESPHighlights) do
        pcall(function() h:Destroy() end)
        _G.GH.ESPHighlights[k] = nil
    end
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local key = "player_" .. player.Name
    if _G.GH.ESPHighlights[key] and _G.GH.ESPHighlights[key].Parent then return end
    _G.GH.ESPHighlights[key] = makeHighlight(char, _G.GH.ESPFillColor, _G.GH.ESPOutlineColor)
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window = WindUI:CreateWindow({
    Title         = "Godz Hub  •  Booga Booga Reborn",
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
        Color           = ColorSequence.new(
            Color3.fromHex("#30FF6A"),
            Color3.fromHex("#e7ff2f")
        ),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green  = Color3.fromHex("#10C550")
local Grey   = Color3.fromHex("#83889E")
local Blue   = Color3.fromHex("#257AF7")
local Red    = Color3.fromHex("#EF4F1D")
local Orange = Color3.fromHex("#FF8C00")
local Cyan   = Color3.fromHex("#00D4FF")

Window:Tag({ Title = "v1.0.0", Icon = "github", Color = Color3.fromHex("#1c1c1c"), Border = true })

-- ============================================================
-- SECTIONS
-- ============================================================
local FarmSection   = Window:Section({ Title = "Farming" })
local MoveSection   = Window:Section({ Title = "Movement & Combat" })
local VisualSection = Window:Section({ Title = "Visuals" })
local MiscSection   = Window:Section({ Title = "Misc" })

-- ============================================================
-- AUTOFARM TAB
-- ============================================================
local AutofarmTab = FarmSection:Tab({
    Title = "Autofarm", Icon = "solar:check-square-bold",
    IconColor = Green, IconShape = "Square", Border = true,
})

do
    AutofarmTab:Section({ Title = "Resource Farming" })

    local resourceTypes  = { "All", "Wood", "Stone", "Leaves", "Fiber", "Berries" }
    local selectedRes    = "All"

    AutofarmTab:Dropdown({
        Title = "Resource Type", Desc = "What to target when farming",
        Values = resourceTypes, Value = "All",
        Callback = function(v) selectedRes = v end,
    })

    AutofarmTab:Space()

    AutofarmTab:Slider({
        Title = "Farm Search Radius",
        Desc  = "How far to look for resources (studs)",
        Step  = 10, Value = { Min = 10, Max = 500, Default = 150 },
        Callback = function(v) _G.GH.FarmRadius = v end,
    })

    AutofarmTab:Space()

    AutofarmTab:Slider({
        Title = "Farm Loop Delay (s)",
        Desc  = "Time between each farm cycle",
        Step  = 0.1, Value = { Min = 0.1, Max = 3, Default = 0.5 },
        Callback = function(v) _G.GH.FarmDelay = v end,
    })

    AutofarmTab:Space()

    AutofarmTab:Toggle({
        Title = "Enable Resource Autofarm",
        Desc  = "Automatically teleports to and collects nearby resources",
        Value = false,
        Callback = function(state)
            _G.GH.Autofarm = state
            if GodzHub and GodzHub.SetAutofarm then
                GodzHub.SetAutofarm(state, selectedRes)
            elseif state then
                task.spawn(function()
                    while _G.GH.Autofarm do
                        local root = getRoot()
                        if root then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if not _G.GH.Autofarm then break end
                                if obj:IsA("Model") then
                                    local prompt = obj:FindFirstChild("ResourcePrompt")
                                        or obj:FindFirstChild("PickupPrompt")
                                        or obj:FindFirstChild("HarvestPrompt")
                                    if prompt then
                                        local part = obj:FindFirstChild("HumanoidRootPart")
                                            or obj:FindFirstChildWhichIsA("BasePart")
                                        if part then
                                            local dist = (root.Position - part.Position).Magnitude
                                            if dist <= (_G.GH.FarmRadius or 150) then
                                                local nameMatch = selectedRes == "All"
                                                    or obj.Name:lower():find(selectedRes:lower())
                                                if nameMatch then
                                                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                                                    task.wait(0.1)
                                                    pcall(fireproximityprompt, prompt)
                                                    task.wait(0.25)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(_G.GH.FarmDelay or 0.5)
                    end
                end)
            end
            Notify("Autofarm", state and "Farming: " .. selectedRes or "Autofarm stopped.")
        end,
    })

    AutofarmTab:Space()

    AutofarmTab:Toggle({
        Title = "Auto Collect Ground Drops",
        Desc  = "Teleports to and picks up any item drops on the ground",
        Value = false,
        Callback = function(state)
            _G.GH.AutoCollect = state
            if state then
                task.spawn(function()
                    while _G.GH.AutoCollect do
                        local root = getRoot()
                        if root then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if not _G.GH.AutoCollect then break end
                                if (obj.Name == "Drop" or obj.Name == "ItemDrop" or obj.Name == "Pickup")
                                    and obj:IsA("BasePart") then
                                    local dist = (root.Position - obj.Position).Magnitude
                                    if dist < 300 then
                                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                                        task.wait(0.15)
                                    end
                                end
                            end
                        end
                        task.wait(0.4)
                    end
                end)
            end
            Notify("Auto Collect", state and "Collecting ground drops." or "Stopped.")
        end,
    })

    AutofarmTab:Space()

    AutofarmTab:Toggle({
        Title = "Auto Eat Food",
        Desc  = "Fires the eat remote every few seconds to keep hunger up",
        Value = false,
        Callback = function(state)
            _G.GH.AutoEat = state
            if GodzHub and GodzHub.SetAutoEat then
                GodzHub.SetAutoEat(state)
            elseif state then
                task.spawn(function()
                    while _G.GH.AutoEat do
                        local remote = ReplicatedStorage:FindFirstChild("EatFood")
                            or ReplicatedStorage:FindFirstChild("UseItem")
                        if remote and remote:IsA("RemoteEvent") then
                            pcall(function() remote:FireServer("Food") end)
                        end
                        task.wait(5)
                    end
                end)
            end
            Notify("Auto Eat", state and "Auto eat enabled." or "Auto eat disabled.")
        end,
    })

    AutofarmTab:Space()
    AutofarmTab:Section({ Title = "Chest Farming" })

    AutofarmTab:Toggle({
        Title = "Auto Open Chests",
        Desc  = "Finds and opens every chest/crate on the map",
        Value = false,
        Callback = function(state)
            _G.GH.AutoChest = state
            if state then
                task.spawn(function()
                    while _G.GH.AutoChest do
                        local root = getRoot()
                        if root then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if not _G.GH.AutoChest then break end
                                local n = obj.Name:lower()
                                if obj:IsA("Model") and (n:find("chest") or n:find("crate")) then
                                    local part = obj:FindFirstChildWhichIsA("BasePart")
                                    if part then
                                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                                        task.wait(0.2)
                                        for _, p2 in ipairs(obj:GetDescendants()) do
                                            if p2:IsA("ProximityPrompt") then
                                                pcall(fireproximityprompt, p2)
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(2)
                    end
                end)
            end
            Notify("Auto Chest", state and "Now farming chests!" or "Chest farm stopped.")
        end,
    })

    AutofarmTab:Space()

    AutofarmTab:Button({
        Title = "Collect Nearest Chest Now", Icon = "box", Justify = "Center",
        Callback = function()
            local root = getRoot()
            if not root then return end
            local nearest, nearestDist = nil, math.huge
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if obj:IsA("Model") and (n:find("chest") or n:find("crate")) then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local d = (root.Position - part.Position).Magnitude
                        if d < nearestDist then nearest = obj; nearestDist = d end
                    end
                end
            end
            if nearest then
                local part = nearest:FindFirstChildWhichIsA("BasePart")
                root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.2)
                for _, p2 in ipairs(nearest:GetDescendants()) do
                    if p2:IsA("ProximityPrompt") then pcall(fireproximityprompt, p2) end
                end
                Notify("Chest", "Opened nearest chest!")
            else
                Notify("Chest", "No chests found.")
            end
        end,
    })

    AutofarmTab:Space()
    AutofarmTab:Section({ Title = "Auto Craft" })

    local craftItems  = { "Stone Axe", "Stone Sword", "Stone Pickaxe", "Wood Wall", "Wood Door", "Campfire", "Torch" }
    local selectedCraft = craftItems[1]

    AutofarmTab:Dropdown({
        Title = "Item to Craft", Values = craftItems, Value = craftItems[1],
        Callback = function(v) selectedCraft = v end,
    })

    AutofarmTab:Space()

    AutofarmTab:Button({
        Title = "Craft Selected Item", Icon = "hammer", Justify = "Center",
        Callback = function()
            if GodzHub and GodzHub.Craft then
                GodzHub.Craft(selectedCraft)
            else
                local remote = ReplicatedStorage:FindFirstChild("CraftItem")
                if remote then
                    pcall(function() remote:FireServer(selectedCraft) end)
                    Notify("Craft", "Crafted: " .. selectedCraft)
                else
                    Notify("Craft", "Craft remote not found in ReplicatedStorage.")
                end
            end
        end,
    })
end

-- ============================================================
-- PATHFINDING TAB
-- ============================================================
local PathfindTab = FarmSection:Tab({
    Title = "Pathfinding", Icon = "solar:cursor-square-bold",
    IconColor = Blue, IconShape = "Square", Border = true,
})

do
    PathfindTab:Section({ Title = "Player Follower" })

    PathfindTab:Paragraph({
        Title = "How to use",
        Desc  = "Select a player from the dropdown below, configure your settings, then toggle pathfinding. Your character will automatically navigate to that player using Roblox's pathfinding engine with jump support.",
    })

    PathfindTab:Space()

    local function getPlayerNames()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        return t
    end

    local PathDropdown = PathfindTab:Dropdown({
        Title    = "Target Player",
        Desc     = "The player your character will walk toward",
        Values   = getPlayerNames(),
        AllowNone= true,
        Callback = function(v) _G.GH.PathfindTarget = v end,
    })

    PathfindTab:Space()

    PathfindTab:Button({
        Title = "Refresh Player List", Icon = "refresh-cw", Justify = "Center",
        Callback = function()
            PathDropdown:Refresh(getPlayerNames())
            Notify("Pathfinding", "Player list refreshed.")
        end,
    })

    PathfindTab:Space()

    PathfindTab:Slider({
        Title = "Recalculate Interval (s)",
        Desc  = "How often the path recalculates while following",
        Step  = 0.5, Value = { Min = 0.5, Max = 5, Default = 1 },
        Callback = function(v) _G.GH.PathfindInterval = v end,
    })

    PathfindTab:Space()

    PathfindTab:Slider({
        Title = "Stop Distance (studs)",
        Desc  = "How close to get to the target before stopping",
        Step  = 1, Value = { Min = 1, Max = 30, Default = 5 },
        Callback = function(v) _G.GH.PathfindStopDist = v end,
    })

    PathfindTab:Space()

    PathfindTab:Toggle({
        Title = "Enable Pathfinding Follow",
        Desc  = "Your character will walk toward the selected player",
        Value = false,
        Callback = function(state)
            _G.GH.PathfindEnabled = state
            if GodzHub and GodzHub.SetPathfind then
                GodzHub.SetPathfind(state, _G.GH.PathfindTarget)
            elseif state then
                task.spawn(function()
                    while _G.GH.PathfindEnabled do
                        local targetName = _G.GH.PathfindTarget
                        if targetName then
                            local tp    = Players:FindFirstChild(targetName)
                            local myRoot= getRoot()
                            local hum   = getHum()
                            if tp and tp.Character and myRoot and hum then
                                local tRoot = tp.Character:FindFirstChild("HumanoidRootPart")
                                if tRoot then
                                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                                    if dist > (_G.GH.PathfindStopDist or 5) then
                                        local path = PathfindingService:CreatePath({
                                            AgentHeight = 5, AgentRadius = 2, AgentCanJump = true,
                                        })
                                        local ok3 = pcall(function()
                                            path:ComputeAsync(myRoot.Position, tRoot.Position)
                                        end)
                                        if ok3 and path.Status == Enum.PathStatus.Success then
                                            for _, wp in ipairs(path:GetWaypoints()) do
                                                if not _G.GH.PathfindEnabled then break end
                                                hum:MoveTo(wp.Position)
                                                if wp.Action == Enum.PathWaypointAction.Jump then
                                                    hum.Jump = true
                                                end
                                                local moved = hum.MoveToFinished:Wait(1.5)
                                                if not moved then break end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(_G.GH.PathfindInterval or 1)
                    end
                    local hum = getHum()
                    if hum and getRoot() then hum:MoveTo(getRoot().Position) end
                end)
            end
            Notify("Pathfinding",
                state and "Now following: " .. (_G.GH.PathfindTarget or "no one selected")
                or "Pathfinding stopped.")
        end,
    })

    PathfindTab:Space()
    PathfindTab:Section({ Title = "Coordinate Teleport" })

    PathfindTab:Paragraph({
        Title = "Manual Teleport",
        Desc  = "Enter X Y Z coordinates to instantly teleport your character to any position on the map.",
    })

    local tpX, tpY, tpZ = 0, 0, 0

    PathfindTab:Input({
        Title = "X", Desc = "X coordinate", Placeholder = "0",
        Callback = function(v) tpX = tonumber(v) or 0 end,
    })
    PathfindTab:Input({
        Title = "Y", Desc = "Y coordinate", Placeholder = "0",
        Callback = function(v) tpY = tonumber(v) or 0 end,
    })
    PathfindTab:Input({
        Title = "Z", Desc = "Z coordinate", Placeholder = "0",
        Callback = function(v) tpZ = tonumber(v) or 0 end,
    })

    PathfindTab:Space()

    PathfindTab:Button({
        Title = "Teleport to Coordinates", Icon = "map-pin", Justify = "Center",
        Callback = function()
            local root = getRoot()
            if root then
                root.CFrame = CFrame.new(tpX, tpY, tpZ)
                Notify("Teleport", ("Teleported to %d, %d, %d"):format(tpX, tpY, tpZ))
            end
        end,
    })

    PathfindTab:Space()

    PathfindTab:Button({
        Title = "Copy My Position to Clipboard", Icon = "copy", Justify = "Center",
        Callback = function()
            local root = getRoot()
            if root then
                local p   = root.Position
                local str = ("%d, %d, %d"):format(math.round(p.X), math.round(p.Y), math.round(p.Z))
                if setclipboard then setclipboard(str) end
                Notify("Position", "Copied: " .. str)
            end
        end,
    })

    PathfindTab:Space()

    PathfindTab:Button({
        Title = "Teleport to Spawn", Icon = "home", Justify = "Center",
        Callback = function()
            local spawn = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChildWhichIsA("SpawnLocation")
            local root  = getRoot()
            if spawn and root then
                root.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                Notify("Teleport", "Teleported to spawn.")
            else
                Notify("Teleport", "Could not find spawn location.")
            end
        end,
    })
end

-- ============================================================
-- MOVEMENT TAB
-- ============================================================
local SpeedTab = MoveSection:Tab({
    Title = "Movement", Icon = "solar:square-transfer-horizontal-bold",
    IconColor = Yellow, IconShape = "Square", Border = true,
})

do
    SpeedTab:Section({ Title = "Speed & Jump" })

    SpeedTab:Slider({
        Flag  = "WalkSpeedSlider",
        Title = "Walk Speed",
        Desc  = "Your character's movement speed (default: 16)",
        Step  = 1, Value = { Min = 1, Max = 21, Default = 16 },
        Callback = function(v)
            _G.GH.CurrentSpeed = v
            local hum = getHum()
            if hum then hum.WalkSpeed = v end
        end,
    })

    SpeedTab:Space()

    SpeedTab:Slider({
        Flag  = "JumpPowerSlider",
        Title = "Jump Power",
        Desc  = "Your character's jump height (default: 50)",
        Step  = 1, Value = { Min = 1, Max = 200, Default = 50 },
        Callback = function(v)
            _G.GH.CurrentJump = v
            local hum = getHum()
            if hum then hum.JumpPower = v end
        end,
    })

    SpeedTab:Space()

    SpeedTab:Toggle({
        Flag  = "SpeedLock",
        Title = "Speed Lock (Survive Respawn)",
        Desc  = "Re-applies your speed and jump power after you die and respawn",
        Value = false,
        Callback = function(state)
            _G.GH.SpeedLock = state
            if state then
                _G.GH.Connections.SpeedLock = LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.6)
                    applySpeed()
                end)
            else
                if _G.GH.Connections.SpeedLock then
                    _G.GH.Connections.SpeedLock:Disconnect()
                    _G.GH.Connections.SpeedLock = nil
                end
            end
            Notify("Speed Lock", state and "Speed will persist on respawn." or "Speed lock disabled.")
        end,
    })

    SpeedTab:Space()

    SpeedTab:Button({
        Title = "Reset Speed & Jump to Default", Icon = "refresh-cw", Justify = "Center",
        Callback = function()
            _G.GH.CurrentSpeed = 16
            _G.GH.CurrentJump  = 50
            local hum = getHum()
            if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
            Notify("Movement", "Speed and jump reset to default values.")
        end,
    })

    SpeedTab:Space()
    SpeedTab:Section({ Title = "Utility Movement" })

    SpeedTab:Toggle({
        Title = "Infinite Jump",
        Desc  = "Lets you jump an unlimited number of times mid-air",
        Value = false,
        Callback = function(state)
            _G.GH.InfJump = state
            if state then
                _G.GH.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                    if _G.GH.InfJump then
                        local hum = getHum()
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            else
                if _G.GH.Connections.InfJump then
                    _G.GH.Connections.InfJump:Disconnect()
                    _G.GH.Connections.InfJump = nil
                end
            end
            Notify("Infinite Jump", state and "Infinite jump ON!" or "Infinite jump OFF.")
        end,
    })

    SpeedTab:Space()

    SpeedTab:Toggle({
        Title = "No Fall Damage",
        Desc  = "Prevents your character from taking damage when falling",
        Value = false,
        Callback = function(state)
            _G.GH.NoFall = state
            if state then
                _G.GH.Connections.NoFall = RunService.Stepped:Connect(function()
                    if _G.GH.NoFall then
                        local hum = getHum()
                        if hum then
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        end
                    end
                end)
            else
                if _G.GH.Connections.NoFall then
                    _G.GH.Connections.NoFall:Disconnect()
                    _G.GH.Connections.NoFall = nil
                end
            end
            Notify("No Fall Damage", state and "No fall damage enabled." or "Fall damage restored.")
        end,
    })

    SpeedTab:Space()

    SpeedTab:Toggle({
        Title = "Noclip",
        Desc  = "Allows you to walk through walls and terrain",
        Value = false,
        Callback = function(state)
            _G.GH.Noclip = state
            if state then
                _G.GH.Connections.Noclip = RunService.Stepped:Connect(function()
                    if _G.GH.Noclip then
                        local char = getChar()
                        if char then
                            for _, p in ipairs(char:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end
                    end
                end)
            else
                if _G.GH.Connections.Noclip then
                    _G.GH.Connections.Noclip:Disconnect()
                    _G.GH.Connections.Noclip = nil
                end
                local char = getChar()
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
            end
            Notify("Noclip", state and "Noclip ON — you can walk through walls." or "Noclip OFF.")
        end,
    })

    SpeedTab:Space()

    SpeedTab:Toggle({
        Title = "Fly (Hover Mode)",
        Desc  = "Lets your character float and fly around freely",
        Value = false,
        Callback = function(state)
            _G.GH.Fly = state
            if state then
                local root = getRoot()
                if not root then return end
                local bg = Instance.new("BodyGyro")
                bg.D = 9000; bg.P = 1e6; bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
                bg.Parent = root
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bv.Parent = root
                _G.GH.FlyBG = bg
                _G.GH.FlyBV = bv
                _G.GH.Connections.Fly = RunService.Heartbeat:Connect(function()
                    if not _G.GH.Fly then return end
                    local cam = Workspace.CurrentCamera
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                    bv.Velocity = dir * 50
                    bg.CFrame   = cam.CFrame
                end)
            else
                if _G.GH.Connections.Fly then
                    _G.GH.Connections.Fly:Disconnect()
                    _G.GH.Connections.Fly = nil
                end
                if _G.GH.FlyBG then _G.GH.FlyBG:Destroy() end
                if _G.GH.FlyBV then _G.GH.FlyBV:Destroy() end
            end
            Notify("Fly", state and "Fly enabled! Use WASD + Space/Shift." or "Fly disabled.")
        end,
    })
end

-- ============================================================
-- COMBAT TAB
-- ============================================================
local CombatTab = MoveSection:Tab({
    Title = "Combat", Icon = "solar:cursor-square-bold",
    IconColor = Red, IconShape = "Square", Border = true,
})

do
    CombatTab:Section({ Title = "Kill Aura" })

    CombatTab:Slider({
        Title = "Kill Aura Range (studs)",
        Desc  = "How far kill aura will reach to attack",
        Step  = 1, Value = { Min = 5, Max = 60, Default = 15 },
        Callback = function(v) _G.GH.KillAuraRange = v end,
    })

    CombatTab:Space()

    CombatTab:Slider({
        Title = "Attack Interval (s)",
        Desc  = "Time between each kill aura attack",
        Step  = 0.05, Value = { Min = 0.05, Max = 2, Default = 0.5 },
        Callback = function(v) _G.GH.KillAuraSpeed = v end,
    })

    CombatTab:Space()

    CombatTab:Toggle({
        Title = "Kill Aura (Mobs Only)",
        Desc  = "Automatically attacks nearby mobs and entities, not players",
        Value = false,
        Callback = function(state)
            _G.GH.KillAura = state
            if GodzHub and GodzHub.SetKillAura then
                GodzHub.SetKillAura(state)
            elseif state then
                task.spawn(function()
                    while _G.GH.KillAura do
                        local root = getRoot()
                        if root then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if not _G.GH.KillAura then break end
                                local hum = obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    local isPlayer = false
                                    for _, p in ipairs(Players:GetPlayers()) do
                                        if p.Character == obj then isPlayer = true; break end
                                    end
                                    if not isPlayer then
                                        local part = obj:FindFirstChild("HumanoidRootPart")
                                        if part then
                                            local d = (root.Position - part.Position).Magnitude
                                            if d <= (_G.GH.KillAuraRange or 15) then
                                                local atk = ReplicatedStorage:FindFirstChild("Attack")
                                                    or ReplicatedStorage:FindFirstChild("DealDamage")
                                                if atk then
                                                    pcall(function() atk:FireServer(obj) end)
                                                else
                                                    pcall(function() hum:TakeDamage(10) end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(_G.GH.KillAuraSpeed or 0.5)
                    end
                end)
            end
            Notify("Kill Aura", state and "Kill aura activated!" or "Kill aura deactivated.")
        end,
    })

    CombatTab:Space()
    CombatTab:Section({ Title = "Defense" })

    CombatTab:Toggle({
        Title = "Auto Block / Parry",
        Desc  = "Continuously fires the block remote to defend against attacks",
        Value = false,
        Callback = function(state)
            _G.GH.AutoParry = state
            if GodzHub and GodzHub.SetAutoParry then
                GodzHub.SetAutoParry(state)
            elseif state then
                task.spawn(function()
                    while _G.GH.AutoParry do
                        local remote = ReplicatedStorage:FindFirstChild("Block")
                            or ReplicatedStorage:FindFirstChild("Parry")
                        if remote then pcall(function() remote:FireServer(true) end) end
                        task.wait(0.1)
                    end
                end)
            end
            Notify("Auto Parry", state and "Auto parry active." or "Parry disabled.")
        end,
    })
end

-- ============================================================
-- ESP TAB
-- ============================================================
local EspTab = VisualSection:Tab({
    Title = "ESP", Icon = "solar:info-square-bold",
    IconColor = Cyan, IconShape = "Square", Border = true,
})

do
    EspTab:Section({ Title = "Player ESP" })

    EspTab:Toggle({
        Title = "Player ESP",
        Desc  = "Highlights all players through walls with a colored glow",
        Value = false,
        Callback = function(state)
            _G.GH.ESPEnabled = state
            if GodzHub and GodzHub.SetESP then
                GodzHub.SetESP(state)
            else
                if state then
                    for _, p in ipairs(Players:GetPlayers()) do applyPlayerESP(p) end
                    _G.GH.Connections.ESPRefresh = RunService.Heartbeat:Connect(function()
                        if not _G.GH.ESPEnabled then return end
                        for _, p in ipairs(Players:GetPlayers()) do
                            local key = "player_" .. p.Name
                            local h   = _G.GH.ESPHighlights[key]
                            if not h or not h.Parent then applyPlayerESP(p) end
                        end
                    end)
                else
                    if _G.GH.Connections.ESPRefresh then
                        _G.GH.Connections.ESPRefresh:Disconnect()
                        _G.GH.Connections.ESPRefresh = nil
                    end
                    removeAllESP()
                end
            end
            Notify("ESP", state and "Player ESP enabled!" or "Player ESP disabled.")
        end,
    })

    EspTab:Space()

    EspTab:Colorpicker({
        Title = "ESP Fill Color", Default = Color3.fromRGB(255, 50, 50),
        Callback = function(color)
            _G.GH.ESPFillColor = color
            for _, h in pairs(_G.GH.ESPHighlights) do
                if h and h.Parent then h.FillColor = color end
            end
        end,
    })

    EspTab:Space()

    EspTab:Colorpicker({
        Title = "ESP Outline Color", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(color)
            _G.GH.ESPOutlineColor = color
            for _, h in pairs(_G.GH.ESPHighlights) do
                if h and h.Parent then h.OutlineColor = color end
            end
        end,
    })

    EspTab:Space()

    EspTab:Slider({
        Title = "Fill Transparency",
        Desc  = "0 = fully solid highlight, 1 = invisible",
        Step  = 0.05, Value = { Min = 0, Max = 1, Default = 0.5 },
        Callback = function(v)
            for _, h in pairs(_G.GH.ESPHighlights) do
                if h and h.Parent then h.FillTransparency = v end
            end
        end,
    })

    EspTab:Space()
    EspTab:Section({ Title = "Mob & World ESP" })

    EspTab:Toggle({
        Title = "Mob ESP",
        Desc  = "Highlights all enemy NPCs and mobs in orange",
        Value = false,
        Callback = function(state)
            _G.GH.MobESP = state
            if state then
                task.spawn(function()
                    while _G.GH.MobESP do
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                                local isPlayer = false
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.Character == obj then isPlayer = true; break end
                                end
                                if not isPlayer and not obj:FindFirstChildOfClass("Highlight") then
                                    makeHighlight(obj, Color3.fromRGB(255,165,0), Color3.fromRGB(255,255,0))
                                end
                            end
                        end
                        task.wait(3)
                    end
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") then
                            local h = obj:FindFirstChildOfClass("Highlight")
                            if h then h:Destroy() end
                        end
                    end
                end)
            end
            Notify("Mob ESP", state and "Mob ESP enabled!" or "Mob ESP disabled.")
        end,
    })

    EspTab:Space()

    EspTab:Toggle({
        Title = "Chest ESP",
        Desc  = "Highlights all chests and crates on the map in gold",
        Value = false,
        Callback = function(state)
            _G.GH.ChestESP = state
            if state then
                task.spawn(function()
                    while _G.GH.ChestESP do
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            local n = obj.Name:lower()
                            if obj:IsA("Model") and (n:find("chest") or n:find("crate"))
                                and not obj:FindFirstChildOfClass("Highlight") then
                                makeHighlight(obj, Color3.fromRGB(255,215,0), Color3.fromRGB(255,140,0), 0.3)
                            end
                        end
                        task.wait(3)
                    end
                end)
            end
            Notify("Chest ESP", state and "Chest ESP enabled!" or "Chest ESP disabled.")
        end,
    })

    EspTab:Space()
    EspTab:Section({ Title = "Name & Distance Tags" })

    EspTab:Toggle({
        Title = "Player Name Tags",
        Desc  = "Shows a floating name label above every player's head",
        Value = false,
        Callback = function(state)
            _G.GH.NameTags = state
            if state then
                task.spawn(function()
                    while _G.GH.NameTags do
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local head = p.Character:FindFirstChild("Head")
                                if head and not head:FindFirstChild("GHNameTag") then
                                    local bb = Instance.new("BillboardGui")
                                    bb.Name = "GHNameTag"; bb.Size = UDim2.new(0,130,0,40)
                                    bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.AlwaysOnTop = true
                                    bb.Parent = head

                                    local bg = Instance.new("Frame")
                                    bg.Size = UDim2.new(1,0,1,0)
                                    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
                                    bg.BackgroundTransparency = 0.5; bg.BorderSizePixel = 0; bg.Parent = bb
                                    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,6); corner.Parent = bg

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
                                    lbl.Text = p.Name; lbl.TextColor3 = Color3.fromRGB(255,255,255)
                                    lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                                    lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true; lbl.Parent = bb
                                end
                            end
                        end
                        task.wait(2)
                    end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then
                            local head = p.Character:FindFirstChild("Head")
                            if head then local t = head:FindFirstChild("GHNameTag"); if t then t:Destroy() end end
                        end
                    end
                end)
            end
            Notify("Name Tags", state and "Name tags enabled!" or "Name tags disabled.")
        end,
    })

    EspTab:Space()

    EspTab:Toggle({
        Title = "Distance Tags",
        Desc  = "Shows the stud distance to each player above their head, updating every 0.5s",
        Value = false,
        Callback = function(state)
            _G.GH.DistTags = state
            if state then
                task.spawn(function()
                    while _G.GH.DistTags do
                        local root = getRoot()
                        if root then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character then
                                    local head  = p.Character:FindFirstChild("Head")
                                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                                    if head and pRoot then
                                        local dist = math.round((root.Position - pRoot.Position).Magnitude)
                                        local tag  = head:FindFirstChild("GHDistTag")
                                        if not tag then
                                            local bb = Instance.new("BillboardGui")
                                            bb.Name = "GHDistTag"; bb.Size = UDim2.new(0, 80, 0, 25)
                                            bb.StudsOffset = Vector3.new(0, 5.8, 0); bb.AlwaysOnTop = true; bb.Parent = head
                                            local lbl = Instance.new("TextLabel")
                                            lbl.Name = "DistLabel"; lbl.Size = UDim2.new(1,0,1,0)
                                            lbl.BackgroundTransparency = 1
                                            lbl.TextColor3 = Color3.fromRGB(255,255,100)
                                            lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.Gotham
                                            lbl.TextScaled = true; lbl.Text = dist .. "m"; lbl.Parent = bb
                                        else
                                            local lbl = tag:FindFirstChild("DistLabel")
                                            if lbl then lbl.Text = dist .. "m" end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then
                            local head = p.Character:FindFirstChild("Head")
                            if head then local t = head:FindFirstChild("GHDistTag"); if t then t:Destroy() end end
                        end
                    end
                end)
            end
            Notify("Distance Tags", state and "Distance tags enabled!" or "Distance tags disabled.")
        end,
    })
end

-- ============================================================
-- MISC TAB
-- ============================================================
local MiscTab = MiscSection:Tab({
    Title = "Misc", Icon = "solar:home-2-bold",
    IconColor = Purple, IconShape = "Square", Border = true,
})

do
    MiscTab:Section({ Title = "Quality of Life" })

    MiscTab:Toggle({
        Title = "Anti-AFK",
        Desc  = "Prevents Roblox from kicking you for being idle",
        Value = false,
        Callback = function(state)
            _G.GH.AntiAFK = state
            if state then
                _G.GH.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
                    if _G.GH.AntiAFK then
                        local vu = game:GetService("VirtualUser")
                        vu:Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        vu:Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
                    end
                end)
            else
                if _G.GH.Connections.AntiAFK then
                    _G.GH.Connections.AntiAFK:Disconnect()
                    _G.GH.Connections.AntiAFK = nil
                end
            end
            Notify("Anti-AFK", state and "Anti-AFK enabled." or "Anti-AFK disabled.")
        end,
    })

    MiscTab:Space()

    MiscTab:Toggle({
        Title = "Always Day (Client)",
        Desc  = "Locks the sky to noon — does not affect other players",
        Value = false,
        Callback = function(state)
            _G.GH.AlwaysDay = state
            if state then
                _G.GH.Connections.AlwaysDay = RunService.Heartbeat:Connect(function()
                    if _G.GH.AlwaysDay then
                        game:GetService("Lighting").TimeOfDay = "12:00:00"
                        game:GetService("Lighting").Brightness = 2
                    end
                end)
            else
                if _G.GH.Connections.AlwaysDay then
                    _G.GH.Connections.AlwaysDay:Disconnect()
                    _G.GH.Connections.AlwaysDay = nil
                end
            end
            Notify("Lighting", state and "Always day enabled." or "Lighting restored.")
        end,
    })

    MiscTab:Space()

    MiscTab:Slider({
        Title = "Field of View",
        Desc  = "Adjusts your camera's field of view (default: 70)",
        Step  = 1, Value = { Min = 30, Max = 120, Default = 70 },
        Callback = function(v)
            Workspace.CurrentCamera.FieldOfView = v
        end,
    })

    MiscTab:Space()

    MiscTab:Slider({
        Title = "Game Speed (TimeScale)",
        Desc  = "Changes how fast the game runs on your client",
        Step  = 0.25, Value = { Min = 0.25, Max = 3, Default = 1 },
        Callback = function(v)
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            -- Adjust via workspace gravity perception (client-side feel)
            _G.GH.TimeScale = v
        end,
    })

    MiscTab:Space()
    MiscTab:Section({ Title = "Server Tools" })

    MiscTab:Button({
        Title = "Copy Server ID", Icon = "copy", Justify = "Center",
        Callback = function()
            if setclipboard then
                setclipboard(game.JobId)
                Notify("Server", "Server ID copied!")
            end
        end,
    })

    MiscTab:Space()

    MiscTab:Button({
        Title = "Rejoin Same Server", Icon = "refresh-cw", Justify = "Center",
        Callback = function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end,
    })

    MiscTab:Space()

    MiscTab:Button({
        Title = "Hop to New Server", Icon = "log-out", Justify = "Center",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end,
    })

    MiscTab:Space()
    MiscTab:Section({ Title = "Script Info" })

    MiscTab:Paragraph({
        Title = "Godz Hub — Booga Booga Reborn",
        Desc  = "Script by Godz Hub\nUI powered by WindUI (Footagesus)\nVersion 1.0.0\n\nFeatures:\n• Autofarm (resources, drops, chests, auto eat, auto craft)\n• Pathfinding (player follow + coordinate teleport)\n• Movement (speed, jump, noclip, fly, infinite jump, no fall)\n• Combat (kill aura, auto parry)\n• ESP (player, mob, chest, name tags, distance tags)\n• Misc (anti-afk, FOV, always day, server tools)",
    })

    MiscTab:Space()

    MiscTab:Button({
        Title = "Destroy UI", Color = Color3.fromHex("#ff4830"),
        Icon = "trash", Justify = "Center",
        Callback = function()
            cleanConnections()
            Window:Destroy()
        end,
    })
end
