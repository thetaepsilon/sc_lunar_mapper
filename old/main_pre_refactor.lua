#!/usr/bin/env lua5.3

local evdev = require "evdev"
local dev = ...
if dev == nil then
	error("Usage: event_dump $device_node")
end
local input = evdev.Device(dev)

local fakeMouse = evdev.Uinput "/dev/uinput"
local c = require "evdev.constants"
fakeMouse:useEvent(c.EV_KEY)
fakeMouse:useEvent(c.EV_REL)
fakeMouse:useRelAxis(c.REL_X,-200,200)
fakeMouse:useRelAxis(c.REL_Y,-200,200)

local uses_mouse = function(k)
	fakeMouse:useKey(k)
end
local factory = dofile("./config_desktop.lua")
local handle_button_delegate = factory(c, nil, uses_mouse)

fakeMouse:init("uinput steam controller mapper")



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
local move = function(mx, my)
	-- gah, linux, why u no float in kernel
	local sx = floor(mx * s)
	local sy = floor(my * s)
	fakeMouse:write(rel, rel_x, sx)
	fakeMouse:write(rel, rel_y, sy)
	flush(fakeMouse)
end




-- the steam controller's touchpads report a 16-bit signed integer.
-- somewhat strangely they are mounted rotated 15° inwards,
-- and the controller doesn't bother to try and translate this.
-- therefore here we do some mapping...
local atan2 = math.atan	-- oh look, 5.3 goodies...
local circle = math.pi * 2
local adjust = math.pi / -8
local scale = 32768
local map_coordinates = function(tx, ty)
	local radians = atan2(tx, -ty)
	radians = radians + adjust
	--print(radians / circle)

	-- the kernel always reports in ints, so scale those down
	local rx = tx / scale
	local ry = ty / scale

	return rx, ry
end




local analog = c.EV_ABS
local button = c.EV_KEY
local rtouch = c.BTN_THUMB2	-- sent touching or releasing the pad
local rx, ry = c.ABS_RX, c.ABS_RY
local x, y
local ox, oy
local handle = function()
	if x and y then
		-- we get sent x and y individually with no SYN!?
		-- wait for them both to turn up again next time.
		local tx, ty = x, y
		x, y = nil, nil

		local ax, ay = map_coordinates(tx, ty)
		--print("# raw:", tx, ty)
		--print("# adj:", ax, ay)

		local nz = ((tx ~= 0) and (ty ~= 0))
		--print(nz)
		--local update = true
		-- just ignore zero samples...
		if ox and nz then
			-- ^ it's very rare that zero is actually reported.
			-- we have to handle that case when the user lets go.
			local dx = ax - ox
			local dy = ay - oy
			--print(dx, dy)
			move(dx, dy)
		end
		
		--if update then
			ox, oy = ax, ay
		--end
	end
end



local handle_button = function(code, value)
	if code == rtouch then
		-- if the user releases the right trackpad,
		-- reset the "old" coordinates so the delta doesn't jump.
		-- this handles the case even if the user executes a "fling",
		-- where the thumb is still moving at the point of release
		-- (in that case, ABS_RX and ABS_RY don't return to zero).
		if value == 0 then
			ox, oy = nil, nil
		end
	else
		handle_button_delegate(nil, fakeMouse, code, value)	
	end
end



while true do
	local timestamp, eventType, eventCode, value = input:read()
	if eventType == analog then
		if eventCode == rx then
			x = value
			handle()
		elseif eventCode == ry then
			y = value
			handle()
		end
	elseif eventType == button then
		handle_button(eventCode, value)
	end
end

