local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt")()
-- https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt
-- Original Maker: https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt

local win = lib:Window("ArchiveHub V5 UI", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local tab = win:Tab("Tab Example")

tab:Button("Button", function()
    lib:Notification("Notification", "Hello!", "Hi!")
end)

tab:Toggle("Toggle", false, function(t)
    print(t)
end)

tab:Slider("Slider", 0, 100, 30, function(t)
    print(t)
end)

tab:Dropdown("Dropdown", {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}, function(t)
    print(t)
end)

tab:Colorpicker("Colorpicker", Color3.fromRGB(255, 0, 0), function(t)
    print(t)
end)

tab:Textbox("Textbox", true, function(t)
    print(t)
end)

tab:Bind("Bind", Enum.KeyCode.RightShift, function()
    print("Pressed!")
end)

tab:Label("Label")

local changeclr = win:Tab("Change UI Color")
changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)

-- Toggle UI Visibility
local isUIVisible = true
local toggleUI = Instance.new("TextButton")

toggleUI.Parent = game:GetService("CoreGui") -- Ensure it appears properly
toggleUI.Size = UDim2.new(0, 150, 0, 30)
toggleUI.Position = UDim2.new(0.5, -75, 0, 10) -- Centered at top middle
toggleUI.BackgroundColor3 = Color3.fromRGB(44, 120, 224)
toggleUI.Text = "Hide UI"
toggleUI.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUI.Font = Enum.Font.SourceSansBold
toggleUI.TextSize = 18
toggleUI.Draggable = false -- Prevent dragging
toggleUI.Active = true
toggleUI.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    win:Toggle(isUIVisible)
    toggleUI.Text = isUIVisible and "Hide UI" or "Show UI"
end)
