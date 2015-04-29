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

local PLUGIN = PLUGIN
PLUGIN.name = "^DB_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^DB_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "DB_Plugin_Name" ] = "FPS",
	[ "DB_Plugin_Desc" ] = "Good stuff.",
	[ "Option_Str_DB_Name" ] = "Show FPS",
	[ "Option_Str_DB_Desc" ] = "Displays the FPS."
} )

catherine.language.Merge( "korean", {
	[ "DB_Plugin_Name" ] = "FPS",
	[ "DB_Plugin_Desc" ] = "FPS 를 표시합니다.",
	[ "Option_Str_DB_Name" ] = "FPS 표시",
	[ "Option_Str_DB_Desc" ] = "FPS 를 표시합니다."
} )

if ( SERVER ) then return end

CAT_CONVAR_FPS = CreateClientConVar( "cat_convar_showfps", "0", true, true )
catherine.option.Register( "CONVAR_FPS", "cat_convar_showfps", "^Option_Str_DB_Name", "^Option_Str_DB_Desc", "^Option_Category_02", CAT_OPTION_SWITCH )

function PLUGIN:HUDPaint( )
	if ( CAT_CONVAR_FPS:GetInt( ) == 0 ) then return end
	
	local curFPS = math.Round( 1 / FrameTime( ) )
	local minFPS = self.minFPS or 60
	local maxFPS = self.maxFPS or 100
	local barW = ( curFPS / maxFPS ) * 90
	if ( curFPS > maxFPS ) then
		self.maxFPS = curFPS
	end
	
	if ( curFPS < minFPS ) then
		self.minFPS = curFPS
	end
	
	draw.SimpleText( "Current : " .. curFPS, "catherine_fps", ScrW( ) - 10, ScrH( ) / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.RoundedBox( 0, ScrW( ) - 100, ScrH( ) / 2 + 15, barW, 10, Color( 255, 255, 255, 255 ) )
	draw.SimpleText( "MAX : " .. maxFPS, "catherine_fps", ScrW( ) - 10, ScrH( ) / 2 + 40, Color( 150, 255, 150, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.SimpleText( "MIN : " .. minFPS, "catherine_fps", ScrW( ) - 10, ScrH( ) / 2 + 55, Color( 255, 150, 150, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

catherine.font.Register( "catherine_fps", "Consolas Bold", 15, 1000 )