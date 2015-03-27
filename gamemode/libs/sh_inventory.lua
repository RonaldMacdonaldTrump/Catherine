catherine.inventory = catherine.inventory or { }
local META = FindMetaTable( "Player" )

if ( SERVER ) then
	CAT_INV_ACTION_ADD = 1
	CAT_INV_ACTION_REMOVE = 2
	CAT_INV_ACTION_UPDATE = 3
	
	function catherine.inventory.Work( pl, workID, data )
		if ( !IsValid( pl ) or !workID or !data ) then return end
		local workInv = catherine.character.SetGlobalVar
		
		if ( workID == CAT_INV_ACTION_ADD ) then
			local inventory, itemTable, itemCount = catherine.inventory.Get( pl ), catherine.item.FindByID( data.uniqueID ), math.max( data.itemCount or 1, 1 ) or 1
			local invData = inventory[ itemTable.uniqueID ]
			
			if ( invData ) then
				inventory[ itemTable.uniqueID ] = {
					uniqueID = invData.uniqueID,
					itemCount = invData.itemCount + itemCount,
					itemData = invData.itemData
				}
			else
				inventory[ itemTable.uniqueID ] = {
					uniqueID = itemTable.uniqueID,
					itemCount = itemCount,
					itemData = itemTable.itemData
				}
			end

			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		elseif ( workID == CAT_INV_ACTION_REMOVE ) then
			local invData = catherine.inventory.GetInvItem( pl, data )
			if ( !invData ) then return end
			
			local inventory = catherine.inventory.Get( pl )
			local itemCount = math.max( invData.itemCount - 1, 0 )
			
			if ( itemCount != 0 ) then
				inventory[ data ] = {
					uniqueID = invData.uniqueID,
					itemCount = itemCount,
					itemData = invData.itemData
				}
			else
				inventory[ data ] = nil
			end
			
			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		elseif ( workID == CAT_INV_ACTION_UPDATE ) then
			local invData = catherine.inventory.GetInvItem( pl, data.uniqueID )
			if ( !invData ) then return end
			
			local inventory = catherine.inventory.Get( pl )
			
			inventory[ data.uniqueID ] = {
				uniqueID = invData.uniqueID,
				itemCount = invData.itemCount,
				itemData = data.newData
			}
			
			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		else
			catherine.util.ErrorPrint( "Bad function id! - catherine.inventory.Work( )" )
		end
	end
	
	function catherine.inventory.GetInvItem( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return false end
		return catherine.inventory.Get( pl )[ uniqueID ]
	end
	
	function catherine.inventory.IsEquipped( pl, uniqueID )
		return catherine.inventory.GetItemData( pl, uniqueID, "equiped", false )
	end

	function catherine.inventory.HasItem( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return false end
		return catherine.inventory.Get( pl )[ uniqueID ] or false
	end
	
	function catherine.inventory.Get( pl )
		return table.Copy( catherine.character.GetGlobalVar( pl, "_inv", { } ) )
	end

	function catherine.inventory.GetItemInt( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return 0 end
		local inventory = catherine.inventory.Get( pl )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].itemCount or 0
	end
	
	function catherine.inventory.GetWeights( pl, customAdd )
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
		return invWeight + ( customAdd or 0 ), invMaxWeight
	end
	
	function catherine.inventory.HasSpace( pl, customAdd )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( pl, customAdd )
		return invWeight < invMaxWeight
	end
	
	function catherine.inventory.GetItemData( pl, uniqueID, key, default )
		if ( !IsValid( pl ) or !uniqueID or !key ) then return default end
		local inventory = catherine.inventory.Get( pl )
		if ( !inventory[ uniqueID ] or !inventory[ uniqueID ].itemData ) then return default end
		return inventory[ uniqueID ].itemData[ key ]
	end
	
	function catherine.inventory.GetItemDatas( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return { } end
		local inventory = catherine.inventory.Get( pl )
		if ( !inventory[ uniqueID ] ) then return { } end
		return inventory[ uniqueID ].itemData or { }
	end
	
	function catherine.inventory.SetItemData( pl, uniqueID, key, newData )
		if ( !IsValid( pl ) or !uniqueID or !key or newData == nil ) then return end
		local itemData = catherine.inventory.GetItemDatas( pl, uniqueID )
		itemData[ key ] = newData
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = uniqueID,
			newData = itemData
		} )
	end
	
	function catherine.inventory.SetItemDatas( pl, uniqueID, newData )
		if ( !IsValid( pl ) or !uniqueID or newData == nil ) then return end
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = uniqueID,
			newData = newData
		} )
	end
	
	function META:HasInvSpace( )
		return catherine.inventory.HasSpace( self )
	end
	
	function META:HasItem( uniqueID )
		return catherine.inventory.HasItem( self, uniqueID )
	end
	
	function META:GetInvItemData( uniqueID, key, default )
		return catherine.inventory.GetItemData( self, uniqueID, key, default )
	end
	
	function META:GetInvItemDatas( uniqueID )
		return catherine.inventory.GetItemDatas( self, uniqueID )
	end
	
	function META:SetInvItemData( uniqueID, key, newData )
		catherine.inventory.SetItemData( self, uniqueID, key, newData )
	end
	
	function META:SetInvItemDatas( uniqueID, newData )
		catherine.inventory.SetItemDatas( self, uniqueID, newData )
	end

	hook.Add( "InitializeNetworking", "catherine.inventory.hooks.InitializeNetworking_0", function( pl, charVars )
		if ( !charVars._inv ) then return end
		local inventory, changed = charVars._inv, false
		for k, v in pairs( inventory ) do
			if ( catherine.item.FindByID( k ) ) then continue end
			inventory[ k ] = nil
			changed = true
		end
		if ( changed ) then
			catherine.character.SetGlobalVar( pl, "_inv", inventory )
		end
	end )
else
	function catherine.inventory.Get( )
		return table.Copy( catherine.character.GetGlobalVar( LocalPlayer( ), "_inv", { } ) )
	end

	function catherine.inventory.GetItemInt( uniqueID )
		if ( !uniqueID ) then return 0 end
		local inventory = catherine.inventory.Get( )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].itemCount or 0
	end
	
	function catherine.inventory.HasItem( uniqueID )
		if ( !uniqueID ) then return false end
		local inventory = catherine.inventory.Get( )
		return inventory[ uniqueID ]
	end
	
	function catherine.inventory.IsEquipped( uniqueID )
		return catherine.inventory.GetItemData( uniqueID, "equiped", false )
	end

	function catherine.inventory.GetWeights( customAdd )
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
		return invWeight + ( customAdd or 0 ), invMaxWeight
	end
	
	function catherine.inventory.GetItemData( uniqueID, key, default )
		if ( !uniqueID or !key ) then return default end
		local inventory = catherine.inventory.Get( )
		if ( !inventory[ uniqueID ] or !inventory[ uniqueID ].itemData ) then return default end
		return inventory[ uniqueID ].itemData[ key ]
	end
	
	function catherine.inventory.GetItemDatas( uniqueID )
		if ( !uniqueID ) then return { } end
		local inventory = catherine.inventory.Get( )
		if ( !inventory[ uniqueID ] ) then return { } end
		return inventory[ uniqueID ].itemData or { }
	end

	function catherine.inventory.HasSpace( customAdd )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( customAdd )
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
	
	function META:GetInvItemDatas( uniqueID )
		return catherine.inventory.GetItemDatas( uniqueID )
	end

	hook.Add( "NetworkGlobalVarChanged", "catherine.inventory.hooks.NetworkGlobalVarChanged_0", function( )
		if ( !IsValid( catherine.vgui.inventory ) ) then return end
		catherine.vgui.inventory:InitializeInventory( )
	end )
end