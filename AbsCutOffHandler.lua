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



	local ox, oy
	local update_x = function(x, s)
		local dx
		local nz = (x ~= 0)
		if ox and nz then
			dx = (x - ox) * s
			move(dx, 0)
		end
		--print("# shift X, old/new/delta:", ox, x, dx)
		ox = x
	end
	local update_y = function(y, s)
		local dy
		local nz = (y ~= 0)
		if oy and nz then
			dy = (y - oy) * s
			move(0, dy)
		end
		--print("# shift Y, old/new/delta:", oy, y, dy)
		oy = y
	end


	local touch_reset = function()
		ox = nil
		oy = nil
		--print("# liftoff\n\n\n\n\n\n\n\n\n")
	end

	return {
		update_x = update_x,
		update_y = update_y,
		reset = touch_reset,
	}
end
