local gameScripts = {
    [70503660100467] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/src/70503660100467.lua'))()"
}

local function createGameListUI(supportedGames)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameListUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
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
    textLabel.Size = UDim2.new(1, -10, 1, -70)
    textLabel.Position = UDim2.new(0, 5, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 16
    textLabel.TextWrapped = true
    textLabel.Text = "Supported Games:\n" .. supportedGames
    textLabel.Parent = frame

    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0, 200, 0, 30)
    executeButton.Position = UDim2.new(0.5, -100, 1, -40)
    executeButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    executeButton.Text = "Execute Script"
    executeButton.Font = Enum.Font.Gotham
    executeButton.TextSize = 18
    executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeButton.Parent = frame

    executeButton.MouseButton1Click:Connect(function()
        local currentGameId = game.GameId
        if gameScripts[currentGameId] then
            local success, err = pcall(function()
                loadstring(gameScripts[currentGameId])()
            end)

            if success then
                print("Script executed successfully for Game ID:", currentGameId)
            else
                warn("Failed to execute script. Error:", err)
            end
        else
            warn("No script found for this Game ID:", currentGameId)
        end
    end)
end

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

createGameListUI(supportedGames)
