local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local currentTarget = nil

print("V4") -- Print when the script starts

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

local function lockOnEnemy()
    runService.RenderStepped:Connect(function()
        -- If the current target is dead or missing, find a new one
        if not currentTarget or not currentTarget:FindFirstChildOfClass("Humanoid") or currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
            currentTarget = getNearestEnemy()
        end

        -- If we found a valid enemy, keep locking onto them
        if currentTarget and currentTarget:FindFirstChild("Head") then
            local targetPosition = currentTarget.Head.Position

            -- Make Clark face the enemy's head
            character.HumanoidRootPart.CFrame = CFrame.lookAt(character.HumanoidRootPart.Position, targetPosition)

            -- Lock the camera onto the enemy's head
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        else
            -- If no enemies are found, restore camera control
            camera.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- Run the ultimate skill
lockOnEnemy()
