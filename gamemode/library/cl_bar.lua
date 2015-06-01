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
local barW = ScrW( ) * catherine.configs.mainBarWideScale
local barH = catherine.configs.mainBarTallSize

function catherine.bar.Register( uniqueID, alwaysShowing, getFunc, maxFunc, col )
	for k, v in pairs( catherine.bar.lists ) do
		if ( ( v.uniqueID and uniqueID ) and v.uniqueID == uniqueID ) then
			return
		end
	end
	
	local index = #catherine.bar.lists + 1
	
	catherine.bar.lists[ index ] = {
		getFunc = getFunc,
		maxFunc = maxFunc,
		col = col,
		uniqueID = uniqueID,
		w = 0,
		y = -( barH / 2 ) + ( index * barH / 2 ),
		a = 0,
		alwaysShowing = alwaysShowing,
		lifeTime = 0,
		prevValue = 0
	}
end

function catherine.bar.Remove( uniqueID )
	for k, v in pairs( catherine.bar.lists ) do
		if ( v.uniqueID and v.uniqueID == uniqueID ) then
			table.remove( catherine.bar.lists, k )
		end
	end
end

function catherine.bar.Draw( )
	if ( GetConVarString( "cat_convar_bar" ) == "0" ) then return end
	if ( hook.Run( "CantDrawBar" ) or !LocalPlayer( ):Alive( ) or !LocalPlayer( ):IsCharacterLoaded( ) or #catherine.bar.lists == 0 ) then
		hook.Run( "HUDDrawBarBottom", 5, 5 )
		return
	end
	
	local i = 0
	
	for k, v in pairs( catherine.bar.lists ) do
		local per = math.min( v.getFunc( ) / v.maxFunc( ), 1 )
		
		if ( v.prevValue != per ) then
			v.lifeTime = CurTime( ) + 5
		end

		v.prevValue = per
		
		if ( !v.alwaysShowing ) then
			if ( v.lifeTime <= CurTime( ) ) then
				v.a = Lerp( 0.03, v.a, 0 )
			else
				if ( per != 0 ) then
					i = i + 1
					v.a = Lerp( 0.03, v.a, 255 )
				else
					v.a = Lerp( 0.03, v.a, 0 )
				end
			end
		else
			if ( per != 0 ) then
				i = i + 1
				v.a = Lerp( 0.03, v.a, 255 )
			else
				v.a = Lerp( 0.03, v.a, 0 )
			end
		end

		v.w = math.Approach( v.w, barW * per, 1 )
		v.y = Lerp( 0.09, v.y, -barH + i * barH * 2 )
		
		if ( v.a > 0 ) then
			local col = v.col
			
			draw.RoundedBox( 0, 5, v.y, barW, barH, Color( 255, 255, 255, v.a / 1.5 ) )
			draw.RoundedBox( 0, 5, v.y, v.w, barH, Color( col.r, col.g, col.b, v.a ) )
		end
	end
	
	hook.Run( "HUDDrawBarBottom", 5, catherine.bar.lists[ #catherine.bar.lists ].y )
end

do
	catherine.bar.Register( "health", true, function( )
			return LocalPlayer( ):Health( )
		end, function( )
			return LocalPlayer( ):GetMaxHealth( )
		end, Color( 255, 50, 50 )
	)
	
	catherine.bar.Register( "armor", true, function( )
			return LocalPlayer( ):Armor( )
		end, function( )
			return 255
		end, Color( 50, 50, 255 )
	)
end