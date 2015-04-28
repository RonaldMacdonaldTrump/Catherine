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
PLUGIN.name = "^DC_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^DC_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "DisplayChating_Talking" ] = "Talking ...",
	[ "DC_Plugin_Name" ] = "Display Chating",
	[ "DC_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "DisplayChating_Talking" ] = "말 하는 중 ...",
	[ "DC_Plugin_Name" ] = "채팅 표시",
	[ "DC_Plugin_Desc" ] = "해당 사람이 채팅을 치고 있는 경우 머리 위에 메세지를 출력합니다."
} )

if ( CLIENT ) then
	function PLUGIN:PostPlayerDraw( pl )
		if ( !pl.IsChatTyping( pl ) ) then return end
		local lp = LocalPlayer( )
		local a = catherine.util.GetAlphaFromDistance( lp.GetPos( lp ), pl.GetPos( pl ), 312 )
		
		if ( math.Round( a ) <= 0 or !pl.Alive( pl ) or pl.GetMoveType( pl ) == MOVETYPE_NOCLIP ) then return end
		
		local ang = lp.EyeAngles( lp )
		local pos = pl.GetBonePosition( pl, pl.LookupBone( pl, "ValveBiped.Bip01_Head1" ) ) + Vector( 0, 0, 15 )
		
		pos = pos + ang.Up( ang )
		ang:RotateAroundAxis( ang.Forward( ang ), 90 )
		ang:RotateAroundAxis( ang.Right( ang ), 90 )
		
		local text = LANG( "DisplayChating_Talking" )
		
		surface.SetFont( "catherine_normal50" )
		local tw, th = surface.GetTextSize( text )
		
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.08 )
			draw.SimpleText( text, "catherine_normal50", 0 - tw / 2, 0, Color( 255, 255, 255, a ) )
		cam.End3D2D( )
	end
end