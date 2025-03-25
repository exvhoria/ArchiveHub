local player = game:GetService("Players").LocalPlayer
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")
local uiService = game:GetService("StarterGui")

-- Ensure LocalPlayer is loaded
while not player do
    wait()
    player = game:GetService("Players").LocalPlayer
end

-- SETTINGS
local SCREEN_SIZE = camera.ViewportSize
local FOV_SIZE = UDim2.new(0.05, 0, 0.05, 0) -- Set relative size
local FOV_POSITION = UDim2.new(0.5, -SCREEN_SIZE.X * 0.025, 0.5, -SCREEN_SIZE.Y * 0.025) -- Centered to crosshair

-- Function to create UI elements
local function createUI()
    -- Remove old UI if exists
    if player:FindFirstChild("PlayerGui") then
        for _, v in pairs(player.PlayerGui:GetChildren()) do
            if v.Name == "AimAssistUI" then
                v:Destroy()
            end
        end
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimAssistUI"
    screenGui.Parent = player:FindFirstChild("PlayerGui") or uiService:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

    -- NPC Distance UI
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = screenGui
    textLabel.Position = UDim2.new(0.5, -100, 0, 20)
    textLabel.Size = UDim2.new(0, 250, 0, 30)
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0) -- Solid Black Background
    textLabel.BackgroundTransparency = 0.3 -- Slight Transparency
    textLabel.BorderSizePixel = 0
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = "Searching for NPCs..."
    
    -- Create a FOV Circle
    local fovFrame = Instance.new("Frame")
    fovFrame.Parent = screenGui
    fovFrame.Size = FOV_SIZE
    fovFrame.Position = FOV_POSITION
    fovFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Black Transparent
    fovFrame.BackgroundTransparency = 0.4 -- 40% Transparent
    fovFrame.ZIndex = 2
    fovFrame.BorderSizePixel = 2 -- White Outline
    fovFrame.BorderColor3 = Color3.new(1, 1, 1)

    -- Fix: Make FOV Circle Shaped
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- Makes it a perfect circle
    corner.Parent = fovFrame

    -- Create an X button to close UI
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = screenGui
    closeButton.Position = UDim2.new(1, -50, 0, 20)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "X"
    closeButton.TextScaled = true
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui, textLabel
end

-- Initialize UI
local screenGui, textLabel = createUI()

-- Function to find NPCs (excluding players)
local function getAllNPCs()
    local npcs = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if not obj:FindFirstChildOfClass("Player") then -- Ensure it's not a player
                table.insert(npcs, obj)
            end
        end
    end

    return npcs
end

-- Function to get the nearest NPC inside FOV circle
local function getNearestNPC()
    local nearestNPC = nil
    local shortestDistance = math.huge
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return nil, nil end -- Prevent errors when player dies

    for _, npc in ipairs(getAllNPCs()) do
        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
        if npcRoot then
            -- Convert NPC world position to screen position
            local screenPosition, onScreen = camera:WorldToViewportPoint(npcRoot.Position)

            -- Check if NPC is inside the FOV circle
            local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(SCREEN_SIZE.X / 2, SCREEN_SIZE.Y / 2)).Magnitude
            if onScreen and screenDistance < (SCREEN_SIZE.X * 0.025) then
                local distance = (npcRoot.Position - humanoidRootPart.Position).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestNPC = npc
                end
            end
        end
    end

    return nearestNPC, shortestDistance
end

-- Lock camera & aim to NPC inside FOV
runService.RenderStepped:Connect(function()
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return end -- Prevent errors when player dies

    local nearestNPC, distance = getNearestNPC()
    
    if nearestNPC then
        textLabel.Text = nearestNPC.Name .. " | " .. math.floor(distance) .. "m"

        -- Find the NPC's Head
        local npcHead = nearestNPC:FindFirstChild("Head") or nearestNPC:FindFirstChild("UpperTorso") or nearestNPC:FindFirstChild("HumanoidRootPart")
        if npcHead then
            -- Lock the camera & player direction to NPC's head
            local lookAtPosition = npcHead.Position + Vector3.new(0, 1.5, 0) -- Slightly above the head
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, lookAtPosition)
            camera.CFrame = CFrame.new(camera.CFrame.Position, lookAtPosition)
        end
    else
        textLabel.Text = "No NPCs in FOV"
    end
end)

-- Recreate UI after respawn
player.CharacterAdded:Connect(function()
    screenGui, textLabel = createUI()
end)
