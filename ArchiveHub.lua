local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Clark's Settings
local sightRange = 100  -- Max range Clark can detect enemies
local refreshRate = 0.1 -- Frequency of enemy updates (in seconds)

-- Function to create or update a highlight for each part of the character
local function createFullCoverageHighlight(character)
    -- Remove any existing highlights to avoid duplicates
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("SelectionBox") and child.Name == "ClarkHighlight" then
            child:Destroy()
        end
    end

    -- Add highlights to each part
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.Name = "ClarkHighlight"
            selectionBox.Adornee = part
            selectionBox.LineThickness = 0.1
            selectionBox.Color3 = Color3.fromRGB(255, 165, 0) -- Orange color
            selectionBox.Parent = character
        end
    end
end

-- Function to update highlights for enemies
local function updateEnemyHighlights(clark)
    local clarkPosition = clark.HumanoidRootPart.Position

    -- Iterate through all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                -- Check if within sight range
                local distance = (humanoidRootPart.Position - clarkPosition).Magnitude
                if distance <= sightRange then
                    -- Add or update highlights for this character
                    createFullCoverageHighlight(character)
                else
                    -- Remove highlights if out of range
                    for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("SelectionBox") and child.Name == "ClarkHighlight" then
                            child:Destroy()
                        end
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
