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
local baseDir = "catherine/framework"

DeriveGamemode( "sandbox" )

GM.Name = "Catherine"
GM.Desc = "A free role-playing framework for Garry's Mod."
GM.Author = "L7D"
GM.Version = "2015/06/30"

catherine.FolderName = GM.FolderName

function catherine.Initialize( )
	--[[ Load utilities ... ]]--
	AddCSLuaFile( baseDir .. "/engine/utility.lua" )
	include( baseDir .. "/engine/utility.lua" )
	
	--[[ Load framework configs ... ]]--
	AddCSLuaFile( baseDir .. "/config/framework_config.lua" )
	include( baseDir .. "/config/framework_config.lua" )
	
	--[[ Load character file ... ]]--
	AddCSLuaFile( baseDir .. "/engine/character.lua" )
	include( baseDir .. "/engine/character.lua" )
	
	--[[ Load library files ... ]]--
	catherine.util.IncludeInDir( "library" )
	
	--[[ Load schema file ... ]]--
	AddCSLuaFile( baseDir .. "/engine/schema.lua" )
	include( baseDir .. "/engine/schema.lua" )
	
	--[[ Load engine files ... ]]--
	if ( SERVER ) then
		AddCSLuaFile( baseDir .. "/engine/client.lua" )
		AddCSLuaFile( baseDir .. "/engine/shared.lua" )
		include( baseDir .. "/engine/server.lua" )
		include( baseDir .. "/engine/shared.lua" )
		include( baseDir .. "/engine/crypto.lua" )
		include( baseDir .. "/engine/data.lua" )
		include( baseDir .. "/engine/database.lua" )
		include( baseDir .. "/engine/resource.lua" )
	else
		include( baseDir .. "/engine/client.lua" )
		include( baseDir .. "/engine/shared.lua" )
	end

	--[[ Load derma(UI) files ... ]]--
	catherine.util.IncludeInDir( "derma" )

	--[[ Load commands ... ]]--
	AddCSLuaFile( baseDir .. "/command/commands.lua" )
	include( baseDir .. "/command/commands.lua" )

	if ( SERVER ) then
		--[[ Connect to database ... ]]--
		if ( !catherine.database.Connected ) then
			catherine.database.Connect( )
		end
	end
	
	--[[ Initalized. ]]--
	hook.Run( "FrameworkInitialized" )

	catherine.isInitialized = true
end

catherine.Initialize( )