local META = FindMetaTable( "Player" )

function META:HasFaction( id )
	if ( SERVER ) then
		return catherine.faction.HasWhiteList( self, id )
	else
		return catherine.faction.HasWhiteList( id )
	end
end