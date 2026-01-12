-- Advanced Smooth ESP Script
-- Uses Highlight for performance, adds names/health/distance with simple GUI
-- Optimized for smoothness with distance checks and Heartbeat updates

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiVisible = true
local lastCheck = 0

-- GUI Setup (Simple toggle with options)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 120)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "ESP Controls"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, -20, 0, 25)
ESPToggle.Position = UDim2.new(0, 10, 0, 35)
ESPToggle.Text = "ESP: ON"
ESPToggle.BackgroundColor3 = Color3.new(0, 1, 0)
ESPToggle.TextColor3 = Color3.new(0, 0, 0)
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.TextSize = 14
ESPToggle.Parent = MainFrame

local NamesToggle = Instance.new("TextButton")
NamesToggle.Size = UDim2.new(1, -20, 0, 25)
NamesToggle.Position = UDim2.new(0, 10, 0, 65)
NamesToggle.Text = "Names: ON"
NamesToggle.BackgroundColor3 = Color3.new(0, 1, 0)
NamesToggle.TextColor3 = Color3.new(0, 0, 0)
NamesToggle.Font = Enum.Font.SourceSansBold
NamesToggle.TextSize = 14
NamesToggle.Parent = MainFrame

local HealthToggle = Instance.new("TextButton")
HealthToggle.Size = UDim2.new(1, -20, 0, 25)
HealthToggle.Position = UDim2.new(0, 10, 0, 95)
HealthToggle.Text = "Health: ON"
HealthToggle.BackgroundColor3 = Color3.new(0, 1, 0)
HealthToggle.TextColor3 = Color3.new(0, 0, 0)
HealthToggle.Font = Enum.Font.SourceSansBold
HealthToggle.TextSize = 14
HealthToggle.Parent = MainFrame

local ESPEnabled = true
local ShowNames = true
local ShowHealth = true
local MaxDistance = 1000
local ESPData = {} -- Store ESP objects

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ESPToggle.BackgroundColor3 = ESPEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

NamesToggle.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    NamesToggle.Text = ShowNames and "Names: ON" or "Names: OFF"
    NamesToggle.BackgroundColor3 = ShowNames and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

HealthToggle.MouseButton1Click:Connect(function()
    ShowHealth = not ShowHealth
    HealthToggle.Text = ShowHealth and "Health: ON" or "Health: OFF"
    HealthToggle.BackgroundColor3 = ShowHealth and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- Hotkey to toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.P then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
end)

-- Function to create ESP for a player
local function CreateESP(player)
    if player == LocalPlayer or ESPData[player] then return end

    local character = player.Character
    if not character then return end

    local data = {
        Highlight = Instance.new("Highlight"),
        Billboard = Instance.new("BillboardGui"),
        NameLabel = Instance.new("TextLabel"),
        HealthLabel = Instance.new("TextLabel")
    }

    -- Highlight setup
    data.Highlight.Adornee = character
    data.Highlight.Enabled = false
    data.Highlight.FillColor = Color3.new(1, 0, 0)
    data.Highlight.OutlineColor = Color3.new(1, 0, 0)
    data.Highlight.FillTransparency = 0.5
    data.Highlight.OutlineTransparency = 0
    data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    data.Highlight.Parent = character

    -- Billboard setup
    data.Billboard.Size = UDim2.new(0, 200, 0, 60)
    data.Billboard.StudsOffset = Vector3.new(0, 3, 0)
    data.Billboard.AlwaysOnTop = true
    data.Billboard.Enabled = false
    data.Billboard.Parent = character

    -- Name label
    data.NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    data.NameLabel.Position = UDim2.new(0, 0, 0, 0)
    data.NameLabel.BackgroundTransparency = 1
    data.NameLabel.TextColor3 = Color3.new(1, 1, 1)
    data.NameLabel.Font = Enum.Font.SourceSansBold
    data.NameLabel.TextSize = 16
    data.NameLabel.TextStrokeTransparency = 0
    data.NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    data.NameLabel.Text = player.Name
    data.NameLabel.Parent = data.Billboard

    -- Health label
    data.HealthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    data.HealthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    data.HealthLabel.BackgroundTransparency = 1
    data.HealthLabel.TextColor3 = Color3.new(0, 1, 0)
    data.HealthLabel.Font = Enum.Font.SourceSans
    data.HealthLabel.TextSize = 14
    data.HealthLabel.TextStrokeTransparency = 0
    data.HealthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    data.HealthLabel.Text = "HP: 100/100"
    data.HealthLabel.Parent = data.Billboard

    ESPData[player] = data
end

-- Function to remove ESP for a player
local function RemoveESP(player)
    if ESPData[player] then
        ESPData[player].Highlight:Destroy()
        ESPData[player] = nil
    end
end

-- Optimized update function
local function UpdateESP(player)
    local data = ESPData[player]
    if not data then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        return
    end

    local humanoidRootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        return
    end

    -- Distance check
    local distance = (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude
    if distance > MaxDistance then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        return
    end

    -- Update highlight
    data.Highlight.Adornee = character
    data.Highlight.Enabled = ESPEnabled

    -- Update billboard
    data.Billboard.Adornee = humanoidRootPart
    data.Billboard.Enabled = ESPEnabled and (ShowNames or ShowHealth)

    -- Update labels
    data.NameLabel.Visible = ShowNames
    data.NameLabel.Text = player.Name

    if ShowHealth then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthColor = Color3.new(1 - healthPercent, healthPercent, 0)
        data.HealthLabel.TextColor3 = healthColor
        data.HealthLabel.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        data.HealthLabel.Visible = true
    else
        data.HealthLabel.Visible = false
    end
end

-- Connect to player events
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Optimized update loop
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        UpdateESP(player)
    end
end)

-- Handle character changes
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if ESPData[player] then
            ESPData[player].Highlight.Adornee = character
        else
            CreateESP(player)
        end
    end)

    player.CharacterRemoving:Connect(function()
        if ESPData[player] then
            ESPData[player].Highlight.Adornee = nil
            ESPData[player].Billboard.Enabled = false
        end
    end)
end)

print("Advanced Smooth ESP loaded! Uses Highlight for performance with names and health.")
