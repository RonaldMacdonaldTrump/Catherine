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
PLUGIN.name = "Head Chat"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff"

if ( SERVER ) then
	netstream.Hook( "catherine.plugin.headchat.Chat", function( pl, data )
		pl:SetNetVar( "typing", data )
	end )
else
	function PLUGIN:StartChat( )
		netstream.Start( "catherine.plugin.headchat.Chat", true )
	end
	
	function PLUGIN:FinishChat( )
		netstream.Start( "catherine.plugin.headchat.Chat", false )
	end
	
	function PLUGIN:PostPlayerDraw( pl )
		if ( !pl:IsChatTyping( ) ) then return end
		local text = "Typing ..."
		local a = catherine.util.GetAlphaFromDistance( LocalPlayer( ):GetPos( ), pl:GetPos( ), 312 )
		
		if ( math.Round( a ) <= 0 or !pl:Alive( ) or pl:GetMoveType( ) == MOVETYPE_NOCLIP ) then
			return
		end
		
		local ang = LocalPlayer( ):EyeAngles( )
		local pos = pl:GetBonePosition( pl:LookupBone( "ValveBiped.Bip01_Head1" ) ) + Vector( 0, 0, 15 )
		
		pos = pos + ang:Up( )
		ang:RotateAroundAxis( ang:Forward( ), 90 )
		ang:RotateAroundAxis( ang:Right( ), 90 )
		
		surface.SetFont( "catherine_normal50" )
		local tw, th = surface.GetTextSize( text )
		
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.08 )
			draw.SimpleText( text, "catherine_normal50", 0 - tw / 2, 0, Color( 255, 255, 255, a ) )
		cam.End3D2D( )
	end
end

local META = FindMetaTable( "Player" )

function META:IsChatTyping( )
	return self:GetNetVar( "typing", false )
end