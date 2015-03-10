catherine.inventory = catherine.inventory or { }

if ( SERVER ) then
	function catherine.inventory.HasItem( pl, itemID )
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv or !itemID ) then return false end
		if ( inv[ itemID ] ) then
			return true
		else
			return false
		end
	end
	
	function catherine.inventory.GetInvHasItemCount( pl, itemID )
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv or !itemID ) then return 0 end
		if ( !inv[ itemID ] ) then return 0 end
		return inv[ itemID ].count
	end
	
	function catherine.inventory.Equiped( pl, itemID )
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv or !itemID ) then return false end
		if ( !inv[ itemID ] ) then return false end
		return inv[ itemID ][ "itemData" ].equiped
	end
	
	function catherine.inventory.GetInvLast( pl, itemID )
		local inv = catherine.inventory.GetInv( pl )
		
		if ( !inv or !itemID ) then return nil end
		if ( !inv[ itemID ] ) then return 1 end
		return #inv[ itemID ]
	end
	
	function catherine.inventory.GetInvItemDatas( pl, itemID )
		if ( !catherine.inventory.HasItem( pl, itemID ) ) then return { } end
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv[ itemID ][ "itemData" ] ) then return { } end
		return inv[ itemID ][ "itemData" ]
	end
	
	function catherine.inventory.GetInvItemDataByID( pl, itemID, id, def )
		local data = catherine.inventory.GetInvItemDatas( pl, itemID )
		if ( !data ) then return nil end
		return data[ id ] or def
	end
	
	function catherine.inventory.SetInvItemData( pl, itemID, id, val )
		if ( !catherine.inventory.HasItem( pl, itemID ) or val == nil ) then return end
		local inv = catherine.inventory.GetInv( pl )
		if ( !inv or !inv[ itemID ] or !inv[ itemID ][ "itemData" ] or inv[ itemID ][ "itemData" ][ id ] == nil ) then return end
		inv[ itemID ][ "itemData" ][ id ] = val
		
		catherine.character.SetGlobalData( pl, "_inv", inv )
	end

	function catherine.inventory.Update( pl, types, data )
		local inv = table.Copy( catherine.inventory.GetInv( pl ) )
		
		if ( types == "add" ) then
			if ( !data.uniqueID ) then return end
			if ( inv[ data.uniqueID ] ) then
				local newData = {
					uniqueID = inv[ data.uniqueID ].uniqueID,
					count = inv[ data.uniqueID ].count + 1,
					itemData = inv[ data.uniqueID ].itemData
				}
				inv[ data.uniqueID ] = newData
			else
				local newData = {
					uniqueID = data.uniqueID,
					count = 1,
					itemData = data.itemData
				}
				inv[ data.uniqueID ] = newData
			end
			catherine.character.SetGlobalData( pl, "_inv", inv )
		elseif ( types == "updateData" ) then
			if ( !data.uniqueID ) then return end
			if ( !inv[ data.uniqueID ] ) then return end
			
			local dataBuffer = { }
			dataBuffer = table.Copy( inv[ data.uniqueID ][ "itemData" ] )
			data.itemData = table.Merge( dataBuffer, data.itemData )
			inv[ data.uniqueID ][ "itemData" ] = data.itemData
			catherine.character.SetGlobalData( pl, "_inv", inv )
		elseif ( types == "remove" ) then
			if ( !data ) then return end
			if ( !inv[ data ] ) then return end
			
			inv[ data ].count = inv[ data ].count - 1
			if ( inv[ data ].count == 0 ) then
				inv[ data ] = nil
			end
			catherine.character.SetGlobalData( pl, "_inv", inv )
		end
	end

	function catherine.inventory.Init( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.character.SetGlobalData( pl, "_inv", { } )
	end
	
	function catherine.inventory.GetInvWeight( pl )
		local inv = catherine.character.GetGlobalData( pl, "_inv" )
		if ( !inv ) then return 0 end
		
		local weight = 0
		for k, v in pairs( inv ) do
			local itemTab = catherine.item.FindByID( k )
			if ( !itemTab ) then continue end
			
			weight = weight + ( ( itemTab.weight or 0 ) * v.count )
		end
		
		return weight
	end
	
	function catherine.inventory.GetInvMaxWeight( pl )
		local weight = catherine.configs.baseInventoryWeight
		
		for k, v in pairs( catherine.item.items ) do
			if ( v.isBag ) then
				local count = catherine.inventory.GetInvHasItemCount( pl, v.uniqueID )
				
				weight = weight + ( v.weightPlus * count )
			end
		end
		
		return weight
	end
else
	function catherine.inventory.GetInvHasItemCount( itemID )
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv or !itemID ) then return 0 end
		if ( !inv[ itemID ] ) then return 0 end
		return inv[ itemID ].count
	end
	
	function catherine.inventory.GetInvWeight( ) // need change.;
		local inv = catherine.character.GetGlobalData( LocalPlayer( ), "_inv" )
		if ( !inv ) then return 0 end
		
		local weight = 0
		for k, v in pairs( inv ) do
			local itemTab = catherine.item.FindByID( v.uniqueID )
			if ( !itemTab ) then continue end
			
			weight = weight + ( ( itemTab.weight or 0 ) * v.count )
		end
		return weight
	end

	function catherine.inventory.GetInvItemDatas( itemID )
		if ( !catherine.inventory.HasItem( itemID ) ) then return { } end
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv[ itemID ][ "itemData" ] ) then return { } end
		return inv[ itemID ][ "itemData" ]
	end
	
	function catherine.inventory.GetInvItemDataByID( pl, itemID, id, def )
		local data = catherine.inventory.GetInvItemDatas( itemID )
		return data[ id ] or def
	end
	
	function catherine.inventory.GetInvMaxWeight( )
		local weight = catherine.configs.baseInventoryWeight
		
		for k, v in pairs( catherine.item.items ) do
			if ( v.isBag ) then
				local count = catherine.inventory.GetInvHasItemCount( v.uniqueID )
				
				weight = weight + ( v.weightPlus * count )
			end
		end
		
		return weight
	end
	
	function catherine.inventory.HasItem( itemID )
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv or !itemID ) then return false end
		if ( inv[ itemID ] ) then
			return true
		else
			return false
		end
	end

	function catherine.inventory.Equiped( itemID )
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv or !itemID ) then return false end
		local key = catherine.inventory.GetInvLast( itemID )
		if ( !inv[ itemID ] ) then return false end
		if ( inv[ itemID ][ "itemData" ].equiped ) then
			return true
		else
			return false
		end
	end
	
	function catherine.inventory.GetItemCount( itemID )
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv or !itemID ) then return 0 end
		if ( !inv[ itemID ] ) then return 0 end
		return inv[ itemID ].count or 0
	end
	
	function catherine.inventory.GetInvLast( itemID )
		local inv = catherine.inventory.GetInv( LocalPlayer( ) )
		if ( !inv or !itemID ) then return nil end
		if ( !inv[ itemID ] ) then return 1 end
		return #inv[ itemID ]
	end
end

function catherine.inventory.GetInv( pl )
	return catherine.character.GetGlobalData( pl, "_inv", nil )
end