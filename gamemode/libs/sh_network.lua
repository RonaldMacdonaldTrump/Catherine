catherine.network = catherine.network or { }
catherine.network.globalVars = catherine.network.globalVars or { }
catherine.network.entityVars = catherine.network.entityVars or { }

// 새로운 네트워킹 시스템; ^-^; 2015-03-10 학교 컴실에서..

if ( SERVER ) then
	function catherine.network.SetNetVar( ent, key, value, noSync )
		if ( !IsValid( ent ) or !key ) then return end
		catherine.network.entityVars[ ent:EntIndex( ) ] = catherine.network.entityVars[ ent:EntIndex( ) ] or { }
		catherine.network.entityVars[ ent:EntIndex( ) ][ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.network.SetNetVar", { ent:EntIndex( ), key, value } )
		end
		ent:CallOnRemove( "ClearVars", function( )
			catherine.network.entityVars[ ent:EntIndex( ) ] = nil
			netstream.Start( nil, "catherine.network.ClearNetVar", ent:EntIndex( ) )
		end )
	end
	
	function catherine.network.SyncAllVars( pl, func )
		netstream.Start( pl, "catherine.network.SyncAllVars", { catherine.network.entityVars, catherine.network.globalVars } )
		if ( func ) then
			func( )
		end
	end
	
	function catherine.network.SetNetGlobalVar( key, value, noSync )
		if ( !key ) then return end
		catherine.network.globalVars[ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.network.SetNetGlobalVar", { key, value } )
		end
		if ( value == nil ) then
			netstream.Start( nil, "catherine.network.ClearNetGlobalVar", key )
		end
	end
	
	function catherine.network.PlayerDisconnected( pl )
		catherine.network.entityVars[ pl:EntIndex( ) ] = nil
		netstream.Start( nil, "catherine.network.ClearNetVar", pl:EntIndex( ) )
	end
	
	hook.Add( "PlayerDisconnected", "catherine.network.PlayerDisconnected", catherine.network.PlayerDisconnected )
else
	netstream.Hook( "catherine.network.SetNetVar", function( data )
		catherine.network.entityVars[ data[ 1 ] ] = catherine.network.entityVars[ data[ 1 ] ] or { }
		catherine.network.entityVars[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.network.SetNetGlobalVar", function( data )
		catherine.network.globalVars[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.network.ClearNetVar", function( data )
		catherine.network.entityVars[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.ClearNetGlobalVar", function( data )
		catherine.network.globalVars[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.SyncAllVars", function( data )
		catherine.network.entityVars = data[ 1 ]
		catherine.network.globalVars = data[ 2 ]
	end )
end

function catherine.network.GetNetVar( ent, key, default )
	if ( !IsValid( ent ) or !key ) then return default end
	if ( SERVER ) then
		if ( !catherine.network.entityVars[ ent:EntIndex( ) ] ) then return default end
		return catherine.network.entityVars[ ent:EntIndex( ) ][ key ] or default
	else
		if ( !catherine.network.entityVars[ ent:EntIndex( ) ] ) then return default end
		return catherine.network.entityVars[ ent:EntIndex( ) ][ key ] or default
	end
end

function catherine.network.GetNetGlobalVar( key, default )
	if ( !key ) then return default end
	return catherine.network.globalVars[ key ] or default
end