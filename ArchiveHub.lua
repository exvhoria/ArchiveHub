local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()
local scriptHubName = "ArchiveHub"
local devName = "GhosttedXV"
local win = lib:Window(scriptHubName .., devName, Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- Function:ESP --
local espEnabled = false
local espParts = {}
local espConnection

local function createESP(part)
    if not part or espParts[part] then return end
    
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.Size = part.Size
    adorn.Color3 = Color3.new(1, 0, 0)
    adorn.Transparency = 0.5
    adorn.ZIndex = 5
    adorn.AlwaysOnTop = true
    adorn.Name = "ESPBox"
    adorn.Parent = part

    espParts[part] = adorn
end

local function removeESP()
    for _, adorn in pairs(espParts) do
        if adorn then adorn:Destroy() end
    end
    espParts = {}
end

local function toggleESP(state)
    espEnabled = state
    local player = getLocalPlayer()
    
    if espEnabled then
        local function applyESP()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        createESP(part)
                    end
                end
            end
        end
        applyESP()
        espConnection = game:GetService("RunService").RenderStepped:Connect(applyESP)
    else
        if espConnection then
            espConnection:Disconnect()
        end
        removeESP()
    end
end

-- TAB
local MainTab = window:Tab("Tab Main")
local Visual = window:Tab("Tab Visual")
local Vombat = window:Tab("Tab Combat")
local LocalPlayer = window:Tab("Tab LocalPlayer")
local Settings = window:Tab("UI Settings")

-- MainTab Content
MainTab:Label("Welcome to ArchiveHub!")
MainTab:Label("Recent Updates:\n- ESP Bones\n- Fullbright Removed\n- Added Noclip")
MainTab:Button("Button", function()
    lib:Notification("Check Version", "ArchiveHub Version: V1", "OK")
end)


-- Visual Content
espTab:Toggle("ESP Bones", false, function(state)
    toggleESP(state)
end)
