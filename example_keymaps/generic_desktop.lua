return function(c)
	local results = {}
	local map = function(src, target)
		results[src] = target
	end

	--map(c.BTN_DPAD_LEFT, prev)
	--map(c.BTN_DPAD_RIGHT, next)
	--map(c.BTN_DPAD_UP, next)
	--map(c.BTN_DPAD_DOWN, prev)
	-- Y key... why is it west. why.
	--map(c.BTN_WEST, prev)
	map(c.BTN_B, c.KEY_ESC)
	--map(c.BTN_GEAR_DOWN, c.KEY_LEFTSHIFT)
	--map(c.BTN_GEAR_UP, c.KEY_SPACE)
	--map(c.BTN_THUMBL, c.KEY_R)
	map(c.BTN_START, c.KEY_ENTER)
	map(c.BTN_SELECT, c.KEY_ESC)
	map(c.BTN_MODE, c.KEY_F12)
	map(c.BTN_TL, c.KEY_LEFTMETA)

	--map(c.BTN_NORTH, c.KEY_F7)
	map(c.BTN_GAMEPAD, c.KEY_ENTER)


	local mousekeys = {}
	local mouse = function(src, target)
		mousekeys[src] = target
	end
	mouse(c.BTN_TL2, c.BTN_0)
	mouse(c.BTN_TR2, c.BTN_2)
	mouse(c.BTN_TR, c.BTN_1)

	local joystick_threshold = 4000
	local ltouch_threshold = 10000
	local dpad = {
		-- why tf is Y axis inverted in hardware!?
		[c.ABS_Y] = { joystick_threshold, c.KEY_DOWN, c.KEY_UP },
		[c.ABS_X] = { joystick_threshold, c.KEY_RIGHT, c.KEY_LEFT },
		--[c.ABS_HAT0Y] = { ltouch_threshold, c.KEY_DOWN, c.KEY_UP },
		--[c.ABS_HAT0X] = { ltouch_threshold, c.KEY_RIGHT, c.KEY_LEFT },
	}


	return {
		keyboard = results,
		mouse = mousekeys,
		dpad = dpad,
	}
end
