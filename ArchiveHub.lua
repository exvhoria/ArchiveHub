-- Load UI Library
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()

-- Basic Info
local scriptHubName = "ArchiveHub"
local devName = "GhosttedXV"
local gameName = gameName or "Unknown Game"

-- Window Setup
local win = lib:Window(scriptHubName .. " || " .. gameName, devName, Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- 🌟 Utility Functions 🌟 --
local function notify(title, message)
    lib:Notification(title, message, "OK")
end

local function getLocalPlayer()
    return game.Players.LocalPlayer
end

-- 🌟 ESP System 🌟 --
local espEnabled = false
local espParts = {}
local espConnection

local function createESP(part)
    if not part or espParts[part] then return end
    
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.Size = part.Size
    adorn.Color3 = Color3.new(1, 0, 0)
    adorn.Transparency = 0.5
    adorn.ZIndex = 5
    adorn.AlwaysOnTop = true
    adorn.Name = "ESPBox"
    adorn.Parent = part

    espParts[part] = adorn
end

local function removeESP()
    for _, adorn in pairs(espParts) do
        if adorn then adorn:Destroy() end
    end
    espParts = {}
end

local function toggleESP(state)
    espEnabled = state
    local player = getLocalPlayer()
    
    if espEnabled then
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
        espConnection = game:GetService("RunService").RenderStepped:Connect(applyESP)
    else
        if espConnection then
            espConnection:Disconnect()
        end
        removeESP()
    end
end

-- 🌟 UI Tabs 🌟 --
local mainTab = win:Tab("Main")
local playerTab = win:Tab("Player Settings")
local espTab = win:Tab("ESP Settings")
local settingsTab = win:Tab("Settings")

-- 🌟 Main Tab 🌟 --
mainTab:Label("Welcome to ArchiveHub!")
mainTab:Label("Recent Updates:\n- ESP Bones\n- Fullbright Removed\n- Added Noclip")
mainTab:Button("Show Notification", function()
    notify("Hello!", "This is a test notification.")
end)

-- 🌟 Player Settings 🌟 --
playerTab:Slider("Walk Speed", 16, 100, 16, function(speed)
    local player = getLocalPlayer()
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end)

playerTab:Slider("Jump Power", 50, 200, 50, function(jumpPower)
    local player = getLocalPlayer()
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

playerTab:Toggle("No Clip (Walk Through Walls)", false, function(enabled)
    local player = getLocalPlayer()
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CanCollide = not enabled

        local function toggleNoClip()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not enabled
                end
            end
        end

        if enabled then
            game:GetService("RunService").Stepped:Connect(toggleNoClip)
        end
    end
end)

-- 🌟 ESP Settings 🌟 --
espTab:Toggle("ESP Bones", false, function(state)
    toggleESP(state)
end)

-- 🌟 UI Settings 🌟 --
settingsTab:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(color)
    lib:ChangePresetColor(Color3.fromRGB(color.R * 255, color.G * 255, color.B * 255))
end)

settingsTab:Bind("Toggle UI", Enum.KeyCode.RightShift, function()
    print("UI Toggled!")
end)
