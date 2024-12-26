local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Clark's Settings
local sightRange = 100  -- Max range Clark can detect enemies
local refreshRate = 0.1 -- Frequency of enemy updates (in seconds)

-- Function to create or update a highlight effect for the entire body
local function createOrUpdateHighlight(character)
    -- Check if the character already has a highlight
    local highlight = character:FindFirstChild("ClarkHighlight")

    if not highlight then
        -- Create a new highlight if one doesn't exist
        highlight = Instance.new("Highlight")
        highlight.Name = "ClarkHighlight"
        highlight.Adornee = character
        highlight.Parent = character
    end

    -- Set the highlight color to orange
    highlight.FillColor = Color3.fromRGB(255, 165, 0) -- Orange fill color
    highlight.OutlineColor = Color3.fromRGB(255, 85, 0) -- Darker orange outline
    highlight.OutlineTransparency = 0 -- Fully visible outline
    highlight.FillTransparency = 0.3 -- Slight transparency for fill
end

-- Function to update enemy highlights
local function updateEnemyHighlights(clark)
    local clarkPosition = clark.HumanoidRootPart.Position

    -- Iterate through all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                -- Check if the player is within range
                local distance = (humanoidRootPart.Position - clarkPosition).Magnitude
                if distance <= sightRange then
                    -- Add or update the highlight
                    createOrUpdateHighlight(character)
                else
                    -- Remove the highlight if out of range
                    local highlight = character:FindFirstChild("ClarkHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end

-- Function to refresh highlights continuously
local function refreshHighlights()
    local clark = Players.LocalPlayer.Character
    if not clark then return end

    while true do
        updateEnemyHighlights(clark)
        wait(refreshRate)
    end
end

-- Activate the passive skill
local function activateThroughWalls()
    -- Listen for new players joining
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            local clark = Players.LocalPlayer.Character
            if clark then
                updateEnemyHighlights(clark)
            end
        end)
    end)

    -- Start the refresh loop
    refreshHighlights()
end

-- Run the passive skill script
activateThroughWalls()
