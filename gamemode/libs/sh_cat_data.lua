catherine.catData = catherine.catData or { }

if ( SERVER ) then
	catherine.catData.Buffers = catherine.catData.Buffers or { }
	
	function catherine.catData.IsValid( pl )
		if ( !IsValid( pl ) ) then return false end
		return catherine.catData.Buffers[ pl:SteamID( ) ]
	end

	function catherine.catData.Load( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( #data == 0 ) then return end
			catherine.catData.Buffers[ pl:SteamID( ) ] = util.JSONToTable( data[ 1 ][ "_catData" ] )
			catherine.catData.Sync( pl )
		end )
	end
	
	function catherine.catData.Sync( pl )
		if ( !IsValid( pl ) or !catherine.catData.IsValid( pl ) ) then return end
		netstream.Start( pl, "catherine.catData.Sync", catherine.catData.Buffers[ pl:SteamID( ) ] )
	end

	function catherine.catData.Save( pl )
		if ( !IsValid( pl ) or !catherine.catData.IsValid( pl ) ) then return end
		catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", {
			_catData = util.TableToJSON( catherine.catData.Buffers[ pl:SteamID( ) ] )
		} )
	end
	
	function catherine.catData.Set( pl, key, value, nosync, save )
		if ( !IsValid( pl ) or !key ) then return end
		catherine.catData.Buffers[ pl:SteamID( ) ] = catherine.catData.Buffers[ pl:SteamID( ) ] or { }
		catherine.catData.Buffers[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then netstream.Start( pl, "catherine.catData.Set", { key, value } ) end
		if ( save ) then catherine.catData.Save( pl ) end
	end

	function catherine.catData.Get( pl, key, default )
		if ( !IsValid( pl ) or !key or !catherine.catData.IsValid( pl ) ) then return default end
		return catherine.catData.Buffers[ pl:SteamID( ) ][ key ] or default
	end
	
	function catherine.catData.PlayerDisconnected( pl )
		catherine.catData.Save( pl )
		catherine.catData.Buffers[ pl:SteamID( ) ] = nil
	end
	hook.Add( "PlayerDisconnected", "catherine.catData.PlayerDisconnected", catherine.catData.PlayerDisconnected )
else
	catherine.catData.localDatas = catherine.catData.localDatas or { }
	
	function catherine.catData.Get( key, default )
		return catherine.catData.localDatas[ key ] or default
	end

	netstream.Hook( "catherine.catData.Set", function( data )
		catherine.catData.localDatas[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.catData.Sync", function( data )
		catherine.catData.localDatas = data
	end )
end