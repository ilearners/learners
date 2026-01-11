-- Roblox ESP Script by Learner
-- This script creates an ESP (Extra Sensory Perception) cheat that shows outlines of players through walls.
-- Includes a GUI to toggle ESP on/off.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Check if Drawing library is available (common in exploits)
if not Drawing then
    warn("Drawing library not available. This script requires an exploit that supports Drawing.")
    return
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "ESP: ON"
ToggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
ToggleButton.TextColor3 = Color3.new(0, 0, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui

local ESPEnabled = true

ToggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ToggleButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ToggleButton.BackgroundColor3 = ESPEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

local ESPObjects = {} -- Table to store ESP objects for each player

-- Function to create ESP for a player
local function CreateESP(player)
    if player == LocalPlayer then return end -- Don't ESP yourself

    local esp = {
        Outline = Drawing.new("Square")
    }

    -- Configure Outline
    esp.Outline.Thickness = 2
    esp.Outline.Filled = false
    esp.Outline.Color = Color3.new(1, 0, 0) -- Red color
    esp.Outline.Visible = false

    ESPObjects[player] = esp
end

-- Function to remove ESP for a player
local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Outline:Remove()
        ESPObjects[player] = nil
    end
end

-- Function to update ESP for a player
local function UpdateESP(player)
    local esp = ESPObjects[player]
    if not esp then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        esp.Outline.Visible = false
        return
    end

    local humanoidRootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        esp.Outline.Visible = false
        return
    end

    -- Calculate screen position
    local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        esp.Outline.Visible = false
        return
    end

    -- Calculate box size based on distance
    local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
    local scale = 1000 / distance -- Adjust scale as needed
    local size = Vector2.new(50 * scale, 100 * scale)

    -- Update Outline
    esp.Outline.Size = size
    esp.Outline.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
    esp.Outline.Visible = ESPEnabled
end

-- Connect to player events
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        UpdateESP(player)
    end
end)

print("ESP Script with GUI loaded successfully!")
