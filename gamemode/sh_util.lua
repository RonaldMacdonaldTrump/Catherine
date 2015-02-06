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

if ( SERVER ) then
	function catherine.util.Notify( pl, message )
		if ( !message ) then return end
		if ( !pl ) then
			return
		end
		pl:ChatPrint( message )
	end
else
	function catherine.util.Notify( message )
		if ( !message ) then return end
		LocalPlayer( ):ChatPrint( message )
	end
end

catherine.util.IncludeInDir( "libs/external", true )