local CREATE_TABLES_USING_MYSQL = [[
CREATE TABLE IF NOT EXISTS `catherine_characters` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_name` varchar(70) NOT NULL,
	`_desc` tinytext NOT NULL,
	`_model` varchar(160) NOT NULL,
	`_att` varchar(180) DEFAULT NULL,
	`_schema` varchar(24) NOT NULL,
	`_registerTime` int(11) unsigned NOT NULL,
	`_steamID` varchar(20) NOT NULL,
	`_charVar` text,
	`_inv` text,
	`_gender` varchar(50),
	`_cash` int(11) unsigned DEFAULT NULL,
	`_faction` varchar(50) NOT NULL,
	PRIMARY KEY (`_id`)
);
CREATE TABLE IF NOT EXISTS `catherine_players` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_steamName` varchar(70) NOT NULL,
	`_steamID` varchar(20) NOT NULL,
	`_catData` text,
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
	`_registerTime` INTEGER,
	`_steamID` TEXT,
	`_charVar` TEXT,
	`_inv` TEXT,
	`_gender` TEXT,
	`_cash` INTEGER,
	`_faction` TEXT
);
CREATE TABLE IF NOT EXISTS `catherine_players` (
	`_id` INTEGER PRIMARY KEY,
	`_steamName` TEXT,
	`_steamID` TEXT,
	`_catData` TEXT
);
]]

local DROP_TABLES = [[
	DROP TABLE IF EXISTS `catherine_characters`;
	DROP TABLE IF EXISTS `catherine_players`;
]]

catherine.database = catherine.database or { modules = { } }
catherine.util.Include( "catherine/gamemode/sv_database_config.lua" )
catherine.database.Connected = catherine.database.Connected or false
catherine.database.ErrorMsg = catherine.database.ErrorMsg or "Server has not connected to Database."
catherine.database.object = catherine.database.object or nil
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
		catherine.database.object = mysqloo.connect( info.db_hostname, info.db_account_id, info.db_account_password, info.db_name, tonumber( info.db_port ) )
		catherine.database.object.onConnected = function( )
			catherine.database.Connected = true
			catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected to database using MySQLoo." )
			initialize( )
			if ( func ) then func( ) end
			hook.Run( "DatabaseConnected" )
		end
		catherine.database.object.onConnectionFailed = function( _, err )
			catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed using MySQLoo - " .. err .. " !!!" )
			catherine.database.Connected = false
			catherine.database.ErrorMsg = err
		end
		catherine.database.object:connect( )
	end,
	query = function( query, func )
		if ( !catherine.database.object ) then return end
		local result = catherine.database.object:query( query )
		if ( !result ) then return end
		if ( func ) then
			function result:onSuccess( data )
				func( data )
			end
		end
		function result:onError( err )
			catherine.util.Print( Color( 255, 0, 0 ), "MySQLoo Query Error : " .. query .. " -> " .. err .. " !!!" )
		end
		result:start( )
	end,
	escape = function( val )
		local typ = type( val )
		if ( typ == "string" ) then
			if ( catherine.database.object ) then
				return catherine.database.object:escape( val )
			else
				return sql.SQLStr( val, true )
			end
		elseif ( typ == "number" ) then
			val = tostring( val )
			if ( catherine.database.object ) then
				return catherine.database.object:escape( val )
			else
				return sql.SQLStr( val, true )
			end
		elseif ( typ == "table" ) then
			val = util.TableToJSON( val )
			if ( catherine.database.object ) then
				return catherine.database.object:escape( val )
			else
				return sql.SQLStr( val, true )
			end
		end
	end
}
catherine.database.modules[ "sqlite" ] = {
	connect = function( func )
		catherine.database.Connected = true
		catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected to database using SQLite." )
		catherine.database.query( CREATE_TABLES_USING_SQLITE )
		if ( func ) then
			func( )
		end
		hook.Run( "DatabaseConnected" )
	end,
	query = function( query, func )
		local result = sql.Query( query )
		if ( result == false ) then
			catherine.util.Print( Color( 255, 0, 0 ), "SQLite Query Error : " .. query .. " -> " .. sql.LastError( ) .. " !!!" )
			return
		end
		if ( func ) then
			func( result, tonumber( sql.QueryValue( "SELECT last_insert_rowid()" ) ) )
		end
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
	local modules = catherine.database.modules[ catherine.database.information.db_module ]
	if ( !modules ) then
		catherine.util.Print( Color( 255, 255, 0 ), "Unknown MySQL module, using SQLite." )
		modules = catherine.database.modules.sqlite
	end
	modules.connect( func )
	catherine.database.query = modules.query
	catherine.database.escape = modules.escape
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
	if ( cre ) then query = query .. " WHERE " .. cre end
	catherine.database.query( query, func )
end

if ( !catherine.database.Connected ) then
	catherine.database.Connect( )
end

concommand.Add( "cat_db_init", function( pl )
	if ( IsValid( pl ) and !pl:IsSuperAdmin( ) ) then
		catherine.util.Notify( pl, "You do not have permission!" )
		return
	end
	catherine.database.Query( DROP_TABLES, function( )
		catherine.util.Print( Color( 255, 0, 0 ), "Database has initialized." )
		catherine.database.Connect( )
	end )
end )