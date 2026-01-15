-- Learners Universal ESP
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
local MaxDistance = 2000 -- Increased for universal support
local GuiVisible = true
local ESPData = {}

-- // GUI CONSTRUCTION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LearnersUniversal_GUI"
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
Title.Text = "Learners | Universal ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

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

CreateLearnerButton("Master ESP", UDim2.new(0, 10, 0, 70), ESPEnabled, function() ESPEnabled = not ESPEnabled return ESPEnabled end)
CreateLearnerButton("Show Names", UDim2.new(0, 10, 0, 115), ShowNames, function() ShowNames = not ShowNames return ShowNames end)
CreateLearnerButton("Show Health", UDim2.new(0, 10, 0, 160), ShowHealth, function() ShowHealth = not ShowHealth return ShowHealth end)
CreateLearnerButton("Team Check", UDim2.new(0, 10, 0, 205), TeamCheck, function() TeamCheck = not TeamCheck return TeamCheck end)

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "Press 'PageDown' to Toggle GUI"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.Parent = MainFrame

-- // UNIVERSAL LOGIC UPGRADES // --

local function GetCharacterData(player)
    local char = player.Character
    if not char then return nil end
    
    -- Universal way to get position: Pivot
    local root = char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
    
    -- Universal way to get health: Any object of class Humanoid
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    
    return char, root, hum
end

local function CreateESPData(player)
    local data = {
        highlight = Instance.new("Highlight"),
        billboard = Instance.new("BillboardGui")
    }
    
    data.highlight.FillTransparency = 1
    data.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    data.billboard.Size = UDim2.new(0, 200, 0, 60)
    data.billboard.AlwaysOnTop = true
    data.billboard.StudsOffset = Vector3.new(0, 3, 0)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 14
    nl.TextStrokeTransparency = 0
    nl.Parent = data.billboard
    data.nameLabel = nl

    local hll = Instance.new("TextLabel")
    hll.Size = UDim2.new(1, 0, 0.5, 0)
    hll.Position = UDim2.new(0, 0, 0.5, 0)
    hll.BackgroundTransparency = 1
    hll.Font = Enum.Font.Gotham
    hll.TextSize = 13
    hll.TextStrokeTransparency = 0
    hll.Parent = data.billboard
    data.healthLabel = hll

    ESPData[player] = data
end

RunService.Heartbeat:Connect(function()
    local camPos = Camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local data = ESPData[player]
        if not data then CreateESPData(player) data = ESPData[player] end

        local char, root, hum = GetCharacterData(player)
        local isTeammate = TeamCheck and player.Team == LocalPlayer.Team
        
        -- Use Pivot if no specific RootPart is found
        local pivotPos = char and char:GetPivot().Position
        local shouldShow = ESPEnabled and char and pivotPos and not isTeammate
        
        if shouldShow then
            local dist = (camPos - pivotPos).Magnitude
            if dist <= MaxDistance then
                data.highlight.Parent = char
                data.highlight.Enabled = true
                
                data.billboard.Parent = char
                data.billboard.Adornee = root or char -- Fallback to character model
                data.billboard.Enabled = true

                data.nameLabel.Visible = ShowNames
                data.nameLabel.Text = player.DisplayName or player.Name
                
                if ShowHealth and hum then
                    data.healthLabel.Visible = true
                    data.healthLabel.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
                    data.healthLabel.TextColor3 = Color3.fromHSV((hum.Health/hum.MaxHealth) * 0.3, 1, 1)
                elseif ShowHealth and not hum then
                    -- Fallback for games without Humanoids
                    data.healthLabel.Visible = true
                    data.healthLabel.Text = "Active"
                    data.healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    data.healthLabel.Visible = false
                end
            else
                shouldShow = false
            end
        end

        if not shouldShow then
            data.highlight.Enabled = false
            data.billboard.Enabled = false
            data.highlight.Parent = nil
            data.billboard.Parent = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPData[player] then
        ESPData[player].highlight:Destroy()
        ESPData[player].billboard:Destroy()
        ESPData[player] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.PageDown then
        GuiVisible = not GuiVisible
        ScreenGui.Enabled = GuiVisible
    end
end)
