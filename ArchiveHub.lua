-- Assuming Clark is the character activating the skill
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local mouse = player:GetMouse()

local autolockSkillEnabled = true
local lockedTarget = nil
local lockRadius = 50 -- How close the enemy needs to be to get locked on
local camera = game.Workspace.CurrentCamera

-- Function to lock the camera onto an enemy's head
local function lockCameraOntoEnemy(enemy)
    -- Check if the enemy has a head (you could check for other parts as well)
    local head = enemy:FindFirstChild("Head")
    if head then
        lockedTarget = head
        autolockSkillEnabled = true
        print("Camera locked onto " .. enemy.Name)
    end
end

-- Function to disable auto-lock
local function disableAutoLock()
    autolockSkillEnabled = false
    lockedTarget = nil
    print("Camera auto-lock disabled.")
end

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

    if nearestEnemy then
        lockCameraOntoEnemy(nearestEnemy)
    else
        disableAutoLock()
    end
end

-- Continuously check and lock the camera onto the nearest enemy's head
game:GetService("RunService").Heartbeat:Connect(function()
    if autolockSkillEnabled and lockedTarget then
        -- Lock the camera to focus on the locked target's head
        local targetPosition = lockedTarget.Position
        -- Set the camera to a fixed distance from the target, you can adjust the vector for better positioning
        local cameraOffset = Vector3.new(0, 2, -10) -- Adjust this to control camera's angle and distance from the target
        camera.CFrame = CFrame.new(targetPosition + cameraOffset, targetPosition) -- Lock camera to enemy's head
    else
        -- Continuously search for enemies within the lockRadius if the skill is not locked
        searchForNearestEnemy()
    end
end)
