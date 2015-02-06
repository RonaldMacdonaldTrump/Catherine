--[[
CREATE TABLE IF NOT EXISTS `catherine_characters` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_name` varchar(70) NOT NULL,
	`_desc` tinytext NOT NULL,
	`_model` varchar(160) NOT NULL,
	`_att` varchar(180) DEFAULT NULL,
	`_schema` varchar(24) NOT NULL,
	`_registerTime` int(11) unsigned NOT NULL,
	`_steamID` varchar(160) NOT NULL,
	`_charData` tinytext,
	`_inv` tinytext,
	`_cash` int(11) unsigned DEFAULT NULL,
	`_faction` varchar(50) NOT NULL,
	PRIMARY KEY (`_id`)
);

CREATE TABLE IF NOT EXISTS `catherine_players` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_steamName` varchar(70) NOT NULL,
	`_steamID` tinytext NOT NULL,
	`_catherineData` tinytext,
	PRIMARY KEY (`_id`)
);
--]]
catherine.database = catherine.database or { }
catherine.database.Connected = catherine.database.Connected or false
catherine.database.object = catherine.database.object or nil
catherine.database[ "mysqloo" ] = {
	ConnectFunc = function( )
		catherine.database.object = mysqloo.connect( catherine.configs.database_host, catherine.configs.database_id, catherine.configs.database_pwd, catherine.configs.database_name, catherine.configs.database_port )
		catherine.database.object.onConnected = function( )
			catherine.util.Print( Color( 0, 255, 0 ), "Catherine has connected by MySQL!" )
			catherine.database.Connected = true
			catherine.character.LoadAllByDataBases( )
		end
		catherine.database.object.onConnectionFailed = function( _, err )
			catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed by MySQL!!! - " .. err )
			catherine.database.Connected = false
		end
		catherine.database.object:connect( )
	end,
	QueryFunc = function( query, call )
		local result = catherine.database.object:query( query )
		if ( result ) then
			if ( call ) then
				result.onSuccess = function( _, re )
					call( re )
				end
			end
			result.onError = function( _, err )
				catherine.util.Print( Color( 255, 0, 0 ), "MySQL Error - " .. err )
			end
			result:start( )
		end
	end,
	EscapeFunc = function( str )
		return catherine.database.object:escape( str )
	end
}

function catherine.database.Connect( )
	local moduleConfig = catherine.configs.database_module
	if ( !moduleConfig ) then
		return catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed by MySQL!!! - please set 'catherine.configs.database_module' config to database module!" )
	end
	require( moduleConfig )
	if ( !catherine.database[ moduleConfig ] ) then
		return catherine.util.Print( Color( 255, 0, 0 ), "Catherine has connect failed by MySQL!!! - function not found!" )
	end
	catherine.database[ moduleConfig ].ConnectFunc( )
end

function catherine.database.Query( sqlStr, call )
	if ( !catherine.database.Connected or !catherine.database.object ) then return end
	catherine.database[ catherine.configs.database_module ].QueryFunc( sqlStr, call )
end

function catherine.database.Insert( data, tab, func )
	if ( !catherine.database.Connected or !catherine.database.object ) then return end
	local sqlStr = "INSERT INTO `" .. tab .. "` ( "
	
	for k, v in pairs( data ) do
		sqlStr = sqlStr .. "`" .. k .. "`, "
	end
	
	sqlStr = string.sub( sqlStr, 1, -3 ) .. " ) VALUES ( "
	
	for k, v in pairs( data ) do
		if ( type( k ) == "string" ) then
			local t = type( v )
			if ( t == "table" ) then
				v = pon.encode( v )
			elseif ( t == "string" ) then
				v = "'" .. catherine.database.Escape( v ) .. "'"
			end
		end
		sqlStr = sqlStr .. v .. ", "
	end
	
	sqlStr = string.sub( sqlStr, 1, -3 ) .. " )"
	catherine.database.Query( sqlStr, func )
end

function catherine.database.Update( cre, data, tab, func )
	if ( !catherine.database.Connected or !catherine.database.object ) then return end
	local sqlStr = "UPDATE `" .. tab .. "` SET "

	for k, v in pairs(data) do
		sqlStr = sqlStr .. catherine.database.Escape( k ) .. " = "
		if ( type( k ) == "string" ) then
			local t = type( v )
			if ( t == "table" ) then
				v = "'" .. util.TableToJSON( v ) .. "'"
			elseif ( t == "string" ) then
				print(v)
				v = "'" .. catherine.database.Escape( v ) .. "'"
			end
		end
		sqlStr = sqlStr .. v .. ", "
	end
	sqlStr = string.sub( sqlStr, 1, -3 ).." WHERE " .. cre
	catherine.database.Query( sqlStr, func )
end

function catherine.database.Escape( val )
	if ( !catherine.database.Connected or !catherine.database.object ) then return nil end
	return catherine.database[ catherine.configs.database_module ].EscapeFunc( val )
end

function catherine.database.GetTable( cre, tab, func )
	if ( !catherine.database.Connected or !catherine.database.object ) then return { } end
	local sqlStr = "SELECT * FROM " .. tab .. " WHERE " .. cre
	catherine.database.Query( sqlStr, func )
end

function catherine.database.GetTable_All( tab, func )
	if ( !catherine.database.Connected or !catherine.database.object ) then return { } end
	local sqlStr = "SELECT * FROM `" .. tab .. "`"
	catherine.database.Query( sqlStr, func )
end

if ( !catherine.database.Connected ) then
	catherine.database.Connect( )
end