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