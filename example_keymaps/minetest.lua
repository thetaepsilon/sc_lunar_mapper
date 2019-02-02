return function(c)
	local results = {}
	local map = function(src, target)
		results[src] = target
	end

	local next = c.KEY_N
	local prev = c.KEY_B
	map(c.BTN_DPAD_LEFT, prev)
	map(c.BTN_DPAD_RIGHT, next)
	map(c.BTN_DPAD_UP, next)
	map(c.BTN_DPAD_DOWN, prev)
	-- Y key... why is it west. why.
	map(c.BTN_WEST, prev)
	map(c.BTN_B, next)
	map(c.BTN_GEAR_DOWN, c.KEY_LEFTSHIFT)
	map(c.BTN_GEAR_UP, c.KEY_SPACE)
	map(c.BTN_THUMBL, c.KEY_R)
	map(c.BTN_SELECT, c.KEY_ESC)
	map(c.BTN_START, c.KEY_E)
	map(c.BTN_TR, c.KEY_Z)
	map(c.BTN_TL, c.KEY_LEFTCTRL)
	map(c.BTN_MODE, c.KEY_F12)
	-- again, weird directions
	map(c.BTN_NORTH, c.KEY_F7)
	map(c.BTN_GAMEPAD, c.KEY_F5)


	local mousekeys = {}
	local mouse = function(src, target)
		mousekeys[src] = target
	end
	mouse(c.BTN_TL2, c.BTN_0)
	mouse(c.BTN_TR2, c.BTN_2)

	local joystick_threshold = 8000
	local dpad = {
		-- why tf is Y axis inverted in hardware!?
		[c.ABS_Y] = { joystick_threshold, c.KEY_S, c.KEY_W },
		[c.ABS_X] = { joystick_threshold, c.KEY_D, c.KEY_A },
	}


	return {
		keyboard = results,
		mouse = mousekeys,
		dpad = dpad,
	}
end
