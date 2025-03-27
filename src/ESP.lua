-- Velocity ESP Hybrid v3.0
local ESP = {
    DeveloperSettings = {
        UpdateMode = "RenderStepped",   -- "RenderStepped", "Stepped", or "Heartbeat"
        TeamCheckOption = "TeamColor",  -- "TeamColor" or "Team"
        RainbowSpeed = 0.5,             -- Lower = faster rainbow
        WidthBoundary = 1.5             -- Box width divisor
    },
    Settings = {
        Enabled = true,
        TeamCheck = true,
        AllyColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0),
        RainbowColor = false,
        MaxDistance = 1000,
        -- Feature toggles
        ESP = true,
        Tracer = true,
        Box = true,
        HealthBar = true,
        HeadDot = false,  -- Disabled by default
        Chams = false     -- Disabled by default
    },
    Properties = {
        ESP = {
            Font = Drawing.Fonts.UI,
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Transparency = 1,
            Offset = 15
        },
        Tracer = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Position = 1,  -- 1 = Bottom, 2 = Center, 3 = Mouse
            Transparency = 1
        },
        Box = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Filled = false
        },
        HealthBar = {
            Thickness = 2,
            Color = Color3.fromRGB(255, 255, 255),
            Position = 3,  -- 1 = Top, 2 = Bottom, 3 = Left, 4 = Right
            Offset = 6,
            Blue = 0
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

-- CORE FUNCTIONS (Optimized from both versions)
local function GetTeamColor(player)
    if not ESP.Settings.TeamCheck then 
        return ESP.Properties.ESP.Color 
    end
    
    if ESP.DeveloperSettings.TeamCheckOption == "TeamColor" then
        return player.TeamColor == LocalPlayer.TeamColor 
               and ESP.Settings.AllyColor 
               or ESP.Settings.EnemyColor
    else
        return player.Team == LocalPlayer.Team 
               and ESP.Settings.AllyColor 
               or ESP.Settings.EnemyColor
    end
end

local function GetRainbowColor()
    return Color3.fromHSV(tick() * ESP.DeveloperSettings.RainbowSpeed % 1, 1, 1)
end

local function GetHealthColor(health, maxHealth)
    local ratio = math.clamp(health / maxHealth, 0, 1)
    return Color3.fromRGB(255 - ratio * 255, ratio * 255, ESP.Properties.HealthBar.Blue)
end

local function GetProperBoxSize(character)
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not root then return Vector2.new(50, 80) end
    
    -- Get positions with proper visibility checks
    local topPos, topVisible = Camera:WorldToViewportPoint(head.Position)
    local bottomPos, bottomVisible = Camera:WorldToViewportPoint(root.Position)
    
    if not (topVisible and bottomVisible) then
        return Vector2.new(50, 80) -- Fallback size
    end
    
    -- Calculate screen-space dimensions
    local height = math.abs(topPos.Y - bottomPos.Y)
    local width = height * (ESP.DeveloperSettings.WidthBoundary / 2) -- Proper aspect ratio
    
    return Vector2.new(width, height)
end

-- MAIN RENDERING (Fixed visibility and scaling)
local function UpdatePlayerESP(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Proper visibility check (fixes stuck ESP)
    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        if drawings[player] then
            for _, drawing in pairs(drawings[player]) do
                drawing.Visible = false
            end
        end
        return
    end

    -- Distance check
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESP.Settings.MaxDistance then return end

    -- Initialize drawings if needed
    if not drawings[player] then
        drawings[player] = {
            Box = {Lines = {}, Fill = nil},
            Tracer = Drawing.new("Line"),
            HealthBar = {Main = nil, Outline = nil},
            Text = Drawing.new("Text")
        }
        
        -- Box setup (4 lines)
        for i = 1, 4 do
            drawings[player].Box.Lines[i] = Drawing.new("Line")
        end
        
        -- Healthbar setup
        drawings[player].HealthBar.Main = Drawing.new("Line")
        drawings[player].HealthBar.Outline = Drawing.new("Line")
    end
    local d = drawings[player]

    -- Get colors
    local baseColor = ESP.Settings.RainbowColor and GetRainbowColor() or GetTeamColor(player)
    local healthColor = GetHealthColor(humanoid.Health, humanoid.MaxHealth)

    -- BOX ESP (Fixed scaling)
    if ESP.Settings.Box then
        local boxSize = GetProperBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        
        -- Box lines
        local corners = {
            Vector2.new(boxPos.X, boxPos.Y), -- Top-left
            Vector2.new(boxPos.X + boxSize.X, boxPos.Y), -- Top-right
            Vector2.new(boxPos.X + boxSize.X, boxPos.Y + boxSize.Y), -- Bottom-right
            Vector2.new(boxPos.X, boxPos.Y + boxSize.Y) -- Bottom-left
        }
        
        for i = 1, 4 do
            local line = d.Box.Lines[i]
            line.Visible = ESP.Settings.Enabled
            line.From = corners[i]
            line.To = corners[i % 4 + 1]
            line.Color = baseColor
            line.Thickness = ESP.Properties.Box.Thickness
        end
    end

    -- TRACER (Fixed visibility)
    if ESP.Settings.Tracer then
        d.Tracer.Visible = ESP.Settings.Enabled and onScreen
        d.Tracer.Color = baseColor
        d.Tracer.Thickness = ESP.Properties.Tracer.Thickness
        
        local originY
        if ESP.Properties.Tracer.Position == 1 then -- Bottom
            originY = Camera.ViewportSize.Y
        elseif ESP.Properties.Tracer.Position == 2 then -- Center
            originY = Camera.ViewportSize.Y / 2
        else -- Mouse
            originY = UserInputService:GetMouseLocation().Y
        end
        
        d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, originY)
        d.Tracer.To = Vector2.new(pos.X, pos.Y)
    end

    -- HEALTHBAR (Optimized)
    if ESP.Settings.HealthBar then
        local boxSize = GetProperBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        
        -- Main bar
        d.HealthBar.Main.Visible = ESP.Settings.Enabled
        d.HealthBar.Main.Color = healthColor
        d.HealthBar.Main.Thickness = ESP.Properties.HealthBar.Thickness
        
        -- Outline
        d.HealthBar.Outline.Visible = ESP.Settings.Enabled
        d.HealthBar.Outline.Color = ESP.Properties.HealthBar.OutlineColor or Color3.new(0,0,0)
        d.HealthBar.Outline.Thickness = ESP.Properties.HealthBar.Thickness + 1
        
        -- Position based on setting
        if ESP.Properties.HealthBar.Position == 1 then -- Top
            d.HealthBar.Main.From = Vector2.new(boxPos.X, boxPos.Y - ESP.Properties.HealthBar.Offset)
            d.HealthBar.Main.To = Vector2.new(boxPos.X + boxSize.X * healthRatio, boxPos.Y - ESP.Properties.HealthBar.Offset)
            d.HealthBar.Outline.From = Vector2.new(boxPos.X, boxPos.Y - ESP.Properties.HealthBar.Offset)
            d.HealthBar.Outline.To = Vector2.new(boxPos.X + boxSize.X, boxPos.Y - ESP.Properties.HealthBar.Offset)
        elseif ESP.Properties.HealthBar.Position == 2 then -- Bottom
            d.HealthBar.Main.From = Vector2.new(boxPos.X, boxPos.Y + boxSize.Y + ESP.Properties.HealthBar.Offset)
            d.HealthBar.Main.To = Vector2.new(boxPos.X + boxSize.X * healthRatio, boxPos.Y + boxSize.Y + ESP.Properties.HealthBar.Offset)
            d.HealthBar.Outline.From = Vector2.new(boxPos.X, boxPos.Y + boxSize.Y + ESP.Properties.HealthBar.Offset)
            d.HealthBar.Outline.To = Vector2.new(boxPos.X + boxSize.X, boxPos.Y + boxSize.Y + ESP.Properties.HealthBar.Offset)
        elseif ESP.Properties.HealthBar.Position == 3 then -- Left
            d.HealthBar.Main.From = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y)
            d.HealthBar.Main.To = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y * (1 - healthRatio))
            d.HealthBar.Outline.From = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y)
            d.HealthBar.Outline.To = Vector2.new(boxPos.X - ESP.Properties.HealthBar.Offset, boxPos.Y)
        else -- Right
            d.HealthBar.Main.From = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y)
            d.HealthBar.Main.To = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y * (1 - healthRatio))
            d.HealthBar.Outline.From = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Offset, boxPos.Y + boxSize.Y)
            d.HealthBar.Outline.To = Vector2.new(boxPos.X + boxSize.X + ESP.Properties.HealthBar.Offset, boxPos.Y)
        end
    end

    -- TEXT ESP (Optimized)
    if ESP.Settings.ESP then
        local boxSize = GetProperBoxSize(character)
        local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
        
        d.Text.Visible = ESP.Settings.Enabled
        d.Text.Text = string.format("%s [%d/%d] (%d)", 
            player.Name, 
            math.floor(humanoid.Health), 
            math.floor(humanoid.MaxHealth),
            math.floor(distance))
        d.Text.Color = baseColor
        d.Text.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20)
        d.Text.Size = ESP.Properties.ESP.Size
        d.Text.Font = ESP.Properties.ESP.Font
        d.Text.Center = true
        d.Text.Outline = ESP.Properties.ESP.Outline
    end
end

-- PLAYER HANDLING (Optimized)
local function PlayerAdded(player)
    if player == LocalPlayer then return end
    
    local connection
    connection = RunService[ESP.DeveloperSettings.UpdateMode]:Connect(function()
        if ESP.Settings.Enabled then
            UpdatePlayerESP(player)
        elseif drawings[player] then
            for _, drawing in pairs(drawings[player]) do
                if typeof(drawing) == "table" then
                    for _, subDrawing in pairs(drawing) do
                        subDrawing.Visible = false
                    end
                else
                    drawing.Visible = false
                end
            end
        end
    end)

    player.CharacterRemoving:Connect(function()
        if drawings[player] then
            for _, drawing in pairs(drawings[player]) do
                if typeof(drawing) == "table" then
                    for _, subDrawing in pairs(drawing) do
                        subDrawing:Remove()
                    end
                else
                    drawing:Remove()
                end
            end
            drawings[player] = nil
        end
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
    self.Settings.RainbowColor = state
    if speed then self.DeveloperSettings.RainbowSpeed = speed end
end

function ESP:Exit()
    for player, drawingTable in pairs(drawings) do
        for _, drawing in pairs(drawingTable) do
            if typeof(drawing) == "table" then
                for _, subDrawing in pairs(drawing) do
                    subDrawing:Remove()
                end
            else
                drawing:Remove()
            end
        end
    end
    drawings = {}
end

-- Start ESP
ESP:Load()

return ESP
