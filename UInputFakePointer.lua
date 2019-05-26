local c = require "evdev.constants"


local floatscale = 200
local rel = c.EV_REL
local sync = c.EV_SYN
local report = c.SYN_REPORT
local flush = function(dev)
	dev:write(sync, report, 0)
end

local floor = math.floor
local s = floatscale
local rel_x = c.REL_X
local rel_y = c.REL_Y



local mleft = c.BTN_0
local mcenter = c.BTN_1
local mright = c.BTN_2
local key = c.EV_KEY

local r = 32768
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
		local sx = floor(mx * s)
		local sy = floor(my * s)
		fakeMouse:write(rel, rel_x, sx)
		fakeMouse:write(rel, rel_y, sy)
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

