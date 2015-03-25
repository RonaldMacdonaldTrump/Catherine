catherine.hooks = catherine.hooks or { }

function catherine.hooks.Register( hookID, uniqueID, func )
	hook.Add( hookID, uniqueID, function( ... )
		func( ... )
	end )
end

function catherine.hooks.Run( hookID, ... )
	hook.Run( hookID, ... )
end