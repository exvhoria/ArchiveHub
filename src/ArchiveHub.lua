local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/refs/heads/main/src/ESP.lua"))()

-- Configure
ESP.Config.Box.Scale = 0.7 -- Smaller boxes
ESP.Config.HealthBar.Position = "Right"
ESP.Config.ESP.FontSize = 14

-- Toggle features
ESP:Toggle(true) -- Master switch
ESP:SetRainbow(true, 0.3) -- Rainbow mode (slower speed)
ESP:ToggleFeature("Tracer", false) -- Disable tracers
