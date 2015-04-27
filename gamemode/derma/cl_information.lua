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
	catherine.vgui.information = self
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.3, ScrH( )
	self.x, self.y = ScrW( ), ScrH( ) / 2 - self.h / 2
	self.closeing = false
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:MoveTo( ScrW( ) - self.w, self.y, 0.2, 0 )
	self:MakePopup( )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 15, 130 )
	self.Lists:SetSize( self.w - 30, self.h - 220 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists:SetDrawBackground( false )
	
	self.descEnt = vgui.Create( "DTextEntry", self )
	self.descEnt:SetPos( 90, 45 )
	self.descEnt:SetSize( self.w - 100, 30 )
	self.descEnt:SetFont( "catherine_normal15" )
	self.descEnt:SetText( self.player:Desc( ) )
	self.descEnt:SetAllowNonAsciiCharacters( true )
	self.descEnt.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.descEnt.OnEnter = function( pnl )
		catherine.command.Run( "charphysdesc", { self.descEnt:GetText( ) } )
	end
	self.descEnt.OnTextChanged = function( pnl )
		
	end

	self.playerModel = vgui.Create( "SpawnIcon", self )
	self.playerModel:SetPos( 15, 15 )
	self.playerModel:SetSize( 60, 60 )
	self.playerModel:SetModel( self.player:GetModel( ) )
	self.playerModel:SetToolTip( false )
	self.playerModel:SetDisabled( true )
	self.playerModel.PaintOver = function( pnl, w, h )
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	local data = { }
	local rpInformation = hook.Run( "AddRPInformation", self, data )
	
	for k, v in pairs( data ) do
		self:AddRPInformation( v )
	end
end

function PANEL:AddRPInformation( text )
	local panel = vgui.Create( "DPanel" )
	panel:SetSize( self.Lists:GetWide( ), 20 )
	panel.Paint = function( pnl, w, h )
		draw.SimpleText( text, "catherine_normal20", 0, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	end
	self.Lists:AddItem( panel )
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 235 ) )
		
	surface.SetDrawColor( 200, 200, 200, 235 )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	draw.SimpleText( self.player:Name( ), "catherine_normal25", 90, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.player:FactionName( ), "catherine_normal20", 15, 80, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	
	local className = self.player:ClassName( )
	if ( className ) then
		draw.SimpleText( className, "catherine_normal15", 15, 100, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	else
		draw.SimpleText( "No Class", "catherine_normal15", 15, 100, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end
	
	draw.RoundedBox( 0, 0, h - 75, w, 1, Color( 50, 50, 50, 255 ) )

	draw.SimpleText( catherine.environment.GetDateString( ), "catherine_normal35", w - 5, h - 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )
	draw.SimpleText( catherine.environment.GetTimeString( ), "catherine_normal25", w - 5, h - 35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( Material( "CAT/date/sun.png", "smooth" ) )
	surface.DrawTexturedRect( 15, h - 65, 54, 54 )
	
	draw.SimpleText( catherine.environment.GetTemperatureString( ), "catherine_normal25", 90, h - 50, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT ) // to do;
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_F1 ) then
		self:Close( )
	end
end

function PANEL:Close( )
	if ( self.closeing ) then return end
	self.closeing = true
	self:MoveTo( ScrW( ), self.y, 0.1, 0, nil, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.information", PANEL, "DFrame" )