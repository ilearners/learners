-- Learners ESP
-- Toggle GUI: PageDown

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Settings
local ESPEnabled = true
local ShowNames = true
local ShowHealth = true
local TeamCheck = true
local MaxDistance = 1000
local GuiVisible = true
local ESPData = {}

-- Cache Folder for Highlights (Prevents Memory Leaks)
local HighlightStorage = Instance.new("Folder")
HighlightStorage.Name = "Learners_HL_Cache"
HighlightStorage.Parent = game:GetService("CoreGui") -- Hidden from game scripts

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersESP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Learners | ESP"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local function CreateLearnerButton(text, pos, enabled, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    Btn.Text = text .. (enabled and ": ON" or ": OFF")
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        local newState = callback()
        Btn.Text = text .. (newState and ": ON" or ": OFF")
        Btn.BackgroundColor3 = newState and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    end)
end

CreateLearnerButton("Master ESP", UDim2.new(0, 10, 0, 90), ESPEnabled, function() ESPEnabled = not ESPEnabled return ESPEnabled end)
CreateLearnerButton("Show Names", UDim2.new(0, 10, 0, 130), ShowNames, function() ShowNames = not ShowNames return ShowNames end)
CreateLearnerButton("Show Health", UDim2.new(0, 10, 0, 170), ShowHealth, function() ShowHealth = not ShowHealth return ShowHealth end)
CreateLearnerButton("Team Check", UDim2.new(0, 10, 0, 210), TeamCheck, function() TeamCheck = not TeamCheck return TeamCheck end)

-- // OPTIMIZED CORE LOGIC // --

local function CreateESPData(player)
    local data = {}
    
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = HighlightStorage -- Stays here to prevent RAM leaks
    
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
    nl.Parent = bb

    local hll = Instance.new("TextLabel")
    hll.Size = UDim2.new(1, 0, 0.5, 0)
    hll.Position = UDim2.new(0, 0, 0.5, 0)
    hll.BackgroundTransparency = 1
    hll.Font = Enum.Font.Gotham
    hll.TextSize = 13
    hll.Parent = bb

    data.highlight = hl
    data.billboard = bb
    data.nameLabel = nl
    data.healthLabel = hll
    ESPData[player] = data
end

-- Managed Loop (Fires 30 times a second - much better for RAM)
task.spawn(function()
    while task.wait(0.033) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local data = ESPData[player]
            if not data then CreateESPData(player) data = ESPData[player] end

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            local isTeammate = TeamCheck and player.Team == LocalPlayer.Team
            local shouldShow = ESPEnabled and char and hrp and hum and not isTeammate
            
            if shouldShow then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist <= MaxDistance then
                    data.highlight.Enabled = true
                    data.highlight.Adornee = char
                    
                    data.billboard.Enabled = true
                    data.billboard.Adornee = hrp
                    data.billboard.Parent = char

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
                    shouldShow = false
                end
            end

            if not shouldShow then
                data.highlight.Enabled = false
                data.highlight.Adornee = nil
                data.billboard.Enabled = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPData[player] then
        data.highlight:Destroy()
        data.billboard:Destroy()
        ESPData[player] = nil
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.PageDown then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
end)
