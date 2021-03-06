#!/usr/bin/env lua5.3

local evdev = require "evdev"

local script, dev = ...
if script == nil or dev == nil then
	error("Usage: mapper path/to/handler_script.lua /dev/input/eventX")
end



local loader = function(c)
	-- TODO: may want to make this runnable outside the source directory.
	-- obviously this will fail if you're not in the source directory!
	return dofile("./"..c..".lua")
end

local IEventHandler = dofile(script)(loader)
local handle = IEventHandler.process_event




local input = evdev.Device(dev)



while true do
	local timestamp, eventType, eventCode, value = input:read()
	handle(timestamp, eventType, eventCode, value)
end

