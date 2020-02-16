-- A "paddle" style input that splits a single ABS axis in half, intended for use with (single) touch inputs.
-- Each half controls a single key on a virtual keyboard.
-- Input values below the threshold trigger one keypress while it is held there,
-- and another while it is held above it.
-- Transitioning to the other half or "releasing" the touch will release the associated key
-- (and trigger the opposite key in the former case).
-- releasing can either be done by detecting a button depress,
-- *or* with an explicit function call if detecting that event needs to come from somewhere else.
-- this handler takes a delegate handler that is called when neither the input axis or cancel button
-- (if appropriate, see "cancel" attribute below) with any events that don't apply to it.

--[[
-- Input configuration from keymap:
-- unlike some of the other components previously written,
-- this component requires it's config entries directly at the top level of the table it is given.
-- This is to more easily allow for multiple instances if required.
-- default values are shown in the example below for each table key-value pair,
-- which are taken when that kv pair isn't set (i.e. nil).
-- entries with ??? are required and cause an error if not set.

config = {
	axis = ABS_X,	-- the ABS axis to divide into two regions
	center = 0,	-- the middle point that marks the boundary.
			-- this may need setting positive for e.g. touchpads
	key_down = ???,
	key_up = ???,
			-- the key events to send for below and above the center point
	cancel = BTN_TOUCH,
			-- the input key event that signals release of the paddle.
			-- if this is explicitly set to false, no key will be intercepted by this handler,
			-- and cancelling will have to be performed explicitly with cancel() below.
	cancel_passthrough = false,
			-- if this value is truth-y, cancel button events will always be passed through,
			-- disregarding the logic discussed above.
			-- this may be useful for configuring multiple "paddles" in a chain.
}
]]
local C = require("evdev.constants")
local abs = C.EV_ABS
local key = C.EV_KEY
local touch = C.BTN_TOUCH
local defaxis = C.ABS_X


local n = function(v)
	assert(type(v) == "number")
end

return function(config, IFakeKeyboard, IEventHandler)
	local delegate = assert(IEventHandler.process_event)
	local button = assert(IFakeKeyboard.button)

	local axis = config.axis or defaxis
	local center = config.center or 0
	local k_up = config.key_up
	local k_down = config.key_down
	local k_cancel = config.cancel or touch
	local passthrough = config.cancel_passthrough and true or false
	
	n(axis)
	n(center)
	n(k_up)
	n(k_down)
	n(k_cancel)
	-- passthrough already coerced above

	-- the last seen state of the paddle after classifying it into which half it's in.
	-- true is the higher half, false the lower, and nil means not currently being actuated.
	-- when this value changes, it may potentially release an old keypress and activate a new one.
	local state = nil

	-- internal private functions
	local release_old = function()
		if state == true then
			button(k_up, 0)
		elseif state == false then
			button(k_down, 0)
		end
		-- nil: not previously pressed, so no key to release
	end
	local press_new = function()
		-- NB: this is called /after/ updating state, obviously.
		-- but only on changes, so we can assume there is something to do.
		if state == true then
			button(k_up, 1)
		elseif state == false then
			button(k_down, 1)
		end
		-- nil: paddle is being released, so no new key to send.
	end

	local update_state = function(st)
		if st ~= state then
			-- paddle changed, update keys
			release_old()
			state = st
			press_new()
		end
	end

	local classify_paddle = function(axis_value)
		-- NB: this doesn't return nil; that's the job of cancellation
		return axis_value >= center
	end


	-- public functions
	local cancel = function()
		-- explicit cancel, also called when the cancel button is released.
		update_state(nil)
	end



	local process = function(timestamp, eventType, eventCode, value)
		local resend = true

		if eventType == key then
			-- handle cancel key if it's that, but we may still have to forward it.
			local isCancel = (eventCode == k_cancel)
			if isCancel and (value == 0) then
				-- we only case about value == 0,
				-- because we'll get axis updates when touch is down anyway.
				cancel()
			end
			-- not a key we care about? let it pass.
			-- also let it pass in any case if passthrough is enabled.
			resend = (not isCancel) or passthrough
		elseif (eventType == abs) and (eventCode == axis) then
			resend = false
			local newstate = classify_paddle(value)
			update_state(newstate)
		end

		if resend then
			delegate(timestamp, eventType, eventCode, value)
		end
	end

	return {
		process_event = process,
		cancel = cancel,
	}
end





