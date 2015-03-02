if ( !catherine.character ) then
	catherine.util.Include( "libs/sh_character.lua" )
end
catherine.character.characterDatas = catherine.character.characterDatas or { }

if ( SERVER ) then
	catherine.character.DataTransferCurTime = catherine.character.DataTransferCurTime or CurTime( ) + catherine.configs.transferInterval
	//catherine.character.NextHPAPSaveTime = catherine.character.NextHPAPSaveTime or CurTime( ) + 20

	// Health, armor loaded by Character Data.
	hook.Add( "CharacterLoaded", "catherine.character.CharacterLoaded", function( pl, charID )
		
		local health = catherine.character.GetCharData( pl, "health", 100 )
		local armor = catherine.character.GetCharData( pl, "armor", 0 )

		pl:SetHealth( health )
		pl:SetArmor( armor )

		catherine.character.SetCharData( pl, "health", pl:Health( ) )
		catherine.character.SetCharData( pl, "armor", pl:Armor( ) )
	end )

	// Character Data create and save Health, armor.
	hook.Add( "PreCharacterLoadStart", "catherine.character.PreCharacterLoadStart", function( pl, prviouscharID )
		// If you have previous character id?, return it.
		if ( !prviouscharID ) then return end
		
		catherine.character.SetCharData( pl, "health", pl:Health( ) )
		catherine.character.SetCharData( pl, "armor", pl:Armor( ) )

		catherine.character.TransferToCharacterTable( pl, prviouscharID )
		catherine.character.ClearCharacterDatas( pl )
	end )
	
	hook.Add( "PlayerDisconnected", "catherine.character.PlayerDisconnected_02", function( pl )
		if ( !pl:Alive( ) ) then
			catherine.character.SetCharData( pl, "health", pl:GetMaxHealth( ) )
			catherine.character.SetCharData( pl, "armor", 0 )
		else
			catherine.character.SetCharData( pl, "health", pl:Health( ) )
			catherine.character.SetCharData( pl, "armor", pl:Armor( ) )
		end
		catherine.character.TransferToCharacterTable( pl, pl.characterID )
		catherine.character.ClearCharacterDatas( pl )
	end )

	hook.Add( "Tick", "catherine.character.Tick", function( )
		if ( catherine.character.DataTransferCurTime <= CurTime( ) ) then
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				catherine.character.TransferToCharacterTable( v, v.characterID )
			end
			catherine.character.DataTransferCurTime = CurTime( ) + catherine.configs.transferInterval
		end
		--[[ // Optimization ; ^ㅡ^
		if ( catherine.character.NextHPAPSaveTime <= CurTime( ) ) then
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				catherine.character.SetCharData( v, "health", v:Health( ), true )
				catherine.character.SetCharData( v, "armor", v:Armor( ), true )
			end
			catherine.character.NextHPAPSaveTime = CurTime( ) + 20
		end--]]
	end )

	function catherine.character.TransferToCharacterTable( pl, charID )
		if ( !IsValid( pl ) or !charID ) then return end
		if ( !catherine.character.characterDatas[ pl:SteamID( ) ] ) then return end
		if ( !catherine.character.buffers[ pl:SteamID( ) ] ) then return end
		local found = nil
		for k, v in pairs( catherine.character.buffers[ pl:SteamID( ) ] ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == charID ) then
					found = k
				end
			end
		end
		if ( !found ) then return end
		local buffer = table.Copy( catherine.character.characterDatas[ pl:SteamID( ) ] )
		local b = catherine.character.buffers[ pl:SteamID( ) ][ found ]
		for k, v in pairs( catherine.character.characterDatas[ pl:SteamID( ) ] ) do
			for k1, v1 in pairs( buffer ) do
				if ( k == k1 and v != v1 ) then
					b[ k1 ] = v1
				elseif ( k == k1 and v == v1 ) then
					b[ k1 ] = v
				end
			end
		end
		catherine.character.buffers[ pl:SteamID( ) ][ found ] = b
	end

	function catherine.character.ClearCharacterDatas( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.character.characterDatas[ pl:SteamID( ) ] = nil
		netstream.Start( nil, "catherine.character.ClearCharacterDatas", pl:SteamID( ) )	
	end
	
	function catherine.character.RegisterCharacterDatas( pl, charID, nosync )
		local globalDatas = catherine.character.GetGlobalDatas( pl, charID )
		if ( !globalDatas ) then return end
		local namePrefix = globalDatas
		for k, v in pairs( globalDatas ) do
			local globaldata = catherine.character.GetGlobalByField( k )
			if ( globaldata and !globaldata.isNetwork ) then
				globalDatas[ k ] = nil
			end
		end
		catherine.character.characterDatas[ pl:SteamID( ) ] = globalDatas
		if ( !nosync ) then
			netstream.Start( nil, "catherine.character.SyncCharacterDatas", { pl:SteamID( ), catherine.character.characterDatas[ pl:SteamID( ) ] } )
		end
	end
	
	function catherine.character.Sync( pl )
		local globalDatas = catherine.character.GetGlobalDatas( pl, pl.characterID )
		if ( !globalDatas ) then return end
		local namePrefix = globalDatas
		for k, v in pairs( globalDatas ) do
			local globaldata = catherine.character.GetGlobalByField( k )
			if ( globaldata and !globaldata.isNetwork ) then
				globalDatas[ k ] = nil
			end
		end
		catherine.character.characterDatas[ pl:SteamID( ) ] = globalDatas
		if ( globalDatas._charData ) then
			local decode = pon.decode( tostring( globalDatas._charData ) )
			globalDatas._charData = decode
		end
		if ( !nosync ) then
			netstream.Start( nil, "catherine.character.SyncCharacterDatas", { pl:SteamID( ), catherine.character.characterDatas[ pl:SteamID( ) ] } )
		end
	end
	
	function catherine.character.SendCurrentCharacterDatas( pl )
		netstream.Start( pl, "catherine.character.SendCurrentCharacterDatas", catherine.character.characterDatas )
	end

	function catherine.character.GetGlobalDatas( pl, charID )
		if ( !IsValid( pl ) or !charID ) then return nil end
		local base = catherine.character.GetPlayerCharacterLists( pl )
		if ( !base ) then return nil end
		for k, v in pairs( base ) do
			if ( v._id == charID ) then
				return table.Copy( v )
			end
		end
		
		return nil
	end
	
	function catherine.character.SetGlobalData( pl, key, value, nosync )
		if ( !IsValid( pl ) or !key ) then return end
		if ( !catherine.character.characterDatas[ pl:SteamID( ) ] ) then return end
		catherine.character.characterDatas[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then
			netstream.Start( nil, "catherine.character.SetCharacterData", { pl:SteamID( ), key, value } )
		end
	end
	
	function catherine.character.SetCharData( pl, key, value, nosync )
		if ( !IsValid( pl ) or !key ) then return end
		if ( !catherine.character.characterDatas[ pl:SteamID( ) ] ) then return end
		catherine.character.characterDatas[ pl:SteamID( ) ][ "_charData" ][ key ] = value
		if ( !nosync ) then
			netstream.Start( nil, "catherine.character.SetCharData", { pl:SteamID( ), key, value } )
		end
	end
else
	netstream.Hook( "catherine.character.SendCurrentCharacterDatas", function( data )
		catherine.character.characterDatas = data
	end )
	
	netstream.Hook( "catherine.character.SyncCharacterDatas", function( data )
		catherine.character.characterDatas[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.character.SetCharacterData", function( data )
		catherine.character.characterDatas[ data[ 1 ] ] = catherine.character.characterDatas[ data[ 1 ] ] or { }
		catherine.character.characterDatas[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
		if ( data[ 2 ] == "_inv" ) then
			if ( IsValid( catherine.vgui.inventory ) ) then
				catherine.vgui.inventory:InitializeInv( )
			end
		end
	end )
	
	netstream.Hook( "catherine.character.SetCharData", function( data )
		catherine.character.characterDatas[ data[ 1 ] ] = catherine.character.characterDatas[ data[ 1 ] ] or { }
		catherine.character.characterDatas[ data[ 1 ] ][ "_charData" ] = catherine.character.characterDatas[ data[ 1 ] ][ "_charData" ] or { }
		catherine.character.characterDatas[ data[ 1 ] ][ "_charData" ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.character.ClearCharacterDatas", function( data )
		catherine.character.characterDatas[ data ] = nil
	end )
end

function catherine.character.GetGlobalData( pl, key, default )
	if ( !IsValid( pl ) or !key ) then return default end
	if ( !catherine.character.characterDatas[ pl:SteamID( ) ] ) then return default end
	if ( !catherine.character.characterDatas[ pl:SteamID( ) ][ key ] ) then return default end
	return catherine.character.characterDatas[ pl:SteamID( ) ][ key ]
end

function catherine.character.GetCharData( pl, key, default )
	if ( !IsValid( pl ) or !key ) then return default end
	if ( !catherine.character.characterDatas[ pl:SteamID( ) ] ) then return default end
	return catherine.character.characterDatas[ pl:SteamID( ) ][ "_charData" ][ key ] or default
end

local META = FindMetaTable( "Player" )

function META:GetCharacterGlobalData( key, default )
	return catherine.character.GetGlobalData( self, key, default )
end

function META:SetCharacterGlobalData( key, value, nosync )
	return catherine.character.SetGlobalData( self, key, value, nosync )
end

function META:GetCharData( key, default )
	return catherine.character.GetCharData( self, key, default )
end