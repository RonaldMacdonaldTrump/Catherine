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

catherine = catherine or GM

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local function schemaSettingsFix( )
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

schemaSettingsFix( )
catherine.util.AddResourceInFolder( "materials/CAT" )

if ( game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	
	concommand.Add( "gm_save", function( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
	end )
end

local art = [[
      `~;;:`      ..     ~~~~..~~~. `.      `.   `.~~~~~`   `.~.      .`  `.       .`  `..~~~~.
    OM8iIIio     8MM:    +++=MMi++= #M      iM~  #M=++++:  MM==i8M=  ~Mi  iMM:     Mi  iMoi+++=
  ~Mo           ;M +M        M8     8M      =M~  8M        M8    =M. ~M=  =M`Mo    M=  =M`
  MM            MI  M#       M8     8MooooooEM~  8Mi+++o   ME.~:=M=  ~M=  =M  MM   M=  =Mo+++o~
  MM           #M=+ioM=      M8     8M ....`+M~  8M ....   M#I=+M+   ~M=  =M   OM~ M=  =M:`...
  ;M+         iM.``` +M`     M8     8M      =M~  8M        M8    M8  ~M=  =M    IM:Mi  =M.
   .8M8i==+8 :M=      MM     M#     #M      iM~  #Mi+++oi  M#    iM~ ~Mi  iM     `MMi  iMO++++o
      `~;:.  ``        `     ``     ``       `   ``.....`  ``     ``  `    `       `    ``.....
]]
MsgC( Color( 0, 255, 0 ), art .. "\n" )