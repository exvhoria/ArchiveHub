local gameScripts = {
    [70503660100467] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/src/70503660100467.lua'))()"
}

local function createDraggableLogUI(supportedGames)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LogUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    title.Text = "Supported Games"
    title.Font = Enum.Font.Gotham
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -40)
    textLabel.Position = UDim2.new(0, 5, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 16
    textLabel.TextWrapped = true
    textLabel.Text = "Supported Games:\n" .. supportedGames
    textLabel.Parent = frame

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local currentGameId = game.GameId

if gameScripts[currentGameId] then
    local success, err = pcall(function()
        loadstring(gameScripts[currentGameId])()
    end)
    
    if not success then
        warn("Failed to execute script for Game ID:", currentGameId, "Error:", err)
    else
        print("Script executed successfully for Game ID:", currentGameId)
    end
else
    local supportedGames = ""
    for gameId, _ in pairs(gameScripts) do
        local success, gameInfo = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(gameId)
        end)
        
        if success and gameInfo then
            supportedGames = supportedGames .. "- " .. gameInfo.Name .. " (ID: " .. gameId .. ")\n"
        else
            supportedGames = supportedGames .. "- Unknown Game (ID: " .. gameId .. ")\n"
        end
    end

    createDraggableLogUI(supportedGames)
end
