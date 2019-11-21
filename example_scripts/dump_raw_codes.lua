-- debug script that just dumps the raw values it recieves.
return function(loader)
	local process_event = function(...)
		print(...)
	end

	return {
		process_event = process_event,
	}
end
