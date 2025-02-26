local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local currentTarget = nil

print("V6") -- Print when script starts

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

-- Function to lock Clark’s **upper body** to the enemy’s head
local function lockOnEnemy()
    runService.RenderStepped:Connect(function()
        -- If the current target is dead or missing, find a new one
        if not currentTarget or not currentTarget:FindFirstChildOfClass("Humanoid") or currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
            currentTarget = getNearestEnemy()
        end

        -- If we found a valid enemy, lock onto them
        if currentTarget and currentTarget:FindFirstChild("Head") then
            local targetPosition = currentTarget.Head.Position

            -- Rotate Clark’s **upper body** (Head & Torso) instead of locking the whole character
            local head = character:FindFirstChild("Head")
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            
            if head and torso then
                local lookVector = (targetPosition - head.Position).unit
                head.CFrame = CFrame.lookAt(head.Position, targetPosition)
                torso.CFrame = CFrame.lookAt(torso.Position, targetPosition)
            end

            -- Keep the camera locked on the enemy's head
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        else
            -- If no enemies are found, restore normal camera control
            camera.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- Run the ultimate skill
lockOnEnemy()
