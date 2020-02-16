return function(c)
	return {
		paddle = {
			key_up = c.KEY_RIGHT,
			key_down = c.KEY_LEFT,
			center = 750,
		},
		-- XXX: still needed so that fake keyboard can reserve keys.
		-- otherwise keys we don't declare to uinput get ignored.
		keyboard = { c.KEY_RIGHT, c.KEY_LEFT },
	}
end
