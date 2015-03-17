catherine.data = catherine.data or { Buffer = { } }

function catherine.data.DataLoad( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/globals" )
	file.CreateDir( "catherine/" .. catherine.schema.GetUniqueID( ) )
end

hook.Add( "DataLoad", "catherine.data.DataLoad", catherine.data.DataLoad )

function catherine.data.Set( key, value, ignoreMap, isGlobal )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/"
	if ( !ignoreMap ) then
		dir = dir .. game.GetMap( )
		file.CreateDir( dir )
	end
	local data = util.TableToJSON( value )
	file.Write( dir .. "/data.txt", data )
	catherine.data.Buffer[ key ] = value
end

function catherine.data.Get( key, default, ignoreMap, isGlobal, isBuffer )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/" .. ( !ignoreMap and game.GetMap( ) or "" ) .. "/data.txt"
	local data = file.Read( dir, "DATA" ) or nil
	if ( !data ) then return default end
	if ( isBuffer ) then
		return catherine.data.Buffer[ key ] or default
	end
	return util.JSONToTable( data )
end