-- // Learners Hitbox Extender | NPC & PLAYER VERSION // --
-- Toggle GUI: PageDown | Toggle Hitbox: PageUp

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // SETTINGS // --
local Settings = {
    Enabled = false,
    HitboxSize = 5.5,
    Transparency = 0.8,
    TeamCheck = true,
    TargetPart = "HumanoidRootPart",
    Mode = "NPCs" -- Options: "Players", "NPCs", "Both"
}

local GuiVisible = true

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersHBE_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 410) -- Increased height for new button
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Learners | HBE V2"
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
StatusLabel.TextSize = 16
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Slider Logic
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
    Slider.Size = UDim2.new(1, -20, 0, 18)
    Slider.Position = pos + UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Slider.Text = ""
    Slider.Parent = MainFrame
    Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 4)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
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
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() callback(Btn) end)
    return Btn
end

CreateButton("Team Check: ON", UDim2.new(0, 10, 0, 205), Color3.fromRGB(60, 140, 60), function(b)
    Settings.TeamCheck = not Settings.TeamCheck
    b.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    b.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(140, 60, 60)
end)

CreateButton("Target Part: RootPart", UDim2.new(0, 10, 0, 245), Color3.fromRGB(90, 60, 150), function(b)
    Settings.TargetPart = (Settings.TargetPart == "HumanoidRootPart") and "Head" or "HumanoidRootPart"
    b.Text = "Target Part: " .. (Settings.TargetPart == "Head" and "Head" or "RootPart")
end)

local ModeBtn = CreateButton("Target Mode: NPCs", UDim2.new(0, 10, 0, 285), Color3.fromRGB(200, 120, 30), function(b)
    if Settings.Mode == "NPCs" then
        Settings.Mode = "Players"
    elseif Settings.Mode == "Players" then
        Settings.Mode = "Both"
    else
        Settings.Mode = "NPCs"
    end
    b.Text = "Target Mode: " .. Settings.Mode
end)

-- // THE UPDATED CORE LOOP // --
task.spawn(function()
    while task.wait(0.2) do -- Slightly slower interval to save CPU
        if not Settings.Enabled then 
            -- Reset logic when disabled (Optional: Can be heavy if world is huge)
            continue 
        end

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent then
                local character = v.Parent
                if character == LocalPlayer.Character then continue end

                local player = Players:GetPlayerFromCharacter(character)
                local shouldTarget = false

                -- Mode Logic
                if Settings.Mode == "NPCs" and not player then
                    shouldTarget = true
                elseif Settings.Mode == "Players" and player then
                    shouldTarget = true
                elseif Settings.Mode == "Both" then
                    shouldTarget = true
                end

                -- Team Check Logic
                if player and Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    shouldTarget = false
                end

                local hrp = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")

                if hrp and head then
                    if shouldTarget and Settings.Enabled then
                        local target = (Settings.TargetPart == "Head") and head or hrp
                        target.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        target.Transparency = Settings.Transparency
                        target.CanCollide = false
                    else
                        -- Reset sizes to defaults if not targeting
                        if hrp.Size.X > 2.1 then hrp.Size = Vector3.new(2, 2, 1) end
                        if head.Size.X > 1.3 then head.Size = Vector3.new(1.2, 1.2, 1.2) end
                    end
                end
            end
        end
    end
end)

-- // INPUT HANDLING // --
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
