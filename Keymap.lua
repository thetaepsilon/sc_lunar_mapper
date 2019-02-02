-- as keymaps can differ on a per-game basis,
-- here we take care of reading them from a file specified in the environment.
-- ultimately the key map is just a table,
-- where the keys are source keycodes and the values are targets.

-- TODO: make this a profile selectable thing instead,
-- with a default containing directory in $HOME, e.g. ~/.config/sc_maps?
-- so then SC_KEYMAP_PROFILE=mygame would resolve to:
-- ~/.config/sc_maps/mygame.lua

local c = require "evdev.constants"

local env = "SC_KEYMAP_PATH"
local msg = "path to keymap file was not specified, " .. 
	"please set environment variable " .. env

return function()
	local path = os.getenv(env)
	if not path then
		error(msg)
	end

	return dofile(path)(c)
end

