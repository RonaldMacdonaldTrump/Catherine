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

catherine.notify = catherine.notify or { }
catherine.notify.lists = { }

function catherine.notify.Add( message, time, sound )
	local index = #catherine.notify.lists + 1
	
	surface.PlaySound( sound or "buttons/button24.wav" )
	
	catherine.notify.lists[ index ] = {
		message = message or "Error",
		endTime = CurTime( ) + ( time or 5 ),
		x = ScrW( ) / 2 - ( ScrW( ) * 0.4 ) / 2,
		y = ( ScrH( ) - 10 ) - ( index * 25 ),
		w = ScrW( ) * 0.4,
		h = 20,
		a = 0
	}
end

function catherine.notify.Draw( )
	for k, v in pairs( catherine.notify.lists ) do
		if ( v.endTime <= CurTime( ) ) then
			v.a = Lerp( 0.05, v.a, 0 )
			
			if ( v.a <= 0 ) then
				table.remove( catherine.notify.lists, k )
				continue
			end
		else
			v.a = Lerp( 0.05, v.a, 255 )
		end
		
		v.y = Lerp( 0.05, v.y, ( ScrH( ) - 10 ) - ( ( k ) * 25 ) )
		
		draw.RoundedBox( 0, v.x, v.y, v.w, v.h, Color( 235, 235, 235, v.a ) )
		draw.SimpleText( v.message, "catherine_normal15", v.x + v.w / 2, v.y + v.h / 2, Color( 50, 50, 50, v.a ), 1, 1 )
	end
end