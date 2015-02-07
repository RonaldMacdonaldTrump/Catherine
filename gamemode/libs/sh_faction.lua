catherine.faction = catherine.faction or { }
catherine.faction.Lists = { }

function catherine.faction.GetAll( )
	return catherine.faction.Lists
end

function catherine.faction.Register( tab )
	catherine.faction.Lists[ #catherine.faction.Lists + 1 ] = tab
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

function catherine.faction.Load( dir )
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
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( pl, "whitelists", { } ) )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return end
		whiteLists[ #whiteLists + 1 ] = id
		catherine.catherine_data.SetcatherineData( pl, "whitelists", whiteLists, false, true )
	end
	
	function catherine.faction.RemoveWhiteList( pl, id )
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( pl, "whitelists", { } ) )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return end
		for k, v in pairs( whiteLists ) do
			if ( v == id ) then
				table.remove( whiteLists, k )
				continue
			end
		end
		catherine.catherine_data.SetcatherineData( pl, "whitelists", whiteLists, false, true )
	end
	
	function catherine.faction.HasWhiteList( pl, id )
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( pl, "whitelists", { } ) )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return false end
		for k, v in pairs( whiteLists ) do
			if ( v == id ) then
				return true
			end
		end
		
		return false
	end
else
	function catherine.faction.HasWhiteList( id )
		local whiteLists = table.Copy( catherine.catherine_data.GetcatherineData( "whitelists", { } ) )
		local factionData = catherine.faction.FindByID( id )
		if ( !factionData ) then return false end
		for k, v in pairs( whiteLists ) do
			if ( v == id ) then
				return true
			end
		end
		
		return false
	end
end



catherine.faction.Load( catherine.FolderName .. "/gamemode" )

