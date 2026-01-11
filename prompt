-- Optimized prompt.lua
-- Preserves: promptRet.create(title, description, primary, secondary, callback)
-- Notes: preserves same animations and interactions, uses a small helper tween() to avoid repetition.

local promptRet = {}
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local useStudio = RunService:IsStudio()
local debounce = false
local closing = false

local function safePlayTween(inst, info, props)
	if not inst then return end
	pcall(function()
		local t = TweenService:Create(inst, info, props)
		t:Play()
	end)
end

local function animateOpen(prompt)
	debounce = true
	closing = false
	-- initial state
	prompt.Policy.Size = UDim2.new(0, 400, 0, 120)
	prompt.Policy.BackgroundTransparency = 1
	prompt.Policy.Shadow.Image.ImageTransparency = 1
	prompt.Policy.Title.TextTransparency = 1
	prompt.Policy.Notice.TextTransparency = 1
	prompt.Policy.Actions.Primary.BackgroundTransparency = 1
	prompt.Policy.Actions.Primary.Shadow.ImageTransparency = 1
	prompt.Policy.Actions.Primary.Title.TextTransparency = 1
	prompt.Policy.Actions.Secondary.Title.TextTransparency = 1

	prompt.Policy.Visible = true
	prompt.Enabled = true

	safePlayTween(prompt.Policy, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
	safePlayTween(prompt.Policy.Shadow.Image, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.6})
	safePlayTween(prompt.Policy, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 463, 0, 150)})

	task.wait(0.15)
	safePlayTween(prompt.Policy.Title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0})
	task.wait(0.03)
	safePlayTween(prompt.Policy.Notice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.5})

	task.wait(0.15)
	safePlayTween(prompt.Policy.Actions.Primary, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3})
	safePlayTween(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.2})
	safePlayTween(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.7})

	-- provide a sensible default timeout so the UI becomes interactive even if user doesn't act
	local timeout = 5
	local elapsed = 0
	while elapsed < timeout and not closing do
		task.wait(0.25)
		elapsed = elapsed + 0.25
	end

	-- ensure the secondary hint becomes visible if user didn't interact
	if not closing and prompt and prompt.Policy and prompt.Policy.Actions and prompt.Policy.Actions.Secondary then
		safePlayTween(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.6})
	end
	debounce = false
end

local function animateClose(prompt)
	-- prevent re-entrancy
	if closing then return end
	closing = true
	debounce = true

	-- collapse visuals
	safePlayTween(prompt.Policy, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 110)})
	safePlayTween(prompt.Policy.Title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1})
	safePlayTween(prompt.Policy.Notice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1})
	safePlayTween(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1})
	safePlayTween(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
	safePlayTween(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1})
	safePlayTween(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 1})
	safePlayTween(prompt.Policy, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
	safePlayTween(prompt.Policy.Shadow.Image, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 1})

	task.wait(1)
	-- it's okay to pcall Destroy in case the UI was removed elsewhere
	pcall(function() prompt:Destroy() end)
	closing = false
	debounce = false
end

-- Public API
-- promptRet.create(title, description, primary, secondary, callback)
function promptRet.create(title, description, primary, secondary, callback)
	local prompt = nil
	if useStudio then
		prompt = script.Parent:FindFirstChild('WarningPrompt')
	else
		-- keep existing asset behaviour
		prompt = game:GetObjects("rbxassetid://76963332287827")[1]
	end
	if not prompt then return end

	prompt.Enabled = false

	-- parent
	if gethui then
		pcall(function() prompt.Parent = gethui() end)
	elseif syn and syn.protect_gui then
		pcall(syn.protect_gui, prompt)
		prompt.Parent = CoreGui
	elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
		prompt.Parent = CoreGui:FindFirstChild("RobloxGui")
	else
		prompt.Parent = CoreGui
	end

	-- disable other instances
	local function disableOthers(parent)
		for _, Interface in ipairs(parent:GetChildren()) do
			if Interface.Name == prompt.Name and Interface ~= prompt then
				Interface.Enabled = false
				Interface.Name = "Prompt-Old"
			end
		end
	end
	pcall(function()
		if gethui then disableOthers(gethui()) else disableOthers(CoreGui) end
	end)

	-- set texts (defensive)
	prompt.Policy.Title.Text = title or ""
	prompt.Policy.Notice.Text = description or ""
	prompt.Policy.Actions.Primary.Title.Text = primary or "OK"
	prompt.Policy.Actions.Secondary.Title.Text = secondary or "Cancel"

	-- connections
	local primaryConn, secondaryConn, enterConn
	primaryConn = prompt.Policy.Actions.Primary.Interact.MouseButton1Click:Connect(function()
		if debounce then return end
		animateClose(prompt)
		if callback then
			pcall(callback, true)
		end
	end)

	secondaryConn = prompt.Policy.Actions.Secondary.Interact.MouseButton1Click:Connect(function()
		if debounce then return end
		animateClose(prompt)
		if callback then
			pcall(callback, false)
		end
	end)

	-- hover effects, guarded for safety
	local function onPrimaryEnter()
		if debounce then return end
		safePlayTween(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		safePlayTween(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0})
		safePlayTween(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.45})
	end
	local function onPrimaryLeave()
		if debounce then return end
		safePlayTween(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2})
		safePlayTween(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.2})
		safePlayTween(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.7})
	end

	local function onSecondaryEnter()
		if debounce then return end
		safePlayTween(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.3})
	end
	local function onSecondaryLeave()
		if debounce then return end
		safePlayTween(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.6})
	end

	-- safe connect
	prompt.Policy.Actions.Primary.Interact.MouseEnter:Connect(onPrimaryEnter)
	prompt.Policy.Actions.Primary.Interact.MouseLeave:Connect(onPrimaryLeave)
	prompt.Policy.Actions.Secondary.Interact.MouseEnter:Connect(onSecondaryEnter)
	prompt.Policy.Actions.Secondary.Interact.MouseLeave:Connect(onSecondaryLeave)

	-- start open animation asynchronously
	task.spawn(animateOpen, prompt)
end

return promptRet
