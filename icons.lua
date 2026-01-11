-- Optimized icons.lua wrapper
-- Purpose: preserve existing API (Icons['48px'][name] => { id, {w,h}, {x,y} })
-- but convert the internal rect arrays to Vector2 lazily only when accessed to reduce upfront memory/Vector2 allocations.
-- Integration: Replace the original icons.lua with this file, or require the original raw table into RawIcons below.

-- NOTE: This file expects the original raw table to be available as RawIcons.
-- If you already have the original generated table (large), set RawIcons = <that table>.
-- If you prefer to keep the original file untouched, instead require it and pass it into the adapter:
-- local raw = require(original_icons_module); return createAdapter(raw)

local RawIcons = { -- sample subset; replace with the full generated table contents when deploying
	["48px"] = {
		-- format: name = { id, {w,h}, {x,y} }
		rewind = {16898613699, {48,48}, {563,967}},
		fuel = {16898613353, {48,48}, {196,967}},
		["square-arrow-out-up-right"] = {16898613777, {48,48}, {967,514}},
		-- ... paste the rest of the generated entries here ...
	}
}

-- adapter: lazy-convert the inner arrays to Vector2 and memoize the converted value
local function createAdapter(raw)
	local adapter = {}
	for sizeKey, tableOfIcons in pairs(raw) do
		local proxy = {}
		local mt = {
			__index = function(t, k)
				local entry = tableOfIcons[k]
				if not entry then return nil end
				-- if already converted to structured, return
				if type(entry) == "table" and entry.id and entry.imageRectSize and entry.imageRectOffset then
					return entry
				end
				-- Convert: entry = {id, {w,h}, {x,y}}
				local id = entry[1]
				local rsize = entry[2] or {0, 0}
				local roff = entry[3] or {0, 0}
				local structured = {
					id = id,
					imageRectSize = Vector2.new(rsize[1] or 0, rsize[2] or 0),
					imageRectOffset = Vector2.new(roff[1] or 0, roff[2] or 0),
				}
				-- memoize (replace raw entry to save future conversions)
				tableOfIcons[k] = structured
				return structured
			end,
			__pairs = function()
				return pairs(tableOfIcons)
			end,
			__len = function() return #tableOfIcons end
		}
		setmetatable(proxy, mt)
		adapter[sizeKey] = proxy
	end
	return adapter
end

return createAdapter(RawIcons)
