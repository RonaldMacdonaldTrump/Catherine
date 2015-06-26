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
local cat_include = catherine.util.Include
local cat_includeDir = catherine.util.IncludeInDir
local baseDir = "catherine/framework"

DeriveGamemode( "sandbox" )

catherine.Name = "Catherine"
catherine.Desc = "A free role-playing framework for Garry's Mod."
catherine.Author = "L7D"

function catherine.Initialize( )
	--[[ Load framework configs ... ]]--
	AddCSLuaFile( baseDir .. "/config/framework_config.lua" )
	include( baseDir .. "/config/framework_config.lua" )
	
	--[[ Load utilities ... ]]--
	AddCSLuaFile( "utility.lua" )
	include( "utility.lua" )

	--[[ Load external library files ... ]]--
	cat_includeDir( "engine/external" )
	
	--[[ Load library files ... ]]--
	cat_includeDir( "library" )
	
	--[[ Load derma(UI) files ... ]]--
	cat_includeDir( "derma" )
	
	--[[ Load commands ... ]]--
	AddCSLuaFile( baseDir .. "/command/commands.lua" )
	include( baseDir .. "/command/commands.lua" )

	--[[ Load engine files ... ]]--
	if ( SERVER ) then
		AddCSLuaFile( "shared.lua" )
		AddCSLuaFile( "client.lua" )
		include( "crypto.lua" )
		include( "data.lua" )
		include( "database.lua" )
		include( "server.lua" )
		include( "shared.lua" )
	else
		include( "client.lua" )
		include( "shared.lua" )
	end

	AddCSLuaFile( "schema.lua" )
	include( "schema.lua" )
	
	--[[ Connect to database ... ]]--
	if ( !catherine.database.Connected ) then
		catherine.database.Connect( )
	end
	
	--[[ Initalized. ]]--
	hook.Run( "FrameworkInitialized" )

	catherine.isInitialized = true
end

catherine.Initialize( )