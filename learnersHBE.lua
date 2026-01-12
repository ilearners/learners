-- Learners Hitbox Extender | Damage-Compatible
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

-- // GUI CONSTRUCTION (SAME STYLE) // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxExtenderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 240)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -120)
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
Title.Text = "Hitbox Extender | Damage"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

local function CreateButton(text, pos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = MainFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

CreateButton("Toggle Extender (PageDown)", UDim2.new(0, 10, 0, 100), function()
    Settings.Enabled = not Settings.Enabled
    StatusLabel.Text = "Status: " .. (Settings.Enabled and "Enabled" or "Disabled")
    StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

CreateButton("Team Check: ON", UDim2.new(0, 10, 0, 145), function(self)
    Settings.TeamCheck = not Settings.TeamCheck
    -- Note: 'self' isn't standard here, so we update button text manually:
    MainFrame:FindFirstChild("TeamCheckBtn").Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
end).Name = "TeamCheckBtn"

-- // CORE LOGIC: THE CORRECT WAY // --

task.spawn(function()
    while task.wait(0.1) do -- 10 times per second is enough for hitboxes
        if Settings.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local isTeammate = Settings.TeamCheck and player.Team == LocalPlayer.Team
                    
                    if hrp and not isTeammate then
                        hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        hrp.Transparency = Settings.Transparency
                        hrp.CanCollide = false -- Important: Prevents physics glitching
                    end
                end
            end
        else
            -- Reset hitboxes when disabled
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1) -- Standard Roblox HRP size
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

-- // INPUTS // --
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        Settings.Enabled = not Settings.Enabled
        StatusLabel.Text = "Status: " .. (Settings.Enabled and "Enabled" or "Disabled")
        StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)
