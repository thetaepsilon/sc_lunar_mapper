local c = require "evdev.constants"
local touchpad = c.BTN_THUMB2

return function(IAbsCutOffHandler, inner_IButtonHandler)
	local reset = IAbsCutOffHandler.reset
	local inner = inner_IButtonHandler.process_button

	local process = function(time, code, value)
		if code == touchpad then
			-- chomp the on event for this "button",
			-- as ABS events start getting delivered earlier anyway.
			if value == 0 then
				reset()
			end
		else
			-- defer to normal handling
			return inner(time, code, value)
		end
	end

	return {
		process_button = process,
	}
end
