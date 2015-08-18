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

local PANEL = { }

function PANEL:Init( )
	self.volume = 0
	self.volumeColor = Color( 150, 255, 150, 255 )
		
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	
	self.name = vgui.Create( "DLabel", self )
	self.name:SetFont( "catherine_normal15" )
	self.name:SetColor( Color( 90, 90, 90, 255 ) )
end

function PANEL:Setup( pl )
	if ( LocalPlayer( ):IsKnow( pl ) or LocalPlayer( ) == pl ) then
		self.isKnow = true
		
		self.avatar = vgui.Create( "AvatarImage", self )
		self.avatar:SetSize( 32, 32 )
		self.avatar:SetPos( 4, 4 )
		self.avatar:SetPlayer( pl )
		self.avatar.PaintOver = function( pnl, w, h )
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		
		self.name:SetText( pl:Name( ) )
	else
		self.isKnow = false
		
		self.avatar = vgui.Create( "AvatarImage", self )
		self.avatar:SetSize( 32, 32 )
		self.avatar:SetPos( 4, 4 )
		self.avatar.PaintOver = function( pnl, w, h )
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		
		self.name:SetText( pl:Desc( ):sub( 1, 33 ) .. "..." )
	end
	
	self:SetSize( 250, 40 )
	self.name:SetPos( 42, 13 )
	self.name:SizeToContents( )
	
	self.player = pl
end

function PANEL:Think( )
	if ( !IsValid( self.player ) or !self.player:IsSpeaking( ) ) then
		self:AlphaTo( 0, 0.1, 0, function( )
			if ( IsValid( self ) ) then
				self:Remove( )
			end
		end )
	end
end

function PANEL:Paint( w, h )
	if ( !IsValid( self.player ) ) then return end
	
	self.volume = Lerp( 0.03, self.volume, self.player:VoiceVolume( ) * h )
			
	local volume = math.Round( self.volume )

	if ( volume <= 18 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 150 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 255 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 150 )
	elseif ( volume > 18 and volume <= 23 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 255 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 255 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 150 )
	elseif ( volume > 23 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 255 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 150 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 150 )
	end
			
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
	
	draw.RoundedBox( 0, w - 15, h - self.volume, 15, self.volume, Color( self.volumeColor.r, self.volumeColor.g, self.volumeColor.b, 255 ) )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h )
end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )