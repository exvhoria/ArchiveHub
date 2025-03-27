-- ESP Module extracted from AirHub V2
local ESP = {
    DeveloperSettings = {
        UpdateMode = "RenderStepped",
        TeamCheckOption = "TeamColor",
        RainbowSpeed = 0.5,
        WidthBoundary = 1.5
    },
    
    Settings = {
        LoadConfigOnLaunch = false,
        Enabled = true,
        PartsOnly = false,
        TeamCheck = true,
        AllyColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0),
        RainbowColor = false,
        Distance = true,
        DistanceMeasurement = "Studs",
        DistanceAbbreviation = true,
        DisplayName = true,
        Health = true,
        HealthPercentage = false,
        Boxes = true,
        BoxFill = false,
        BoxFillTransparency = 0.5,
        Tracers = true,
        HeadDots = true,
        HeadDotOutline = true,
        HealthBars = true,
        HealthText = true,
        Chams = true,
        ChamOutline = true,
        TextOutline = true,
        TextFont = "UI",
        TextSize = 13,
        TextOffset = 15,
        LimitDistance = false,
        MaxDistance = 1000
    },
    
    Properties = {
        ESP = {
            Font = Drawing.Fonts.UI,
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Offset = 15
        },
        
        Tracer = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = false,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            FromMouse = false,
            Position = 1 -- 1 = Bottom, 2 = Center, 3 = Mouse
        },
        
        HeadDot = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Filled = false,
            NumSides = 30
        },
        
        Box = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Filled = false,
            FilledColor = Color3.fromRGB(255, 255, 255),
            FilledTransparency = 0.5
        },
        
        HealthBar = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Position = 2, -- 1 = Top, 2 = Bottom, 3 = Left, 4 = Right
            Offset = 6,
            Blue = 0
        },
        
        Chams = {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Filled = false,
            FilledColor = Color3.fromRGB(255, 255, 255),
            FilledTransparency = 0.5
        },
        
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 12,
            GapSize = 5,
            Rotation = 0,
            RotationSpeed = 0,
            Thickness = 1,
            Transparency = 1,
            Pulsing = false,
            PulsingSpeed = 5,
            PulsingStep = 0,
            PulsingBounds = {0, 12},
            Position = 1, -- 1 = Mouse, 2 = Center
            CenterDot = {
                Enabled = false,
                Color = Color3.fromRGB(255, 255, 255),
                Radius = 3,
                NumSides = 12,
                Thickness = 1,
                Transparency = 1,
                Filled = false
            }
        }
    }
}

-- Internal variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Objects = {}
local Connections = {}

-- Drawing functions
local function Create(class, properties)
    local drawing = Drawing.new(class)
    
    for property, value in next, properties do
        drawing[property] = value
    end
    
    return drawing
end

local function AddObject(player, object)
    if not Objects[player] then
        Objects[player] = {}
    end
    
    table.insert(Objects[player], object)
    return object
end

-- ESP functions
local function UpdateTeamColor(player, drawing)
    if ESP.Settings.TeamCheck and player.Team ~= LocalPlayer.Team then
        drawing.Color = ESP.Settings.EnemyColor
    else
        drawing.Color = ESP.Settings.AllyColor
    end
end

local function UpdateRainbowColor(drawing)
    local hue = tick() * ESP.DeveloperSettings.RainbowSpeed % 1
    drawing.Color = Color3.fromHSV(hue, 1, 1)
end

local function UpdateESP(player, character)
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    
    -- Create ESP objects if they don't exist
    if not Objects[player] then
        Objects[player] = {}
        
        -- Text
        local text = Create("Text", {
            Text = player.Name,
            Size = ESP.Properties.ESP.Size,
            Center = ESP.Properties.ESP.Center,
            Outline = ESP.Properties.ESP.Outline,
            OutlineColor = ESP.Properties.ESP.OutlineColor,
            Color = ESP.Properties.ESP.Color,
            Transparency = ESP.Properties.ESP.Transparency,
            Visible = false
        })
        
        AddObject(player, text)
        
        -- Tracer
        if ESP.Settings.Tracers then
            local tracer = Create("Line", {
                Thickness = ESP.Properties.Tracer.Thickness,
                Color = ESP.Properties.Tracer.Color,
                Transparency = ESP.Properties.Tracer.Transparency,
                Visible = false
            })
            
            AddObject(player, tracer)
        end
        
        -- Box
        if ESP.Settings.Boxes then
            local box = {}
            
            for i = 1, 4 do
                box[i] = Create("Line", {
                    Thickness = ESP.Properties.Box.Thickness,
                    Color = ESP.Properties.Box.Color,
                    Transparency = ESP.Properties.Box.Transparency,
                    Visible = false
                })
                
                AddObject(player, box[i])
            end
            
            if ESP.Settings.BoxFill then
                local boxFill = Create("Square", {
                    Thickness = 1,
                    Color = ESP.Properties.Box.FilledColor,
                    Transparency = ESP.Properties.Box.FilledTransparency,
                    Filled = true,
                    Visible = false
                })
                
                AddObject(player, boxFill)
            end
        end
        
        -- Head Dot
        if ESP.Settings.HeadDots then
            local headDot = Create("Circle", {
                Thickness = ESP.Properties.HeadDot.Thickness,
                Color = ESP.Properties.HeadDot.Color,
                Transparency = ESP.Properties.HeadDot.Transparency,
                NumSides = ESP.Properties.HeadDot.NumSides,
                Filled = ESP.Properties.HeadDot.Filled,
                Visible = false
            })
            
            if ESP.Properties.HeadDot.Outline then
                local headDotOutline = Create("Circle", {
                    Thickness = ESP.Properties.HeadDot.Thickness + 1,
                    Color = ESP.Properties.HeadDot.OutlineColor,
                    Transparency = ESP.Properties.HeadDot.Transparency,
                    NumSides = ESP.Properties.HeadDot.NumSides,
                    Filled = false,
                    Visible = false
                })
                
                AddObject(player, headDotOutline)
            end
            
            AddObject(player, headDot)
        end
        
        -- Health Bar
        if ESP.Settings.HealthBars then
            local healthBar = {}
            
            for i = 1, 2 do
                healthBar[i] = Create("Line", {
                    Thickness = ESP.Properties.HealthBar.Thickness,
                    Color = ESP.Properties.HealthBar.Color,
                    Transparency = ESP.Properties.HealthBar.Transparency,
                    Visible = false
                })
                
                AddObject(player, healthBar[i])
            end
            
            if ESP.Properties.HealthBar.Outline then
                local healthBarOutline = {}
                
                for i = 1, 4 do
                    healthBarOutline[i] = Create("Line", {
                        Thickness = ESP.Properties.HealthBar.Thickness + 1,
                        Color = ESP.Properties.HealthBar.OutlineColor,
                        Transparency = ESP.Properties.HealthBar.Transparency,
                        Visible = false
                    })
                    
                    AddObject(player, healthBarOutline[i])
                end
            end
        end
        
        -- Chams
        if ESP.Settings.Chams then
            -- Cham implementation would go here
        end
    end
    
    -- Update ESP objects
    local text = Objects[player][1]
    local index = 2
    
    if ESP.Settings.Tracers then
        local tracer = Objects[player][index]
        index = index + 1
        
        if ESP.Settings.RainbowColor then
            UpdateRainbowColor(tracer)
        else
            UpdateTeamColor(player, tracer)
        end
        
        tracer.Thickness = ESP.Properties.Tracer.Thickness
        tracer.Transparency = ESP.Properties.Tracer.Transparency
        tracer.Visible = ESP.Settings.Enabled and ESP.Settings.Tracers
    end
    
    if ESP.Settings.Boxes then
        local box = {Objects[player][index], Objects[player][index + 1], Objects[player][index + 2], Objects[player][index + 3]}
        index = index + 4
        
        if ESP.Settings.BoxFill then
            local boxFill = Objects[player][index]
            index = index + 1
            
            if ESP.Settings.RainbowColor then
                UpdateRainbowColor(boxFill)
            else
                UpdateTeamColor(player, boxFill)
            end
            
            boxFill.Transparency = ESP.Properties.Box.FilledTransparency
            boxFill.Visible = ESP.Settings.Enabled and ESP.Settings.Boxes and ESP.Settings.BoxFill
        end
        
        for i, line in ipairs(box) do
            if ESP.Settings.RainbowColor then
                UpdateRainbowColor(line)
            else
                UpdateTeamColor(player, line)
            end
            
            line.Thickness = ESP.Properties.Box.Thickness
            line.Transparency = ESP.Properties.Box.Transparency
            line.Visible = ESP.Settings.Enabled and ESP.Settings.Boxes
        end
    end
    
    if ESP.Settings.HeadDots then
        local headDotOutline, headDot
        
        if ESP.Properties.HeadDot.Outline then
            headDotOutline = Objects[player][index]
            headDot = Objects[player][index + 1]
            index = index + 2
        else
            headDot = Objects[player][index]
            index = index + 1
        end
        
        if ESP.Settings.RainbowColor then
            UpdateRainbowColor(headDot)
            if headDotOutline then
                UpdateRainbowColor(headDotOutline)
            end
        else
            UpdateTeamColor(player, headDot)
            if headDotOutline then
                UpdateTeamColor(player, headDotOutline)
            end
        end
        
        headDot.Thickness = ESP.Properties.HeadDot.Thickness
        headDot.Transparency = ESP.Properties.HeadDot.Transparency
        headDot.NumSides = ESP.Properties.HeadDot.NumSides
        headDot.Visible = ESP.Settings.Enabled and ESP.Settings.HeadDots
        
        if headDotOutline then
            headDotOutline.Thickness = ESP.Properties.HeadDot.Thickness + 1
            headDotOutline.Transparency = ESP.Properties.HeadDot.Transparency
            headDotOutline.NumSides = ESP.Properties.HeadDot.NumSides
            headDotOutline.Visible = ESP.Settings.Enabled and ESP.Settings.HeadDots and ESP.Properties.HeadDot.Outline
        end
    end
    
    if ESP.Settings.HealthBars then
        -- Health bar update logic would go here
    end
    
    -- Update text
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    local displayText = ""
    
    if ESP.Settings.DisplayName then
        displayText = player.Name
    end
    
    if ESP.Settings.Distance then
        if displayText ~= "" then
            displayText = displayText .. " "
        end
        
        local distanceText = tostring(math.floor(distance))
        
        if ESP.Settings.DistanceAbbreviation then
            distanceText = distanceText .. "s"
        end
        
        displayText = displayText .. "[" .. distanceText .. "]"
    end
    
    if ESP.Settings.Health then
        if displayText ~= "" then
            displayText = displayText .. " "
        end
        
        local healthText
        
        if ESP.Settings.HealthPercentage then
            healthText = tostring(math.floor((humanoid.Health / humanoid.MaxHealth) * 100)) .. "%"
        else
            healthText = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(math.floor(humanoid.MaxHealth))
        end
        
        displayText = displayText .. "(" .. healthText .. ")"
    end
    
    text.Text = displayText
    text.Size = ESP.Properties.ESP.Size
    text.Outline = ESP.Properties.ESP.Outline
    text.OutlineColor = ESP.Properties.ESP.OutlineColor
    text.Center = ESP.Properties.ESP.Center
    text.Offset = ESP.Properties.ESP.Offset
    
    if ESP.Settings.RainbowColor then
        UpdateRainbowColor(text)
    else
        UpdateTeamColor(player, text)
    end
    
    text.Transparency = ESP.Properties.ESP.Transparency
    text.Visible = ESP.Settings.Enabled and (not ESP.Settings.LimitDistance or distance <= ESP.Settings.MaxDistance)
end

local function UpdateAllESP()
    for player, objects in pairs(Objects) do
        if player ~= LocalPlayer and player.Character then
            UpdateESP(player, player.Character)
        end
    end
end

local function CharacterAdded(player, character)
    character:WaitForChild("HumanoidRootPart")
    UpdateESP(player, character)
end

local function PlayerAdded(player)
    Connections[player] = player.CharacterAdded:Connect(function(character)
        CharacterAdded(player, character)
    end)
    
    if player.Character then
        CharacterAdded(player, player.Character)
    end
end

local function PlayerRemoving(player)
    if Connections[player] then
        Connections[player]:Disconnect()
        Connections[player] = nil
    end
    
    if Objects[player] then
        for _, object in ipairs(Objects[player]) do
            object:Remove()
        end
        
        Objects[player] = nil
    end
end

-- Public functions
function ESP:Load()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            PlayerAdded(player)
        end
    end
    
    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(PlayerRemoving)
    
    RunService[ESP.DeveloperSettings.UpdateMode]:Connect(UpdateAllESP)
end

function ESP:Restart()
    for player in pairs(Objects) do
        PlayerRemoving(player)
    end
    
    self:Load()
end

function ESP:Exit()
    for player in pairs(Objects) do
        PlayerRemoving(player)
    end
    
    for _, connection in pairs(Connections) do
        connection:Disconnect()
    end
    
    table.clear(Objects)
    table.clear(Connections)
end

return ESP
