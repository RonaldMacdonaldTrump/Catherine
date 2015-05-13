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
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.5
	self.name = "MENU"
	self.player = LocalPlayer( )
	
	self:SetSize( self.w, self.h )
	self:SetPos( 0 - self.w * 3, 80 )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	self:PanelCalled( )
end

function PANEL:OnMenuSizeChanged( w, h ) end
function PANEL:PanelCalled( ) end

function PANEL:SetMenuSize( w, h )
	self.w, self.h = w, h
	self:SetSize( w, h )
	self:SetPos( 0 - w, ScrH( ) / 2 - h / 2 )
	self:MoveTo( ScrW( ) / 2 - w / 2, ScrH( ) / 2 - h / 2, 0.2, 0 )
	
	self:OnMenuSizeChanged( w, h )
end

function PANEL:SetMenuName( name )
	self.name = name
end

function PANEL:IsHiding( )
	return self.isHiding
end

function PANEL:FakeHide( )
	if ( self.isHiding ) then return end
	
	self.isHiding = true
	
	self:AlphaTo( 0, 0.2, 0, nil, function( )
		self:SetVisible( false )
	end )
end

function PANEL:Show( )
	if ( !self.isHiding ) then return end
	
	self.isHiding = false
	
	self:SetPos( 0 - w, ScrH( ) / 2 - h / 2 )
	self:MoveTo( ScrW( ) / 2 - w / 2, ScrH( ) / 2 - h / 2, 0.2, 0, nil, function( )
		// nothing.
	end )
end

function PANEL:MenuPaint( w, h ) end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.SimpleText( self.name, "catherine_normal25", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	self:MenuPaint( w, h )
end

function PANEL:Close( )
	self:AlphaTo( 0, 0.2, 0, nil, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.menuBase", PANEL, "DFrame" )