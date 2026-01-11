--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

--// DEFAULTS
local DEFAULTS = {
	TOGGLE = "L",
	TARGET_LIMB = "HumanoidRootPart",
	LIMB_SIZE = 15,
	LIMB_TRANSPARENCY = 0.9,
	LIMB_CAN_COLLIDE = false,
	MOBILE_BUTTON = true,
	LISTEN_FOR_INPUT = true,
	TEAM_CHECK = true,
	FORCEFIELD_CHECK = true,
	RESET_LIMB_ON_DEATH2 = false,
	USE_HIGHLIGHT = true,
	DEPTH_MODE = "AlwaysOnTop",
	HIGHLIGHT_FILL_COLOR = Color3.fromRGB(255,117,24),
	HIGHLIGHT_FILL_TRANSPARENCY = 0.7,
	HIGHLIGHT_OUTLINE_COLOR = Color3.new(0,0,0),
	HIGHLIGHT_OUTLINE_TRANSPARENCY = 1,
}

----------------------------------------------------------------
--// SHARED DATA
----------------------------------------------------------------

local limbExtenderData = getgenv().limbExtenderData or {}
getgenv().limbExtenderData = limbExtenderData

----------------------------------------------------------------
--// SAFE TERMINATION
----------------------------------------------------------------

if type(limbExtenderData.terminateOldProcess) == "function" then
	limbExtenderData.terminateOldProcess("Restart")
end

----------------------------------------------------------------
--// CONNECTION MANAGER
----------------------------------------------------------------

limbExtenderData.ConnectionManager =
	limbExtenderData.ConnectionManager
	or loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/AAPVdev/modules/refs/heads/main/ConnectionManager.lua"
	))()

local ConnectionManager = limbExtenderData.ConnectionManager

----------------------------------------------------------------
--// SETTINGS MERGE
----------------------------------------------------------------

local function mergeSettings(user)
	local s = table.clone(DEFAULTS)
	if user then
		for k,v in pairs(user) do s[k] = v end
	end
	return s
end

----------------------------------------------------------------
--// METATABLE SPOOF (ONCE)
----------------------------------------------------------------

local spoofedTargets = {}

local function spoofSizeOnce(part)
	if spoofedTargets[part] then return end
	spoofedTargets[part] = true

	local realSize = part.Size
	local name = part.Name

	task.spawn(function()
		local mt = getrawmetatable(game)
		setreadonly(mt,false)

		local old = mt.__index
		mt.__index = function(self,key)
			if not checkcaller()
			and key == "Size"
			and tostring(self) == name then
				return realSize
			end
			return old(self,key)
		end

		setreadonly(mt,true)
	end)
end

----------------------------------------------------------------
--// PLAYER DATA
----------------------------------------------------------------

local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(parent, player)
	local self = setmetatable({
		parent = parent,
		player = player,
		conns = ConnectionManager.new(),
		limbs = {},
		destroyed = false,
	}, PlayerData)

	self.conns:Connect(player.CharacterAdded, function(c)
		self:onCharacter(c)
	end)

	if player.Character then
		self:onCharacter(player.Character)
	end

	return self
end

function PlayerData:onCharacter(char)
	if self.destroyed then return end
	if not char then return end
	if self.parent:_isTeam(self.player) then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name == self.parent._settings.TARGET_LIMB then
			self:applyLimb(part)
		end
	end
end

function PlayerData:applyLimb(limb)
	if self.limbs[limb] then return end
	self.limbs[limb] = true

	spoofSizeOnce(limb)

	limb.Size = Vector3.one * self.parent._settings.LIMB_SIZE
	limb.Transparency = self.parent._settings.LIMB_TRANSPARENCY
	limb.CanCollide = self.parent._settings.LIMB_CAN_COLLIDE
	limb.Massless = true

	self.conns:Connect(limb.Destroying, function()
		self.limbs[limb] = nil
	end)
end

function PlayerData:Destroy()
	if self.destroyed then return end
	self.destroyed = true
	self.conns:DisconnectAll()
end

----------------------------------------------------------------
--// LIMB EXTENDER CORE
----------------------------------------------------------------

local LimbExtender = {}
LimbExtender.__index = LimbExtender

function LimbExtender.new(userSettings)
	local self = setmetatable({
		_settings = mergeSettings(userSettings),
		_players = {},
		_connections = ConnectionManager.new(),
		_running = false,
		_restartQueued = false,
	}, LimbExtender)

	limbExtenderData.terminateOldProcess = function()
		self:Destroy()
	end

	return self
end

----------------------------------------------------------------
--// TEAM CHECK
----------------------------------------------------------------

function LimbExtender:_isTeam(player)
	return self._settings.TEAM_CHECK
	and localPlayer.Team
	and player.Team == localPlayer.Team
end

----------------------------------------------------------------
--// START / STOP
----------------------------------------------------------------

function LimbExtender:Start()
	if self._running then return end
	self._running = true

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= localPlayer then
			self._players[p] = PlayerData.new(self,p)
		end
	end

	self._connections:Connect(Players.PlayerAdded,function(p)
		self._players[p] = PlayerData.new(self,p)
	end)

	self._connections:Connect(Players.PlayerRemoving,function(p)
		if self._players[p] then
			self._players[p]:Destroy()
			self._players[p] = nil
		end
	end)
end

function LimbExtender:Stop()
	if not self._running then return end
	self._running = false

	self._connections:DisconnectAll()

	for _,pd in pairs(self._players) do
		pd:Destroy()
	end
	table.clear(self._players)
end

----------------------------------------------------------------
--// RESTART (THROTTLED)
----------------------------------------------------------------

function LimbExtender:_queueRestart()
	if self._restartQueued then return end
	self._restartQueued = true

	RunService.Heartbeat:Once(function()
		self._restartQueued = false
		if self._running then
			self:Stop()
			self:Start()
		end
	end)
end

----------------------------------------------------------------
--// API
----------------------------------------------------------------

function LimbExtender:Toggle(state)
	if type(state) == "boolean" then
		if state then self:Start() else self:Stop() end
	else
		if self._running then self:Stop() else self:Start() end
	end
end

function LimbExtender:Set(key,value)
	if self._settings[key] ~= value then
		self._settings[key] = value
		self:_queueRestart()
	end
end

function LimbExtender:Get(key)
	return self._settings[key]
end

function LimbExtender:Destroy()
	self:Stop()
	self._connections:DisconnectAll()
end

return setmetatable({}, {
	__call = function(_,settings)
		return LimbExtender.new(settings)
	end,
	__index = LimbExtender
})
