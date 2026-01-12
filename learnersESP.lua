-- AXIOS ESP | Original Aesthetic Restored
-- Toggle GUI: P | ESP Toggle: Auto-updates on UI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Settings
local ESPEnabled = true
local ShowNames = true
local ShowHealth = true
local MaxDistance = 1000
local GuiVisible = true
local lastCheck = 0
local ESPData = {}

-- // AXIOS GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiosESP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 300) -- Matched size to Hitbox GUI
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Text = "AXIOS | ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Monitoring"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Reusable AXIOS Button Function
local function CreateAxiosButton(text, pos, enabled, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    Btn.Text = text .. (enabled and ": ON" or ": OFF")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        local newState = callback()
        Btn.Text = text .. (newState and ": ON" or ": OFF")
        Btn.BackgroundColor3 = newState and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    end)
    return Btn
end

CreateAxiosButton("Master ESP", UDim2.new(0, 10, 0, 100), ESPEnabled, function()
    ESPEnabled = not ESPEnabled
    return ESPEnabled
end)

CreateAxiosButton("Show Names", UDim2.new(0, 10, 0, 145), ShowNames, function()
    ShowNames = not ShowNames
    return ShowNames
end)

CreateAxiosButton("Show Health", UDim2.new(0, 10, 0, 190), ShowHealth, function()
    ShowHealth = not ShowHealth
    return ShowHealth
end)

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "Press 'P' to Toggle GUI"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.Parent = MainFrame

-- // CORE ESP LOGIC // --

local function RemoveESP(player)
    if ESPData[player] then
        if ESPData[player].highlight then ESPData[player].highlight:Destroy() end
        if ESPData[player].billboard then ESPData[player].billboard:Destroy() end
        ESPData[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end

    RemoveESP(player)

    local data = {}

    -- Highlight (Outline Only)
    local hl = Instance.new("Highlight")
    hl.Adornee = character
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = character
    data.highlight = hl

    -- Billboard
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = character
    data.billboard = bb

    -- Labels
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 14
    nl.TextStrokeTransparency = 0
    nl.Parent = bb
    data.nameLabel = nl

    local hl_label = Instance.new("TextLabel")
    hl_label.Size = UDim2.new(1, 0, 0.5, 0)
    hl_label.Position = UDim2.new(0, 0, 0.5, 0)
    hl_label.BackgroundTransparency = 1
    hl_label.Font = Enum.Font.Gotham
    hl_label.TextSize = 13
    hl_label.TextStrokeTransparency = 0
    hl_label.Parent = bb
    data.healthLabel = hl_label

    ESPData[player] = data
end

local function UpdateESP(player)
    local data = ESPData[player]
    if not data or not player.Character then return end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChild("Humanoid")
    
    if not hrp or not hum then
        if data.highlight then data.highlight.Enabled = false end
        data.billboard.Enabled = false
        return
    end

    local distance = (workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude
    local inRange = distance <= MaxDistance

    if data.highlight then
        data.highlight.Enabled = ESPEnabled and inRange
    end

    data.billboard.Enabled = ESPEnabled and inRange and (ShowNames or ShowHealth)
    data.billboard.Adornee = hrp

    data.nameLabel.Visible = ShowNames
    data.nameLabel.Text = player.Name
    
    if ShowHealth then
        local hpPercent = hum.Health / hum.MaxHealth
        data.healthLabel.TextColor3 = Color3.fromHSV(hpPercent * 0.3, 1, 1) -- Smooth green to red
        data.healthLabel.Text = math.floor(hum.Health) .. " HP"
        data.healthLabel.Visible = true
    else
        data.healthLabel.Visible = false
    end
end

-- // CONNECTIONS // --

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.2) CreateESP(p) end)
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- Initial Load
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then CreateESP(p) end
    p.CharacterAdded:Connect(function() task.wait(0.2) CreateESP(p) end)
end

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        UpdateESP(p)
    end
end)

print("AXIOS ESP Loaded | Press 'P' for GUI")
