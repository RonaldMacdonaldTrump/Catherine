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
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Remove( )
	end
	
	catherine.vgui.menu = self
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )
	self.blurAmount = 0

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	self:MakePopup( )
	
	self.ListsBase = vgui.Create( "DPanel", self )
	self.ListsBase:SetSize( self.w, 50 )
	self.ListsBase:SetPos( 0, self.h )
	self.ListsBase:MoveTo( 0, self.h - self.ListsBase:GetTall( ), 0.2, 0.1, nil, function( )
		local delta = 0
		local pl = self.player
		
		for k, v in pairs( catherine.menu.GetAll( ) ) do
			if ( v.canLook and v.canLook( pl ) == false ) then continue end
			
			local menuButton = self:AddMenuItem( type( v.name ) == "function" and v.name( pl ) or v.name, v.func )
			menuButton:SetAlpha( 0 )
			menuButton:AlphaTo( 255, 0.2, delta )
			
			delta = delta + 0.05
		end
	end )
	self.ListsBase.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 235 ) )
	end
	
	self.ListsBase.Lists = vgui.Create( "DHorizontalScroller", self.ListsBase )
	self.ListsBase.Lists:SetSize( 0, self.ListsBase:GetTall( ) )
end

function PANEL:AddMenuItem( name, func )
	surface.SetFont( "catherine_normal20" )
	local tw = surface.GetTextSize( name )
	local mainCol = catherine.configs.mainColor
	
	local menuItem = vgui.Create( "DButton" )
	menuItem:SetText( name )
	menuItem:SetFont( "catherine_normal20" )
	menuItem:SetTextColor( Color( 50, 50, 50 ) )
	menuItem:SetSize( tw + 30, self.ListsBase:GetTall( ) )
	menuItem:SetDrawBackground( false )
	menuItem.DoClick = function( pnl )
		local activePanel = catherine.menu.GetActivePanel( )
		local activePanelName = catherine.menu.GetActivePanelName( )
		
		if ( activePanelName and activePanelName == name ) then
			if ( IsValid( activePanel ) ) then
				activePanel:Close( )
				catherine.menu.SetActivePanel( nil )
				catherine.menu.SetActivePanelName( nil )
				
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_SAMEMENU )
			else
				catherine.menu.SetActivePanel( func( self, pnl ) )
				catherine.menu.SetActivePanelName( name )
				
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_SAMEMENU_NO )
			end
		else
			if ( IsValid( activePanel ) ) then
				activePanel:Close( )
				catherine.menu.SetActivePanel( func( self, pnl ) )
				catherine.menu.SetActivePanelName( name )
				
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_NOTSAMEMENU )
			else
				catherine.menu.SetActivePanel( func( self, pnl ) )
				catherine.menu.SetActivePanelName( name )
				
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_NOTSAMEMENU_NO )
			end
		end
		
		--[[ // Old version :>
		if ( self.lastmenuName == name ) then
			if ( IsValid( self.lastmenuPnl ) ) then
				catherine.util.PlayButtonSound( CAT_UTIL_BUTTOMSOUND_1 )
				self.lastmenuPnl:Close( )
				self.lastmenuPnl = nil
				self.lastmenuName = ""
			else
				catherine.util.PlayButtonSound( CAT_UTIL_BUTTOMSOUND_2 )
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			end
		else
			if ( IsValid( self.lastmenuPnl ) ) then
				catherine.util.PlayButtonSound( CAT_UTIL_BUTTOMSOUND_2 )
				self.lastmenuPnl:Close( )
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			else
				catherine.util.PlayButtonSound( CAT_UTIL_BUTTOMSOUND_3 )
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			end
		end
		]]--
	end
	
	self.ListsBase.Lists:AddPanel( menuItem )
	self.ListsBase.Lists:SetWide( math.min( self.ListsBase.Lists:GetWide( ) + menuItem:GetWide( ), self.w ) )
	self.ListsBase.Lists:SetPos( self.w / 2 - self.ListsBase.Lists:GetWide( ) / 2, 0 )
	
	return menuItem
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_TAB ) then
		self:Close( )
	end
end

function PANEL:Paint( w, h )
	self.blurAmount = Lerp( 0.05, self.blurAmount, self.closeing and 0 or 3 )
	
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
end

function PANEL:Close( )
	if ( self.closeing ) then return end
	
	CloseDermaMenus( )
	gui.EnableScreenClicker( false )
	self.closeing = true

	self.ListsBase:MoveTo( self.w / 2 - self.ListsBase:GetWide( ) / 2, self.h, 0.2, 0, nil, function( anim, pnl )
		if ( IsValid( self ) ) then
			self:Remove( )
			self = nil
		end
	end )
end

vgui.Register( "catherine.vgui.menu", PANEL, "DFrame" )