-- AXIOS Hitbox Extender | Restored Aesthetic
-- Toggle GUI: L | Toggle Hitbox: PageDown

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    Enabled = false,
    HitboxSize = 10,
    Transparency = 0.5,
    TeamCheck = true,
    VisualizeHitbox = true,
}

local HitboxParts = {}
local GuiVisible = true

-- Container for physics stability
local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "Axios_Storage"
HitboxFolder.Parent = workspace

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiosExtender"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
local HeaderHide = Instance.new("Frame") -- Hides bottom corners of header
HeaderHide.Size = UDim2.new(1, 0, 0, 10)
HeaderHide.Position = UDim2.new(0, 0, 1, -10)
HeaderHide.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HeaderHide.BorderSizePixel = 0
HeaderHide.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "AXIOS v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Header

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "SYSTEM IDLE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- Reusable Slider Function for Aesthetics
local function MakeSlider(name, offset, min, max, default, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, offset)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame

    local BG = Instance.new("TextButton")
    BG.Size = UDim2.new(1, -30, 0, 6)
    BG.Position = UDim2.new(0, 15, 0, offset + 25)
    BG.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    BG.Text = ""
    BG.Parent = MainFrame
    Instance.new("UICorner", BG)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = BG
    Instance.new("UICorner", Fill)

    local dragging = false
    local function update(input)
        local r = math.clamp((input.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * r
        Fill.Size = UDim2.new(r, 0, 1, 0)
        Label.Text = name .. ": " .. math.floor(val * 10)/10
        callback(val)
    end

    BG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
end

MakeSlider("Hitbox Size", 90, 2, 50, Settings.HitboxSize, function(v) Settings.HitboxSize = v end)
MakeSlider("Transparency", 145, 0, 1, Settings.Transparency, function(v) Settings.Transparency = v end)

-- Aesthetic Buttons
local function MakeButton(text, offset, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -30, 0, 35)
    Btn.Position = UDim2.new(0, 15, 0, offset)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local TeamBtn = MakeButton("Team Check: ON", 205, Color3.fromRGB(50, 150, 100), function()
    Settings.TeamCheck = not Settings.TeamCheck
    _G.UpdateButtons()
end)

local VisBtn = MakeButton("Visualize: ON", 250, Color3.fromRGB(50, 150, 100), function()
    Settings.VisualizeHitbox = not Settings.VisualizeHitbox
    _G.UpdateButtons()
end)

_G.UpdateButtons = function()
    TeamBtn.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    TeamBtn.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(150, 50, 50)
    VisBtn.Text = "Visualize: " .. (Settings.VisualizeHitbox and "ON" or "OFF")
    VisBtn.BackgroundColor3 = Settings.VisualizeHitbox and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(150, 50, 50)
end

-- // CORE LOGIC // --

local function CreateHitbox(player)
    if player == LocalPlayer or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hitbox = Instance.new("Part")
    hitbox.Name = "AxiosPart"
    hitbox.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    hitbox.Transparency = Settings.VisualizeHitbox and Settings.Transparency or 1
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.Parent = HitboxFolder

    local weld = Instance.new("Weld")
    weld.Part0 = hitbox
    weld.Part1 = hrp
    weld.Parent = hitbox

    HitboxParts[player] = hitbox
end

local function Toggle()
    Settings.Enabled = not Settings.Enabled
    StatusLabel.Text = Settings.Enabled and "SYSTEM ACTIVE" or "SYSTEM IDLE"
    StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 100, 100)
    if not Settings.Enabled then
        for _, v in pairs(HitboxParts) do v:Destroy() end
        HitboxParts = {}
    end
end

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isTeam = Settings.TeamCheck and p.Team == LocalPlayer.Team
            if isTeam then
                if Hitbox
