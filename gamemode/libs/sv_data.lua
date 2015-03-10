catherine.data = catherine.data or { }
catherine.data.buffer = catherine.data.buffer or { }

function catherine.data.DataLoad( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/globals" )
	file.CreateDir( "catherine/" .. catherine.schema.GetUniqueID( ) )
end

hook.Add( "DataLoad", "catherine.data.DataLoad", catherine.data.DataLoad )

function catherine.data.Set( key, value, ignoreMap, isGlobal )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. 
	file.CreateDir( dir .. key )
	dir = dir .. key .. "/"

	local dir = "catherine/".. key .. "/" .. ( ( !ignoreMap and game.GetMap( ) .. "/" ) or "" ) .. "data.txt"
	local data = util.TableToJSON( value )
	file.CreateDir( "catherine/" .. key )
	if ( !ignoreMap ) then
		file.CreateDir( "catherine/" .. key .. "/" .. game.GetMap( ) )
	end
	file.Write( dir, data )
	catherine.data.buffer[ key ] = value
end

function catherine.data.Get( key, default, ignoreMap, bufferGet )
	local dir = "catherine/" .. key .. "/" .. ( ( !ignoreMap and game.GetMap( ) .. "/" ) or "" ) .. "data.txt"
	local data = file.Read( dir, "DATA" ) or nil
	if ( !data ) then return default end

	if ( bufferGet ) then
		return catherine.data.buffer[ key ] or default
	end
	return util.JSONToTable( data )
end