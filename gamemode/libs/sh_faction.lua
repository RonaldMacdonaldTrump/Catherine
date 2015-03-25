catherine.faction = catherine.faction or { }
catherine.faction.Lists = catherine.faction.Lists or { }

function catherine.faction.Register( factionTable )
	if ( !factionTable or !factionTable.index ) then
		catherine.util.ErrorPrint( "Faction register error, can't found faction table!" )
		return
	end
	catherine.faction.Lists[ factionTable.index ] = factionTable
	return factionTable.index
end

function catherine.faction.Create( uniqueID )
	return { uniqueID = uniqueID, index = table.Count( catherine.faction.Lists ) + 1 }
end

function catherine.faction.GetPlayerUsableFaction( pl )
	if ( !IsValid( pl ) ) then return { } end
	local factions = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and catherine.faction.HasWhiteList( self, id ) == false ) then continue end
		factions[ #factions + 1 ] = v
	end
	
	return factions
end

function catherine.faction.GetAll( )
	return catherine.faction.Lists
end

function catherine.faction.FindByName( name )
	if ( !name ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.name == name ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByIndex( index )
	if ( !index ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.index == index ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.Include( dir )
	local files = file.Find( dir .. "/factions/*", "LUA" )
	for k, v in pairs( files ) do
		local uniqueID = catherine.util.GetUniqueName( v )
		Faction = catherine.faction.Lists[ uniqueID ] or { uniqueID = uniqueID, index = table.Count( catherine.faction.Lists[ uniqueID ] ) + 1 }
		catherine.util.Include( dir .. "/factions/" .. v, "SHARED" )
		catherine.faction.Register( Faction )
		Faction = nil
	end
end

catherine.faction.Include( catherine.FolderName .. "/gamemode" )

if ( SERVER ) then
	function catherine.faction.AddWhiteList( pl, id )
		if ( !IsValid( pl ) or !id ) then return false, "player or faction id is not valid!" end
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or ( factionData and !factionData.isWhitelist ) or catherine.faction.HasWhiteList( pl, id ) ) then return false, "faction is not whitelist or player already has whitelist!" end
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		whiteLists[ #whiteLists + 1 ] = id
		catherine.catData.Set( pl, "whitelists", whiteLists, false, true )
		return true
	end
	
	function catherine.faction.RemoveWhiteList( pl, id )
		if ( !IsValid( pl ) or !id ) then return false, "player or faction id is not valid!" end
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or ( factionData and !factionData.isWhitelist ) ) then return false, "faction is not whitelist!" end
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		table.RemoveByValue( whiteLists, id )
		catherine.catData.Set( pl, "whitelists", whiteLists, false, true )
		return true
	end

	function catherine.faction.HasWhiteList( pl, id )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or !factionData.isWhitelist ) then return false end
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		return table.HasValue( whiteLists, id )
	end
else
	function catherine.faction.HasWhiteList( id )
		if ( !id ) then return false end
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or !factionData.isWhitelist ) then return false end
		local whiteLists = catherine.catData.Get( "whitelists", { } )
		return table.HasValue( whiteLists, id )
	end
end

local META = FindMetaTable( "Player" )

function META:HasWhiteList( id )
	if ( SERVER ) then
		return catherine.faction.HasWhiteList( self, id )
	else
		return catherine.faction.HasWhiteList( id )
	end
end

catherine.command.Register( {
	command = "plygivewhitelist",
	syntax = "[name] [faction unique name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, reason = catherine.faction.AddWhiteList( pl, args[ 2 ] )
					if ( success ) then
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "Faction_AddMessage01" ) )
					else
						catherine.util.Notify( pl, reason or catherine.language.GetValue( pl, "UnknownError" ) )
					end
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

catherine.command.Register( {
	command = "plytakewhitelist",
	syntax = "[name] [faction unique name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, reason = catherine.faction.RemoveWhiteList( pl, args[ 2 ] )
					if ( success ) then
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "Faction_RemoveMessage01" ) )
					else
						catherine.util.Notify( pl, reason or catherine.language.GetValue( pl, "UnknownError" ) )
					end
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )