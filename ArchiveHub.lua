local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Clark's Settings
local sightRange = 100  -- Max range Clark can detect enemies
local refreshRate = 0.1 -- Frequency of enemy updates (in seconds)

-- Function to create a highlight effect for the entire body
local function createFullBodyHighlight(character)
    if not character:FindFirstChild("ClarkHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red highlight color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
        highlight.OutlineTransparency = 0.5
        highlight.Adornee = character
        highlight.Name = "ClarkHighlight"
        highlight.Parent = character
    end
end

-- Function to check visibility and highlight enemies
local function updateEnemyHighlights(clark)
    local clarkPosition = clark.HumanoidRootPart.Position

    -- Go through all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                -- Check if within sight range
                local distance = (humanoidRootPart.Position - clarkPosition).Magnitude
                if distance <= sightRange then
                    -- Create or update the highlight effect
                    createFullBodyHighlight(character)
                else
                    -- Remove the highlight if the target is out of range
                    if character:FindFirstChild("ClarkHighlight") then
                        character.ClarkHighlight:Destroy()
                    end
                end
            end
        end
    end
end

-- Function to continuously refresh highlights
local function refreshHighlights()
    local clark = Players.LocalPlayer.Character
    if not clark then return end

    -- Start continuous enemy tracking
    while true do
        updateEnemyHighlights(clark)
        wait(refreshRate)
    end
end

-- Execute the highlight script (triggered by the UI or script execution)
local function activateThroughWalls()
    -- Listen for new players joining
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            local clark = Players.LocalPlayer.Character
            if clark then
                -- Ensure highlights are updated for new players
                updateEnemyHighlights(clark)
            end
        end)
    end)

    -- Start highlighting enemies
    refreshHighlights()
end

-- Run the function to activate the passive ability
activateThroughWalls()
