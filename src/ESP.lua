-- Revised ESP Script with Fixed Visibility and Cleanup
-- Based on Exunys' ESP module with improvements

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings with better defaults
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
    NeutralColor = Color3.fromRGB(255, 255, 255),
    
    -- New settings for better control
    MaxDistance = 1000, -- Max render distance in studs
    FOV = 120, -- Field of view for visibility checks
    CheckOcclusion = true -- Check if players are behind walls
}

-- ESP Objects storage with better management
local ESP_Objects = {}
local ActiveConnections = {}

-- Utility functions
local function IsOnScreen(position)
    local screenPos = Camera:WorldToViewportPoint(position)
    return screenPos.Z > 0 and screenPos.X > 0 and screenPos.X < 1 and screenPos.Y > 0 and screenPos.Y < 1
end

local function IsInFOV(position)
    local cameraCF = Camera.CFrame
    local direction = (position - cameraCF.Position).Unit
    local dot = cameraCF.LookVector:Dot(direction)
    return dot > math.cos(math.rad(ESP_Settings.FOV / 2))
end

local function IsVisible(part)
    if not ESP_Settings.CheckOcclusion then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * (part.Position - origin).Magnitude)
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

-- Rainbow color generator
local function GetRainbowColor(speed)
    local hue = tick() * speed % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Create ESP for a player with better checks
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local head = character:WaitForChild("Head")
    if not humanoid or not head then return end
    
    local espData = {
        Character = character,
        Humanoid = humanoid,
        Head = head,
        Drawings = {},
        Connections = {}
    }
    
    -- Box ESP
    espData.Drawings.Box = Drawing.new("Square")
    espData.Drawings.BoxOutline = Drawing.new("Square")
    
    -- Tracer
    espData.Drawings.Tracer = Drawing.new("Line")
    espData.Drawings.TracerOutline = Drawing.new("Line")
    
    -- Name
    espData.Drawings.Name = Drawing.new("Text")
    espData.Drawings.Name.Center = true
    
    -- Distance
    espData.Drawings.Distance = Drawing.new("Text")
    espData.Drawings.Distance.Center = true
    
    -- Health bar
    espData.Drawings.HealthBar = Drawing.new("Square")
    espData.Drawings.HealthBarOutline = Drawing.new("Square")
    espData.Drawings.HealthBar.Filled = true
    espData.Drawings.HealthBarOutline.Filled = true
    
    -- Store the ESP data
    ESP_Objects[player] = espData
    
    -- Character cleanup connection
    espData.Connections.CharacterRemoving = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            RemoveESP(player)
        end
    end)
    
    -- Humanoid cleanup connection
    espData.Connections.HumanoidDied = humanoid.Died:Connect(function()
        RemoveESP(player)
    end)
    
    return espData
end

-- Remove ESP for a player with proper cleanup
local function RemoveESP(player)
    local espData = ESP_Objects[player]
    if not espData then return end
    
    -- Disconnect all connections
    for _, connection in pairs(espData.Connections) do
        connection:Disconnect()
    end
    
    -- Remove all drawings
    for _, drawing in pairs(espData.Drawings) do
        drawing:Remove()
    end
    
    ESP_Objects[player] = nil
end

-- Update ESP visuals with proper visibility checks
local function UpdateESP()
    if not ESP_Settings.Enabled then
        -- Hide all ESP when disabled
        for player, espData in pairs(ESP_Objects) do
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
        end
        return
    end
    
    local localCharacter = LocalPlayer.Character
    local localHead = localCharacter and localCharacter:FindFirstChild("Head")
    local localPosition = localHead and localHead.Position or Camera.CFrame.Position
    
    for player, espData in pairs(ESP_Objects) do
        local character = espData.Character
        local humanoid = espData.Humanoid
        local head = espData.Head
        
        if not character or not humanoid or not head or humanoid.Health <= 0 then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            RemoveESP(player)
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
        
        -- Check distance and visibility
        local distance = (head.Position - localPosition).Magnitude
        local isVisible = IsVisible(head) and IsInFOV(head.Position) and distance <= ESP_Settings.MaxDistance
        
        -- Update all components
        for _, drawing in pairs(espData.Drawings) do
            drawing.Visible = isVisible
            if string.find(drawing.__type, "Text") or string.find(drawing.__type, "Line") then
                drawing.Color = color
            end
        end
        
        if not isVisible then continue end
        
        -- Box ESP
        if ESP_Settings.BoxESP then
            local size = (Camera:WorldToViewportPoint(head.Position - Vector3.new(0, 3, 0)).Y - 
                         Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.6, 0)).Y / 2
            local width = size * 1.5
            
            espData.Drawings.Box.Size = Vector2.new(width, size * 2)
            espData.Drawings.Box.Position = Vector2.new(head.Position.X - width / 2, head.Position.Y - size)
            espData.Drawings.Box.Visible = true
            
            -- Outline
            espData.Drawings.BoxOutline.Size = espData.Drawings.Box.Size
            espData.Drawings.BoxOutline.Position = espData.Drawings.Box.Position
            espData.Drawings.BoxOutline.Visible = true
        end
        
        -- Tracer
        if ESP_Settings.Tracer then
            espData.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Drawings.Tracer.To = Vector2.new(head.Position.X, head.Position.Y)
            espData.Drawings.Tracer.Visible = true
            
            -- Outline
            espData.Drawings.TracerOutline.From = espData.Drawings.Tracer.From
            espData.Drawings.TracerOutline.To = espData.Drawings.Tracer.To
            espData.Drawings.TracerOutline.Visible = true
        end
        
        -- Name and distance
        if ESP_Settings.NameESP or ESP_Settings.DistanceESP then
            local nameText = ""
            local distanceText = ""
            
            if ESP_Settings.NameESP then
                nameText = player.Name
                if player.DisplayName ~= player.Name then
                    nameText = player.DisplayName .. " (" .. player.Name .. ")"
                end
            end
            
            if ESP_Settings.DistanceESP then
                distanceText = string.format("[%d]", math.floor(distance))
            end
            
            espData.Drawings.Name.Text = nameText
            espData.Drawings.Name.Position = Vector2.new(head.Position.X, head.Position.Y - 30)
            
            espData.Drawings.Distance.Text = distanceText
            espData.Drawings.Distance.Position = Vector2.new(head.Position.X, head.Position.Y + 30)
        end
        
        -- Health bar
        if ESP_Settings.Healthbar then
            local health = humanoid.Health / humanoid.MaxHealth
            local barHeight = 40
            local barWidth = 3
            local barX = head.Position.X - 25
            local barY = head.Position.Y - barHeight / 2
            
            espData.Drawings.HealthBar.Size = Vector2.new(barWidth, barHeight * health)
            espData.Drawings.HealthBar.Position = Vector2.new(barX, barY + (barHeight * (1 - health)))
            espData.Drawings.HealthBar.Color = Color3.fromRGB(255 - health * 255, health * 255, 0)
            espData.Drawings.HealthBar.Visible = true
            
            -- Outline
            espData.Drawings.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            espData.Drawings.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
            espData.Drawings.HealthBarOutline.Visible = true
        end
    end
end

-- Initialize ESP for all players with proper connections
local function InitializeESP()
    -- Clean up any existing ESP first
    for player in pairs(ESP_Objects) do
        RemoveESP(player)
    end
    
    -- Set up player connections
    local function setupPlayer(player)
        if player == LocalPlayer then return end
        
        local espData = CreateESP(player)
        if not espData then return end
        
        -- Handle character changes
        espData.Connections.CharacterAdded = player.CharacterAdded:Connect(function(character)
            RemoveESP(player)
            wait() -- Small delay to ensure character is fully loaded
            CreateESP(player)
        end)
    end
    
    -- Set up existing players
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end
    
    -- Set up for new players
    ActiveConnections.PlayerAdded = Players.PlayerAdded:Connect(setupPlayer)
    
    -- Set up for leaving players
    ActiveConnections.PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)
    
    -- Main update loop
    ActiveConnections.UpdateLoop = RunService.RenderStepped:Connect(UpdateESP)
end

-- Toggle ESP with proper cleanup
local function ToggleESP(enable)
    ESP_Settings.Enabled = enable
    
    if not enable then
        -- Clean up all ESP objects when disabled
        for player in pairs(ESP_Objects) do
            RemoveESP(player)
        end
    else
        -- Reinitialize when enabled
        InitializeESP()
    end
end

-- GUI for settings (optional)
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESP_GUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 250, 0, 350)
    Frame.Position = UDim2.new(0, 10, 0.5, -175)
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
    
    local yPos = 35
    CreateToggle("ESP Enabled", "Enabled", yPos); yPos = yPos + 30
    CreateToggle("Team Check", "TeamCheck", yPos); yPos = yPos + 30
    CreateToggle("Team Color", "TeamColor", yPos); yPos = yPos + 30
    CreateToggle("Rainbow Mode", "RainbowMode", yPos); yPos = yPos + 30
    CreateToggle("Box ESP", "BoxESP", yPos); yPos = yPos + 30
    CreateToggle("Tracer", "Tracer", yPos); yPos = yPos + 30
    CreateToggle("Healthbar", "Healthbar", yPos); yPos = yPos + 30
    CreateToggle("Name ESP", "NameESP", yPos); yPos = yPos + 30
    CreateToggle("Distance ESP", "DistanceESP", yPos); yPos = yPos + 30
    
    -- Add slider for max distance
    local DistanceSliderLabel = Instance.new("TextLabel")
    DistanceSliderLabel.Text = "Max Distance: " .. ESP_Settings.MaxDistance
    DistanceSliderLabel.Size = UDim2.new(1, -20, 0, 20)
    DistanceSliderLabel.Position = UDim2.new(0, 10, 0, yPos)
    DistanceSliderLabel.BackgroundTransparency = 1
    DistanceSliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DistanceSliderLabel.Parent = Frame
    yPos = yPos + 20
    
    local DistanceSlider = Instance.new("TextBox")
    DistanceSlider.Size = UDim2.new(1, -20, 0, 25)
    DistanceSlider.Position = UDim2.new(0, 10, 0, yPos)
    DistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DistanceSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    DistanceSlider.Text = tostring(ESP_Settings.MaxDistance)
    DistanceSlider.Parent = Frame
    yPos = yPos + 30
    
    DistanceSlider.FocusLost:Connect(function()
        local value = tonumber(DistanceSlider.Text)
        if value and value > 0 then
            ESP_Settings.MaxDistance = value
            DistanceSliderLabel.Text = "Max Distance: " .. value
        else
            DistanceSlider.Text = tostring(ESP_Settings.MaxDistance)
        end
    end)
    
    -- Unload button
    local UnloadButton = Instance.new("TextButton")
    UnloadButton.Text = "Unload ESP"
    UnloadButton.Size = UDim2.new(1, -20, 0, 30)
    UnloadButton.Position = UDim2.new(0, 10, 0, yPos)
    UnloadButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnloadButton.Parent = Frame
    
    UnloadButton.MouseButton1Click:Connect(function()
        -- Clean up everything
        ToggleESP(false)
        for _, connection in pairs(ActiveConnections) do
            connection:Disconnect()
        end
        ScreenGui:Destroy()
    end)
end

-- Toggle ESP with a keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F1 and not gameProcessed then
        ToggleESP(not ESP_Settings.Enabled)
    end
end)

-- Initial setup
InitializeESP()
CreateGUI()

print("Improved ESP loaded! Press F1 to toggle. Settings GUI is available in the top-left corner.")
