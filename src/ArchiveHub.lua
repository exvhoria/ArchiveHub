-- ESP Test, hell yeah
-- Velocity ESP v2.0
-- Features: Advanced ESP, Tracer, Box, Healthbar, Rainbow Mode
-- No bloat (No Chams/HeadDot/Crosshair)

local ESP = {
    Settings = {
        Enabled = true,
        TeamCheck = true,
        MaxDistance = 1500,
        RainbowMode = false,
        RainbowSpeed = 0.5
    },
    Colors = {
        Ally = Color3.fromRGB(0, 255, 0),
        Enemy = Color3.fromRGB(255, 0, 0),
        HealthHigh = Color3.fromRGB(0, 255, 0),
        HealthLow = Color3.fromRGB(255, 0, 0)
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing cache
local drawings = {
    Boxes = {},
    Tracers = {},
    HealthBars = {},
    Texts = {}
}

-- Core Functions
local function GetTeamColor(player)
    if ESP.Settings.TeamCheck then
        return player.Team == LocalPlayer.Team 
               and ESP.Colors.Ally 
               or ESP.Colors.Enemy
    end
    return ESP.Colors.Enemy
end

local function GetRainbowColor()
    return Color3.fromHSV(tick() * ESP.Settings.RainbowSpeed % 1, 1, 1)
end

local function GetHealthColor(health, maxHealth)
    local ratio = health / maxHealth
    return ESP.Colors.HealthLow:Lerp(ESP.Colors.HealthHigh, ratio)
end

-- Main Rendering
local function UpdatePlayerESP(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return end

    -- Distance check
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESP.Settings.MaxDistance then return end

    -- Calculate box size based on distance
    local boxSize = Vector2.new(50, 80) * (1000 / math.max(distance, 1))
    local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)

    -- Get colors
    local baseColor = ESP.Settings.RainbowMode and GetRainbowColor() or GetTeamColor(player)
    local healthColor = GetHealthColor(humanoid.Health, humanoid.MaxHealth)

    -- Create/update drawings
    if not drawings.Boxes[player] then
        drawings.Boxes[player] = Drawing.new("Square")
        drawings.Tracers[player] = Drawing.new("Line")
        drawings.HealthBars[player] = Drawing.new("Line")
        drawings.Texts[player] = Drawing.new("Text")
    end

    -- Box
    local box = drawings.Boxes[player]
    box.Visible = true
    box.Color = baseColor
    box.Position = boxPos
    box.Size = boxSize
    box.Thickness = 1
    box.Filled = false

    -- Tracer
    local tracer = drawings.Tracers[player]
    tracer.Visible = true
    tracer.Color = baseColor
    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    tracer.To = Vector2.new(pos.X, pos.Y)
    tracer.Thickness = 1

    -- Healthbar
    local healthBar = drawings.HealthBars[player]
    healthBar.Visible = true
    healthBar.Color = healthColor
    healthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y)
    healthBar.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y * (1 - humanoid.Health/humanoid.MaxHealth))
    healthBar.Thickness = 2

    -- Text
    local text = drawings.Texts[player]
    text.Visible = true
    text.Color = baseColor
    text.Text = string.format("%s [%d/%d] (%d studs)", 
        player.Name, 
        math.floor(humanoid.Health), 
        math.floor(humanoid.MaxHealth),
        math.floor(distance))
    text.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 16)
    text.Size = 13
    text.Center = true
end

-- Player Handling
local function PlayerAdded(player)
    if player == LocalPlayer then return end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if ESP.Settings.Enabled then
            UpdatePlayerESP(player)
        else
            -- Clear drawings when disabled
            if drawings.Boxes[player] then
                drawings.Boxes[player].Visible = false
                drawings.Tracers[player].Visible = false
                drawings.HealthBars[player].Visible = false
                drawings.Texts[player].Visible = false
            end
        end
    end)

    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            if drawings.Boxes[player] then
                drawings.Boxes[player]:Remove()
                drawings.Tracers[player]:Remove()
                drawings.HealthBars[player]:Remove()
                drawings.Texts[player]:Remove()
                drawings.Boxes[player] = nil
            end
        end
    end)
end

-- Initialization
for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
Players.PlayerAdded:Connect(PlayerAdded)

-- Control Functions
function ESP:Toggle(state)
    self.Settings.Enabled = state
    print("Velocity ESP", state and "ENABLED" or "DISABLED")
end

function ESP:SetRainbowMode(state)
    self.Settings.RainbowMode = state
end

return ESP
