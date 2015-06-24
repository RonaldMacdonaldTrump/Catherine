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
local META = FindMetaTable( "Player" )
PLUGIN.currAreaDisplay = PLUGIN.currAreaDisplay or nil

CAT_CONVAR_SHOW_AREA = CreateClientConVar( "cat_convar_showarea", "1", true, true )
catherine.option.Register( "CONVAR_SHOW_AREA", "cat_convar_showarea", "^Option_Str_Area_Name", "^Option_Str_Area_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )

netstream.Hook( "catherine.plugin.area.Display", function( data )
	PLUGIN:StartAreaDisplay( data )
end )

netstream.Hook( "catherine.plugin.area.DisplayPosition", function( data )
	local emitter = ParticleEmitter( data )
	local em = emitter:Add( "sprites/glow04_noz", data )
	em:SetVelocity( Vector( 0, 0, 1 ) )
	em:SetColor( 255, 255, 50 )
	em:SetStartAlpha( 255 )
	em:SetEndAlpha( 255 )
	em:SetStartSize( 64 )
	em:SetEndSize( 64 )
	em:SetDieTime( 10 )
	em:SetAirResistance( 300 )
end )

netstream.Hook( "catherine.plugin.area.DisplayPosition_Custom", function( data )
	local pos = data[ 1 ]
	local time = data[ 2 ]
	
	local emitter = ParticleEmitter( pos )
	local em = emitter:Add( "sprites/glow04_noz", pos )
	em:SetVelocity( Vector( 0, 0, 1 ) )
	em:SetColor( 255, 255, 50 )
	em:SetStartAlpha( 255 )
	em:SetEndAlpha( 255 )
	em:SetStartSize( 64 )
	em:SetEndSize( 64 )
	em:SetDieTime( time or 10 )
	em:SetAirResistance( 300 )
end )

function PLUGIN:StartAreaDisplay( text )
	surface.PlaySound( "common/talk.wav" )
	
	surface.SetFont( "catherine_normal35" )
	local tw, th = surface.GetTextSize( text )
	
	self.currAreaDisplay = {
		text = text,
		titleY = ScrH( ) * 0.2 - 80,
		textY = ScrH( ) * 0.2 + 80,
		titleA = 0,
		textA = 0,
		fadeTime = CurTime( ) + 5
	}
end

function META:GetCurrentArea( )
	return self:GetNetVar( "currArea" )
end

function META:GetCurrentAreaName( )
	return self:GetNetVar( "currAreaName" )
end

function PLUGIN:HUDPaint( )
	if ( !self.currAreaDisplay ) then return end
	local areaDisplay = self.currAreaDisplay
	local w, h = ScrW( ), ScrH( )
	
	if ( areaDisplay.fadeTime <= CurTime( ) ) then
		areaDisplay.titleY = Lerp( 0.03, areaDisplay.titleY, h * 0.2 - 80 )
		areaDisplay.textY = Lerp( 0.03, areaDisplay.textY, h * 0.2 + 80 )
		areaDisplay.titleA = Lerp( 0.05, areaDisplay.titleA, 0 )
		areaDisplay.textA = Lerp( 0.05, areaDisplay.textA, 0 )
		
		if ( math.Round( areaDisplay.titleA ) <= 0 and math.Round( areaDisplay.textA ) <= 0 ) then
			self.currAreaDisplay = nil
			return
		end
	else
		areaDisplay.titleY = Lerp( 0.03, areaDisplay.titleY, h * 0.2 - 20 )
		areaDisplay.textY = Lerp( 0.03, areaDisplay.textY, h * 0.2 + 20 )
		areaDisplay.titleA = Lerp( 0.05, areaDisplay.titleA, 255 )
		areaDisplay.textA = Lerp( 0.05, areaDisplay.textA, 255 )
	end

	draw.SimpleText( LANG( "Area_UI_JoinedStr" ), "catherine_outline30", w / 2, areaDisplay.titleY, Color( 255, 255, 255, areaDisplay.titleA ), 1, 1 )
	draw.SimpleText( areaDisplay.text, "catherine_outline25", w / 2, areaDisplay.textY, Color( 255, 255, 255, areaDisplay.textA ), 1, 1 )
end