local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local currentTarget = nil

print("Skill Active") -- Print when script starts

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

-- Function to lock Clark onto an enemy’s head while allowing movement
local function lockOnEnemy()
    runService.RenderStepped:Connect(function()
        -- Find a new target if needed
        if not currentTarget or not currentTarget:FindFirstChildOfClass("Humanoid") or currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
            currentTarget = getNearestEnemy()
        end

        -- If we found a valid enemy, keep locking onto them
        if currentTarget and currentTarget:FindFirstChild("Head") then
            local targetPosition = currentTarget.Head.Position

            -- Make Clark smoothly rotate toward the enemy's head **without locking movement**
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local direction = (targetPosition - rootPart.Position).unit
                local newCFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(direction.X, 0, direction.Z))
                rootPart.CFrame = rootPart.CFrame:Lerp(newCFrame, 0.2) -- Smooth rotation without freezing movement
            end

            -- Keep the camera locked onto the enemy's head
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        else
            -- If no enemies are found, restore normal camera control
            camera.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- Start the lock-on function
lockOnEnemy()
