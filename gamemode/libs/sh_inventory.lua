catherine.inventory = catherine.inventory or { }

if ( SERVER ) then
	function catherine.inventory.GetInv( pl )
		return catherine.character.GetGlobalData( pl, "_inv" )
	end

	function catherine.inventory.HasItem( pl, itemID )
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv or !itemID ) then return false end
		if ( inv[ itemID ] ) then
			return true
		else
			return false
		end
	end
	
	function catherine.inventory.Update( pl, types, data )
		local inv = table.Copy( catherine.inventory.GetInv( pl ) )
		
		if ( types == "add" ) then
			if ( !data.uniqueID ) then return end
			if ( !inv[ data.uniqueID ] ) then inv[ data.uniqueID ] = { } end
			
			inv[ data.uniqueID ][ #inv[ data.uniqueID ] + 1 ] = data
			catherine.character.SetGlobalData( pl, "_inv", inv )
		elseif ( types == "updateData" ) then
			if ( !data.uniqueID or !data.key ) then return end
			if ( !inv[ data.uniqueID ] ) then return end
			if ( !inv[ data.uniqueID ][ data.key ] ) then return end
			
			local dataBuffer = { }
			dataBuffer = table.Copy( inv[ data.uniqueID ][ data.key ][ "itemData" ] )
			data.newData = table.Merge( dataBuffer, data.newData )
			inv[ data.uniqueID ][ data.key ][ "itemData" ] = data.newData
			catherine.character.SetGlobalData( pl, "_inv", inv )
		elseif ( types == "remove" ) then
			if ( !data ) then return end
			if ( !inv[ data ] ) then return end
			
			table.remove( inv[ data ], #inv[ data ] )
			catherine.character.SetGlobalData( pl, "_inv", inv )
		end
	end
	
	//catherine.inventory.Update( player.GetByID( 1 ), "updateData", { uniqueID = "weapon_pistol", key = 1, newData = { equiped = true } } )

	//catherine.item.GiveToCharacter( player.GetByID( 1 ), "weapon_pistol" )
	//catherine.inventory.Init( player.GetByID( 1 ) )
	//PrintTable(catherine.inventory.GetInv( player.GetByID( 1 )))

	function catherine.inventory.Init( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.character.SetGlobalData( pl, "_inv", { } )
	end
	
	function catherine.inventory.GetInvWeight( pl )
		local inv = catherine.character.GetGlobalData( pl, "_inv" )
		if ( !inv ) then return 0 end
		
		local weight = 0
		for k, v in pairs( inv ) do
			for k1, v1 in pairs( v ) do
				local itemTab = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTab ) then continue end
				
				weight = weight + ( itemTab.weight or 0 )
			end
		end
		
		return weight
	end
	
	//print(catherine.inventory.GetInvWeight( player.GetByID(1) ))
	
else
	function catherine.inventory.GetInvWeight( ) // need change.;
		local inv = catherine.character.GetGlobalData( LocalPlayer( ), "_inv" )
		if ( !inv ) then return 0 end
		
		local weight = 0
		for k, v in pairs( inv ) do
			for k1, v1 in pairs( v ) do
				local itemTab = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTab ) then continue end
				
				weight = weight + ( itemTab.weight or 0 )
			end
		end
		return weight
	end
end