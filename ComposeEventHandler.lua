local c = require("evdev.constants")
local ev_analog = c.EV_ABS
local ev_button = c.EV_KEY

return function(IAnalogHandler, IButtonHandler)
	local analog = IAnalogHandler.process_analog
	local button = IButtonHandler.process_button	

	local process = function(time, type, code, value)
		if type == ev_analog then
			return analog(time, code, value)
		elseif type == ev_button then
			return button(time, code, value)
		else
			-- ???
		end
	end

	return {
		process_event = process
	}
end

