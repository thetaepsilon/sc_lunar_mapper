-- the steam controller only reports EV_ABS events for the touchpads.
-- in order to properly turn thumb movements into relative motion,
-- the delta between events needs to be tracked,
-- but *also* some information about when the pad is let go is required.
-- this information is delivered as a button-off event;
-- when that occurs, the previous position is forgotten about,
-- so when the user next touches the pad the camera doesn't yank back to center.

return function(IFakePointer)
	local ox, oy
	local move = IFakePointer.move_pointer

	-- note, 0-1 ish float coordinates,
	-- whereas evdev reports integers -
	-- it is expected the IAnalogHandler will perform appropriate scaling,
	-- as well as syncing delivery of the X and Y values
	-- (as they're typically separate events,
	-- but the SC sends no EV_SYN events for touchpad axes).
	-- scale should be set to 1.0 if unused,
	-- it allows easily scaling the pointer deltas at the point of calculation.
	local update_abs = function(x, y, s)
		local nz = ((x ~= 0) and (y ~= 0))

		-- just ignore zero samples, they just cause problems.
		-- also skip if we have no previous coordinates.
		if ox and nz then
			-- ^ it's very rare that zero is actually reported.
			-- just ignore them as the touch_reset will follow.
			local dx = (x - ox) * s
			local dy = (y - oy) * s
			move(dx, dy)
		end
		
		ox, oy = x, y
	end

	local touch_reset = function()
		ox = nil
		oy = nil
	end

	return {
		update = update_abs,
		reset = touch_reset,
	}
end
