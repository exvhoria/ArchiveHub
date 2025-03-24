local api_url = "https://bfebe58f-f44e-4bd6-9c13-aac28475f511-00-45jwfxlr38yx.sisko.replit.dev/index.php"

local hwid = gethwid() -- Get user's HWID
local user_id = game:GetService("Players").LocalPlayer.UserId -- Get user ID

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local SubmitButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true

TextBox.Parent = Frame
TextBox.Size = UDim2.new(0, 200, 0, 30)
TextBox.Position = UDim2.new(0.5, -100, 0.3, 0)
TextBox.PlaceholderText = "Enter your key here"
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Text = ""

SubmitButton.Parent = Frame
SubmitButton.Size = UDim2.new(0, 100, 0, 30)
SubmitButton.Position = UDim2.new(0.5, -50, 0.6, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SubmitButton.Text = "Verify Key"

StatusLabel.Parent = Frame
StatusLabel.Size = UDim2.new(0, 280, 0, 30)
StatusLabel.Position = UDim2.new(0.5, -140, 0.8, 0)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Open your browser and paste the link on the clipboard!"
StatusLabel.TextScaled = true
StatusLabel.BackgroundTransparency = 1

print("🔹 Visit the link below to generate your key:")
setclipboard(api_url .. "?action=generate&user_id=" .. user_id .. "&hwid=" .. hwid)

local function check_key()
    local key = TextBox.Text
    if key == "" then
        StatusLabel.Text = "❌ Please enter a key!"
        return
    end

    local response = game:HttpGet(api_url .. "?action=check&user_id=" .. user_id .. "&hwid=" .. hwid .. "&key=" .. key)
    local data = game.HttpService:JSONDecode(response)

    if data.error then
        StatusLabel.Text = "❌ Key Invalid: " .. data.error
    else
        StatusLabel.Text = "✅ Valid Key! Access granted."
        wait(1)
        ScreenGui:Destroy() -- Close UI
    end
end

SubmitButton.MouseButton1Click:Connect(check_key)
