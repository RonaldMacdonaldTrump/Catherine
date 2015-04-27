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

catherine.theme = catherine.theme or { }
CAT_THEME_MENU_BACKGROUND = 1
CAT_THEME_PNLLIST = 2
CAT_THEME_FORM = 3
local func = {
	[ CAT_THEME_MENU_BACKGROUND ] = function( w, h )
		draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
		surface.SetDrawColor( 200, 200, 200, 235 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 25, w, h )
	end,
	[ CAT_THEME_PNLLIST ] = function( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end,
	[ CAT_THEME_FORM ] = function( w, h )
		draw.RoundedBox( 0, 0, 0, w, 20, Color( 225, 225, 225, 255 ) )
		draw.RoundedBox( 0, 0, 20, w, 1, Color( 50, 50, 50, 90 ) )
	end
}

function catherine.theme.Draw( typ, w, h )
	func[ typ ]( w, h )
end