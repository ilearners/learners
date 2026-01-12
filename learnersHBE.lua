-- Learners Hitbox Extender
-- Toggle GUI: PageDown | Toggle Hitbox: PageUp

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // SETTINGS // --
local Settings = {
    Enabled = false,
    HitboxSize = 5.5,
    Transparency = 0.9,
    TeamCheck = true,
    TargetPart = "HumanoidRootPart" -- "Head" or "HumanoidRootPart"
}

local GuiVisible = true

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersHBE_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Learners | HBE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20 -- Increased
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 16 -- Increased
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Slider labels and Slider setup
local function CreateSlider(name, pos, defaultVal, min, max, isSize, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = pos
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = pos + UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Slider.Text = ""
    Slider.Parent = MainFrame
    Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 4)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Fill.Parent = Slider
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * relX
        local finalVal = isSize and (math.floor(val * 2) / 2) or (math.floor(val * 10) / 10)
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        Label.Text = name .. ": " .. finalVal
        callback(finalVal)
    end

    Slider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
end

CreateSlider("Hitbox Size", UDim2.new(0, 10, 0, 90), Settings.HitboxSize, 2, 50, true, function(v) Settings.HitboxSize = v end)
CreateSlider("Transparency", UDim2.new(0, 10, 0, 145), Settings.Transparency, 0, 1, false, function(v) Settings.Transparency = v end)

-- Buttons
local function CreateButton(text, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 38)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15 -- Bigger text
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() callback(Btn) end)
end

CreateButton("Team Check: ON", UDim2.new(0, 10, 0, 210), Color3.fromRGB(100, 200, 100), function(b)
    Settings.TeamCheck = not Settings.TeamCheck
    b.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    b.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
end)

CreateButton("Target: RootPart", UDim2.new(0, 10, 0, 255), Color3.fromRGB(120, 80, 200), function(b)
    if Settings.TargetPart == "HumanoidRootPart" then
        Settings.TargetPart = "Head"
        b.Text = "Target: Head"
        b.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    else
        Settings.TargetPart = "HumanoidRootPart"
        b.Text = "Target: RootPart"
        b.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
    end
end)

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "Press 'PageDown' to Toggle GUI"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 13 -- Fixed size
Footer.Parent = MainFrame

-- // CORE LOGIC (PHYSICS FIX) // --
task.spawn(function()
    while task.wait(0.1) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                
                if head and hrp then
                    local isTeammate = Settings.TeamCheck and player.Team == LocalPlayer.Team
                    
                    if Settings.Enabled and not isTeammate then
                        local target = (Settings.TargetPart == "Head") and head or hrp
                        local other = (Settings.TargetPart == "Head") and hrp or head
                        
                        -- PHYSICS FIX: Make target Massless to prevent character floating/freezing
                        target.Massless = true
                        target.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        target.Transparency = Settings.Transparency
                        target.CanCollide = false
                        target.Material = Enum.Material.ForceField
                        
                        -- Reset the one we aren't using
                        if other == head then
                            other.Size = Vector3.new(2,1,1)
                            other.Transparency = 0
                        else
                            other.Size = Vector3.new(2,2,1)
                            other.Transparency = 1
                        end
                    else
                        -- Complete Reset
                        head.Size = Vector3.new(2,1,1)
                        head.Transparency = 0
                        hrp.Size = Vector3.new(2,2,1)
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
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    elseif input.KeyCode == Enum.KeyCode.PageUp then 
        Settings.Enabled = not Settings.Enabled
        StatusLabel.Text = "Status: " .. (Settings.Enabled and "Enabled" or "Disabled")
        StatusLabel.TextColor3 = Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)
