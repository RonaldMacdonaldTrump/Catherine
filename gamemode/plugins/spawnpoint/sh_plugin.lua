local Plugin = Plugin

Plugin.name = "Spawnpoint"
Plugin.author = "L7D"
Plugin.desc = "Good stuff."

catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	command = "spawnpointadd",
	syntax = "[faction]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local factionTable = catherine.faction.FindByID( args[ 1 ] )
			if ( factionTable ) then
				local map = game.GetMap( )
				local faction = factionTable.uniqueID
				Plugin.Lists[ map ] = Plugin.Lists[ map ] or { }
				Plugin.Lists[ map ][ faction ] = Plugin.Lists[ map ][ faction ] or { }
				Plugin.Lists[ map ][ faction ][ #Plugin.Lists[ map ][ faction ] + 1 ] = pl:GetPos( )
				
				Plugin:SavePoints( )
				
				catherine.util.Notify( pl, "You added spawn point for " .. factionTable.name .. " faction!" )
			else
				catherine.util.Notify( pl, "Faction is a not valid!" )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

catherine.command.Register( {
	command = "spawnpointremove",
	syntax = "[rad]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local rad = math.max( tonumber( args[ 1 ] or "" ) or 140, 8 )
		local pos = pl:GetPos( )
		local i = 0

		for k, v in pairs( Plugin.Lists[ game.GetMap( ) ] ) do
			if ( v:Distance( pos ) <= rad ) then
				i = i + 1
				table.remove( Plugin.Lists[ game.GetMap( ) ], k )
			end
		end
		
		catherine.util.Notify( pl, "You removed " .. i .. "'s spawn points!" )
	end
} )