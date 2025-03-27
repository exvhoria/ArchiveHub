-- Velocity ESP v3.1 - Fully Fixed Version
local ESP = {
    Settings = {
        Enabled = true,
        TeamCheck = true,
        AllyColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0),
        RainbowMode = false,
        RainbowSpeed = 0.5,
        MaxDistance = 1500,
        -- Feature toggles
        Box = true,
        Tracer = true,
        HealthBar = true,
        Name = true,
        Distance = true
    },
    Properties = {
        Box = {
            Thickness = 1,
            Scale = 1.0, -- 1.0 = normal size
            MinScale = 0.5 -- Minimum scale at max distance
        },
        Tracer = {
            Thickness = 1,
            Origin = "Bottom" -- "Bottom", "Center", or "Mouse"
        },
        HealthBar = {
            Thickness = 2,
            Width = 4,
            Position = "Left" -- "Left" or "Right"
        }
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing cache
local drawings = {}

-- CORE FUNCTIONS
local function GetTeamColor(player)
    if not ESP.Settings.TeamCheck then 
        return ESP.Settings.AllyColor 
    end
    return player.Team == LocalPlayer.Team and ESP.Settings.AllyColor or ESP.Settings.EnemyColor
end

local function GetRainbowColor()
    return Color3.fromHSV(tick() * ESP.Settings.RainbowSpeed % 1, 1, 1)
end

local function GetHealthColor(health, maxHealth)
    local ratio = math.clamp(health / maxHealth, 0, 1)
    return Color3.fromRGB(255 - ratio * 255, ratio * 255, 0)
end

-- PROPER BOX SIZE CALCULATION (FIXED)
local function GetBoxSize(character, distance)
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not root then return Vector2.new(50, 80) end
    
    -- Calculate scale based on distance
    local scale = math.clamp(
        1 - (distance / ESP.Settings.MaxDistance) * (1 - ESP.Properties.Box.MinScale), 
        ESP.Properties.Box.MinScale, 
        1
    ) * ESP.Properties.Box.Scale
    
    -- Get actual character height
    local topPos, topVisible = Camera:WorldToViewportPoint(head.Position)
    local bottomPos, bottomVisible = Camera:WorldToViewportPoint(root.Position)
    
    if not (topVisible and bottomVisible) then
        return Vector2.new(50 * scale, 80 * scale) -- Fallback size
    end
    
    local height = math.abs(topPos.Y - bottomPos.Y)
    return Vector2.new(height * 0.6 * scale, height * scale) -- Maintain aspect ratio
end

-- FIXED VISIBILITY CHECK
local function IsVisible(part)
    local character = part.Parent
    local origin = Camera.CFrame.Position
    local target = part.Position
    
    -- Raycast check
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(origin, target - origin, raycastParams)
    return raycastResult == nil
end

-- MAIN RENDERING (FULLY FIXED)
local function UpdatePlayerESP(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Distance calculation
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESP.Settings.MaxDistance then return end

    -- Visibility check (FIXED)
    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    local isVisible = onScreen and IsVisible(rootPart)
    
    -- Initialize drawings if needed
    if not drawings[player] then
        drawings[player] = {
            Box = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            HealthBar = Drawing.new("Line"),
            Text = Drawing.new("Text")
        }
    end
    local d = drawings[player]

    -- Get colors
    local baseColor = ESP.Settings.RainbowMode and GetRainbowColor() or GetTeamColor(player)
    local healthColor = GetHealthColor(humanoid.Health, humanoid.MaxHealth)

    -- BOX ESP (FIXED SCALING AND VISIBILITY)
    if ESP.Settings.Box then
        local boxSize = GetBoxSize(character, distance)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        
        d.Box.Visible = ESP.Settings.Enabled and isVisible
        d.Box.Position = boxPos
        d.Box.Size = boxSize
        d.Box.Color = baseColor
        d.Box.Thickness = ESP.Properties.Box.Thickness
        d.Box.Filled = false
    else
        d.Box.Visible = false
    end

    -- TRACER (FIXED VISIBILITY)
    if ESP.Settings.Tracer then
        d.Tracer.Visible = ESP.Settings.Enabled and isVisible
        d.Tracer.Color = baseColor
        d.Tracer.Thickness = ESP.Properties.Tracer.Thickness
        
        local originY
        if ESP.Properties.Tracer.Origin == "Bottom" then
            originY = Camera.ViewportSize.Y
        elseif ESP.Properties.Tracer.Origin == "Center" then
            originY = Camera.ViewportSize.Y/2
        else -- Mouse
            originY = UserInputService:GetMouseLocation().Y
        end
        
        d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, originY)
        d.Tracer.To = Vector2.new(pos.X, pos.Y)
    else
        d.Tracer.Visible = false
    end

    -- HEALTHBAR (FIXED)
    if ESP.Settings.HealthBar then
        local boxSize = GetBoxSize(character, distance)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        
        d.HealthBar.Visible = ESP.Settings.Enabled and isVisible
        d.HealthBar.Color = healthColor
        d.HealthBar.Thickness = ESP.Properties.HealthBar.Thickness
        
        if ESP.Properties.HealthBar.Position == "Left" then
            d.HealthBar.From = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Width, boxPos.Y + boxSize.Y)
            d.HealthBar.To = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Width, boxPos.Y + boxSize.Y * (1 - healthRatio))
        else -- Right
            d.HealthBar.From = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Width, boxPos.Y + boxSize.Y)
            d.HealthBar.To = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Width, boxPos.Y + boxSize.Y * (1 - healthRatio))
        end
    else
        d.HealthBar.Visible = false
    end

    -- TEXT ESP
    if ESP.Settings.Name or ESP.Settings.Distance then
        local boxSize = GetBoxSize(character, distance)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        local text = ""
        
        if ESP.Settings.Name then
            text = player.Name
        end
        if ESP.Settings.Distance then
            text = text .. string.format(" (%d)", math.floor(distance))
        end
        
        d.Text.Visible = ESP.Settings.Enabled and isVisible
        d.Text.Text = text
        d.Text.Color = baseColor
        d.Text.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20)
        d.Text.Size = 13
        d.Text.Center = true
        d.Text.Outline = true
    else
        d.Text.Visible = false
    end
end

-- PLAYER HANDLING
local function PlayerAdded(player)
    if player == LocalPlayer then return end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        UpdatePlayerESP(player)
    end)

    player.CharacterRemoving:Connect(function()
        if drawings[player] then
            for _, drawing in pairs(drawings[player]) do
                drawing:Remove()
            end
            drawings[player] = nil
        end
        connection:Disconnect()
    end)
end

-- INITIALIZATION
function ESP:Load()
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerAdded(player)
    end
    Players.PlayerAdded:Connect(PlayerAdded)
end

function ESP:Toggle(state)
    self.Settings.Enabled = state
end

function ESP:SetRainbow(state, speed)
    self.Settings.RainbowMode = state
    if speed then self.Settings.RainbowSpeed = speed end
end

function ESP:Exit()
    for player, drawingTable in pairs(drawings) do
        for _, drawing in pairs(drawingTable) do
            drawing:Remove()
        end
    end
    drawings = {}
end

-- Start ESP
ESP:Load()

return ESP
