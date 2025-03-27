-- Fixed ESP Script without nil value errors
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings with safe defaults
local ESP_Settings = {
    Enabled = true,
    TeamCheck = true,
    TeamColor = true,
    RainbowMode = false, -- Disabled by default for stability
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
    
    -- Safety settings
    MaxDistance = 1000,
    FOV = 120,
    CheckOcclusion = false -- Disabled by default for performance
}

-- ESP storage with safe access
local ESP_Objects = {}
local ActiveConnections = {}

-- Safe utility functions
local function SafeWorldToViewportPoint(position)
    local success, result = pcall(function()
        return Camera:WorldToViewportPoint(position)
    end)
    return success and result or nil
end

local function IsOnScreen(position)
    local screenPos = SafeWorldToViewportPoint(position)
    return screenPos and screenPos.Z > 0 and screenPos.X > 0 and screenPos.X < 1 and screenPos.Y > 0 and screenPos.Y < 1
end

local function IsInFOV(position)
    if not Camera or not Camera.CFrame then return false end
    local cameraCF = Camera.CFrame
    local direction = (position - cameraCF.Position).Unit
    local dot = cameraCF.LookVector:Dot(direction)
    return dot > math.cos(math.rad(ESP_Settings.FOV / 2))
end

-- Safe rainbow color generator
local function GetRainbowColor(speed)
    local hue = tick() * (speed or 0.5) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Safe ESP creation
local function CreateESP(player)
    if player == LocalPlayer then return nil end
    
    local character = player.Character
    if not character then
        -- Wait for character safely
        local success, result = pcall(function()
            return player.CharacterAdded:Wait()
        end)
        if not success then return nil end
        character = result
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return nil end
    
    local espData = {
        Character = character,
        Humanoid = humanoid,
        Head = head,
        Drawings = {},
        Connections = {}
    }
    
    -- Safely create drawings
    local function SafeCreateDrawing(type)
        local success, drawing = pcall(Drawing.new, type)
        return success and drawing or nil
    end
    
    -- Create drawings with nil checks
    espData.Drawings.Box = SafeCreateDrawing("Square")
    espData.Drawings.BoxOutline = SafeCreateDrawing("Square")
    espData.Drawings.Tracer = SafeCreateDrawing("Line")
    espData.Drawings.TracerOutline = SafeCreateDrawing("Line")
    espData.Drawings.Name = SafeCreateDrawing("Text")
    espData.Drawings.Distance = SafeCreateDrawing("Text")
    espData.Drawings.HealthBar = SafeCreateDrawing("Square")
    espData.Drawings.HealthBarOutline = SafeCreateDrawing("Square")
    
    -- Configure drawings if they exist
    if espData.Drawings.Name then
        espData.Drawings.Name.Center = true
    end
    if espData.Drawings.Distance then
        espData.Drawings.Distance.Center = true
    end
    if espData.Drawings.HealthBar then
        espData.Drawings.HealthBar.Filled = true
    end
    if espData.Drawings.HealthBarOutline then
        espData.Drawings.HealthBarOutline.Filled = true
    end
    
    -- Store the ESP data
    ESP_Objects[player] = espData
    
    -- Safe connections
    if character then
        espData.Connections.CharacterRemoving = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                RemoveESP(player)
            end
        end)
    end
    
    if humanoid then
        espData.Connections.HumanoidDied = humanoid.Died:Connect(function()
            RemoveESP(player)
        end)
    end
    
    return espData
end

-- Safe ESP removal
local function RemoveESP(player)
    local espData = ESP_Objects[player]
    if not espData then return end
    
    -- Disconnect all connections safely
    for _, connection in pairs(espData.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    
    -- Remove all drawings safely
    for _, drawing in pairs(espData.Drawings) do
        if drawing and typeof(drawing) == "userdata" and drawing.Remove then
            pcall(drawing.Remove, drawing)
        end
    end
    
    ESP_Objects[player] = nil
end

-- Safe ESP update
local function UpdateESP()
    if not ESP_Settings.Enabled then
        for player, espData in pairs(ESP_Objects) do
            for _, drawing in pairs(espData.Drawings) do
                if drawing and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
        return
    end
    
    local localCharacter = LocalPlayer.Character
    local localHead = localCharacter and localCharacter:FindFirstChild("Head")
    local localPosition = localHead and localHead.Position or (Camera and Camera.CFrame and Camera.CFrame.Position or Vector3.new())
    
    for player, espData in pairs(ESP_Objects) do
        local character = espData.Character
        local humanoid = espData.Humanoid
        local head = espData.Head
        
        if not character or not humanoid or not head or humanoid.Health <= 0 then
            RemoveESP(player)
            continue
        end
        
        -- Calculate team color safely
        local color
        if ESP_Settings.RainbowMode then
            color = GetRainbowColor(ESP_Settings.RainbowSpeed)
        elseif ESP_Settings.TeamCheck and player.Team == LocalPlayer.Team then
            color = ESP_Settings.AllyColor
        else
            color = ESP_Settings.EnemyColor
        end
        
        -- Check distance and visibility safely
        local distance = (head.Position - localPosition).Magnitude
        local isVisible = distance <= ESP_Settings.MaxDistance and IsOnScreen(head.Position) and IsInFOV(head.Position)
        
        -- Update all components safely
        for _, drawing in pairs(espData.Drawings) do
            if drawing then
                pcall(function()
                    drawing.Visible = isVisible
                    if (drawing.Color ~= nil) and (string.find(tostring(drawing), "Text") or string.find(tostring(drawing), "Line")) then
                        drawing.Color = color
                    end
                end)
            end
        end
        
        if not isVisible then continue end
        
        -- Update box ESP safely
        if ESP_Settings.BoxESP and espData.Drawings.Box and espData.Drawings.BoxOutline then
            local headPos = SafeWorldToViewportPoint(head.Position)
            if headPos then
                local size = (SafeWorldToViewportPoint(head.Position - Vector3.new(0, 3, 0)).Y - 
                             SafeWorldToViewportPoint(head.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                local width = size * 1.5
                
                pcall(function()
                    espData.Drawings.Box.Size = Vector2.new(width, size * 2)
                    espData.Drawings.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - size)
                    espData.Drawings.Box.Visible = true
                    
                    espData.Drawings.BoxOutline.Size = espData.Drawings.Box.Size
                    espData.Drawings.BoxOutline.Position = espData.Drawings.Box.Position
                    espData.Drawings.BoxOutline.Visible = true
                end)
            end
        end
        
        -- Update tracer safely
        if ESP_Settings.Tracer and espData.Drawings.Tracer and espData.Drawings.TracerOutline then
            pcall(function()
                espData.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                espData.Drawings.Tracer.To = Vector2.new(head.Position.X, head.Position.Y)
                espData.Drawings.Tracer.Visible = true
                
                espData.Drawings.TracerOutline.From = espData.Drawings.Tracer.From
                espData.Drawings.TracerOutline.To = espData.Drawings.Tracer.To
                espData.Drawings.TracerOutline.Visible = true
            end)
        end
        
        -- Update name and distance safely
        if (ESP_Settings.NameESP or ESP_Settings.DistanceESP) and espData.Drawings.Name and espData.Drawings.Distance then
            pcall(function()
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
            end)
        end
        
        -- Update health bar safely
        if ESP_Settings.Healthbar and espData.Drawings.HealthBar and espData.Drawings.HealthBarOutline then
            pcall(function()
                local health = humanoid.Health / humanoid.MaxHealth
                local barHeight = 40
                local barWidth = 3
                local barX = head.Position.X - 25
                local barY = head.Position.Y - barHeight / 2
                
                espData.Drawings.HealthBar.Size = Vector2.new(barWidth, barHeight * health)
                espData.Drawings.HealthBar.Position = Vector2.new(barX, barY + (barHeight * (1 - health)))
                espData.Drawings.HealthBar.Color = Color3.fromRGB(255 - health * 255, health * 255, 0)
                espData.Drawings.HealthBar.Visible = true
                
                espData.Drawings.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                espData.Drawings.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
                espData.Drawings.HealthBarOutline.Visible = true
            end)
        end
    end
end

-- Safe initialization
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
        
        -- Handle character changes safely
        espData.Connections.CharacterAdded = player.CharacterAdded:Connect(function(character)
            RemoveESP(player)
            wait(0.1) -- Small safe delay
            CreateESP(player)
        end)
    end
    
    -- Set up existing players safely
    for _, player in ipairs(Players:GetPlayers()) do
        pcall(setupPlayer, player)
    end
    
    -- Set up for new players safely
    ActiveConnections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        pcall(setupPlayer, player)
    end)
    
    -- Set up for leaving players safely
    ActiveConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        pcall(RemoveESP, player)
    end)
    
    -- Main update loop
    ActiveConnections.UpdateLoop = RunService.RenderStepped:Connect(function()
        pcall(UpdateESP)
    end)
end

-- Safe toggle
local function ToggleESP(enable)
    ESP_Settings.Enabled = enable
    
    if not enable then
        for player in pairs(ESP_Objects) do
            pcall(RemoveESP, player)
        end
    else
        pcall(InitializeESP)
    end
end

-- Safe GUI creation
local function CreateGUI()
    local success, screenGui = pcall(Instance.new, "ScreenGui")
    if not success then return end
    
    screenGui.Name = "ESP_GUI"
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 350)
    frame.Position = UDim2.new(0, 10, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "ESP Settings"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame
    
    local yPos = 35
    local function CreateToggle(name, setting)
        local toggle = Instance.new("TextButton")
        toggle.Text = name .. ": " .. (ESP_Settings[setting] and "ON" or "OFF")
        toggle.Size = UDim2.new(1, -20, 0, 25)
        toggle.Position = UDim2.new(0, 10, 0, yPos)
        toggle.BackgroundColor3 = ESP_Settings[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Parent = frame
        yPos = yPos + 30
        
        toggle.MouseButton1Click:Connect(function()
            ESP_Settings[setting] = not ESP_Settings[setting]
            toggle.Text = name .. ": " .. (ESP_Settings[setting] and "ON" or "OFF")
            toggle.BackgroundColor3 = ESP_Settings[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        end)
    end
    
    CreateToggle("ESP Enabled", "Enabled")
    CreateToggle("Team Check", "TeamCheck")
    CreateToggle("Team Color", "TeamColor")
    CreateToggle("Rainbow Mode", "RainbowMode")
    CreateToggle("Box ESP", "BoxESP")
    CreateToggle("Tracer", "Tracer")
    CreateToggle("Healthbar", "Healthbar")
    CreateToggle("Name ESP", "NameESP")
    CreateToggle("Distance ESP", "DistanceESP")
    
    -- Unload button
    local unloadButton = Instance.new("TextButton")
    unloadButton.Text = "Unload ESP"
    unloadButton.Size = UDim2.new(1, -20, 0, 30)
    unloadButton.Position = UDim2.new(0, 10, 0, yPos)
    unloadButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadButton.Parent = frame
    
    unloadButton.MouseButton1Click:Connect(function()
        pcall(function()
            ToggleESP(false)
            for _, connection in pairs(ActiveConnections) do
                connection:Disconnect()
            end
            screenGui:Destroy()
        end)
    end)
end

-- Safe keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F1 and not gameProcessed then
        pcall(function() ToggleESP(not ESP_Settings.Enabled) end)
    end
end)

-- Safe initialization
pcall(function()
    InitializeESP()
    CreateGUI()
    print("Safe ESP loaded! Press F1 to toggle. Settings GUI is available in the top-left corner.")
end)
