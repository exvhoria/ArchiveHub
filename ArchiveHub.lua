local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local currentTarget = nil
local humanoid = character:FindFirstChildOfClass("Humanoid")

print("V9") -- Print when script starts

-- Function to find the nearest enemy
local function getNearestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Team ~= player.Team then
            local enemyChar = otherPlayer.Character
            local humanoid = enemyChar and enemyChar:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and enemyChar:FindFirstChild("Head") and enemyChar:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - enemyChar.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = enemyChar
                end
            end
        end
    end

    return closestEnemy
end

-- Function to smoothly rotate Clark while allowing movement
local function lockOnEnemy()
    runService.RenderStepped:Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            -- Find a new target if needed
            if not currentTarget or not currentTarget:FindFirstChildOfClass("Humanoid") or currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
                currentTarget = getNearestEnemy()
            end

            -- If we found a valid enemy, keep locking onto them
            if currentTarget and currentTarget:FindFirstChild("Head") then
                local targetPosition = currentTarget.Head.Position

                -- Rotate Clark **only when moving**
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local direction = (targetPosition - rootPart.Position).unit
                    local newLookVector = Vector3.new(direction.X, 0, direction.Z)
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + newLookVector)
                end

                -- Keep the camera locked onto the enemy's head
                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
            else
                -- If no enemies are found, restore normal camera control
                camera.CameraType = Enum.CameraType.Custom
            end
        end
    end)
end

-- Start the lock-on function
lockOnEnemy()
