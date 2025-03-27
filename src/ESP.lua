-- Advanced ESP Script with Tracer, Box, Healthbar, and Rainbow Mode
-- Inspired by Exunys' AirHub V2 ESP implementation

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local ESP_Settings = {
    Enabled = true,
    TeamCheck = true,
    TeamColor = true,
    RainbowMode = true,
    RainbowSpeed = 0.5,
    
    -- Component toggles
    BoxESP = true,
    Tracer = true,
    Healthbar = true,
    NameESP = true,
    DistanceESP = true,
    
    -- Colors
    AllyColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    NeutralColor = Color3.fromRGB(255, 255, 255)
}

-- ESP Objects storage
local ESP_Objects = {}

-- Rainbow color generator
local function GetRainbowColor(speed)
    local hue = tick() * speed % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Create ESP for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local head = character:WaitForChild("Head")
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name
    espFolder.Parent = game:GetService("CoreGui")
    
    -- Box ESP
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP_Settings.EnemyColor
    box.Thickness = 1
    box.Filled = false
    box.ZIndex = 2
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESP_Settings.EnemyColor
    tracer.Thickness = 1
    tracer.ZIndex = 1
    
    -- Name
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = ESP_Settings.EnemyColor
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.ZIndex = 3
    nameText.Text = player.Name
    
    -- Distance
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = ESP_Settings.EnemyColor
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.ZIndex = 3
    
    -- Health bar
    local healthBarOutline = Drawing.new("Square")
    healthBarOutline.Visible = false
    healthBarOutline.Color = Color3.new(0, 0, 0)
    healthBarOutline.Thickness = 1
    healthBarOutline.Filled = true
    healthBarOutline.ZIndex = 1
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = ESP_Settings.EnemyColor
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.ZIndex = 2
    
    -- Store all drawing objects
    ESP_Objects[player] = {
        Character = character,
        Box = box,
        Tracer = tracer,
        Name = nameText,
        Distance = distanceText,
        HealthBarOutline = healthBarOutline,
        HealthBar = healthBar,
        Humanoid = humanoid,
        Head = head
    }
end

-- Remove ESP for a player
local function RemoveESP(player)
    local espData = ESP_Objects[player]
    if not espData then return end
    
    for _, drawing in pairs(espData) do
        if typeof(drawing) == "Drawing" then
            drawing:Remove()
        end
    end
    
    ESP_Objects[player] = nil
end

-- Update ESP visuals
local function UpdateESP()
    if not ESP_Settings.Enabled then return end
    
    for player, espData in pairs(ESP_Objects) do
        if not player or not player.Character or not espData.Character or not espData.Character.Parent then
            RemoveESP(player)
            continue
        end
        
        local character = espData.Character
        local humanoid = espData.Humanoid
        local head = espData.Head
        
        if not character or not humanoid or not head or humanoid.Health <= 0 then
            for _, drawing in pairs(espData) do
                if typeof(drawing) == "Drawing" then
                    drawing.Visible = false
                end
            end
            continue
        end
        
        -- Calculate team color
        local color
        if ESP_Settings.RainbowMode then
            color = GetRainbowColor(ESP_Settings.RainbowSpeed)
        elseif ESP_Settings.TeamCheck and player.Team == LocalPlayer.Team then
            color = ESP_Settings.AllyColor
        else
            color = ESP_Settings.EnemyColor
        end
        
        -- Update color for all components
        espData.Box.Color = color
        espData.Tracer.Color = color
        espData.Name.Color = color
        espData.Distance.Color = color
        espData.HealthBar.Color = color
        
        -- Calculate positions
        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local rootPos, rootOnScreen
        
        if rootPart then
            rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
        end
        
        if not headOnScreen and (not rootPart or not rootOnScreen) then
            for _, drawing in pairs(espData) do
                if typeof(drawing) == "Drawing" then
                    drawing.Visible = false
                end
            end
            continue
        end
        
        -- Box ESP
        if ESP_Settings.BoxESP then
            local size = (Camera:WorldToViewportPoint(head.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local width = size * 1.5
            
            espData.Box.Size = Vector2.new(width, size * 2)
            espData.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - size)
            espData.Box.Visible = true
        else
            espData.Box.Visible = false
        end
        
        -- Tracer
        if ESP_Settings.Tracer then
            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Tracer.To = Vector2.new(headPos.X, headPos.Y)
            espData.Tracer.Visible = true
        else
            espData.Tracer.Visible = false
        end
        
        -- Name
        if ESP_Settings.NameESP then
            espData.Name.Position = Vector2.new(headPos.X, headPos.Y - 30)
            espData.Name.Visible = true
        else
            espData.Name.Visible = false
        end
        
        -- Distance
        if ESP_Settings.DistanceESP and rootPart then
            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
            espData.Distance.Text = string.format("[%d]", math.floor(distance))
            espData.Distance.Position = Vector2.new(headPos.X, headPos.Y - 15)
            espData.Distance.Visible = true
        else
            espData.Distance.Visible = false
        end
        
        -- Health bar
        if ESP_Settings.Healthbar then
            local health = humanoid.Health / humanoid.MaxHealth
            local barHeight = 40
            local barWidth = 3
            local barX = headPos.X - 25
            local barY = headPos.Y - barHeight / 2
            
            -- Health bar outline
            espData.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            espData.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
            espData.HealthBarOutline.Visible = true
            
            -- Health bar
            espData.HealthBar.Size = Vector2.new(barWidth, barHeight * health)
            espData.HealthBar.Position = Vector2.new(barX, barY + (barHeight * (1 - health)))
            espData.HealthBar.Visible = true
        else
            espData.HealthBarOutline.Visible = false
            espData.HealthBar.Visible = false
        end
    end
end

-- Initialize ESP for all players
local function InitializeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            coroutine.wrap(CreateESP)(player)
        end
    end
end

-- Player added/removed events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Character added event
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Reinitialize ESP when local player respawns
    for player, _ in pairs(ESP_Objects) do
        RemoveESP(player)
    end
    InitializeESP()
end)

-- Main loop
RunService.RenderStepped:Connect(UpdateESP)

-- Initial setup
InitializeESP()

-- Toggle ESP with a keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F1 and not gameProcessed then
        ESP_Settings.Enabled = not ESP_Settings.Enabled
        if not ESP_Settings.Enabled then
            -- Hide all ESP when disabled
            for _, espData in pairs(ESP_Objects) do
                for _, drawing in pairs(espData) do
                    if typeof(drawing) == "Drawing" then
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end)

-- GUI for settings (optional - you can remove this if you want)
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESP_GUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 300)
    Frame.Position = UDim2.new(0, 10, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Text = "ESP Settings"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Frame
    
    local function CreateToggle(name, setting, yPos)
        local Toggle = Instance.new("TextButton")
        Toggle.Text = name .. ": " .. (ESP_Settings[setting] and "ON" or "OFF")
        Toggle.Size = UDim2.new(1, -20, 0, 25)
        Toggle.Position = UDim2.new(0, 10, 0, yPos)
        Toggle.BackgroundColor3 = ESP_Settings[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Parent = Frame
        
        Toggle.MouseButton1Click:Connect(function()
            ESP_Settings[setting] = not ESP_Settings[setting]
            Toggle.Text = name .. ": " .. (ESP_Settings[setting] and "ON" or "OFF")
            Toggle.BackgroundColor3 = ESP_Settings[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        end)
    end
    
    CreateToggle("ESP Enabled", "Enabled", 35)
    CreateToggle("Team Check", "TeamCheck", 65)
    CreateToggle("Team Color", "TeamColor", 95)
    CreateToggle("Rainbow Mode", "RainbowMode", 125)
    CreateToggle("Box ESP", "BoxESP", 155)
    CreateToggle("Tracer", "Tracer", 185)
    CreateToggle("Healthbar", "Healthbar", 215)
    CreateToggle("Name ESP", "NameESP", 245)
    CreateToggle("Distance ESP", "DistanceESP", 275)
end

-- Create the GUI
CreateGUI()

print("Advanced ESP loaded! Press F1 to toggle. Settings GUI is available in the top-left corner.")
