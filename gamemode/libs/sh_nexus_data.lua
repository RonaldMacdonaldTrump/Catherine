nexus.nexus_data = nexus.nexus_data or { }

if ( SERVER ) then
	nexus.nexus_data.buffers = nexus.nexus_data.buffers or { }
	
	hook.Add( "PlayerDisconnected", "nexus.nexus_data.PlayerDisconnected", function( pl )
		if ( !nexus.nexus_data.buffers[ pl:SteamID( ) ] ) then return end
		nexus.nexus_data.SaveToMySQL( pl )
		nexus.nexus_data.buffers[ pl:SteamID( ) ] = nil
		print("Init!")
		// Init z;
	end )
	
	function nexus.nexus_data.RegisterByMySQL( pl, isLoading )
		if ( !IsValid( pl ) ) then return end
		if ( isLoading ) then
			netstream.Start( pl, "nexus.LoadingStatus", "Registering nexus datas ..." )
		end
		nexus.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "nexus_players", function( data )
			if ( #data == 0 ) then return end
			local data = data[ 1 ][ "_nexusData" ]
			nexus.nexus_data.buffers[ pl:SteamID( ) ] = util.JSONToTable( data )
			print("Transfer finished")
			if ( isLoading ) then
				netstream.Start( pl, "nexus.LoadingStatus", "Registering nexus data finished ..." )
			end
		end )
	end

	function nexus.nexus_data.SaveToMySQL( pl )
		if ( !IsValid( pl ) ) then return end
		if ( !nexus.nexus_data.buffers[ pl:SteamID( ) ] ) then return end
		local data = {
			_nexusData = util.TableToJSON( nexus.nexus_data.buffers[ pl:SteamID( ) ] )
		}
		nexus.database.Update( "_steamID = '" .. pl:SteamID( ) .. "'", data, "nexus_players", function( )
			print("Save finished")
		end )
	end
	
	function nexus.nexus_data.SetNexusData( pl, key, value, nosync, save )
		if ( !IsValid( pl ) or !key ) then return end
		nexus.nexus_data.buffers[ pl:SteamID( ) ] = nexus.nexus_data.buffers[ pl:SteamID( ) ] or { }
		nexus.nexus_data.buffers[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then
			netstream.Start( pl, "nexus.nexus_data.SetNexusData", { key, value } )
		end
		if ( save ) then
			nexus.nexus_data.SaveToMySQL( pl )
		end
	end
--[[
	nexus.nexus_data.SetNexusData( player.GetByID( 1 ), "test", nil )
	nexus.nexus_data.SetNexusData( player.GetByID( 1 ), "zz", nil )
	nexus.nexus_data.SetNexusData( player.GetByID( 1 ), "gg", nil )--]]
	//nexus.nexus_data.SaveToMySQL( player.GetByID( 1 ) )

	function nexus.nexus_data.GetNexusData( pl, key, default )
		if ( !IsValid( pl ) or !key ) then return default end
		if ( !nexus.nexus_data.buffers[ pl:SteamID( ) ] ) then return default end
		return nexus.nexus_data.buffers[ pl:SteamID( ) ][ key ]
	end
else
	nexus.nexus_data.localData = nexus.nexus_data.localData or nil
	
	function nexus.nexus_data.GetNexusData( key, default )
		if ( !key ) then return default end
		if ( !nexus.nexus_data.localData ) then return default end
		return nexus.nexus_data.localData[ key ]
	end
	
	netstream.Hook( "nexus.nexus_data.SetNexusData", function( data )
		nexus.nexus_data.localData = nexus.nexus_data.localData or { }
		nexus.nexus_data.localData[ data[ 1 ] ] = data[ 2 ]
	end )
end

