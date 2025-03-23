local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()
-- Original Maker: https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt

local scriptHubName = "ArchiveHub"  -- Your custom script name
local devName = "GhosttedXV"  -- Developer Name

local gameName = gameName or "Unknown Game"
local win = lib:Window(scriptHubName .. " || " .. gameName, devName, Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local tab = win:Tab("Tab Example")

tab:Label("Example Label")
tab:Label("This a update that I made so far in this script, you can see the recent update below. For the full update log check at my github (github.com/exvhoria)! \n\nUpdate:\n1. ESP Bones\n2. Fullbright removed\n3. Add Noclip")

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

local changeclr = win:Tab("Change UI Color")
changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)

-- Player Settings Tab
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
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

playerTab:Toggle("No Clip (Walk Through Walls)", false, function(enabled)
    local player = game.Players.LocalPlayer
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CanCollide = not enabled
        
        -- No Clip loop for all parts
        local function toggleNoClip()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not enabled
                end
            end
        end
        
        -- Update CanCollide continuously while enabled
        if enabled then
            game:GetService("RunService").Stepped:Connect(toggleNoClip)
        end
    end
end)

-- ESP Tab
local espTab = win:Tab("ESP Settings")

espTab:Toggle("ESP Bones", false, function(enabled)
    local player = game.Players.LocalPlayer
    local espParts = {}

    local function createESP(part)
        if not part or espParts[part] then return end
        
        local adorn = Instance.new("BoxHandleAdornment")
        adorn.Adornee = part
        adorn.Size = part.Size
        adorn.Color3 = Color3.fromRGB(255, 0, 0)
        adorn.Transparency = 0.5
        adorn.ZIndex = 5
        adorn.AlwaysOnTop = true
        adorn.Parent = part
        espParts[part] = adorn
    end

    local function clearESP()
        for part, adorn in pairs(espParts) do
            if adorn then adorn:Destroy() end
        end
        espParts = {}
    end

    if enabled then
        -- Create ESP for bones (all parts in character)
        local function applyESP()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        createESP(part)
                    end
                end
            end
        end
        
        applyESP()
        -- Update ESP each frame (in case parts are added/removed)
        espConnection = game:GetService("RunService").RenderStepped:Connect(applyESP)
    else
        if espConnection then
            espConnection:Disconnect()
        end
        clearESP()
    end
end)
