return function(c)
	local results = {}
	local map = function(src, target)
		results[src] = target
	end

	-- I should probably use some constants for the SC buttons;
	-- like WEST below (which is the Y key... y tho!?) could be sc.Y etc.
	-- though then you'd probably want ones for future other controllers too...
	map(c.BTN_WEST, c.KEY_C)

	map(c.BTN_SELECT, c.KEY_ESC)
	map(c.BTN_START, c.KEY_TAB)
	
	map(c.BTN_B, c.KEY_BACKSPACE)
	map(c.BTN_GAMEPAD, c.KEY_ENTER)
	map(c.BTN_GEAR_DOWN, c.KEY_LEFTSHIFT)


	local mousekeys = {}
	local mouse = function(src, target)
		mousekeys[src] = target
	end
	mouse(c.BTN_TL2, c.BTN_0)
	mouse(c.BTN_TR2, c.BTN_2)

	local joystick_threshold = 4000
	local dpad = {
		[c.ABS_Y] = { joystick_threshold, c.KEY_DOWN, c.KEY_UP },
		[c.ABS_X] = { joystick_threshold, c.KEY_RIGHT, c.KEY_LEFT },
	}


	return {
		keyboard = results,
		mouse = mousekeys,
		dpad = dpad,
	}
end
