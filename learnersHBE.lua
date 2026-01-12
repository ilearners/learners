-- Learners Hitbox Extender
-- Toggle GUI: PageDown | Toggle Hitbox: PageUp

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
}

local GuiVisible = true

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxExtenderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
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
Title.Text = "learners | HBE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Size Slider
local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(1, -20, 0, 25)
SizeLabel.Position = UDim2.new(0, 10, 0, 90)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Hitbox Size: 10"
SizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeLabel.Font = Enum.Font.Gotham
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = MainFrame

local SizeSlider = Instance.new("TextButton")
SizeSlider.Size = UDim2.new(1, -20, 0, 20)
SizeSlider.Position = UDim2.new(0, 10, 0, 120)
SizeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SizeSlider.Text = ""
SizeSlider.Parent = MainFrame
Instance.new("UICorner", SizeSlider).CornerRadius = UDim.new(0, 4)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0) -- Default start
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SliderFill.Parent = SizeSlider
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

-- Transparency Slider
local TransLabel = Instance.new("TextLabel")
TransLabel.Size = UDim2.new(1, -20, 0, 25)
TransLabel.Position = UDim2.new(0, 10, 0, 150)
TransLabel.BackgroundTransparency = 1
TransLabel.Text = "Transparency: 0.5"
TransLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TransLabel.Font = Enum.Font.Gotham
TransLabel.TextXAlignment = Enum.TextXAlignment.Left
TransLabel.Parent = MainFrame

local TransSlider = Instance.new("TextButton")
TransSlider.Size = UDim2.new(1, -20, 0, 20)
TransSlider.Position = UDim2.new(0, 10, 0, 180)
TransSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TransSlider.Text = ""
TransSlider.Parent = MainFrame
Instance.new("UICorner", TransSlider).CornerRadius = UDim.new(0, 4)

local TransFill = Instance.new("Frame")
TransFill.Size = UDim2.new(0.5, 0, 1, 0)
TransFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
TransFill.Parent = TransSlider
Instance.new("UICorner", TransFill).CornerRadius = UDim.new(0, 4)

local TeamCheckBtn = Instance.new("TextButton")
TeamCheckBtn.Size = UDim2.new(1, -20, 0, 40)
TeamCheckBtn.Position = UDim2.new(0, 10, 0, 220)
TeamCheckBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
TeamCheckBtn.Text = "Team Check: ON"
TeamCheckBtn.TextColor3 = Color3.new(1,1,1)
TeamCheckBtn.Font = Enum.Font.GothamBold
TeamCheckBtn.Parent = MainFrame
Instance.new("UICorner", TeamCheckBtn).CornerRadius = UDim.new(0, 6)

-- // LOGIC // --

local function UpdateSlider(slider, fill, min, max, callback)
    local dragging = false
    local function update(input)
        local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        callback(min + (max - min) * relativeX)
    end
    slider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
end

UpdateSlider(SizeSlider, SliderFill, 2, 50, function(value)
    Settings.HitboxSize = math.floor(value)
    SizeLabel.Text = "Hitbox Size: " .. Settings.HitboxSize
end)

UpdateSlider(TransSlider, TransFill, 0, 1, function(value)
    Settings.Transparency = math.floor(value * 10) / 10
    TransLabel.Text = "Transparency: " .. Settings.Transparency
end)

TeamCheckBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamCheckBtn.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    TeamCheckBtn.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
end)

-- The "Damage-Enabled" Loop
task.spawn(function()
    while task.wait(0.1) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local isTeammate = Settings.TeamCheck and player.Team == LocalPlayer.Team
                    if Settings.Enabled and not isTeammate then
                        -- Modify existing HRP so bullets actually register hits
                        hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        hrp.Transparency = Settings.Transparency
                        hrp.CanCollide = false
                        hrp.Color = Color3.fromRGB(255, 0, 0) -- Visual hint
                        hrp.Material = Enum.Material.ForceField
                    else
                        -- Reset to original state
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.PageDown then 
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.PageUp then 
        Settings.Enabled = not Settings.Enabled
        StatusLabel.Text = "Status: " .. (Settings.Enabled and "Enabled" or "Disabled")
        StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)
