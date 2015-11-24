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
	catherine.vgui.block = self
	
	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Block_UI_Title" ) )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	
	self:BuildBlock( )
end

function PANEL:OnMenuRecovered( )
	self:BuildBlock( )
end

function PANEL:BuildBlock( )
	self.Lists:Clear( )
	
	// not yet ;-)
end

vgui.Register( "catherine.vgui.block", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Block_UI_Title" )
end, "block", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.block ) and catherine.vgui.block or vgui.Create( "catherine.vgui.block", menuPnl )
end )