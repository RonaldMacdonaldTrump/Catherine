--[[
CREATE TABLE IF NOT EXISTS `nexus_characters` (
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
--]]
nexus.database = nexus.database or { }
nexus.database.Connected = nexus.database.Connected or false
nexus.database.object = nexus.database.object or nil
nexus.database[ "mysqloo" ] = {
	ConnectFunc = function( )
		nexus.database.object = mysqloo.connect( nexus.configs.database_host, nexus.configs.database_id, nexus.configs.database_pwd, nexus.configs.database_name, nexus.configs.database_port )
		nexus.database.object.onConnected = function( )
			nexus.util.Print( Color( 0, 255, 0 ), "Nexus framework has connected by MySQL!" )
			nexus.database.Connected = true
			nexus.character.LoadAllByDataBases( )
		end
		nexus.database.object.onConnectionFailed = function( _, err )
			nexus.util.Print( Color( 255, 0, 0 ), "Nexus framework has connect failed by MySQL!!! - " .. err )
			nexus.database.Connected = false
		end
		nexus.database.object:connect( )
	end,
	QueryFunc = function( query, call )
		local result = nexus.database.object:query( query )
		if ( result ) then
			if ( call ) then
				result.onSuccess = function( _, re )
					call( re )
				end
			end
			result.onError = function( _, err )
				nexus.util.Print( Color( 255, 0, 0 ), "MySQL Error - " .. err )
			end
			result:start( )
		end
	end,
	EscapeFunc = function( str )
		return nexus.database.object:escape( str )
	end
}

function nexus.database.Connect( )
	local moduleConfig = nexus.configs.database_module
	if ( !moduleConfig ) then
		return nexus.util.Print( Color( 255, 0, 0 ), "Nexus framework has connect failed by MySQL!!! - please set 'nexus.configs.database_module' config to database module!" )
	end
	require( moduleConfig )
	if ( !nexus.database[ moduleConfig ] ) then
		return nexus.util.Print( Color( 255, 0, 0 ), "Nexus framework has connect failed by MySQL!!! - function not found!" )
	end
	nexus.database[ moduleConfig ].ConnectFunc( )
end

function nexus.database.Query( sqlStr, call )
	if ( !nexus.database.Connected or !nexus.database.object ) then return end
	nexus.database[ nexus.configs.database_module ].QueryFunc( sqlStr, call )
end

function nexus.database.Insert( data, tab, func )
	if ( !nexus.database.Connected or !nexus.database.object ) then return end
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
				v = "'" .. nexus.database.Escape( v ) .. "'"
			end
		end
		sqlStr = sqlStr .. v .. ", "
	end
	
	sqlStr = string.sub( sqlStr, 1, -3 ) .. " )"
	nexus.database.Query( sqlStr, func )
end

function nexus.database.Update( cre, data, tab, func )
	if ( !nexus.database.Connected or !nexus.database.object ) then return end
	local sqlStr = "UPDATE `" .. tab .. "` SET "

	for k, v in pairs(data) do
		sqlStr = sqlStr .. nexus.database.Escape( k ) .. " = "
		if ( type( k ) == "string" ) then
			local t = type( v )
			if ( t == "table" ) then
				v = "'" .. util.TableToJSON( v ) .. "'"
			elseif ( t == "string" ) then
				print(v)
				v = "'" .. nexus.database.Escape( v ) .. "'"
			end
		end
		sqlStr = sqlStr .. v .. ", "
	end
	sqlStr = string.sub( sqlStr, 1, -3 ).." WHERE " .. cre
	nexus.database.Query( sqlStr, func )
end

function nexus.database.Escape( val )
	if ( !nexus.database.Connected or !nexus.database.object ) then return nil end
	return nexus.database[ nexus.configs.database_module ].EscapeFunc( val )
end

function nexus.database.GetTable( cre, tab, func )
	if ( !nexus.database.Connected or !nexus.database.object ) then return { } end
	local sqlStr = "SELECT * FROM " .. tab .. " WHERE " .. cre
	nexus.database.Query( sqlStr, func )
end

function nexus.database.GetTable_All( tab, func )
	if ( !nexus.database.Connected or !nexus.database.object ) then return { } end
	local sqlStr = "SELECT * FROM `" .. tab .. "`"
	nexus.database.Query( sqlStr, func )
end

if ( !nexus.database.Connected ) then
	nexus.database.Connect( )
end