-- Learners Hitbox Extender | Fixed GUI & Damage Compatible
-- Toggle GUI: L | Toggle Hitbox: PageDown

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false,
    HitboxSize = 10,
    Transparency = 0.5,
    TeamCheck = true,
}

local GuiVisible = true

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersHitbox_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220) -- Compact & clean
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Learners | Hitbox"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- UI List Layout handles the spacing automatically (No more mess!)
local List = Instance.new("UIListLayout")
List.Parent = MainFrame
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 35)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() callback(Btn) end)
    return Btn
end

-- Spacer for the ListLayout (since title and status aren't in the list)
local Spacer = Instance.new("Frame")
Spacer.Size = UDim2.new(1, 0, 0, 70)
Spacer.BackgroundTransparency = 1
Spacer.LayoutOrder = 0
Spacer.Parent = MainFrame

local MasterBtn = CreateButton("Toggle Extender", Color3.fromRGB(60, 60, 60), function(self)
    Settings.Enabled = not Settings.Enabled
    StatusLabel.Text = "Status: " .. (Settings.Enabled and "ON" or "OFF")
    StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    self.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(60, 60, 60)
end)

local TeamBtn = CreateButton("Team Check: ON", Color3.fromRGB(40, 80, 120), function(self)
    Settings.TeamCheck = not Settings.TeamCheck
    self.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    self.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(40, 80, 120) or Color3.fromRGB(120, 40, 40)
end)

-- // CORE LOGIC // --
task.spawn(function()
    while task.wait(0.2) do -- Slower loop = Better RAM
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local isTeammate = Settings.TeamCheck and player.Team == LocalPlayer.Team
                    if Settings.Enabled and not isTeammate then
                        hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        hrp.Transparency = Settings.Transparency
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

-- // TOGGLES // --
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        MasterBtn:MouseButton1Click() -- Triggers the function above
    end
end)
