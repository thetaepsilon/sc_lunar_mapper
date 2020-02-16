return function(c)
	local results = {}
	local map = function(src, target)
		results[src] = target
	end

	-- Y key... why is it west. why.
	map(c.BTN_WEST, c.KEY_SEMICOLON)
	map(c.BTN_B, c.KEY_L)
	--map(c.BTN_TL2, c.KEY_LEFTSHIFT)
	--map(c.BTN_GEAR_UP, c.KEY_SPACE)
	--map(c.BTN_THUMBL, c.KEY_R)
	map(c.BTN_SELECT, c.KEY_ESC)
	map(c.BTN_START, c.KEY_ENTER)
	--map(c.BTN_TR, c.KEY_R)
	--map(c.BTN_THUMBR, c.KEY_Z)
	--map(c.BTN_TL, c.KEY_LEFTCTRL)
	map(c.BTN_MODE, c.KEY_F12)
	-- again, weird directions
	map(c.BTN_NORTH, c.KEY_K)
	map(c.BTN_GAMEPAD, c.KEY_J)


	local mousekeys = {}
	local mouse = function(src, target)
		mousekeys[src] = target
	end
	mouse(c.BTN_TL2, c.BTN_0)
	mouse(c.BTN_TR2, c.BTN_2)

	local joystick_threshold = 9000
	local ltouch_threshold = 10000
	local dpad = {
		-- why tf is Y axis inverted in hardware!?
		[c.ABS_Y] = { joystick_threshold, c.KEY_S, c.KEY_W },
		[c.ABS_X] = { joystick_threshold, c.KEY_D, c.KEY_A },
		--[c.ABS_HAT0Y] = { ltouch_threshold, c.KEY_S, c.KEY_W },
		--[c.ABS_HAT0X] = { ltouch_threshold, c.KEY_D, c.KEY_A },
		[c.ABS_HAT2Y] = { 20, c.KEY_LEFTSHIFT, c.KEY_LEFTSHIFT },
		[c.ABS_HAT2X] = { 20, c.KEY_3, c.KEY_3 },		
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
