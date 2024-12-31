-- LocalScript in StarterPlayerScripts or StarterCharacterScripts

-- Function to find the nearest player to target
local function getNearestPlayer()
    local players = game.Players:GetPlayers()
    local hero = game.Players.LocalPlayer.Character
    if not hero then return end

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(players) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local distance = (player.Character.HumanoidRootPart.Position - hero.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player.Character
            end
        end
    end

    return nearestPlayer
end

-- Function to lock the hero's head towards the target
local function lockHeadTowardsTarget()
    local hero = game.Players.LocalPlayer.Character
    if not hero then return end

    local targetPlayer = getNearestPlayer()
    if targetPlayer then
        local head = hero:FindFirstChild("Head")
        local targetHead = targetPlayer:FindFirstChild("Head")
        if head and targetHead then
            head.CFrame = CFrame.new(head.Position, targetHead.Position)
        end
    end
end

-- Loop to continuously update the head lock
while true do
    lockHeadTowardsTarget()
    wait(0.1) -- Update every 0.1 seconds
end