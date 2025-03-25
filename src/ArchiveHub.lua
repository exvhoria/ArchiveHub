local cameraToggle = false
local cameraTarget = nil

-- Function to find the closest player to the center of the screen, excluding the local player
local function findClosestPlayerToScreenCenter()
    local playerList = game.Players:GetPlayers()
    local center = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    local closestPlayer = nil
    local minDistance = math.huge
    local localPlayer = game.Players.LocalPlayer  -- Get the local player

    for _, player in pairs(playerList) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            
            if onScreen then
                local distance = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Function to aim the camera at a specific player
local function aimCameraAtPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local camera = game.Workspace.CurrentCamera
        local targetPosition = player.Character.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

-- Function to toggle the camera aim on/off
local function toggleCameraAim()
    cameraToggle = not cameraToggle
    if cameraToggle then
        cameraTarget = findClosestPlayerToScreenCenter()
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "Press 'V' to toggle the aimbot",
            Color = Color3.new(1, 1, 0),  -- Yellow color
            FontSize = Enum.FontSize.Size24,
        })
    else
        cameraTarget = nil
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "Aimbot toggled off",
            Color = Color3.new(1, 0, 0),  -- Red color
            FontSize = Enum.FontSize.Size24,
        })
    end
end

-- Connect the toggleCameraAim function to the "V" key press
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.V then
        toggleCameraAim()
    end
end)

-- Continuously aim the camera at the closest player if the cameraToggle is on
local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    if cameraToggle and cameraTarget then
        aimCameraAtPlayer(cameraTarget)
    end
end)
