local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/refs/heads/main/src/ESP.lua"))()

-- Configure settings:
ESP.Settings.TeamCheck = true
ESP.Properties.Box.Thickness = 2
ESP.Properties.HealthBar.Position = 3 -- Left side

-- Toggle features:
ESP:Toggle(true) -- Master switch
ESP:SetRainbow(true, 0.3) -- Rainbow mode (slower speed)
