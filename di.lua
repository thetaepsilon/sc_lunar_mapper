-- construct objects and their dependencies.
-- TODO in future is to see if this can be auto-generated from the lua files;
-- e.g. "if di then di.needs_deps(...) ... return di.done end"

return function(loader)
	-- XXX - if we ever added lifetimes,
	-- we'd want to "pin" the constructor returned by a module file,
	-- then call it as needed, instead of re-loading every invocation.
	-- here it's fine because this is just one-off at init time.

	local IUInputFactory = loader("UInputFactory")()

	-- the fake keyboard needs the keymap early on.
	-- this is so it can correctly declare the keys it will send beforehand.
	local IKeymap = loader("Keymap")()

	local IFakePointer = loader("UInputFakePointer")(IUInputFactory)
	local IFakeKeyboard = 
		loader("UInputFakeKeyboard")(IUInputFactory, IKeymap)


	-- "Abs cut-off" is referring to the fact that on it's own,
	-- the analog data from the touchpad isn't enough to know when to reset events;
	-- a "button" event created the touchpad is also required.
	-- time-outs don't work if the user holds their thumb still for a while.
	local IAbsCutOffHandler = loader("AbsCutOffHandler")(IFakePointer)

	local __analogHandler =
		loader("MapToDPadAnalogHandler")(IFakeKeyboard, IKeymap)
	local IAnalogHandler =
		loader("TouchpadWithFocusAnalogHandler")(IAbsCutOffHandler, __analogHandler)

	-- chain of responsibility pattern -
	-- map to keys to handle buttons the touchpad emulation doesn't need.
	-- well, not quite that pattern, as KeyMapButtonHandler doesn't chain again.
	local __buttonHandler =
		loader("KeymapButtonHandler")(IFakeKeyboard, IFakePointer, IKeymap)
	local IButtonHandler =
		loader("AbsCutOffButtonHandler")(IAbsCutOffHandler, __buttonHandler)

	local IEventHandler =
		loader("ComposeEventHandler")(IAnalogHandler, IButtonHandler)

	return IEventHandler
end
