local api_url = "https://bfebe58f-f44e-4bd6-9c13-aac28475f511-00-45jwfxlr38yx.sisko.replit.dev/index.php"

local hwid = gethwid() -- Get user's HWID
local user_id = game:GetService("Players").LocalPlayer.UserId -- Get user ID

local function get_key()
    local response = game:HttpGet(api_url .. "?action=generate&user_id=" .. user_id .. "&hwid=" .. hwid)
    print(response) -- Display key in console
end

local function check_key()
    local response = game:HttpGet(api_url .. "?action=check&user_id=" .. user_id .. "&hwid=" .. hwid)
    local data = game.HttpService:JSONDecode(response)
    if data.error then
        print("Key Invalid: " .. data.error)
    else
        print("Valid Key: " .. data.key)
    end
end

local function renew_key()
    local response = game:HttpGet(api_url .. "?action=renew&user_id=" .. user_id .. "&hwid=" .. hwid)
    print(response) -- Renew key if valid
end

get_key() -- Generate key
check_key() -- Verify key
renew_key() -- Renew key
