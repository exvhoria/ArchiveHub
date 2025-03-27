local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/refs/heads/main/src/ESP.lua"))()

-- 1. Configure core settings
ESP.UpdateSettings({
    Enabled = true,     -- Master switch
    TeamCheck = false,  -- Don't highlight teammates
    AliveCheck = true   -- Only show living players
})

-- 2. Customize visuals
ESP.UpdateProperties({
    ESP = {
        Enabled = true,
        DisplayName = true,
        DisplayDistance = true,
        DisplayHealth = true,
        Font = 2,       -- 1:UI, 2:System, 3:Plex, 4:Monospace
        Size = 14
    },
    Box = {
        Enabled = true,
        Outline = true,
        Thickness = 1,
        Scale = 1.2     -- If available in your version
    },
    HealthBar = {
        Enabled = true,
        Position = 4,   -- Right side
        Blue = 150      -- Affects health color gradient
    },
    Tracer = {
        Enabled = true,
        Position = 1    -- Bottom of screen
    }
})

-- 3. Advanced effects
-- Option 1: If using the AirHub-style ESP
ESP.Properties.ESP.RainbowColor = true
ESP.Properties.Tracer.RainbowColor = true
ESP.DeveloperSettings.RainbowSpeed = 0.3

-- Option 2: If using Exunys-style ESP with SetRainbow
if ESP.SetRainbow then
    ESP:SetRainbow(true, 0.3)
end

-- 4. Verify it's working
print("ESP loaded with config:")
print("Box Scale:", ESP.Properties.Box.Scale)
print("HealthBar Position:", ESP.Properties.HealthBar.Position)
