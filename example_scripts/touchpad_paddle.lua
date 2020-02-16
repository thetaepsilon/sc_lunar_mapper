return function(loader, constants)

	local IUInputFactory = loader("UInputFactory")()

	local IKeymap = loader("Keymap")()

	local IFakeKeyboard = 
		loader("UInputFakeKeyboard")(IUInputFactory, IKeymap)

	local null = loader("NullHandler")
	local IEventHandler = loader("AbsPaddle")(IKeymap.paddle, IFakeKeyboard, null)

	return IEventHandler
end
