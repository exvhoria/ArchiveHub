local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()
local window = ui:Window("ArchiveHub", "GhosttedXV", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local MainTab = window:Tab("Main")
MainTab:Label("Welcome to ArchiveHub!")
MainTab:Label("Recent Updates:\n- Simple Auto Win")
MainTab:Button("Check Version", function()
    ui:Notification("Check Version", "ArchiveHub Version: V1", "OK")
end)

local player = game.Players.LocalPlayer

local function ArchiveHubTP()
    player.Character:PivotTo(CFrame.new(303, 658, 203))
end

MainTab:Button("CFrame TP to Finish", "rbxassetid://105845194767795", function()
    ArchiveHubTP()
end)
