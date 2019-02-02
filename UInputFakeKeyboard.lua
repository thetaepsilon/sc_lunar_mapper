local c = require "evdev.constants"

local sync = c.EV_SYN
local report = c.SYN_REPORT
local flush = function(dev)
	dev:write(sync, report, 0)
end



local key = c.EV_KEY
return function(IUInputFactory, IKeymap)
	local fakeKeyboard = IUInputFactory()
	fakeKeyboard:useEvent(c.EV_KEY)

	-- no actual mapping performed here,
	-- this is just so key events can be declared to uinput.
	local declare_keys = IKeymap.keyboard
	for _, target_key in pairs(declare_keys) do
		fakeKeyboard:useKey(target_key)
	end
	for _, target_dpad in pairs(IKeymap.dpad) do
		fakeKeyboard:useKey(target_dpad[2])
		fakeKeyboard:useKey(target_dpad[3])
	end
	fakeKeyboard:init("uinput steam controller mapper keyboard")

	return {
		button = function(code, state)
			--print("FIRE", code, state)
			fakeKeyboard:write(key, code, state)
			flush(fakeKeyboard)
		end
	}
end

