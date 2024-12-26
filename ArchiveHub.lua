-- Assuming Clark is the character activating the skill
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = game.Workspace.CurrentCamera

local lockRadius = 50 -- How close the enemy needs to be to get locked on
local cameraOffset = Vector3.new(0, 2, -10) -- Camera offset to get a better view of the enemy's head

-- Function to search for the nearest enemy
local function searchForNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = lockRadius -- Only search within lockRadius

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherCharacter = otherPlayer.Character
            if otherCharacter and otherCharacter:FindFirstChild("Head") then
                local distance = (character.HumanoidRootPart.Position - otherCharacter.HumanoidRootPart.Position).magnitude
                if distance < shortestDistance then
                    nearestEnemy = otherCharacter
                    shortestDistance = distance
                end
            end
        end
    end

    return nearestEnemy
end

-- Function to lock the camera onto an enemy's head
local function lockCameraToEnemy(enemy)
    local head = enemy:FindFirstChild("Head")
    if head then
        local targetPosition = head.Position
        -- Set the camera to focus on the enemy's head, adjusting the offset
        camera.CFrame = CFrame.new(targetPosition + cameraOffset, targetPosition) -- Lock camera to enemy's head
    end
end

-- Continuously search for the nearest enemy and lock camera to their head
game:GetService("RunService").Heartbeat:Connect(function()
    local nearestEnemy = searchForNearestEnemy()
    if nearestEnemy then
        lockCameraToEnemy(nearestEnemy)
    end
end)
