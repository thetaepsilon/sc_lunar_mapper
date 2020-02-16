local c = require "evdev.constants"


local floatscale = 200
local rel = c.EV_REL
local sync = c.EV_SYN
local report = c.SYN_REPORT
local flush = function(dev)
	dev:write(sync, report, 0)
end

local floor = math.floor
local ceil = math.ceil
local s = floatscale
local rel_x = c.REL_X
local rel_y = c.REL_Y



local mleft = c.BTN_0
local mcenter = c.BTN_1
local mright = c.BTN_2
local key = c.EV_KEY

local r = 32768

-- yet another thing I wish was already in lua by default.
local round_towards_zero = function(v)
	return (v > 0) and floor(v) or ceil(v)
end

return function(IUInputFactory)
	local fakeMouse = IUInputFactory()
	fakeMouse:useEvent(c.EV_KEY)
	fakeMouse:useEvent(c.EV_REL)
	fakeMouse:useKey(mleft)
	fakeMouse:useKey(mright)
	fakeMouse:useKey(mcenter)

	-- TODO: make ranges configurable?
	fakeMouse:useRelAxis(c.REL_X,-r,r)
	fakeMouse:useRelAxis(c.REL_Y,-r,r)
	fakeMouse:init("uinput steam controller mapper pointer")

	local move = function(mx, my)
		-- gah, linux, why u no float in kernel
		local sx = round_towards_zero(mx * s)
		local sy = round_towards_zero(my * s)
		if sx ~= 0 then fakeMouse:write(rel, rel_x, sx) end
		if sy ~= 0 then fakeMouse:write(rel, rel_y, sy) end
		flush(fakeMouse)
	end

	local button = function(code, state)
		fakeMouse:write(key, code, state)
		flush(fakeMouse)
	end

	return {
		move_pointer = move,
		button = button,
	}
end

