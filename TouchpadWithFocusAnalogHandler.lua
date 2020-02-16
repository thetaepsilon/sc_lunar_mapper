-- handler for analog events that works with the ABS cut-off handler
-- (which needs to work in tandem with an appropriate button handler -
-- see AbsCutOffHandler for the need for this).
-- touchpad events are sent to be processed as pointer movements,
-- and the right trigger is used as a "focus";
-- tightening the hold on RT decreases the scaling applied to the pointer event,
-- theoretically allowing for more precise aim on this small touchpad.
-- (note the button at the end of RT is a button event and not used here.)

local c = require("evdev.constants")
-- feck it, why not LT as well?
local lt = c.ABS_HAT2Y
local rt = c.ABS_HAT2X
local touchX = c.ABS_RX
local touchY = c.ABS_RY



-- the steam controller touchpads report a signed 16-bit integer,
-- where 0 is the precise center of the pad.
-- we want to work with values in -1.0 to 1.0 range for convenience,
-- so do that conversion here.
local abs_range = function(v)
	return v / 32768
end



-- TODO: make minimum configurable?
local min = 0.5
local rt_max = 255
-- conversion of integer values to float ranges again...
local scale = (1.0 - min) / rt_max
local trigger_to_scale = function(value)
	return 1.0 - (scale * value)
end



local strongerof = math.min
return function(IAbsCutOffHandler, IAnalogHandler, IConfig)
	local update_x = IAbsCutOffHandler.update_x
	local update_y = IAbsCutOffHandler.update_y
	local lscale = 1.0
	local rscale = 1.0
	
	local inner = IAnalogHandler.process_analog

	-- this used to handle pairing up the x/y axes,
	-- but this approach caused many issues with jankiness of motion
	-- (particularly when only moving mostly along one axis).
	-- hence why it's called maybe_.
	local x = 0
	local y = 0
	local s = 1.0
	local update_scale = function()
		s = strongerof(lscale, rscale)
	end

	-- currently the analog inputs used for this are hardcoded above...
	-- I should probably FIXME this someday.
	-- in the meantime, allow the values to be passed through,
	-- even if they were used for an event here.
	local bypass = IConfig.passthrough_pointer_events
	--print("bypass", bypass)

	local process = function(timestamp, code, value)
		local pass = false
		if code == rt then
			lscale = trigger_to_scale(value)
			update_scale()
		elseif code == lt then
			rscale = trigger_to_scale(value)
			update_scale()
		elseif code == touchX then
			x = abs_range(value)
			update_x(x, s)
		elseif code == touchY then
			y = abs_range(value)
			update_y(y, s)
		else
			pass = true
		end
		--print("pass", pass)
		if pass or bypass then
			--print("passthrough!")
			inner(timestamp, code, value)
		end
	end

	return {
		process_analog = process,
	}
end

