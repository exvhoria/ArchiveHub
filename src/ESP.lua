-- Velocity ESP v2.1.1 - Fixed Box Size Calculation
local ESP = {
    Config = {
        -- Master switches
        Enabled = true,
        TeamCheck = true,
        MaxDistance = 1500,
        
        -- Feature toggles
        ESP = {
            Enabled = true,
            ShowName = true,
            ShowDistance = true,
            ShowHealth = true,
            Font = Drawing.Fonts.UI,
            FontSize = 13,
            Offset = Vector2.new(0, -20) -- Text position offset
        },
        Box = {
            Enabled = true,
            Thickness = 1,
            Filled = false,
            Scale = 0.8 -- Fixed box size multiplier (0.8 = 80% of original size)
        },
        Tracer = {
            Enabled = true,
            Thickness = 1,
            Origin = "Bottom" -- "Bottom", "Center", or "Mouse"
        },
        HealthBar = {
            Enabled = true,
            Thickness = 2,
            Width = 4, -- Healthbar width
            Position = "Left" -- "Left" or "Right"
        },
        Rainbow = {
            Enabled = false,
            Speed = 0.5
        }
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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing cache
local drawings = {}

-- Core Functions
local function GetTeamColor(player)
    if not ESP.Config.TeamCheck then 
        return ESP.Colors.Enemy 
    end
    return player.Team == LocalPlayer.Team and ESP.Colors.Ally or ESP.Colors.Enemy
end

local function GetRainbowColor()
    return Color3.fromHSV(tick() * ESP.Config.Rainbow.Speed % 1, 1, 1)
end

local function GetHealthColor(health, maxHealth)
    local ratio = math.clamp(health / maxHealth, 0, 1)
    return ESP.Colors.HealthLow:Lerp(ESP.Colors.HealthHigh, ratio)
end

-- Proper box size calculation (fixed)
local function GetBoxSize(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not root or not head then return Vector2.new(50, 80) end
    
    -- Get world positions
    local topPos = Vector3.new(0, head.Position.Y, 0)
    local bottomPos = Vector3.new(0, root.Position.Y - (root.Size.Y/2), 0)
    
    -- Convert to screen space with safety checks
    local topScreen, topVisible = Camera:WorldToViewportPoint(topPos)
    local bottomScreen, bottomVisible = Camera:WorldToViewportPoint(bottomPos)
    
    if not (topVisible and bottomVisible) then
        return Vector2.new(50, 80) -- Fallback size
    end
    
    -- Calculate proper dimensions
    local screenHeight = math.abs(topScreen.Y - bottomScreen.Y)
    local screenWidth = screenHeight * 0.6 -- Aspect ratio
    
    return Vector2.new(
        screenWidth * ESP.Config.Box.Scale,
        screenHeight * ESP.Config.Box.Scale
    )
end

-- Main Rendering
local function UpdatePlayerESP(player)
    if not ESP.Config.Enabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return end

    -- Distance check
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESP.Config.MaxDistance then return end

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
    local baseColor = ESP.Config.Rainbow.Enabled and GetRainbowColor() or GetTeamColor(player)
    local healthColor = GetHealthColor(humanoid.Health, humanoid.MaxHealth)

    -- Box ESP
    if ESP.Config.Box.Enabled then
        local boxSize = GetBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        
        d.Box.Visible = true
        d.Box.Color = baseColor
        d.Box.Position = boxPos
        d.Box.Size = boxSize
        d.Box.Thickness = ESP.Config.Box.Thickness
        d.Box.Filled = ESP.Config.Box.Filled
    else
        d.Box.Visible = false
    end

    -- Tracer
    if ESP.Config.Tracer.Enabled then
        d.Tracer.Visible = true
        d.Tracer.Color = baseColor
        d.Tracer.Thickness = ESP.Config.Tracer.Thickness
        
        local originY
        if ESP.Config.Tracer.Origin == "Bottom" then
            originY = Camera.ViewportSize.Y
        elseif ESP.Config.Tracer.Origin == "Center" then
            originY = Camera.ViewportSize.Y/2
        else -- Mouse
            originY = UserInputService:GetMouseLocation().Y
        end
        
        d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, originY)
        d.Tracer.To = Vector2.new(pos.X, pos.Y)
    else
        d.Tracer.Visible = false
    end

    -- HealthBar
    if ESP.Config.HealthBar.Enabled then
        local boxSize = GetBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        
        d.HealthBar.Visible = true
        d.HealthBar.Color = healthColor
        d.HealthBar.Thickness = ESP.Config.HealthBar.Thickness
        
        if ESP.Config.HealthBar.Position == "Left" then
            d.HealthBar.From = Vector2.new(boxPos.X - ESP.Config.HealthBar.Width, boxPos.Y + boxSize.Y)
            d.HealthBar.To = Vector2.new(boxPos.X - ESP.Config.HealthBar.Width, boxPos.Y + boxSize.Y * (1 - healthRatio))
        else -- Right
            d.HealthBar.From = Vector2.new(boxPos.X + boxSize.X + ESP.Config.HealthBar.Width, boxPos.Y + boxSize.Y)
            d.HealthBar.To = Vector2.new(boxPos.X + boxSize.X + ESP.Config.HealthBar.Width, boxPos.Y + boxSize.Y * (1 - healthRatio))
        end
    else
        d.HealthBar.Visible = false
    end

    -- Text ESP
    if ESP.Config.ESP.Enabled then
        local boxSize = GetBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        local text = ""
        
        if ESP.Config.ESP.ShowName then
            text = player.Name
        end
        if ESP.Config.ESP.ShowHealth then
            text = text .. string.format(" [%d/%d]", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        end
        if ESP.Config.ESP.ShowDistance then
            text = text .. string.format(" (%d)", math.floor(distance))
        end
        
        d.Text.Visible = true
        d.Text.Color = baseColor
        d.Text.Text = text
        d.Text.Position = boxPos + ESP.Config.ESP.Offset
        d.Text.Size = ESP.Config.ESP.FontSize
        d.Text.Font = ESP.Config.ESP.Font
        d.Text.Center = true
    else
        d.Text.Visible = false
    end
end

-- Player Handling
local function PlayerAdded(player)
    if player == LocalPlayer then return end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        UpdatePlayerESP(player)
    end)

    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            if drawings[player] then
                for _, drawing in pairs(drawings[player]) do
                    drawing:Remove()
                end
                drawings[player] = nil
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
    self.Config.Enabled = state
end

function ESP:ToggleFeature(feature, state)
    if self.Config[feature] then
        self.Config[feature].Enabled = state
    end
end

function ESP:SetRainbow(state, speed)
    self.Config.Rainbow.Enabled = state
    if speed then self.Config.Rainbow.Speed = speed end
end

return ESP
