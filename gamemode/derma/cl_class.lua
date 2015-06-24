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
	catherine.vgui.class = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Class_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.classes and table.Count( self.classes ) == 0 ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Class_UI_NoJoinable" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self:InitializeClasses( )
end

function PANEL:OnMenuRecovered( )
	self:InitializeClasses( )
end

function PANEL:InitializeClasses( )
	self.classes = catherine.class.GetJoinable( )
	
	self:BuildClasses( )
end

function PANEL:BuildClasses( )
	self.Lists:Clear( )
	
	for k, v in pairs( self.classes or { } ) do
		local name = catherine.util.StuffLanguage( v.name )
		local desc = catherine.util.StuffLanguage( v.desc )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Lists:GetWide( ), 70 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
			
			draw.SimpleText( name, "catherine_normal25", 80, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( desc, "catherine_normal15", 80, 50, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( LANG( "Class_UI_LimitStr", #catherine.class.GetPlayers( v.uniqueID ), v.limit or LANG( "Class_UI_Unlimited" ) ), "catherine_normal20", w - 10, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.SimpleText( LANG( "Class_UI_SalaryStr", catherine.cash.GetName( v.salary or 0 ) ), "catherine_normal20", w - 10, 50, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ), panel:GetTall( ) )
		button:Center( )
		button:SetText( "" )
		button:SetDrawBackground( false )
		button.DoClick = function( )
			netstream.Start( "catherine.class.Set", v.index )
		end
		
		local spawnIcon = vgui.Create( "SpawnIcon", panel )
		spawnIcon:SetSize( 60, 60 )
		spawnIcon:SetPos( 5, 5 )
		spawnIcon:SetModel( table.Random( v.model or { self.player:GetModel( ) } ) )
		spawnIcon.PaintOver = function( pnl, w, h )
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		spawnIcon:SetToolTip( false )
		spawnIcon:SetDisabled( true )
		
		self.Lists:AddItem( panel )
	end
end

vgui.Register( "catherine.vgui.class", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Class_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.class ) and catherine.vgui.class or vgui.Create( "catherine.vgui.class", menuPnl )
end )