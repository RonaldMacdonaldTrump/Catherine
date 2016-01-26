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

local DeriveGamemode = DeriveGamemode
local AddCSLuaFile = AddCSLuaFile
local include = include

DeriveGamemode( "sandbox" )

GM.Name = "Catherine"
GM.Description = "A neat and beautiful role-play framework for Garry's Mod."
GM.Author = "L7D"
GM.Website = "https://github.com/L7D/Catherine"
GM.Email = "smhjyh2009@gmail.com"
GM.Version = "0.95.1"
GM.Build = "CAT"

catherine.FolderName = GM.FolderName

function catherine.Boot( )
	local sysTime = SysTime( )
	
	AddCSLuaFile( "catherine/framework/engine/utility.lua" )
	include( "catherine/framework/engine/utility.lua" )
	
	AddCSLuaFile( "catherine/framework/config/framework_config.lua" )
	include( "catherine/framework/config/framework_config.lua" )
	
	AddCSLuaFile( "catherine/framework/engine/character.lua" )
	include( "catherine/framework/engine/character.lua" )
	
	AddCSLuaFile( "catherine/framework/engine/plugin.lua" )
	include( "catherine/framework/engine/plugin.lua" )
	
	catherine.util.IncludeInDir( "library" )
	
	AddCSLuaFile( "catherine/framework/engine/hook.lua" )
	include( "catherine/framework/engine/hook.lua" )
	
	AddCSLuaFile( "catherine/framework/engine/schema.lua" )
	include( "catherine/framework/engine/schema.lua" )
	
	if ( SERVER ) then
		AddCSLuaFile( "catherine/framework/engine/client.lua" )
		AddCSLuaFile( "catherine/framework/engine/shared.lua" )
		AddCSLuaFile( "catherine/framework/engine/lime.lua" )
		AddCSLuaFile( "catherine/framework/engine/external_x.lua" )
		AddCSLuaFile( "catherine/framework/engine/database.lua" )
		
		include( "catherine/framework/engine/server.lua" )
		include( "catherine/framework/engine/shared.lua" )
		include( "catherine/framework/engine/crypto.lua" )
		include( "catherine/framework/engine/data.lua" )
		include( "catherine/framework/engine/database.lua" )
		include( "catherine/framework/engine/resource.lua" )
		include( "catherine/framework/engine/external_x.lua" )
		include( "catherine/framework/engine/lime.lua" )
	else
		include( "catherine/framework/engine/client.lua" )
		include( "catherine/framework/engine/shared.lua" )
		include( "catherine/framework/engine/lime.lua" )
		include( "catherine/framework/engine/external_x.lua" )
		include( "catherine/framework/engine/database.lua" )
	end
	
	catherine.util.IncludeInDir( "derma" )
	
	AddCSLuaFile( "catherine/framework/command/commands.lua" )
	include( "catherine/framework/command/commands.lua" )
	
	if ( !catherine.isInitialized ) then
		MsgC( Color( 0, 255, 0 ), "[CAT] Catherine framework are loaded at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec).\n" )
		catherine.isInitialized = true
	else
		MsgC( Color( 0, 255, 255 ), "[CAT] Catherine framework are refreshed at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec).\n" )
	end
	
	if ( SERVER and !catherine.database.connected ) then
		catherine.database.Connect( )
	end
end

local getFunctionsData = {
	{ "GetName", "Name" },
	{ "GetAuthor", "Author" },
	{ "GetDescription", "Description" },
	{ "GetVersion", "Version" },
	{ "GetBuild", "Build" },
	{ "GetWebsite", "Website" },
	{ "GetEmail", "Email" }
}

for i = 1, #getFunctionsData do
	catherine[ getFunctionsData[ i ][ 1 ] ] = function( )
		return GAMEMODE[ getFunctionsData[ i ][ 2 ] ]
	end
end

catherine.Boot( )