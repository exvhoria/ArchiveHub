local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function getNearestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Team ~= player.Team then
            local enemyChar = otherPlayer.Character
            if enemyChar and enemyChar:FindFirstChild("Head") and enemyChar:FindFirstChild("HumanoidRootPart") then
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

local function executeUltimate()
    local enemy = getNearestEnemy()
    if enemy and enemy:FindFirstChild("Head") then
        local targetPosition = enemy.Head.Position

        -- Make Clark face the enemy's head
        local direction = (targetPosition - character.HumanoidRootPart.Position).unit
        local newCFrame = CFrame.lookAt(character.HumanoidRootPart.Position, targetPosition)
        character.HumanoidRootPart.CFrame = newCFrame

        -- Simulate an attack (Replace with actual attack logic)
        print("Clark is using ultimate on", enemy.Name)

        -- Example attack effect (Replace with real attack effect)
        local effect = Instance.new("Part")
        effect.Size = Vector3.new(1, 1, 1)
        effect.Color = Color3.fromRGB(255, 0, 0)
        effect.Material = Enum.Material.Neon
        effect.Position = targetPosition
        effect.Anchored = true
        effect.Parent = workspace

        game:GetService("Debris"):AddItem(effect, 1) -- Remove effect after 1 second
    else
        print("No enemy found!")
    end
end

-- Run the ultimate attack when the script is executed
executeUltimate()
