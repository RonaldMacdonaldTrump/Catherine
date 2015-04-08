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
	catherine.vgui.option = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( "Setting" )
	
	self.optionTable = nil

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self:InitializeOption( )
end

function PANEL:InitializeOption( )
	local opt = { }
	for k, v in pairs( catherine.option.GetAll( ) ) do
		opt[ v.category ] = opt[ v.category ] or { }
		opt[ v.category ][ #opt[ v.category ] + 1 ] = v
	end
	self.optionTable = opt
	self:BuildOption( )
end

function PANEL:BuildOption( )
	self.Lists:Clear( )
	for k, v in pairs( self.optionTable or { } ) do
		local form = vgui.Create( "DForm" )
		form:SetName( k )
		form:SetSpacing( 0 )
		form:SetAutoSize( true )
		form.Paint = function( pnl, w, h )
			catherine.theme.Draw( CAT_THEME_FORM, w, h )
		end
		form.Header:SetFont( "catherine_normal15" )
		form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
		
		for k1, v1 in pairs( v ) do
			local item = vgui.Create( "catherine.vgui.optionItem" )
			item:SetTall( 60 )
			item:SetOption( v1 )
			form:AddItem( item )
		end
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.option", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	self.optionTable, self.val, self.iconX, self.iconColor = nil, nil, 5, Color( 50, 50, 50, 255 )
	
	self.Button = vgui.Create( "DButton", self )
	self.Button:SetSize( 70, 30 )
	self.Button:SetPos( self:GetWide( ) - self.Button:GetWide( ) - 20, self:GetTall( ) / 2 - self.Button:GetTall( ) / 2 )
	self.Button:SetText( "" )
	self.Button.Paint = function( pnl, w, h )
		if ( !self.optionTable ) then return end
		self.val = catherine.option.Get( self.optionTable.uniqueID )
		
		if ( tobool( self.val ) == true ) then
			self.iconX = Lerp( 0.03, self.iconX, w - 25 )
			self.iconColor.g = Lerp( 0.03, self.iconColor.g, 200 )
		else
			self.iconX = Lerp( 0.03, self.iconX, 5 )
			self.iconColor.g = Lerp( 0.03, self.iconColor.g, 50 )
		end
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.SetMaterial( Material( "CAT/ui/option_sw_o.png", "smooth" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		surface.SetDrawColor( self.iconColor )
		surface.SetMaterial( Material( "CAT/ui/option_sw_c.png", "smooth" ) )
		surface.DrawTexturedRect( self.iconX, h / 2 - 20 / 2, 20, 20 )
	end
	self.Button.DoClick = function( pnl )
		surface.PlaySound( "common/talk.wav" )
		catherine.option.Toggle( self.optionTable.uniqueID )
	end
end

function PANEL:Paint( w, h )
	if ( !self.optionTable ) then return end
	local opt = self.optionTable
	draw.SimpleText( opt.name, "catherine_normal25", 15, 15, Color( 30, 30, 30, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( opt.desc, "catherine_normal15", 15, 40, Color( 30, 30, 30, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
end

function PANEL:PerformLayout( w, h )
	self.Button:SetSize( 70, 30 )
	self.Button:SetPos( w - self.Button:GetWide( ) - 20, h / 2 - self.Button:GetTall( ) / 2 )
end

function PANEL:SetOption( optionTable )
	self.optionTable = optionTable
end

vgui.Register( "catherine.vgui.optionItem", PANEL, "DPanel" )

catherine.menu.Register( "Setting", function( menuPnl, itemPnl )
	return vgui.Create( "catherine.vgui.option", menuPnl )
end )