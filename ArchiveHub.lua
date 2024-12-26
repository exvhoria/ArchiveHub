local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AutoLockHead = {}

local LOCK_RANGE = 100 -- Maximum distance to lock onto a target
local LOCK_ANGLE = math.rad(45) -- Maximum angle to consider a target (in radians)

function AutoLockHead.new(player)
    local self = setmetatable({}, {__index = AutoLockHead})
    self.player = player
    self.character = player.Character or player.CharacterAdded:Wait()
    self.humanoid = self.character:WaitForChild("Humanoid")
    self.rootPart = self.character:WaitForChild("HumanoidRootPart")
    self.camera = workspace.CurrentCamera
    self.currentTarget = nil
    self.isLocking = false

    return self
end

function AutoLockHead:startLocking()
    self.isLocking = true
    self:updateLock()
end

function AutoLockHead:stopLocking()
    self.isLocking = false
    self.currentTarget = nil
end

function AutoLockHead:updateLock()
    if not self.isLocking then return end

    local closestEnemy = self:findClosestEnemy()
    if closestEnemy then
        self.currentTarget = closestEnemy.Head
        self:lookAtTarget()
    else
        self.currentTarget = nil
    end

    RunService.RenderStepped:Wait()
    self:updateLock()
end

function AutoLockHead:findClosestEnemy()
    local closestDistance = LOCK_RANGE
    local closestEnemy = nil

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= self.player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local enemyHead = otherPlayer.Character.Head
            local distance = (enemyHead.Position - self.rootPart.Position).Magnitude

            if distance <= closestDistance then
                local lookVector = self.camera.CFrame.LookVector
                local toEnemy = (enemyHead.Position - self.camera.CFrame.Position).Unit
                local angle = math.acos(lookVector:Dot(toEnemy))

                if angle <= LOCK_ANGLE then
                    closestDistance = distance
                    closestEnemy = otherPlayer.Character
                end
            end
        end
    end

    return closestEnemy
end

function AutoLockHead:lookAtTarget()
    if self.currentTarget then
        local lookAt = CFrame.new(self.camera.CFrame.Position, self.currentTarget.Position)
        self.camera.CFrame = lookAt
    end
end

-- Initialize the auto-lock for the local player
local function initializeAutoLockForLocalPlayer()
    local localPlayer = Players.LocalPlayer
    if localPlayer then
        local autoLock = AutoLockHead.new(localPlayer)
        autoLock:startLocking()
    else
        warn("Local player not found.")
    end
end

initializeAutoLockForLocalPlayer()

return AutoLockHead