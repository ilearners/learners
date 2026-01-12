-- Clean Performance-Friendly Hitbox Extender
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
    TargetPart = "HumanoidRootPart",
}

local OriginalSizes = {}
local OriginalProperties = {}
local GuiVisible = true

-- Create GUI
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
Title.BorderSizePixel = 0
Title.Text = "Hitbox Extender"
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
SizeLabel.TextSize = 14
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = MainFrame

local SizeSlider = Instance.new("TextButton")
SizeSlider.Size = UDim2.new(1, -20, 0, 20)
SizeSlider.Position = UDim2.new(0, 10, 0, 120)
SizeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SizeSlider.BorderSizePixel = 0
SizeSlider.Text = ""
SizeSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SizeSlider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SizeSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = SliderFill

-- Transparency Slider
local TransLabel = Instance.new("TextLabel")
TransLabel.Size = UDim2.new(1, -20, 0, 25)
TransLabel.Position = UDim2.new(0, 10, 0, 150)
TransLabel.BackgroundTransparency = 1
TransLabel.Text = "Transparency: 0.5"
TransLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TransLabel.Font = Enum.Font.Gotham
TransLabel.TextSize = 14
TransLabel.TextXAlignment = Enum.TextXAlignment.Left
TransLabel.Parent = MainFrame

local TransSlider = Instance.new("TextButton")
TransSlider.Size = UDim2.new(1, -20, 0, 20)
TransSlider.Position = UDim2.new(0, 10, 0, 180)
TransSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TransSlider.BorderSizePixel = 0
TransSlider.Text = ""
TransSlider.Parent = MainFrame

local TransCorner = Instance.new("UICorner")
TransCorner.CornerRadius = UDim.new(0, 4)
TransCorner.Parent = TransSlider

local TransFill = Instance.new("Frame")
TransFill.Size = UDim2.new(0.5, 0, 1, 0)
TransFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
TransFill.BorderSizePixel = 0
TransFill.Parent = TransSlider

local TransFillCorner = Instance.new("UICorner")
TransFillCorner.CornerRadius = UDim.new(0, 4)
TransFillCorner.Parent = TransFill

-- Team Check Toggle
local TeamCheckBtn = Instance.new("TextButton")
TeamCheckBtn.Size = UDim2.new(1, -20, 0, 35)
TeamCheckBtn.Position = UDim2.new(0, 10, 0, 215)
TeamCheckBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
TeamCheckBtn.Text = "Team Check: ON"
TeamCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckBtn.Font = Enum.Font.GothamBold
TeamCheckBtn.TextSize = 14
TeamCheckBtn.Parent = MainFrame

local TeamBtnCorner = Instance.new("UICorner")
TeamBtnCorner.CornerRadius = UDim.new(0, 6)
TeamBtnCorner.Parent = TeamCheckBtn

-- Visualize Toggle
local VisualizeBtn = Instance.new("TextButton")
VisualizeBtn.Size = UDim2.new(1, -20, 0, 35)
VisualizeBtn.Position = UDim2.new(0, 10, 0, 260)
VisualizeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
VisualizeBtn.Text = "Visualize: ON"
VisualizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VisualizeBtn.Font = Enum.Font.GothamBold
VisualizeBtn.TextSize = 14
VisualizeBtn.Parent = MainFrame

local VisBtnCorner = Instance.new("UICorner")
VisBtnCorner.CornerRadius = UDim.new(0, 6)
VisBtnCorner.Parent = VisualizeBtn

-- Helper function to update slider
local function UpdateSlider(slider, fill, min, max, current, callback)
    local dragging = false
    
    local function update(input)
        local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relativeX
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

-- Setup sliders
UpdateSlider(SizeSlider, SliderFill, 1, 50, Settings.HitboxSize, function(value)
    Settings.HitboxSize = math.floor(value * 10) / 10
    SizeLabel.Text = "Hitbox Size: " .. Settings.HitboxSize
end)

UpdateSlider(TransSlider, TransFill, 0, 1, Settings.Transparency, function(value)
    Settings.Transparency = math.floor(value * 100) / 100
    TransLabel.Text = "Transparency: " .. Settings.Transparency
end)

-- Team Check button
TeamCheckBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamCheckBtn.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    TeamCheckBtn.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
end)

-- Visualize button
VisualizeBtn.MouseButton1Click:Connect(function()
    Settings.VisualizeHitbox = not Settings.VisualizeHitbox
    VisualizeBtn.Text = "Visualize: " .. (Settings.VisualizeHitbox and "ON" or "OFF")
    VisualizeBtn.BackgroundColor3 = Settings.VisualizeHitbox and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
end)

-- Function to modify hitbox
local function ModifyHitbox(character, enable)
    if not character then return end
    
    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart or not targetPart:IsA("BasePart") then return end
    
    if enable then
        -- Store original properties
        if not OriginalSizes[targetPart] then
            OriginalSizes[targetPart] = targetPart.Size
            OriginalProperties[targetPart] = {
                Transparency = targetPart.Transparency,
                CanCollide = targetPart.CanCollide,
                Massless = targetPart.Massless,
            }
        end
        
        -- Apply new size
        targetPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
        targetPart.Transparency = Settings.VisualizeHitbox and Settings.Transparency or 1
        targetPart.CanCollide = false
        targetPart.Massless = true
        
    else
        -- Restore original properties
        if OriginalSizes[targetPart] then
            targetPart.Size = OriginalSizes[targetPart]
            if OriginalProperties[targetPart] then
                targetPart.Transparency = OriginalProperties[targetPart].Transparency
                targetPart.CanCollide = OriginalProperties[targetPart].CanCollide
                targetPart.Massless = OriginalProperties[targetPart].Massless
            end
            OriginalSizes[targetPart] = nil
            OriginalProperties[targetPart] = nil
        end
    end
end

-- Function to apply hitbox to all players
local function ApplyToAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team check
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                if player.Character then
                    ModifyHitbox(player.Character, false)
                end
            else
                if player.Character then
                    ModifyHitbox(player.Character, Settings.Enabled)
                end
            end
        end
    end
end

-- Function to toggle hitbox extender
local function ToggleHitbox()
    Settings.Enabled = not Settings.Enabled
    
    if Settings.Enabled then
        StatusLabel.Text = "Status: Enabled"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "Status: Disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    ApplyToAllPlayers()
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Wait for character to fully load
        if Settings.Enabled then
            if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
                ModifyHitbox(character, true)
            end
        end
    end)
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        task.wait(0.1)
        if Settings.Enabled then
            if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
                ModifyHitbox(player.Character, true)
            end
        end
    end
    
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Settings.Enabled then
            if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
                ModifyHitbox(character, true)
            end
        end
    end)
end

-- Update loop (only when enabled)
RunService.Heartbeat:Connect(function()
    if Settings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
                if targetPart and targetPart:IsA("BasePart") then
                    -- Skip teammates if team check is on
                    if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                        ModifyHitbox(player.Character, false)
                    else
                        -- Update size and transparency in real-time
                        targetPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        targetPart.Transparency = Settings.VisualizeHitbox and Settings.Transparency or 1
                    end
                end
            end
        end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI with L
    if input.KeyCode == Enum.KeyCode.L then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
    
    -- Toggle Hitbox with PageDown
    if input.KeyCode == Enum.KeyCode.PageDown then
        ToggleHitbox()
    end
end)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ModifyHitbox(player.Character, false)
    end
end)

print("Hitbox Extender Loaded!")
print("Press 'L' to toggle GUI")
print("Press 'PageDown' to toggle hitbox extender")
