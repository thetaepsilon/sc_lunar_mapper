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
return function(IAbsCutOffHandler, IAnalogHandler)
	local update = IAbsCutOffHandler.update
	local lscale = 1.0
	local rscale = 1.0
	
	local inner = IAnalogHandler.process_analog

	-- handle X/Y syncing so they only get sent in pairs.
	local x, y
	local maybe_update = function()
		if x and y then
			local scale = strongerof(lscale, rscale)
			update(x, y, scale)
			x, y = nil, nil
		end
	end

	local process = function(timestamp, code, value)
		if code == rt then
			lscale = trigger_to_scale(value)
		elseif code == lt then
			rscale = trigger_to_scale(value)
		elseif code == touchX then
			x = abs_range(value)
			maybe_update()
		elseif code == touchY then
			y = abs_range(value)
			maybe_update()
		else
			inner(timestamp, code, value)
		end
	end

	return {
		process_analog = process,
	}
end
