
local ternary_compare = function(value, upper, lower)
	if (value > upper) then
		return true
	elseif (value < lower) then 
		return false
	else
		return nil
	end
end

local create_updater = function(IFakeKeyboard)
	local button = IFakeKeyboard.button

	-- I'm really tripping on this logic here... no idea how to simplify
	local match_state = function(s, code, oldstate, newstate)
		if ((oldstate ~= s) and (newstate == s)) then
			--print("button ON: "..code)
			return button(code, 1)
		end
		if ((oldstate == s) and (newstate ~= s)) then
			--print("button OFF: "..code)
			return button(code, 0)
		end
	end

	return function(mapping, oldstate, newstate)
		local key_up = mapping[2]
		local key_down = mapping[3]

		match_state(true, key_up, oldstate, newstate)
		match_state(false, key_down, oldstate, newstate)
	end
end



return function(IFakeKeyboard, IKeymap)
	local map = IKeymap.dpad
	local change_buttons = create_updater(IFakeKeyboard)

	local state_cache = {}



	local process = function(time, code, value)
		local mapping = map[code]
		if not mapping then
			--print("analog ???", code)
			return
		end
		-- defaults to nil, not pressed before, which is fine
		local oldstate = state_cache[code]

		local threshold = mapping[1]
		local newstate = ternary_compare(value, threshold, -threshold)
		change_buttons(mapping, oldstate, newstate)
		state_cache[code] = newstate
	end

	return {
		process_analog = process,
	}
end
