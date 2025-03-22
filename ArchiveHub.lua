local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()
-- Original Maker: https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt

local win = lib:Window("ArchiveHub || GAME NAME HERE", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
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

-- Player Tab
local playerTab = win:Tab("Player Settings")

playerTab:Slider("Walk Speed", 16, 100, 16, function(speed)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end)

playerTab:Slider("Jump Power", 50, 200, 50, function(jumpPower)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

playerTab:Toggle("No Clip (Walk Through Walls)", false, function(enabled)
    local player = game.Players.LocalPlayer
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if enabled then
        if humanoidRootPart then
            humanoidRootPart.CanCollide = false
        end
    else
        if humanoidRootPart then
            humanoidRootPart.CanCollide = true
        end
    end
end)
