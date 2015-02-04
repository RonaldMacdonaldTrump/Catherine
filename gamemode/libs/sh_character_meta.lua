local META = FindMetaTable( "Player" )

function META:GetCharacterID( )
	return self:GetNetworkValue( "characterID", nil )
end

function META:IsCharacterLoaded( )
	return self:GetNetworkValue( "characterLoaded", false )
end
