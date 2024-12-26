local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local sightRange = 100  -- Max range Clark can detect enemies
local refreshRate = 0.1 -- Frequency of enemy updates (in seconds)

-- UI setup
local screenGui = Instance.new("ScreenGui")
local toggleFrame = Instance.new("Frame")
local highlightToggle = Instance.new("TextButton")
local autoLockToggle = Instance.new("TextButton")

screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "ClarkSkillUI"

toggleFrame.Parent = screenGui
toggleFrame.Size = UDim2.new(0, 200, 0, 100)
toggleFrame.Position = UDim2.new(0.5, -100, 0.8, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame.BorderSizePixel = 2
toggleFrame.BorderColor3 = Color3.new(1, 1, 1)

highlightToggle.Parent = toggleFrame
highlightToggle.Size = UDim2.new(1, 0, 0.5, 0)
highlightToggle.Position = UDim2.new(0, 0, 0, 0)
highlightToggle.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
highlightToggle.TextColor3 = Color3.new(0, 0, 0)
highlightToggle.Text = "Toggle Highlight: OFF"

autoLockToggle.Parent = toggleFrame
autoLockToggle.Size = UDim2.new(1, 0, 0.5, 0)
autoLockToggle.Position = UDim2.new(0, 0, 0.5, 0)
autoLockToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
autoLockToggle.TextColor3 = Color3.new(0, 0, 0)
autoLockToggle.Text = "Toggle Auto-Lock: OFF"

-- Flags for toggling functionalities
local highlightEnabled = false
local autoLockEnabled = false

-- Highlight function
local function createOrUpdateHighlight(character)
    local highlight = character:FindFirstChild("ClarkHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ClarkHighlight"
        highlight.Adornee = character
        highlight.Parent = character
    end

    highlight.FillColor = Color3.fromRGB(255, 165, 0) -- Orange
    highlight.OutlineColor = Color3.fromRGB(255, 85, 0)
    highlight.OutlineTransparency = 0
    highlight.FillTransparency = 0.3
end

-- Update highlights
local function updateEnemyHighlights(clark)
    if not highlightEnabled then return end
    local clarkPosition = clark.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - clarkPosition).Magnitude
                if distance <= sightRange then
                    createOrUpdateHighlight(character)
                else
                    local highlight = character:FindFirstChild("ClarkHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end

-- Auto-lock function
local function autoLockOnClosestEnemy(clark)
    if not autoLockEnabled then return end
    local closestEnemy = nil
    local closestDistance = math.huge

    local clarkPosition = clark.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - clarkPosition).Magnitude
                if distance <= sightRange and distance < closestDistance then
                    closestEnemy = humanoidRootPart
                    closestDistance = distance
                end
            end
        end
    end

    -- Lock on to the closest enemy's head
    if closestEnemy then
        clark.Humanoid:MoveTo(closestEnemy.Position)
    end
end

-- Refresh loop for highlights and auto-lock
local function refreshSkills()
    local clark = Players.LocalPlayer.Character
    if not clark then return end

    while true do
        updateEnemyHighlights(clark)
        autoLockOnClosestEnemy(clark)
        wait(refreshRate)
    end
end

-- Activate skills with UI toggle
highlightToggle.MouseButton1Click:Connect(function()
    highlightEnabled = not highlightEnabled
    highlightToggle.Text = "Toggle Highlight: " .. (highlightEnabled and "ON" or "OFF")
end)

autoLockToggle.MouseButton1Click:Connect(function()
    autoLockEnabled = not autoLockEnabled
    autoLockToggle.Text = "Toggle Auto-Lock: " .. (autoLockEnabled and "ON" or "OFF")
end)

-- Start the script
refreshSkills()
