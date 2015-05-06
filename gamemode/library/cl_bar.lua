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

catherine.bar = catherine.bar or { }
catherine.bar.lists = { }
local barMaterial = Material( "CAT/bar_background.png", "smooth" )

function catherine.bar.Register( getFunc, max, color, uniqueID )
	for k, v in pairs( catherine.bar.lists ) do
		if ( ( v.uniqueID and uniqueID ) and v.uniqueID == uniqueID ) then
			return
		end
	end
	
	local index = #catherine.bar.lists + 1
	
	catherine.bar.lists[ index ] = {
		getFunc = getFunc,
		max = max,
		color = color,
		uniqueID = uniqueID,
		w = 0,
		y = -10 + ( index * 14 ),
		alpha = 0
	}
end

function catherine.bar.Draw( )
	if ( catherine.option.Get( "CONVAR_BAR" ) == "0" ) then return end
	if ( !LocalPlayer( ):Alive( ) or !LocalPlayer( ):IsCharacterLoaded( ) or #catherine.bar.lists == 0 ) then
		hook.Run( "HUDDrawBarBottom", 5, 5 )
		return
	end
	
	local count = 0
	
	for k, v in pairs( catherine.bar.lists ) do
		local percent = math.min( v.getFunc( ) / v.max( ), 1 )
		
		if ( percent == 0 ) then
			v.alpha = Lerp( 0.03, v.alpha, 0 )
		else
			count = count + 1
			v.alpha = Lerp( 0.03, v.alpha, 255 )
		end
		
		v.w = math.Approach( v.w, ( ScrW( ) * 0.3 ) * percent, 1 )
		v.y = Lerp( 0.03, v.y, -5 + count * 10 )
		
		if ( v.alpha > 0 ) then
			surface.SetDrawColor( 255,255,255, v.alpha - 30 )
			surface.SetMaterial( barMaterial )
			surface.DrawTexturedRect( 5, v.y + 4, ScrW( ) * 0.3, 1 )
			
			draw.RoundedBox( 0, 5, v.y, v.w, 5, Color( v.color.r, v.color.g, v.color.b, v.alpha ) )
		end
	end
	
	hook.Run( "HUDDrawBarBottom", 5, catherine.bar.lists[ #catherine.bar.lists ].y )
end

do
	catherine.bar.Register( function( )
		return LocalPlayer( ):Health( )
	end, function( )
		return LocalPlayer( ):GetMaxHealth( )
	end, Color( 255, 0, 150 ), "health" )

	catherine.bar.Register( function( )
		return LocalPlayer( ):Armor( )
	end, function( )
		return 255
	end, Color( 255, 255, 150 ), "armor" )
end