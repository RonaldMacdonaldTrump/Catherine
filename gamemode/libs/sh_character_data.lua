if ( !nexus.character ) then
	nexus.util.Include( "libs/sh_character.lua" )
end
nexus.character.characterDatas = nexus.character.characterDatas or { }

if ( SERVER ) then
	hook.Add( "CharacterLoaded", "nexus.character.CharacterLoaded", function( pl, charID )
		nexus.character.RegisterCharacterDatas( pl, charID )
	end )
	
	hook.Add( "PreCharacterLoaded", "nexus.character.PreCharacterLoaded", function( pl, prviouscharID )
		if ( !prviouscharID ) then 
			return print( "Not need previous character data clear!" )
		end
		netstream.Start( nil, "nexus.character.ClearCharacterDatas", pl:SteamID( ) )
	end )
	
	hook.Add( "PlayerDisconnected", "nexus.character.PlayerDisconnected_02", function( pl )
		netstream.Start( nil, "nexus.character.ClearCharacterDatas", pl:SteamID( ) )
		// please add save character codes.
	end )
	
	function nexus.character.RegisterCharacterDatas( pl, charID, nosync )
		local globalDatas = nexus.character.GetGlobalDatas( pl, charID )
		if ( !globalDatas ) then return end
		local namePrefix = globalDatas
		for k, v in pairs( globalDatas ) do
			local globaldata = nexus.character.GetGlobalByField( k )
			if ( globaldata and !globaldata.isNetwork ) then
				globalDatas[ k ] = nil
			end
		end
		nexus.character.characterDatas[ pl:SteamID( ) ] = globalDatas
		if ( !nosync ) then
			netstream.Start( nil, "nexus.character.SyncCharacterDatas", { pl:SteamID( ), nexus.character.characterDatas[ pl:SteamID( ) ] } )
		end
	end
	
	function nexus.character.Sync( pl )
		local globalDatas = nexus.character.GetGlobalDatas( pl, pl.characterID )
		if ( !globalDatas ) then return end
		local namePrefix = globalDatas
		for k, v in pairs( globalDatas ) do
			local globaldata = nexus.character.GetGlobalByField( k )
			if ( globaldata and !globaldata.isNetwork ) then
				globalDatas[ k ] = nil
			end
		end
		nexus.character.characterDatas[ pl:SteamID( ) ] = globalDatas
		if ( globalDatas._charData ) then
			local decode = pon.decode( tostring( globalDatas._charData ) )
			globalDatas._charData = decode
		end
		if ( !nosync ) then
			netstream.Start( nil, "nexus.character.SyncCharacterDatas", { pl:SteamID( ), nexus.character.characterDatas[ pl:SteamID( ) ] } )
		end
	end

	function nexus.character.GetGlobalDatas( pl, charID )
		if ( !IsValid( pl ) or !charID ) then return nil end
		local base = nexus.character.GetPlayerCharacterLists( pl )
		if ( !base ) then return nil end
		for k, v in pairs( base ) do
			if ( v._id == charID ) then
				return table.Copy( v )
			end
		end
		
		return nil
	end
	
	function nexus.character.SetGlobalData( pl, key, value, nosync )
		if ( !IsValid( pl ) or !key ) then return end
		if ( !nexus.character.characterDatas[ pl:SteamID( ) ] ) then return end
		nexus.character.characterDatas[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then
			netstream.Start( nil, "nexus.character.SetCharacterData", { pl:SteamID( ), key, value } )
		end
	end
	
	function nexus.character.SetCharData( pl, key, value, nosync )
		if ( !IsValid( pl ) or !key ) then return end
		if ( !nexus.character.characterDatas[ pl:SteamID( ) ] ) then return end
		nexus.character.characterDatas[ pl:SteamID( ) ][ "_charData" ][ key ] = value
		if ( !nosync ) then
			netstream.Start( nil, "nexus.character.SetCharData", { pl:SteamID( ), key, value } )
		end
	end
	
	function nexus.character.TransferToCharacterTable( pl, charID )
		if ( !IsValid( pl ) ) then return end
		if ( !nexus.character.characterDatas[ pl:SteamID( ) ] ) then return end
		for k, v in pairs( nexus.character.characterDatas[ pl:SteamID( ) ] ) do
			if ( nexus.character.buffers[ pl:SteamID( ) ][ charID ][ k ] != v ) then
				nexus.character.buffers[ pl:SteamID( ) ][ charID ][ k ] = v
			end
		end
	end
else
	netstream.Hook( "nexus.character.SyncCharacterDatas", function( data )
		nexus.character.characterDatas[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "nexus.character.SetCharacterData", function( data )
		nexus.character.characterDatas[ data[ 1 ] ] = nexus.character.characterDatas[ data[ 1 ] ] or { }
		nexus.character.characterDatas[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "nexus.character.SetCharData", function( data )
		nexus.character.characterDatas[ data[ 1 ] ] = nexus.character.characterDatas[ data[ 1 ] ] or { }
		nexus.character.characterDatas[ data[ 1 ] ][ "_charData" ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "nexus.character.ClearCharacterDatas", function( data )
		nexus.character.characterDatas[ data ] = nil
	end )
end

function nexus.character.GetGlobalData( pl, key, default )
	if ( !IsValid( pl ) or !key ) then return default end
	if ( !nexus.character.characterDatas[ pl:SteamID( ) ] ) then return default end
	if ( !nexus.character.characterDatas[ pl:SteamID( ) ][ key ] ) then return default end
	return nexus.character.characterDatas[ pl:SteamID( ) ][ key ]
end

local META = FindMetaTable( "Player" )

function META:GetCharacterGlobalData( key, default )
	return nexus.character.GetGlobalData( self, key, default )
end

function META:SetCharacterGlobalData( key, value, nosync )
	return nexus.character.SetGlobalData( self, key, value, nosync )
end