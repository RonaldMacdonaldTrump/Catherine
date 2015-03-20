catherine.inventory = catherine.inventory or { }
local META = FindMetaTable( "Player" )

if ( SERVER ) then
	CAT_INV_ACTION_ADD = 1
	CAT_INV_ACTION_REMOVE = 2
	CAT_INV_ACTION_UPDATE = 3
	
	function catherine.inventory.Work( pl, workID, data )
		if ( !IsValid( pl ) or !workID or !data ) then return end
		if ( workID == CAT_INV_ACTION_ADD ) then
			local inventory = catherine.inventory.Get( pl )
			local uniqueID = data.uniqueID
			local int = math.max( data.int or 1, 1 ) or 1
			if ( catherine.inventory.HasItem( pl, uniqueID ) ) then
				inventory[ uniqueID ] = {
					uniqueID = inventory[ uniqueID ].uniqueID,
					int = inventory[ uniqueID ].int + int,
					itemData = inventory[ uniqueID ].itemData
				}
				catherine.character.SetGlobalVar( pl, "_inv", inventory )
			else
				inventory[ uniqueID ] = {
					uniqueID = uniqueID,
					int = int,
					itemData = data.itemData
				}
				catherine.character.SetGlobalVar( pl, "_inv", inventory )
			end
		elseif ( workID == CAT_INV_ACTION_REMOVE ) then
			if ( !catherine.inventory.HasItem( pl, data ) ) then return end
			local inventory = catherine.inventory.Get( pl )
			local int = math.max( inventory[ data ].int - 1, 0 )
			if ( int != 0 ) then
				inventory[ data ] = {
					uniqueID = inventory[ data ].uniqueID,
					int = int,
					itemData = inventory[ data ].itemData
				}
			else
				inventory[ data ] = nil
			end
			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		elseif ( workID == CAT_INV_ACTION_UPDATE ) then
			local uniqueID = data.uniqueID
			if ( !catherine.inventory.HasItem( pl, uniqueID ) ) then return end
			local inventory = catherine.inventory.Get( pl )
			inventory[ uniqueID ] = {
				uniqueID = inventory[ uniqueID ].uniqueID,
				int = inventory[ uniqueID ].int,
				itemData = data.newData
			}
			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		else
			catherine.util.ErrorPrint( "Bad function id! - catherine.inventory.Work( )" )
		end
	end
	
	function catherine.inventory.IsEquipped( pl, uniqueID )
		local itemData = catherine.inventory.GetItemData( pl, uniqueID )
		return itemData.equiped
	end

	function catherine.inventory.HasItem( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return false end
		local inventory = catherine.inventory.Get( pl )
		return inventory[ uniqueID ]
	end
	
	function catherine.inventory.Get( pl )
		return catherine.character.GetGlobalVar( pl, "_inv", { } )
	end

	function catherine.inventory.GetItemInt( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return 0 end
		local inventory = catherine.inventory.Get( pl )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].int or 0
	end
	
	function catherine.inventory.GetWeights( pl )
		local inventory = catherine.inventory.Get( pl )
		local invWeight, invMaxWeight = 0, catherine.configs.baseInventoryWeight
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			local itemInt = catherine.inventory.GetItemInt( pl, k )
			if ( itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( itemTable.weightPlus or 0 )
			end
			invWeight = invWeight + itemInt * ( itemTable.weight or 1 )
		end
		return invWeight, invMaxWeight
	end
	
	function catherine.inventory.HasSpace( pl )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( pl )
		return invWeight < invMaxWeight
	end
	
	function catherine.inventory.GetItemData( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return { } end
		local inventory = catherine.inventory.Get( pl )
		if ( !inventory[ uniqueID ] ) then return { } end
		return inventory[ uniqueID ].itemData or { }
	end
	
	function catherine.inventory.SetItemData( pl, uniqueID, key, newData )
		if ( !IsValid( pl ) or !uniqueID or !key or newData == nil ) then return end
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		itemData[ key ] = newData
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = uniqueID,
			newData = itemData
		} )
	end
	
	function META:HasInvSpace( )
		return catherine.inventory.HasSpace( self )
	end
	
	function META:HasItem( uniqueID )
		return catherine.inventory.HasItem( self, uniqueID )
	end
	
	function META:GetInvItemData( uniqueID )
		return catherine.inventory.GetItemData( self, uniqueID )
	end
	
	function META:SetInvItemData( uniqueID, key, newData )
		return catherine.inventory.SetItemData( self, uniqueID, key, newData )
	end
else
	function catherine.inventory.Get( )
		return catherine.character.GetGlobalVar( LocalPlayer( ), "_inv", { } )
	end

	function catherine.inventory.GetItemInt( uniqueID )
		if ( !uniqueID ) then return 0 end
		local inventory = catherine.inventory.Get( )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].int or 0
	end
	
	function catherine.inventory.HasItem( uniqueID )
		if ( !uniqueID ) then return false end
		local inventory = catherine.inventory.Get( )
		return inventory[ uniqueID ]
	end
	
	function catherine.inventory.IsEquipped( uniqueID )
		local itemData = catherine.inventory.GetItemData( uniqueID )
		return itemData.equiped
	end

	function catherine.inventory.GetWeights( )
		local inventory = catherine.inventory.Get( )
		local invWeight, invMaxWeight = 0, catherine.configs.baseInventoryWeight
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			local itemInt = catherine.inventory.GetItemInt( k )
			if ( itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( itemTable.weightPlus or 0 )
			end
			invWeight = invWeight + itemInt * ( itemTable.weight or 1 )
		end
		return invWeight, invMaxWeight
	end
	
	function catherine.inventory.GetItemData( uniqueID )
		if ( !uniqueID ) then return { } end
		local inventory = catherine.inventory.Get( )
		if ( !inventory[ uniqueID ] ) then return { } end
		return inventory[ uniqueID ].itemData or { }
	end
	
	function catherine.inventory.HasSpace( )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( )
		return invWeight < invMaxWeight
	end
	
	function META:HasInvSpace( )
		return catherine.inventory.HasSpace( )
	end
	
	function META:HasItem( uniqueID )
		return catherine.inventory.HasItem( uniqueID )
	end
	
	function META:GetInvItemData( uniqueID )
		return catherine.inventory.GetItemData( uniqueID )
	end

	catherine.character.RegisterNyanHook( "NetworkGlobalVarChanged", function( )
		if ( !IsValid( catherine.vgui.inventory ) ) then return end
		catherine.vgui.inventory:InitializeInventory( )
	end )
end