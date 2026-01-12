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
        highlights = {},
        billboard = Instance.new("BillboardGui"),
        nameLabel = Instance.new("TextLabel"),
        healthLabel = Instance.new("TextLabel")
    }

    -- Highlight setup
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.Enabled = false
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    table.insert(data.highlights, highlight)

    -- Billboard setup
    data.billboard.Size = UDim2.new(0, 200, 0, 60)
    data.billboard.StudsOffset = Vector3.new(0, 3, 0)
    data.billboard.AlwaysOnTop = true
    data.billboard.Enabled = false
    data.billboard.Parent = character

    -- Name label
    data.nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    data.nameLabel.Position = UDim2.new(0, 0, 0, 0)
    data.nameLabel.BackgroundTransparency = 1
    data.nameLabel.TextColor3 = Color3.new(1, 1, 1)
    data.nameLabel.Font = Enum.Font.SourceSansBold
    data.nameLabel.TextSize = 16
    data.nameLabel.TextStrokeTransparency = 0
    data.nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    data.nameLabel.Text = player.Name
    data.nameLabel.Parent = data.billboard

    -- Health label
    data.healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    data.healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    data.healthLabel.BackgroundTransparency = 1
    data.healthLabel.TextColor3 = Color3.new(0, 1, 0)
    data.healthLabel.Font = Enum.Font.SourceSans
    data.healthLabel.TextSize = 14
    data.healthLabel.TextStrokeTransparency = 0
    data.healthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    data.healthLabel.Text = "HP: 100/100"
    data.healthLabel.Parent = data.healthLabel.Parent = data.billboard

    ESPData[player] = data
end

-- Function to remove ESP for a player
local function RemoveESP(player)
    if ESPData[player] then
        for _, highlight in ipairs(ESPData[player].highlights) do
            highlight:Destroy()
        end
        ESPData[player] = nil
    end
end

-- Optimized update function
local function UpdateESP(player)
    local data = ESPData[player]
    if not data then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        for _, highlight in ipairs(data.highlights) do
            highlight.Enabled = false
        end
        data.billboard.Enabled = false
        return
    end

    local humanoidRootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        for _, highlight in ipairs(data.highlights) do
            highlight.Enabled = false
        end
        data.billboard.Enabled = false
        return
    end

    -- Distance check
    local distance = (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude
    if distance > MaxDistance then
        for _, highlight in ipairs(data.highlights) do
            highlight.Enabled = false
        end
        data.billboard.Enabled = false
        return
    end

    -- Update highlights
    for _, highlight in ipairs(data.highlights) do
        highlight.Adornee = character
        highlight.Enabled = ESPEnabled
    end

    -- Update billboard
    data.billboard.Adornee = humanoidRootPart
    data.billboard.Enabled = ESPEnabled and (ShowNames or ShowHealth)

    -- Update labels
    data.nameLabel.Visible = ShowNames
    data.nameLabel.Text = player.Name

    if ShowHealth then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthColor = Color3.new(1 - healthPercent, healthPercent, 0)
        data.healthLabel.TextColor3 = healthColor
        data.healthLabel.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        data.healthLabel.Visible = true
    else
        data.healthLabel.Visible = false
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
    local currentTime = tick()
    if currentTime - lastCheck >= 15 then
        lastCheck = currentTime
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESPData[player] then
                CreateESP(player)
            end
        end
    end
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
