catherine.util = catherine.util or { }

function catherine.util.Print( color, message )
	if ( !color ) then
		color = Color( 255, 255, 255 )
	end
	if ( !message ) then return end
	MsgC( color, "[Catherine] " .. message .. "\n" )
end

function catherine.util.Include( dir, types )
	if ( !dir ) then return end
	local lowerDir = string.lower( dir )
	if ( SERVER and ( types == "SERVER" or string.find( lowerDir, "sv_" ) ) ) then
		include( dir )
	elseif ( types == "CLIENT" or string.find( lowerDir, "cl_" ) ) then
		if ( SERVER ) then
			AddCSLuaFile( dir )
		else
			include( dir )
		end
	elseif ( types == "SHARED" or string.find( lowerDir, "sh_" ) ) then
		AddCSLuaFile( dir )
		include( dir )
	end
end

function catherine.util.IncludeInDir( dir, iscatherine )
	if ( !dir ) then return end
	if ( ( !iscatherine or string.find( dir, "schema/" ) ) and !Schema ) then return end
	local dir2 = ( ( iscatherine and "catherine" ) or Schema.FolderName ) .. "/gamemode/" .. dir .. "/*.lua"
	for k, v in pairs( file.Find( dir2, "LUA" ) ) do
		catherine.util.Include( dir .. "/" .. v )
	end
end

function catherine.util.FindPlayerByName( name )
	if ( !name ) then return nil end
	for k, v in pairs( player.GetAll( ) ) do
		if ( string.match( string.lower( v:Name( ) ), string.lower( name ) ) ) then
			return v
		end
	end
	
	return nil
end

catherine.util.IncludeInDir( "libs/external", true )

if ( SERVER ) then
	catherine.util.StringQuerys = catherine.util.StringQuerys or { }
	
	function catherine.util.Notify( pl, message, time, icon )
		if ( !IsValid( pl ) or !message ) then return end
		netstream.Start( pl, "catherine.util.Notify", { message, time, icon } )
	end
	
	function catherine.util.ProgressBar( pl, message, time )
		if ( !IsValid( pl ) or !message or !time ) then return end
		netstream.Start( pl, "catherine.util.ProgressBar", { message, time } )
	end
	
	function catherine.util.PlaySound( pl, dir )
		if ( !dir ) then return end
		netstream.Start( pl or nil, "catherine.util.PlaySound", dir )
	end
	
	function catherine.util.NotifyAll( message, time, icon )
		if ( !message ) then return end
		netstream.Start( nil, "catherine.util.Notify", { message, time, icon } )
	end
	
	function catherine.util.UniqueStringReceiver( pl, id, title, msg, defV, func )
		if ( !IsValid( pl ) or !id or !title or !msg or !func ) then return end
		if ( !defV ) then defV = "" end
		catherine.util.StringQuerys[ pl:SteamID( ) ] = catherine.util.StringQuerys[ pl:SteamID( ) ] or { }
		catherine.util.StringQuerys[ pl:SteamID( ) ][ id ] = { id, title, msg, func }
		netstream.Start( pl, "catherine.util.UniqueStringReceiver", { id, title, msg, defV } )
	end
	
	netstream.Hook( "catherine.util.UniqueStringReceiver_Receive", function( caller, data )
		local id = data[ 1 ]
		if ( !catherine.util.StringQuerys[ caller:SteamID( ) ] or !catherine.util.StringQuerys[ caller:SteamID( ) ][ id ] ) then return end
		catherine.util.StringQuerys[ caller:SteamID( ) ][ id ][ 4 ]( caller, data[ 2 ] )
		catherine.util.StringQuerys[ caller:SteamID( ) ][ id ] = nil
	end )
else
	netstream.Hook( "catherine.util.UniqueStringReceiver", function( data )
		 Derma_StringRequest( data[ 2 ], data[ 3 ], data[ 4 ], function( val )
			netstream.Start( "catherine.util.UniqueStringReceiver_Receive", { data[ 1 ], val } )
		 end, function( ) end, "OK", "NO" )
	end )
	
	netstream.Hook( "catherine.util.PlaySound", function( data )
		surface.PlaySound( data )
	end )

	netstream.Hook( "catherine.util.Notify", function( data )
		catherine.util.Notify( data[ 1 ], data[ 2 ], data[ 3 ] )
	end )
	
	netstream.Hook( "catherine.util.ProgressBar", function( data )
		catherine.util.ProgressBar( data[ 1 ], data[ 2 ] )
	end )
	
	function catherine.util.Notify( message, time, sound, icon )
		if ( !message ) then return end
		catherine.notify.Add( message, time or 5, sound, icon )
	end
	
	function catherine.util.ProgressBar( message, endTime )
		if ( !message or !endTime ) then return end
		catherine.hud.ProgressBarAdd( message, endTime )
	end
	
	function catherine.util.BlurDraw( x, y, w, h, amount )
		local blur = Material( "pp/blurscreen" )
		amount = amount or 5
		surface.SetMaterial( blur )
		surface.SetDrawColor( 255, 255, 255 )
		
		local x2, y2 = x / ScrW( ), y / ScrH( )
		local w2, h2 = ( x + w ) / ScrW( ), ( y + h ) / ScrH( )

		for i = -0.2, 1, 0.2 do
			blur:SetFloat( "$blur", i * amount )
			blur:Recompute( )
			render.UpdateScreenEffectTexture( )
			surface.DrawTexturedRectUV( x, y, w, h, x2, y2, w2, h2 )
		end
	end
end