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
	catherine.vgui.attribute = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Attribute_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end

	self:BuildAttribute( )
end

function PANEL:OnMenuRecovered( )
	self:BuildAttribute( )
end

function PANEL:BuildAttribute( )
	self.Lists:Clear( )

	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		local item = vgui.Create( "catherine.vgui.attributeItem" )
		item:SetTall( 90 )
		item:SetAttribute( v )
		item:SetProgress( catherine.attribute.GetProgress( k ) )
		item:SetBoostProgress( catherine.attribute.GetBoostProgress( k ) )

		self.Lists:AddItem( item )
	end
end

vgui.Register( "catherine.vgui.attribute", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	self.attributeTable = nil
	self.attAni = 0
	self.attBoostAni = 0
	
	self.attTextAni = 0
	self.attProgress = 0
	
	self.attBoostProgress = 0
end

function PANEL:Paint( w, h )
	if ( !self.attributeTable ) then return end
	local per = self.attProgress / self.attributeTable.max
	local per2 = 0
	
	if ( self.attBoostProgress != 0 ) then
		per2 = self.attBoostProgress / self.attributeTable.max
		self.attBoostAni = Lerp( 0.08, self.attBoostAni, per2 * 360 )
	end
	
	self.attAni = Lerp( 0.08, self.attAni, per * 360 )
	self.attTextAni = Lerp( 0.1, self.attTextAni, per + per2 )
	
	draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
	
	draw.NoTexture( )
	surface.SetDrawColor( 200, 200, 200, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, self.attAni, 100 )
	
	if ( per2 != 0 ) then
		draw.NoTexture( )
		surface.SetDrawColor( 90, 255, 90, 255 )
		catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90 + self.attAni, self.attBoostAni, 100 )	
	end
	
	if ( self.attributeTable.image ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( self.attributeTable.image, "smooth" ) )
		surface.DrawTexturedRect( 15, 15, 60, 60 )
		
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 10, 10, 70, 70 )
	else
		draw.RoundedBox( 0, 10, 10, 70, 70, Color( 50, 50, 50, 100 ) )
	end
	
	draw.SimpleText( self.attribute_name, "catherine_normal25", 100, 30, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.attribute_desc, "catherine_normal15", 100, 60, Color( 90, 90, 90, 255 ), TEXT_ALIGN_LEFT, 1 )
	
	draw.SimpleText( math.Round( self.attTextAni * 100 ) .. " %", "catherine_normal20", w - ( h / 3 ) - 15, h / 2, Color( 0, 0, 0, 255 ), 1, 1 )
end

function PANEL:SetAttribute( attributeTable )
	self.attributeTable = attributeTable
	self.attribute_name = catherine.util.StuffLanguage( attributeTable.name )
	self.attribute_desc = catherine.util.StuffLanguage( attributeTable.desc )
end

function PANEL:SetProgress( progress )
	self.attProgress = progress
end

function PANEL:SetBoostProgress( progress )
	self.attBoostProgress = progress
end

vgui.Register( "catherine.vgui.attributeItem", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Attribute_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.attribute ) and catherine.vgui.attribute or vgui.Create( "catherine.vgui.attribute", menuPnl )
end )