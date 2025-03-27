local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/refs/heads/main/src/ESP.lua"))()

-- Configure settings:
ESP.Settings.Box = true
ESP.Settings.HealthBar = true
ESP.Settings.Tracer = true
ESP.Properties.Box.Scale = 1.2 -- Make boxes 20% bigger
ESP.Properties.HealthBar.Position = "Right"

-- Toggle features:
ESP:Toggle(true) -- Enable ESP
ESP:SetRainbow(true, 0.3) -- Rainbow mode (slower speed)
