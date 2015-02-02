nexus.database = nexus.database or { }
nexus.database.object = nexus.database.object or nil
nexus.database[ "mysqloo" ] = {
	ConnectFunc = function( )
		nexus.database.object = mysqloo.connect( nexus.configs.database_host, nexus.configs.database_id, nexus.configs.database_pwd, nexus.configs.database_name, nexus.configs.database_port )
		nexus.database.object.onConnected = function( )
			MsgN( "Nexus has connected by MySQL" )
		end
		nexus.database.object.onConnectionFailed = function( sql, err )
			MsgN( "Nexus has connect failed by MySQL!!!\n" .. err )
		end
		nexus.database.object:connect( )
	end,
	QueryFunc = function( query, call )
		local result = nexus.database.object:query( query )
		if ( result ) then
			if ( call ) then
				result.onSuccess = function( sql, re )
					MsgN( "Query Fin" )
					call( re )
				end
			end
			result.onError = function( sql, err )
				MsgN( "Query Error\n" .. err )
			end
			result:start( )
		end
	end,
	EscapeFunc = function( str )
		return nexus.database.object:escape( str )
	end
}

function nexus.database.Connect( )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	require( nexus.configs.database_module )
	if ( !nexus.database[ nexus.configs.database_module ] ) then
		error( "DB Func not inputed" )
		return
	end
	nexus.database[ nexus.configs.database_module ].ConnectFunc( )
end

function nexus.database.Query( sqlStr, call )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	if ( !nexus.database.object ) then
		error( "Object missing." )
		return
	end
	nexus.database[ nexus.configs.database_module ].QueryFunc( sqlStr, call )
end

function nexus.database.Insert( data, tab, call )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	if ( !nexus.database.object ) then
		error( "Object missing." )
		return
	end
	local sqlStr = "UPDATE `" .. tab .. "`"
	
	for k, v in pairs( data ) do
		sqlStr = sqlStr .. "`" .. k .. "`, "
	end
	
	sqlStr = string.sub( sqlStr, 1, -3 ) .. ") VALUES ("
	
	for k, v in pairs( data ) do
		if ( type( k ) == "string" ) then
			local t = type( v )
			if ( t == "table" ) then
				v = pon.encode( v )
			elseif ( t == "string" ) then
				v = "'" .. nexus.database.Escape( v ) .. "'"
			end
		end
		
		sqlStr = sqlStr .. v .. ", "
	end
	
	sqlStr = string.sub( sqlStr, 1, -3 ) .. ")"
	nexus.database.Query( sqlStr, call )
end

function nexus.database.Update( cre, data, tab, call )
	local sqlStr = "UPDATE `" .. tab .. "` SET "

	for k, v in pairs(data) do
		sqlStr = sqlStr .. nexus.database.Escape( k ) .. " = "

		if ( type( k ) == "string" ) then
			local t = type( v )
			if ( t == "table" ) then
				v = pon.encode( v )
			elseif ( t == "string" ) then
				v = "'" .. nexus.database.Escape( v ) .. "'"
			end
		end

		sqlStr = sqlStr .. v .. ", "
	end

	sqlStr = string.sub( sqlStr, 1, -3 ).." WHERE " .. cre
	nexus.database.Query( sqlStr, call )
end

function nexus.database.Escape( val )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	if ( !nexus.database.object ) then
		error( "Object missing." )
		return
	end
	return nexus.database[ nexus.configs.database_module ].EscapeFunc( val )
end

function nexus.database.GetTable( cre, tab, call )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	if ( !nexus.database.object ) then
		error( "Object missing." )
		return
	end
	local sqlStr = "SELECT * FROM " .. tab .. " WHERE " .. cre
	nexus.database.Query( sqlStr, call )
end

function nexus.database.GetTable_All( tab, call )
	if ( !nexus.configs.database_module ) then
		error( "DB Module missing." )
		return
	end
	if ( !nexus.database.object ) then
		error( "Object missing." )
		return
	end
	local sqlStr = "SELECT * FROM `" .. tab .. "`"
	nexus.database.Query( sqlStr, call )
end

if ( !nexus.database.object ) then
	nexus.database.Connect( )
end

--[[
nexus.database.GetTable( "Name = 'L7D'", "players", function( data )
	PrintTable( data )
end )
--]]

--[[
nexus.database.Update( "IPAddress = '127.0.0.1'", {
	IPAddress = "test"
}, "players" )
--]]

--[[
nexus.database.Insert( {
	Name = "Fristet",
	SteamID = "STEAM_0:1:25704824",
	IPAddress = "127.0.0.1"
}, "players" )
--]]