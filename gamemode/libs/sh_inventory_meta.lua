local META = FindMetaTable( "Player" )

function META:GetInv( )
	return catherine.inventory.GetInv( self )
end

function META:HasItem( itemID )
	return catherine.inventory.HasItem( self, itemID )
end

function META:GetInvWeight( )
	return catherine.inventory.GetInvWeight( self )
end

function META:GetInvMaxWeight( )
	return catherine.inventory.GetInvMaxWeight( self )
end

if ( SERVER ) then
	function META:SetInvItemData( itemID, id, val )
		catherine.inventory.SetInvItemData( self, itemID, id, val )
	end
	
	function META:GetInvItemData( itemID, id, def )
		return catherine.inventory.GetInvItemDataByID( self, itemID, id, def )
	end
	
	function META:IsEquiped( itemID )
		return catherine.inventory.Equiped( self, itemID )
	end
	
	function META:GetInvItemDatas( itemID )
		return catherine.inventory.GetInvItemDatas( self, itemID )
	end
else
	function META:GetInvItemData( itemID, id, def )
		return catherine.inventory.GetInvItemDataByID( itemID, id, def )
	end
	
	function META:IsEquiped( itemID )
		return catherine.inventory.Equiped( itemID )
	end
	
	function META:GetInvItemDatas( itemID )
		return catherine.inventory.GetInvItemDatas( itemID )
	end
end