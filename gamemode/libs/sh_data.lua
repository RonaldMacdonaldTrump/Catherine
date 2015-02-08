catherine.catherine_data = catherine.catherine_data or { }

if ( SERVER ) then
	catherine.catherine_data.buffers = catherine.catherine_data.buffers or { }
	
	hook.Add( "PlayerDisconnected", "catherine.catherine_data.PlayerDisconnected", function( pl )
		if ( !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return end
		catherine.catherine_data.SaveToMySQL( pl )
		catherine.catherine_data.buffers[ pl:SteamID( ) ] = nil
		print("Init!")
		// Init z;
	end )
	
	function catherine.catherine_data.RegisterByMySQL( pl, isLoading )
		if ( !IsValid( pl ) ) then return end
		if ( isLoading ) then
			netstream.Start( pl, "catherine.LoadingStatus", "Registering catherine datas ..." )
		end
		catherine.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "catherine_players", function( data )
			if ( #data == 0 ) then return end
			local data = data[ 1 ][ "_catherineData" ]
			catherine.catherine_data.buffers[ pl:SteamID( ) ] = util.JSONToTable( data )
			print("Transfer finished")
			if ( isLoading ) then
				netstream.Start( pl, "catherine.LoadingStatus", "Registering catherine data finished ..." )
			end
		end )
	end

	function catherine.catherine_data.SaveToMySQL( pl )
		if ( !IsValid( pl ) ) then return end
		if ( !catherine.catherine_data.buffers[ pl:SteamID( ) ] ) then return end
		local data = {
			_catherineData = util.TableToJSON( catherine.catherine_data.buffers[ pl:SteamID( ) ] )
		}
		catherine.database.Update( "_steamID = '" .. pl:SteamID( ) .. "'", data, "catherine_players", function( )
			print("Save finished")
		end )
	end
	
	function catherine.catherine_data.SetcatherineData( pl, key, value, nosync, save )
		if ( !IsValid( pl ) or !key ) then return end
		catherine.catherine_data.buffers[ pl:SteamID( ) ] = catherine.catherine_data.buffers[ pl:SteamID( ) ] or { }
		catherine.catherine_data.buffers[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then
			netstream.Start( pl, "catherine.catherine_data.SetcatherineData", { key, value } )
		end
		if ( save ) then
			catherine.catherine_data.SaveToMySQL( pl )
		end
	end
--[[
	catherine.catherine_data.SetcatherineData( player.GetByID( 1 ), "test", nil )
	catherine.catherine_data.SetcatherineData( player.GetByID( 1 ), "zz", nil )
	catherine.catherine_data.SetcatherineData( player.GetByID( 1 ), "gg", nil )--]]
	//catherine.catherine_data.SaveToMySQL( player.GetByID( 1 ) )

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
		return catherine.catherine_data.localData[ key ]
	end
	
	netstream.Hook( "catherine.catherine_data.SetcatherineData", function( data )
		catherine.catherine_data.localData = catherine.catherine_data.localData or { }
		catherine.catherine_data.localData[ data[ 1 ] ] = data[ 2 ]
	end )
end

