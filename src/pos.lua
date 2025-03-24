local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Create a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

-- Create a TextLabel
local positionLabel = Instance.new("TextLabel")
positionLabel.Parent = screenGui
positionLabel.Size = UDim2.new(0, 250, 0, 50) -- Width: 250px, Height: 50px
positionLabel.Position = UDim2.new(0.5, -125, 0.1, 0) -- Centered at the top
positionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
positionLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
positionLabel.TextScaled = true
positionLabel.Font = Enum.Font.SourceSansBold
positionLabel.Text = "Position: Loading..."

-- Update the position in the UI
while true do
    local position = character.PrimaryPart.Position
    positionLabel.Text = string.format("X: %.2f | Y: %.2f | Z: %.2f", position.X, position.Y, position.Z)
    wait(0.5) -- Update every 0.5 seconds
end
