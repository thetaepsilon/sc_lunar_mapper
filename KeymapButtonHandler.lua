

return function(IFakeKeyboard, IFakePointer, IKeymap)
	local keys = IKeymap.keyboard
	local mouse = IKeymap.mouse

	local press_keyboard = IFakeKeyboard.button
	local press_mouse = IFakePointer.button

	local process = function(time, code, value)
		local k = keys[code]
		if k then
			press_keyboard(k, value)
		else
			-- try to see if there's a mouse button?
			k = mouse[code]
			if k then
				press_mouse(k, value)
			else
				-- unhandled ??
			end
		end
	end

	return {
		process_button = process,
	}
end
