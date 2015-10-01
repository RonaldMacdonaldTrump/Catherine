--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.database = catherine.database or { }

if ( SERVER ) then
	catherine.database.modules = { }
	catherine.database.Connected = catherine.database.Connected or false
	catherine.database.ErrorMsg = catherine.database.ErrorMsg or "Connection Error"
	catherine.database.object = catherine.database.object or nil

	local CREATE_TABLES_USING_MYSQL = [[
	CREATE TABLE IF NOT EXISTS `catherine_characters` (
		`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		`_name` varchar(70) NOT NULL,
		`_desc` tinytext NOT NULL,
		`_model` varchar(160) NOT NULL,
		`_att` varchar(180) DEFAULT NULL,
		`_schema` varchar(24) NOT NULL,
		`_registerTime` text,
		`_steamID` varchar(20) NOT NULL,
		`_charVar` text,
		`_inv` text,
		`_cash` int(11) unsigned DEFAULT NULL,
		`_faction` varchar(50) NOT NULL,
		PRIMARY KEY (`_id`)
	);
	CREATE TABLE IF NOT EXISTS `catherine_players` (
		`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		`_steamName` varchar(70) NOT NULL,
		`_steamID` varchar(20) NOT NULL,
		`_catData` text,
		`_steamID64` text,
		`_ipAddress` varchar(50) DEFAULT NULL,
		`_lastConnect` text,
		PRIMARY KEY (`_id`)
	);
	]]

	local CREATE_TABLES_USING_SQLITE = [[
	CREATE TABLE IF NOT EXISTS `catherine_characters` (
		`_id` INTEGER PRIMARY KEY,
		`_name` TEXT,
		`_desc` TEXT,
		`_model` TEXT,
		`_att` TEXT,
		`_schema` TEXT,
		`_registerTime` TEXT,
		`_steamID` TEXT,
		`_charVar` TEXT,
		`_inv` TEXT,
		`_cash` INTEGER,
		`_faction` TEXT
	);
	CREATE TABLE IF NOT EXISTS `catherine_players` (
		`_id` INTEGER PRIMARY KEY,
		`_steamName` TEXT,
		`_steamID` TEXT,
		`_catData` TEXT,
		`_steamID64` TEXT,
		`_ipAddress` TEXT,
		`_lastConnect` TEXT
	);
	]]

	local DROP_TABLES = [[
		DROP TABLE IF EXISTS `catherine_characters`;
		DROP TABLE IF EXISTS `catherine_players`;
	]]

	catherine.database.modules[ "mysqloo" ] = {
		connect = function( func )
			if ( !pcall( require, "mysqloo" ) ) then
				catherine.util.Print( Color( 255, 0, 0 ), "Can't load database module!!! - MySQLoo" )
				return
			end
			
			local function initialize( )
				local queries = string.Explode( ";", CREATE_TABLES_USING_MYSQL )

				for i = 1, 2 do
					catherine.database.query( queries[ i ] )
				end
			end
			
			local info = catherine.database.information
			catherine.database.object = mysqloo.connect( info.DATABASE_HOST or "127.0.0.1", info.DATABASE_ID, info.DATABASE_PASSWORD, info.DATABASE_NAME, tonumber( info.DATABASE_PORT ) or 3306 )
			catherine.database.object.onConnected = function( )
				catherine.database.Connected = true
				catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected to database using MySQLoo." )
				initialize( )
				
				catherine.database.SetStatus( 0 )
				
				if ( func ) then
					func( )
				end
				
				hook.Run( "DatabaseConnected" )
			end
			catherine.database.object.onConnectionFailed = function( _, err )
				catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed using MySQLoo - " .. err .. " !!!" )
				catherine.database.Connected = false
				catherine.database.ErrorMsg = err
				
				catherine.database.SetStatus( 3 )
			end
			
			catherine.database.object:connect( )
		end,
		query = function( query, func )
			if ( !catherine.database.object ) then return end
			catherine.database.SetStatus( 1 )
			
			local result = catherine.database.object:query( query )
			
			if ( !result ) then
				catherine.database.SetStatus( 0 )
				return
			end
			
			function result:onSuccess( data )
				if ( func ) then
					func( data )
				end
				
				timer.Simple( 2, function( )
					if ( catherine.database.GetStatus( ) == 1 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
			end
			
			function result:onError( err )
				catherine.database.SetStatus( 2 )
				
				MsgC( Color( 255, 0, 0 ), "[CAT Query ERROR] " .. query .. " -> " .. err .. " !!!\n" )
				
				timer.Simple( 10, function( )
					if ( catherine.database.GetStatus( ) == 2 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
			end
			
			result:start( )
		end,
		escape = function( val )
			local typ = type( val )
			
			if ( typ == "string" ) then
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			elseif ( typ == "number" ) then
				val = tostring( val )
				
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			elseif ( typ == "table" ) then
				val = util.TableToJSON( val )
				
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			end
		end
	}
	catherine.database.modules[ "tmysql4" ] = {
		connect = function( func )
			if ( !pcall( require, "tmysql4" ) ) then
				catherine.util.Print( Color( 255, 0, 0 ), "Can't load database module!!! - tMySQL4" )
				return
			end
			
			local function initialize( )
				local queries = string.Explode( ";", CREATE_TABLES_USING_MYSQL )

				for i = 1, 2 do
					catherine.database.query( queries[ i ] )
				end
			end
			
			local info = catherine.database.information
			local object, err = tmysql.initialize( info.DATABASE_HOST or "127.0.0.1", info.DATABASE_ID, info.DATABASE_PASSWORD, info.DATABASE_NAME, tonumber( info.DATABASE_PORT ) or 3306 )
			
			if ( object ) then
				catherine.database.object = object
				catherine.database.Connected = true
				catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected to database using tMySQL4." )
				initialize( )
				
				catherine.database.SetStatus( 0 )
				
				if ( func ) then
					func( )
				end
				
				hook.Run( "DatabaseConnected" )
			else
				catherine.database.SetStatus( 3 )
				
				catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed using tMySQL4 - " .. err .. " !!!" )
				catherine.database.Connected = false
				catherine.database.ErrorMsg = err
				
				hook.Run( "DatabaseError", nil, err )
			end
		end,
		query = function( query, func )
			catherine.database.SetStatus( 1 )
			
			catherine.database.object:Query( query, function( data, status, err )
				if ( QUERY_SUCCESS and status == QUERY_SUCCESS ) then
					timer.Simple( 2, function( )
						if ( catherine.database.GetStatus( ) == 1 ) then
							catherine.database.SetStatus( 0 )
						end
					end )
					
					if ( func ) then
						func( data )
					end
				else
					catherine.database.SetStatus( 2 )
					
					if ( data and data[ 1 ] ) then
						local firstData = data[ 1 ]
						
						if ( firstData.status ) then
							if ( func ) then
								func( firstData.data, firstData.lastid )
							end
							
							return
						else
							err = firstData.error
						end
					end
					
					MsgC( Color( 255, 0, 0 ), "[CAT Query ERROR] " .. query .. " -> " .. ( err or "Unknown" ) .. " !!!\n" )
					hook.Run( "DatabaseError", query, err )
					
					timer.Simple( 10, function( )
						if ( catherine.database.GetStatus( ) == 2 ) then
							catherine.database.SetStatus( 0 )
						end
					end )
				end
			end )
		end,
		escape = function( val )
			if ( catherine.database.object ) then
				return catherine.database.object:Escape( val )
			end
			
			return ( tmysql and tmysql.escape ) and tmysql.escape( val ) or sql.SQLStr( val, true )
		end
	}
	catherine.database.modules[ "sqlite" ] = {
		connect = function( func )
			catherine.database.Connected = true
			catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected to database using SQLite." )
			catherine.database.query( CREATE_TABLES_USING_SQLITE )
			
			catherine.database.SetStatus( 0 )
			
			if ( func ) then
				func( )
			end
			
			hook.Run( "DatabaseConnected" )
		end,
		query = function( query, func )
			catherine.database.SetStatus( 1 )
			
			local result = sql.Query( query )
			
			if ( result == false ) then
				catherine.database.SetStatus( 2 )
				
				local err = sql.LastError( )
				
				MsgC( Color( 255, 0, 0 ), "[CAT Query ERROR] " .. query .. " -> " .. err .. " !!!\n" )
				hook.Run( "DatabaseError", query, err )
				
				timer.Simple( 10, function( )
					if ( catherine.database.GetStatus( ) == 2 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
				
				return
			end
			
			if ( func ) then
				func( result, tonumber( sql.QueryValue( "SELECT last_insert_rowid()" ) ) )
			end
			
			timer.Simple( 2, function( )
				if ( catherine.database.GetStatus( ) == 1 ) then
					catherine.database.SetStatus( 0 )
				end
			end )
		end,
		escape = function( val )
			local typ = type( val )
			
			if ( typ == "string" ) then
				return sql.SQLStr( val, true )
			elseif ( typ == "number" ) then
				return sql.SQLStr( tostring( val ), true )
			elseif ( typ == "table" ) then
				return sql.SQLStr( util.TableToJSON( val ), true )
			end
		end
	}
	catherine.database.query = catherine.database.query or catherine.database.modules.sqlite.query
	catherine.database.escape = catherine.database.escape or catherine.database.modules.sqlite.escape
	
	function catherine.database.Connect( func )
		catherine.database.information = catherine.database.GetConfig( )
		
		local modules = catherine.database.modules[ catherine.database.information.DATABASE_MODULE ]
		
		if ( !modules ) then
			catherine.util.Print( Color( 255, 0, 0 ), "A unknown Database module! <" .. catherine.database.information.DATABASE_MODULE .. ">, so instead using SQLite." )
			modules = catherine.database.modules.sqlite
		end
		
		modules.connect( func )
		catherine.database.query = modules.query
		catherine.database.escape = modules.escape
	end
	
	function catherine.database.SetStatus( id )
		SetGlobalInt( "catherine.database.status", id )
	end
	
	function catherine.database.GetConfig( )
		local config = file.Read( "catherine/database_config.cfg", "LUA" ) or nil
		
		if ( config ) then
			local result = CompileString( config, "catherine.database.GetConfig" )( )
			
			if ( result and type( result ) == "table" and table.Count( result ) == 6 ) then
				return result
			else
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load Database config file, so instead using SQLite.\n" )
				
				return {
					DATABASE_MODULE = "sqlite",
					DATABASE_HOST = "127.0.0.1",
					DATABASE_ID = "root",
					DATABASE_PASSWORD = "",
					DATABASE_NAME = "",
					DATABASE_PORT = 3306
				}
			end
		else
			MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load Database config file, so instead using SQLite.\n" )
			
			return {
				DATABASE_MODULE = "sqlite",
				DATABASE_HOST = "127.0.0.1",
				DATABASE_ID = "root",
				DATABASE_PASSWORD = "",
				DATABASE_NAME = "",
				DATABASE_PORT = 3306
			}
		end
	end

	function catherine.database.InsertDatas( tab, data, func )
		if ( !catherine.database.Connected or !tab or !data ) then return end
		local query = "INSERT INTO `" .. tab .. "` ( "
		
		for k, v in pairs( data ) do
			query = query .. "`" .. k .. "`, "
		end
		
		query = query:sub( 1, -3 ) .. " ) VALUES ( "
		
		for k, v in pairs( data ) do
			query = query .. "'" .. catherine.database.escape( v ) .. "', "
		end
		
		query = query:sub( 1, -3 ) .. " )"
		catherine.database.query( query, func )
	end

	function catherine.database.UpdateDatas( tab, cre, newData, func )
		if ( !catherine.database.Connected or !tab or !newData or !cre ) then return end
		local query = "UPDATE `" .. tab .. "` SET "

		for k, v in pairs( newData ) do
			query = query .. k .. " = '" .. catherine.database.escape( v ) .. "', "
		end
		
		query = query:sub( 1, -3 ) .. " WHERE " .. cre
		catherine.database.query( query, func )
	end

	function catherine.database.Query( query, func )
		if ( !catherine.database.Connected or !query ) then return end
		
		catherine.database.query( query, func )
	end

	function catherine.database.GetDatas( tab, cre, func )
		if ( !catherine.database.Connected or !tab ) then return end
		local query = "SELECT * FROM " .. "`" .. tab .. "`"
		
		if ( cre ) then
			query = query .. " WHERE " .. cre
		end
		
		catherine.database.query( query, func )
	end

	--[[
		[ How can i reset the database? ]
		
		Input 'cat_db_init' command to 'Dedicated Console'.
		( if you are working Local Server, Run command in Client Console !! ( You are must be joined 'Super Admin' group. ) )
	]]--

	concommand.Add( "cat_db_init", function( pl )
		if ( game.IsDedicated( ) and IsValid( pl ) ) then
			return
		elseif ( !game.IsDedicated( ) and !pl:IsSuperAdmin( ) ) then
			return
		end

		if ( catherine.database.object ) then
			local ex = string.Explode( ";", DROP_TABLES )
			
			for i = 1, 2 do
				catherine.database.Query( ex[ i ], function( )
					if ( i == 2 ) then
						catherine.util.Print( Color( 255, 0, 0 ), "ALL Database has initialized." )
						catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "ALL Database has initialized!!!" )
						RunConsoleCommand( "changelevel", game.GetMap( ) )
					end
				end )
			end
		else
			catherine.database.Query( DROP_TABLES, function( )
				catherine.util.Print( Color( 255, 0, 0 ), "ALL Database has initialized." )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "ALL Database has initialized!!!" )
				RunConsoleCommand( "changelevel", game.GetMap( ) )
			end )
		end
	end )
else
	
end

function catherine.database.GetStatus( )
	return GetGlobalInt( "catherine.database.status", 3 )
end