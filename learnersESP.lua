-- Learners ESP
-- Toggle GUI: P

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Settings
local ESPEnabled = true
local ShowNames = true
local ShowHealth = true
local TeamCheck = true
local MaxDistance = 1000
local GuiVisible = true
local ESPData = {}

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersESP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
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
Title.Text = "Learners | ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

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

local function CreateLearnerButton(text, pos, enabled, callback)
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

CreateLearnerButton("Master ESP", UDim2.new(0, 10, 0, 90), ESPEnabled, function()
    ESPEnabled = not ESPEnabled
    return ESPEnabled
end)

CreateLearnerButton("Show Names", UDim2.new(0, 10, 0, 130), ShowNames, function()
    ShowNames = not ShowNames
    return ShowNames
end)

CreateLearnerButton("Show Health", UDim2.new(0, 10, 0, 170), ShowHealth, function()
    ShowHealth = not ShowHealth
    return ShowHealth
end)

CreateLearnerButton("Team Check", UDim2.new(0, 10, 0, 210), TeamCheck, function()
    TeamCheck = not TeamCheck
    return TeamCheck
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

-- // OPTIMIZED CORE LOGIC // --

local function CreateESPData(player)
    local data = {}
    
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 14
    nl.TextStrokeTransparency = 0
    nl.Parent = bb

    local hll = Instance.new("TextLabel")
    hll.Size = UDim2.new(1, 0, 0.5, 0)
    hll.Position = UDim2.new(0, 0, 0.5, 0)
    hll.BackgroundTransparency = 1
    hll.Font = Enum.Font.Gotham
    hll.TextSize = 13
    hll.TextStrokeTransparency = 0
    hll.Parent = bb

    data.highlight = hl
    data.billboard = bb
    data.nameLabel = nl
    data.healthLabel = hll
    
    ESPData[player] = data
end

-- RenderStepped is used for smooth visual updates
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Create data only once per player session
        local data = ESPData[player]
        if not data then 
            CreateESPData(player) 
            data = ESPData[player] 
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        -- Visibility Logic
        local isTeammate = TeamCheck and player.Team == LocalPlayer.Team
        local shouldShow = ESPEnabled and char and hrp and hum and not isTeammate
        
        if shouldShow then
            local dist = (workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude
            if dist <= MaxDistance then
                -- Attach visuals
                data.highlight.Enabled = true
                data.highlight.Adornee = char
                data.highlight.Parent = char

                data.billboard.Enabled = true
                data.billboard.Adornee = hrp
                data.billboard.Parent = char

                -- Update Content
                data.nameLabel.Visible = ShowNames
                data.nameLabel.Text = player.Name
                
                if ShowHealth then
                    data.healthLabel.Visible = true
                    data.healthLabel.Text = math.floor(hum.Health) .. " HP"
                    data.healthLabel.TextColor3 = Color3.fromHSV((hum.Health/hum.MaxHealth) * 0.3, 1, 1)
                else
                    data.healthLabel.Visible = false
                end
            else
                shouldShow = false -- Out of distance range
            end
        end

        -- Clean up if they shouldn't be seen (or died)
        if not shouldShow then
            data.highlight.Enabled = false
            data.billboard.Enabled = false
        end
    end
end)

-- Clean up memory when players leave
Players.PlayerRemoving:Connect(function(player)
    if ESPData[player] then
        if ESPData[player].highlight then ESPData[player].highlight:Destroy() end
        if ESPData[player].billboard then ESPData[player].billboard:Destroy() end
        ESPData[player] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.P then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
end)
