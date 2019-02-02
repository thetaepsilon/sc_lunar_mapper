local evdev = require "evdev"
local uinput = os.getenv("LUA_UINPUT_DEVICE_PATH") or "/dev/uinput"
local construct = evdev.Uinput

-- constructor for DI purposes
return function()

	-- the actual factory method
	return function()
		return construct(uinput)
	end
end

