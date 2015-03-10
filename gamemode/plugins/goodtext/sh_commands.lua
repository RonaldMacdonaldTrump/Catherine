local Plugin = Plugin

catherine.command.Register( {
	command = "textadd",
	syntax = "[Text] [Size]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			Plugin:AddText( pl, args[ 1 ], tonumber( args[ 2 ] ) )
			catherine.util.Notify( pl, "You are added text to that place!" )
		else
			catherine.util.Notify( pl, "args[ 1 ] is missing!" )
		end
	end
} )

catherine.command.Register( {
	command = "textremove",
	syntax = "[Distance]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( !args[ 1 ] ) then args[ 1 ] = 256 end
		local count = Plugin:RemoveText( pl:GetShootPos( ), args[ 1 ] )
		if ( count == 0 ) then
			catherine.util.Notify( pl, "No texts that place!" )
		else
			catherine.util.Notify( pl, "You are removed " .. count .. "'s texts!" )
		end
	end
} )