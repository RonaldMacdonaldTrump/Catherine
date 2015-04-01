--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

catherine = catherine or GM

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local function badSchemaSettingFix( )
	local currGM = GetConVarString( "gamemode" ):lower( )
	if ( currGM == "catherine" ) then
		local _, gmDirs = file.Find( "gamemodes/*", "GAME" )
		for k, v in pairs( gmDirs ) do
			if ( !v:lower( ):find( "cat_" ) ) then continue end
			catherine.util.Print( Color( 255, 255, 0 ), "Don't setting gamemode to Catherine, automatic change to " .. v .. "!" )
			RunConsoleCommand( "gamemode", v )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end
	end
end

badSchemaSettingFix( )
catherine.util.AddResourceInFolder( "materials/CAT" )
catherine.util.AddResourceInFolder( "sound/CAT" )

if ( game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	concommand.Add( "gm_save", function( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.util.Notify( pl, "You are not allowed to do that" )
	end )
end