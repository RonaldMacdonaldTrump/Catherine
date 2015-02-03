if ( !nexus.character ) then
	nexus.util.Include( "libs/sh_character.lua" )
end

local META = FindMetaTable( "Player" )

if ( SERVER ) then
	nexus.character.characterDatas = nexus.character.characterDatas or { }
	
	function META:SetCharacterData( key, value, dbSave, force )
		if ( key == "_NexusData" and !force ) then
			ErrorNoHalt( "[Nexus] SetCharacterData has can't change Nexus Data!" )
			return
		end
		nexus.character.characterDatas[ self:UniqueID( ) ] = nexus.character.characterDatas[ self:UniqueID( ) ] or { }
		nexus.character.characterDatas[ self:UniqueID( ) ][ key ] = value
		self:CallOnRemove( "ClearCharacterData", function( )
			nexus.character.characterDatas[ self:UniqueID( ) ] = nil
			netstream.Start( nil, "nexus.character.ClearCharacterDatas", {
				self:UniqueID( )
			} )
		end )
		netstream.Start( nil, "nexus.character.SendCharacterDatas", { self:UniqueID( ), key, value } )
		if ( dbSave ) then
			nexus.character.SaveTargetPlayer( self )
		end
	end
	
	function META:IsCharacterLoaded( )
		return self:GetNetworkValue( "characterLoaded", false )
	end

end

function META:GetCharacterData( key, default )
	if ( !nexus.character.characterDatas[ self:UniqueID( ) ] ) then return default end
	if ( !nexus.character.characterDatas[ self:UniqueID( ) ][ key ] ) then return default end
	return nexus.character.characterDatas[ self:UniqueID( ) ][ key ] or default
end
	
function META:GetCharacterID( )
	return self:GetNetworkValue( "characterID", 0 )
end