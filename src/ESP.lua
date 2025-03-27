--[[
    Advanced ESP Module extracted from AirHub V2
    Features:
    - Advanced ESP
    - Tracer
    - Box
    - Healthbar
    - Rainbow mode
]]

-- Cache frequently used functions and services
local game = game
local mathfloor, mathabs, mathclamp = math.floor, math.abs, math.clamp
local stringformat = string.format
local tablefind = table.find
local wait, spawn = task.wait, task.spawn
local Drawing = Drawing
local Vector2new = Vector2.new
local Color3fromRGB, Color3fromHSV = Color3.fromRGB, Color3.fromHSV

-- Get services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Cache important objects
local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
local ESP = {
    Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = true,
        EntityESP = true,
        EnableTeamColors = false,
        TeamColor = Color3fromRGB(170, 170, 255)
    },
    
    Properties = {
        ESP = {
            Enabled = true,
            RainbowColor = false,
            RainbowOutlineColor = false,
            Offset = 10,
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 1,
            Size = 14,
            Font = Drawing.Fonts.Plex,
            OutlineColor = Color3fromRGB(0, 0, 0),
            Outline = true,
            DisplayDistance = true,
            DisplayHealth = false,
            DisplayName = false,
            DisplayDisplayName = true,
            DisplayTool = true
        },
        
        Tracer = {
            Enabled = true,
            RainbowColor = false,
            RainbowOutlineColor = false,
            Position = 1, -- 1 = Bottom; 2 = Center; 3 = Mouse
            Transparency = 1,
            Thickness = 1,
            Color = Color3fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3fromRGB(0, 0, 0)
        },
        
        Box = {
            Enabled = true,
            RainbowColor = false,
            RainbowOutlineColor = false,
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 1,
            Thickness = 1,
            Filled = false,
            OutlineColor = Color3fromRGB(0, 0, 0),
            Outline = true
        },
        
        HealthBar = {
            Enabled = true,
            RainbowOutlineColor = false,
            Offset = 4,
            Blue = 100,
            Position = 3, -- 1 = Top; 2 = Bottom; 3 = Left; 4 = Right
            Thickness = 1,
            Transparency = 1,
            OutlineColor = Color3fromRGB(0, 0, 0),
            Outline = true
        }
    },
    
    DeveloperSettings = {
        UpdateMode = "RenderStepped",
        TeamCheckOption = "TeamColor",
        RainbowSpeed = 1,
        WidthBoundary = 1.5,
        UnwrapOnCharacterAbsence = false
    },
    
    WrappedObjects = {},
    Connections = {}
}

-- Core functions
local function GetRainbowColor()
    local RainbowSpeed = ESP.DeveloperSettings.RainbowSpeed
    return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local function GetColorFromHealth(Health, MaxHealth, Blue)
    return Color3fromRGB(255 - mathfloor(Health / MaxHealth * 255), mathfloor(Health / MaxHealth * 255), Blue or 0)
end

local function GetTeamColor(Player, DefaultColor)
    local Settings = ESP.Settings
    local TeamCheckOption = ESP.DeveloperSettings.TeamCheckOption
    
    return Settings.EnableTeamColors and Player[TeamCheckOption] == LocalPlayer[TeamCheckOption] and Settings.TeamColor or DefaultColor
end

local function CalculateBoxParameters(Object)
    local IsPlayer = Object:IsA("Player")
    local Character = IsPlayer and Object.Character or Object.Parent
    local Part = IsPlayer and (Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")) or Object
    
    if not Part then return nil, nil, false end
    
    local PartCFrame = Part.CFrame
    local PartUpVector = PartCFrame.UpVector
    local RigType = Character:FindFirstChild("Torso") and "R6" or "R15"
    local CameraUpVector = CurrentCamera.CFrame.UpVector
    
    local Top, TopOnScreen = CurrentCamera:WorldToViewportPoint(Part.Position + (PartUpVector * (RigType == "R6" and 0.5 or 1.8)) + CameraUpVector)
    local Bottom, BottomOnScreen = CurrentCamera:WorldToViewportPoint(Part.Position - (PartUpVector * (RigType == "R6" and 4 or 2.5)) - CameraUpVector)
    
    local Width = mathmax(mathfloor(mathabs(Top.X - Bottom.X)), 3)
    local Height = mathmax(mathfloor(mathmax(mathabs(Bottom.Y - Top.Y), Width / 2)), 3)
    local BoxSize = Vector2new(mathfloor(mathmax(Height / (IsPlayer and ESP.DeveloperSettings.WidthBoundary or 1), Width)), Height)
    local BoxPosition = Vector2new(mathfloor(Top.X / 2 + Bottom.X / 2 - BoxSize.X / 2), mathfloor(mathmin(Top.Y, Bottom.Y)))
    
    return BoxPosition, BoxSize, (TopOnScreen and BottomOnScreen)
end

-- Visual update functions
local function UpdateESP(Entry, TopText, BottomText)
    local Settings = ESP.Properties.ESP
    local Position, Size, OnScreen = CalculateBoxParameters(Entry.Object)
    
    TopText.Visible = OnScreen
    BottomText.Visible = OnScreen
    
    if OnScreen then
        -- Update common properties
        TopText.Size = Settings.Size
        TopText.Transparency = Settings.Transparency
        TopText.Outline = Settings.Outline
        BottomText.Size = Settings.Size
        BottomText.Transparency = Settings.Transparency
        BottomText.Outline = Settings.Outline
        
        -- Update colors
        TopText.Color = GetTeamColor(Entry.Object, Settings.RainbowColor and GetRainbowColor() or Settings.Color)
        TopText.OutlineColor = Settings.RainbowOutlineColor and GetRainbowColor() or Settings.OutlineColor
        BottomText.Color = TopText.Color
        BottomText.OutlineColor = TopText.OutlineColor
        
        -- Position text
        local Offset = mathclamp(Settings.Offset, 10, 30)
        TopText.Position = Vector2new(Position.X + (Size.X / 2), Position.Y - Offset * 2)
        BottomText.Position = Vector2new(Position.X + (Size.X / 2), Position.Y + Size.Y + Offset / 2)
        
        -- Set text content
        local Character = Entry.Object.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Health, MaxHealth = Humanoid and Humanoid.Health or 0, Humanoid and Humanoid.MaxHealth or 100
        local Tool = Settings.DisplayTool and Character:FindFirstChildOfClass("Tool")
        
        -- Top text (name/health)
        local nameText = Settings.DisplayName and Entry.Object.Name or ""
        local displayNameText = Settings.DisplayDisplayName and Entry.Object.DisplayName or ""
        local combinedName = displayNameText ~= nameText and stringformat("%s (%s)", displayNameText, nameText) or nameText
        
        if Settings.DisplayHealth then
            TopText.Text = stringformat("[%d/%d] %s", mathfloor(Health), MaxHealth, combinedName)
        else
            TopText.Text = combinedName
        end
        
        -- Bottom text (distance/tool)
        local distanceText = Settings.DisplayDistance and stringformat("%d Studs", mathfloor((Character.PrimaryPart.Position - CurrentCamera.CFrame.Position).Magnitude)) or ""
        local toolText = Tool and ((distanceText ~= "" and "\n" or "")..Tool.Name) or ""
        BottomText.Text = distanceText..toolText
    end
end

local function UpdateTracer(Entry, Tracer, TracerOutline)
    local Settings = ESP.Properties.Tracer
    local Position, Size, OnScreen = CalculateBoxParameters(Entry.Object)
    
    Tracer.Visible = OnScreen
    TracerOutline.Visible = OnScreen and Settings.Outline
    
    if OnScreen then
        -- Update common properties
        Tracer.Thickness = Settings.Thickness
        Tracer.Transparency = Settings.Transparency
        
        -- Update colors
        Tracer.Color = GetTeamColor(Entry.Object, Settings.RainbowColor and GetRainbowColor() or Settings.Color)
        
        -- Set positions
        local CameraViewportSize = CurrentCamera.ViewportSize
        local TargetPosition = Vector2new(Position.X + (Size.X / 2), Position.Y + Size.Y)
        
        if Settings.Position == 1 then -- Bottom
            Tracer.From = Vector2new(CameraViewportSize.X / 2, CameraViewportSize.Y)
        elseif Settings.Position == 2 then -- Center
            Tracer.From = CameraViewportSize / 2
        elseif Settings.Position == 3 then -- Mouse
            Tracer.From = UserInputService:GetMouseLocation()
        else
            Settings.Position = 1
        end
        
        Tracer.To = TargetPosition
        
        -- Update outline if enabled
        if Settings.Outline then
            TracerOutline.Color = Settings.RainbowOutlineColor and GetRainbowColor() or Settings.OutlineColor
            TracerOutline.Thickness = Settings.Thickness + 1
            TracerOutline.Transparency = Settings.Transparency
            TracerOutline.From = Tracer.From
            TracerOutline.To = Tracer.To
        end
    end
end

local function UpdateBox(Entry, Box, BoxOutline)
    local Settings = ESP.Properties.Box
    local Position, Size, OnScreen = CalculateBoxParameters(Entry.Object)
    
    Box.Visible = OnScreen
    BoxOutline.Visible = OnScreen and Settings.Outline
    
    if OnScreen then
        -- Update common properties
        Box.Thickness = Settings.Thickness
        Box.Transparency = Settings.Transparency
        Box.Filled = Settings.Filled
        
        -- Update colors
        Box.Color = GetTeamColor(Entry.Object, Settings.RainbowColor and GetRainbowColor() or Settings.Color)
        
        -- Set position and size
        Box.Position = Position
        Box.Size = Size
        
        -- Update outline if enabled
        if Settings.Outline then
            BoxOutline.Color = Settings.RainbowOutlineColor and GetRainbowColor() or Settings.OutlineColor
            BoxOutline.Thickness = Settings.Thickness + 1
            BoxOutline.Transparency = Settings.Transparency
            BoxOutline.Position = Position
            BoxOutline.Size = Size
        end
    end
end

local function UpdateHealthBar(Entry, HealthBar, Outline, Humanoid)
    local Settings = ESP.Properties.HealthBar
    local Position, Size, OnScreen = CalculateBoxParameters(Entry.Object)
    
    HealthBar.Visible = OnScreen
    Outline.Visible = OnScreen and Settings.Outline
    
    if OnScreen then
        -- Update common properties
        HealthBar.Thickness = Settings.Thickness
        HealthBar.Transparency = Settings.Transparency
        
        -- Get health values
        local MaxHealth = Humanoid and Humanoid.MaxHealth or 100
        local Health = Humanoid and mathclamp(Humanoid.Health, 0, MaxHealth) or 0
        local Offset = mathclamp(Settings.Offset, 4, 12)
        
        -- Update color based on health
        HealthBar.Color = GetColorFromHealth(Health, MaxHealth, Settings.Blue)
        
        -- Position health bar based on settings
        if Settings.Position == 1 then -- Top
            HealthBar.From = Vector2new(Position.X, Position.Y - Offset)
            HealthBar.To = Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y - Offset)
            
            if Settings.Outline then
                Outline.From = Vector2new(Position.X - 1, Position.Y - Offset)
                Outline.To = Vector2new(Position.X + Size.X + 1, Position.Y - Offset)
            end
        elseif Settings.Position == 2 then -- Bottom
            HealthBar.From = Vector2new(Position.X, Position.Y + Size.Y + Offset)
            HealthBar.To = Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y + Size.Y + Offset)
            
            if Settings.Outline then
                Outline.From = Vector2new(Position.X - 1, Position.Y + Size.Y + Offset)
                Outline.To = Vector2new(Position.X + Size.X + 1, Position.Y + Size.Y + Offset)
            end
        elseif Settings.Position == 3 then -- Left
            HealthBar.From = Vector2new(Position.X - Offset, Position.Y + Size.Y)
            HealthBar.To = Vector2new(Position.X - Offset, Position.Y + Size.Y - (Health / MaxHealth) * Size.Y)
            
            if Settings.Outline then
                Outline.From = Vector2new(Position.X - Offset, Position.Y + Size.Y + 1)
                Outline.To = Vector2new(Position.X - Offset, Position.Y + Size.Y - Size.Y - 2)
            end
        elseif Settings.Position == 4 then -- Right
            HealthBar.From = Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y)
            HealthBar.To = Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y - (Health / MaxHealth) * Size.Y)
            
            if Settings.Outline then
                Outline.From = Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y + 1)
                Outline.To = Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y - Size.Y - 2)
            end
        else
            Settings.Position = 3
        end
        
        -- Update outline if enabled
        if Settings.Outline then
            Outline.Color = Settings.RainbowOutlineColor and GetRainbowColor() or Settings.OutlineColor
            Outline.Thickness = Settings.Thickness + 1
            Outline.Transparency = Settings.Transparency
        end
    end
end

-- Object management
local function CreateVisuals(Entry)
    -- ESP Text
    local TopText = Drawing.new("Text")
    TopText.Center = true
    TopText.Visible = false
    
    local BottomText = Drawing.new("Text")
    BottomText.Center = true
    BottomText.Visible = false
    
    -- Tracer
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    
    local TracerOutline = Drawing.new("Line")
    TracerOutline.Visible = false
    
    -- Box
    local Box = Drawing.new("Square")
    Box.Visible = false
    
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    
    -- Health Bar
    local HealthBar = Drawing.new("Line")
    HealthBar.Visible = false
    
    local HealthBarOutline = Drawing.new("Line")
    HealthBarOutline.Visible = false
    
    -- Store visuals in entry
    Entry.Visuals = {
        ESP = {TopText, BottomText},
        Tracer = {Tracer, TracerOutline},
        Box = {Box, BoxOutline},
        HealthBar = {HealthBar, HealthBarOutline}
    }
    
    -- Create update connections
    Entry.Connections = {
        ESP = RunService[ESP.DeveloperSettings.UpdateMode]:Connect(function()
            if ESP.Settings.Enabled and ESP.Properties.ESP.Enabled then
                UpdateESP(Entry, TopText, BottomText)
            else
                TopText.Visible = false
                BottomText.Visible = false
            end
        end),
        
        Tracer = RunService[ESP.DeveloperSettings.UpdateMode]:Connect(function()
            if ESP.Settings.Enabled and ESP.Properties.Tracer.Enabled then
                UpdateTracer(Entry, Tracer, TracerOutline)
            else
                Tracer.Visible = false
                TracerOutline.Visible = false
            end
        end),
        
        Box = RunService[ESP.DeveloperSettings.UpdateMode]:Connect(function()
            if ESP.Settings.Enabled and ESP.Properties.Box.Enabled then
                UpdateBox(Entry, Box, BoxOutline)
            else
                Box.Visible = false
                BoxOutline.Visible = false
            end
        end),
        
        HealthBar = RunService[ESP.DeveloperSettings.UpdateMode]:Connect(function()
            local Humanoid = Entry.Object.Character and Entry.Object.Character:FindFirstChildOfClass("Humanoid")
            if ESP.Settings.Enabled and ESP.Properties.HealthBar.Enabled then
                UpdateHealthBar(Entry, HealthBar, HealthBarOutline, Humanoid)
            else
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
        end)
    }
end

local function WrapPlayer(Player)
    if Player == LocalPlayer or ESP.WrappedObjects[Player] then return end
    
    local Entry = {
        Object = Player,
        Visuals = {},
        Connections = {}
    }
    
    ESP.WrappedObjects[Player] = Entry
    
    -- Create visuals when character exists
    local function OnCharacterAdded(Character)
        if Character then
            CreateVisuals(Entry)
        end
    end
    
    if Player.Character then
        OnCharacterAdded(Player.Character)
    end
    
    Entry.Connections.CharacterAdded = Player.CharacterAdded:Connect(OnCharacterAdded)
    Entry.Connections.PlayerRemoving = Player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            UnwrapPlayer(Player)
        end
    end)
end

local function UnwrapPlayer(Player)
    local Entry = ESP.WrappedObjects[Player]
    if not Entry then return end
    
    -- Disconnect all connections
    for _, connection in pairs(Entry.Connections) do
        connection:Disconnect()
    end
    
    -- Remove all visuals
    for _, visuals in pairs(Entry.Visuals) do
        for _, drawing in pairs(visuals) do
            drawing:Remove()
        end
    end
    
    ESP.WrappedObjects[Player] = nil
end

-- Initialize ESP
local function Initialize()
    -- Wrap existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            WrapPlayer(player)
        end
    end
    
    -- Connect to player added/removed events
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(WrapPlayer)
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(UnwrapPlayer)
end

-- Public API
ESP.Toggle = function(state)
    ESP.Settings.Enabled = state
end

ESP.UpdateSettings = function(newSettings)
    for key, value in pairs(newSettings) do
        if ESP.Settings[key] ~= nil then
            ESP.Settings[key] = value
        end
    end
end

ESP.UpdateProperties = function(newProperties)
    for category, properties in pairs(newProperties) do
        if ESP.Properties[category] then
            for key, value in pairs(properties) do
                if ESP.Properties[category][key] ~= nil then
                    ESP.Properties[category][key] = value
                end
            end
        end
    end
end

ESP.Unload = function()
    -- Unwrap all players
    for player, _ in pairs(ESP.WrappedObjects) do
        UnwrapPlayer(player)
    end
    
    -- Disconnect all connections
    for _, connection in pairs(ESP.Connections) do
        connection:Disconnect()
    end
    
    -- Clear tables
    ESP.WrappedObjects = {}
    ESP.Connections = {}
end

-- Start ESP
Initialize()

return ESP
