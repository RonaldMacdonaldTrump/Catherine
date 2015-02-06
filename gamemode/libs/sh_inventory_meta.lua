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
	function META:IsEquiped( itemID )
		return catherine.inventory.Equiped( self, itemID )
	end
else
	function META:IsEquiped( itemID )
		return catherine.inventory.Equiped( itemID )
	end
end

