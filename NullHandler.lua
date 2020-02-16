-- simple null handler satisfying IEventHandler to just eat events.
-- useful for sealing off the end of an event chain.

return {
	process_event = function(...) end,
}
