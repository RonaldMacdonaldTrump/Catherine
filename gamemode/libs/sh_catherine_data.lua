catherine.catherine_data = catherine.catherine_data or { }

if ( SERVER ) then
	catherine.catherine_data.buffers = catherine.catherine_data.buffers or { }
	
	hook.Add( "PlayerDisconnected", "catherine.catherine_data.PlayerDisconnected", function( pl )
		if ( !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return end
		catherine.catherine_data.Save( pl )
		catherine.catherine_data.buffers[ pl:SteamID( ) ] = nil
	end )

	function catherine.catherine_data.RegisterByMySQL( pl, isLoading )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( #data == 0 ) then return end
			catherine.catherine_data.buffers[ pl:SteamID( ) ] = util.JSONToTable( data[ 1 ][ "_catherineData" ] )
			catherine.catherine_data.SendToPlayer( pl )
		end )
	end
	
	function catherine.catherine_data.SendToPlayer( pl )
		if ( !IsValid( pl ) ) then return end
		if ( !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return end
		netstream.Start( pl, "catherine.catherine_data.SendcatherineData", catherine.catherine_data.buffers[ pl:SteamID( ) ] )
	end

	function catherine.catherine_data.Save( pl )
		if ( !IsValid( pl ) or !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return end
		catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", {
			_catherineData = util.TableToJSON( catherine.catherine_data.buffers[ pl:SteamID( ) ] )
		} )
	end
	
	function catherine.catherine_data.SetcatherineData( pl, key, value, nosync, save )
		if ( !IsValid( pl ) or !key ) then return end
		catherine.catherine_data.buffers[ pl:SteamID( ) ] = catherine.catherine_data.buffers[ pl:SteamID( ) ] or { }
		catherine.catherine_data.buffers[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then
			netstream.Start( pl, "catherine.catherine_data.SetcatherineData", { key, value } )
		end
		if ( save ) then
			catherine.catherine_data.Save( pl )
		end
	end

	function catherine.catherine_data.GetcatherineData( pl, key, default )
		if ( !IsValid( pl ) or !key ) then return default end
		if ( !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return default end
		return catherine.catherine_data.buffers[ pl:SteamID( ) ][ key ] or default
	end
else
	catherine.catherine_data.localData = catherine.catherine_data.localData or nil
	
	function catherine.catherine_data.GetcatherineData( key, default )
		if ( !key ) then return default end
		if ( !catherine.catherine_data.localData ) then return default end
		return catherine.catherine_data.localData[ key ] or default
	end

	netstream.Hook( "catherine.catherine_data.SetcatherineData", function( data )
		catherine.catherine_data.localData = catherine.catherine_data.localData or { }
		catherine.catherine_data.localData[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.catherine_data.SendcatherineData", function( data )
		catherine.catherine_data.localData = data
	end )
end