return function(c)
	local results = {}
	local map = function(src, target)
		results[src] = target
	end



	map(c.BTN_GEAR_DOWN, c.KEY_LEFTSHIFT)
	map(c.BTN_GEAR_UP, c.KEY_SPACE)

	map(c.BTN_SELECT, c.KEY_ESC)
	map(c.BTN_START, c.KEY_ENTER)


	local mousekeys = {}
	local mouse = function(src, target)
		mousekeys[src] = target
	end
	mouse(c.BTN_TL, c.BTN_0)
	mouse(c.BTN_TR, c.BTN_2)

	local joystick_threshold = 8000
	local trigger_threshold = 50

	local dpad = {
		-- why tf is Y axis inverted in hardware!?
		[c.ABS_Y] = { joystick_threshold, c.KEY_DOWN, c.KEY_UP },
		[c.ABS_X] = { joystick_threshold, c.KEY_RIGHT, c.KEY_LEFT },
		[c.ABS_HAT2Y] = { trigger_threshold, c.KEY_LEFT, c.KEY_LEFT },
		[c.ABS_HAT2X] = { trigger_threshold, c.KEY_RIGHT, c.KEY_RIGHT },
	}


	return {
		keyboard = results,
		mouse = mousekeys,
		dpad = dpad,
		config = {
			passthrough_pointer_events = true,
		},
	}
end
