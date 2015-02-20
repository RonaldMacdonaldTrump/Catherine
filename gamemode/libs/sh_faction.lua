catherine.faction = catherine.faction or { }
catherine.faction.Lists = { }
local META = FindMetaTable( "Player" )

function catherine.faction.GetAll( )
	return catherine.faction.Lists
end

function catherine.faction.Register( tab )
	tab.index = tab.index or #catherine.faction.Lists + 1
	catherine.faction.Lists[ tab.index ] = tab
	team.SetUp( tab.index, tab.name, tab.color )
end

function catherine.faction.FindByName( name )
	if ( !name ) then return nil end
	for k, v in pairs( catherine.faction.Lists ) do
		if ( v.name == name ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.faction.Lists ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByIndex( index )
	if ( !index ) then return nil end
	for k, v in pairs( catherine.faction.Lists ) do
		if ( v.index == index ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.Include( dir )
	local files = file.Find( dir .. "/factions/*", "LUA" )
	for k, v in pairs( files ) do
		Faction = { }
		Faction.uniqueID = string.sub( v, 4, -5 )
		catherine.util.Include( dir .. "/factions/" .. v )
		catherine.faction.Register( Faction )
		Faction = nil
	end
end

if ( SERVER ) then
	function catherine.faction.AddWhiteList( pl, id )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or ( factionData and !factionData.isWhitelist ) ) then return end
		if ( catherine.faction.HasWhiteList( pl, id ) ) then return end
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( pl, "whitelists", { } ) )
		whiteLists[ #whiteLists + 1 ] = id
		catherine.catherine_data.SetcatherineData( pl, "whitelists", whiteLists, false, true )
	end
	

	function catherine.faction.RemoveWhiteList( pl, id )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData or ( factionData and !factionData.isWhitelist ) ) then return end
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( pl, "whitelists", { } ) )
		for k, v in pairs( whiteLists ) do
			if ( v == id ) then
				table.remove( whiteLists, k )
			end
		end
		catherine.catherine_data.SetcatherineData( pl, "whitelists", whiteLists, false, true )
	end
	
	function META:AddWhiteList( id )
		catherine.faction.AddWhiteList( self, id )
	end
	
	function META:RemoveWhiteList( id )
		catherine.faction.RemoveWhiteList( self, id )
	end
	
	concommand.Add( "addwhitelist", function( pl, cmd, args )
		catherine.faction.AddWhiteList( pl, args[ 1 ] )
	end )
	
	concommand.Add( "removewhitelist", function( pl, cmd, args )
		catherine.faction.RemoveWhiteList( pl, args[ 1 ] )
	end )
	
	
	function catherine.faction.HasWhiteList( pl, id )
		local whiteLists = catherine.catherine_data.GetcatherineData( pl, "whitelists", { } )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return false end
		if ( !factionData.isWhitelist ) then return true end
		return table.HasValue( whiteLists, id )
	end
	
	function META:HasWhiteList( id )
		return catherine.faction.HasWhiteList( self, id )
	end
else
	function catherine.faction.HasWhiteList( id )
		local whiteLists = catherine.catherine_data.GetcatherineData( "whitelists", { } )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return false end
		if ( !factionData.isWhitelist ) then return true end
		return table.HasValue( whiteLists, id )
	end

	function META:HasWhiteList( id )
		return catherine.faction.HasWhiteList( id )
	end
end

catherine.faction.Include( catherine.FolderName .. "/gamemode" )