-- Optimized Hitbox Extender (Fixed Physics Bug)
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

-- Create a secure folder for hitboxes to prevent physics lag
local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "LocalHitboxContainer"
HitboxFolder.Parent = workspace

-- // GUI SECTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxExtenderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "AXIOS | HITBOX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

-- Slider Logic
local function CreateSlider(name, pos, min, max, default, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.Parent = MainFrame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -20, 0, 15)
    sliderBtn.Position = pos + UDim2.new(0, 0, 0, 25)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBtn.Text = ""
    sliderBtn.Parent = MainFrame
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.Parent = sliderBtn
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local ratio = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * ratio
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = name .. ": " .. math.floor(val * 10)/10
        callback(val)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
end

CreateSlider("Size", UDim2.new(0, 10, 0, 90), 2, 50, Settings.HitboxSize, function(v) Settings.HitboxSize = v end)
CreateSlider("Transparency", UDim2.new(0, 10, 0, 150), 0, 1, Settings.Transparency, function(v) Settings.Transparency = v end)

-- // LOGIC SECTION // --

local function CreateHitbox(player)
    if player == LocalPlayer or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if HitboxParts[player] then HitboxParts[player]:Destroy() end

    local hitbox = Instance.new("Part")
    hitbox.Name = "ClientHitbox_" .. player.Name
    hitbox.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    hitbox.Transparency = Settings.VisualizeHitbox and Settings.Transparency or 1
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(255, 50, 50)
    hitbox.Parent = HitboxFolder

    -- Using a legacy Weld allows the part to stay in the Folder while following the HRP
    local weld = Instance.new("Weld")
    weld.Part0 = hitbox
    weld.Part1 = hrp
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = hitbox

    HitboxParts[player] = hitbox
end

local function CleanUp()
    for _, part in pairs(HitboxParts) do part:Destroy() end
    HitboxParts = {}
end

local function ToggleExtender()
    Settings.Enabled = not Settings.Enabled
    StatusLabel.Text = "Status: " .. (Settings.Enabled and "Enabled" or "Disabled")
    StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if not Settings.Enabled then CleanUp() end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isTeammate = Settings.TeamCheck and player.Team == LocalPlayer.Team
            
            if isTeammate then
                if HitboxParts[player] then 
                    HitboxParts[player]:Destroy() 
                    HitboxParts[player] = nil
                end
            else
                local hitbox = HitboxParts[player]
                if not hitbox or not hitbox.Parent then
                    CreateHitbox(player)
                else
                    -- Real-time updates without recreation
                    hitbox.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hitbox.Transparency = Settings.VisualizeHitbox and Settings.Transparency or 1
                end
            end
        end
    end
end)

-- Buttons
local TeamCheckBtn = Instance.new("TextButton")
TeamCheckBtn.Size = UDim2.new(1, -20, 0, 35)
TeamCheckBtn.Position = UDim2.new(0, 10, 0, 215)
TeamCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
TeamCheckBtn.Text = "Team Check: ON"
TeamCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckBtn.Font = Enum.Font.GothamBold
TeamCheckBtn.Parent = MainFrame
TeamCheckBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamCheckBtn.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    TeamCheckBtn.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(180, 60, 60)
end)

-- Inputs
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        ToggleExtender()
    end
end)

print("AXIOS Loaded | L = GUI | PageDown = Toggle")
