# Vape by Dawid Script UI Revamp Guide
This UI library helps you create a simple UI in Roblox using Lua. It loads dynamically from an external file.

## How to Load the UI

To use this UI, load it with:
```lua
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/exvhoria/ArchiveHub/main/scriptui.txt"))()
```
This fetches and runs the script, setting up the UI.

## Creating a UI Window

Create a window using:
```lua
local window = ui:Window("My UI", "Developer", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
```
- `"My UI"` - The UI title.
- `"Developer"` - Your name.
- `Color3.fromRGB(44, 120, 224)` - UI color.
- `Enum.KeyCode.RightControl` - Keybind to toggle the UI.

## Adding UI Elements

### Create a Tab
```lua
local tab = window:Tab("Main")
```
Tabs help organize different sections.

### Add a Button
```lua
tab:Button("Click Me", function()
    print("Button clicked!")
end)
```
Prints a message when clicked.

### Add a Toggle
```lua
tab:Toggle("Enable Feature", false, function(state)
    print("Enabled:", state)
end)
```
A switch to enable/disable a feature.

### Add a Slider
```lua
tab:Slider("Adjust", 0, 100, 50, function(value)
    print("Slider:", value)
end)
```
A slider to select values.

### Add a Dropdown
```lua
tab:Dropdown("Pick One", {"Option A", "Option B", "Option C"}, function(choice)
    print("Chosen:", choice)
end)
```
A dropdown with multiple choices.

### Add a Textbox
```lua
tab:Textbox("Enter Something", true, function(text)
    print("Typed:", text)
end)
```
A textbox for user input.

### Show a Notification
```lua
ui:Notification("Notice", "This is a test.", "OK")
```
Shows a popup message.

## Toggle UI
The UI toggles with `RightControl` or the button at the top.

## Conclusion
This UI library is easy to use and customize for your projects!

