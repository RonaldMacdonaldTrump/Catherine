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
	catherine.vgui.globalban = self
	
	self.globalBan = catherine.net.GetNetGlobalVar( "cat_globalban_database" )
	
	self:SetMenuSize( ScrW( ) * 0.7, ScrH( ) * 0.75 )
	self:SetMenuName( LANG( "GlobalBan_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( catherine.configs.enable_globalBan ) then
			if ( self.globalBan and table.Count( self.globalBan ) == 0 ) then
				draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
				draw.SimpleText( LANG( "GlobalBan_UI_Blank" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
			end
		else
			draw.SimpleText( LANG( "GlobalBan_UI_NotUsing" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self:BuildGlobalBan( )
end

function PANEL:OnMenuRecovered( )
	self:BuildGlobalBan( )
end

function PANEL:MenuPaint( w, h )
	if ( self.globalBan ) then
		draw.SimpleText( LANG( "GlobalBan_UI_Users", #self.globalBan ), "catherine_normal20", w, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )
	end
end

function PANEL:BuildGlobalBan( )
	if ( !catherine.configs.enable_globalBan ) then return end
	
	self.Lists:Clear( )

	for k, v in pairs( self.globalBan or { } ) do
		local name = v.name
		local steamID = v.steamID
		local reason = v.reason
		local steamID64 = util.SteamIDTo64( steamID )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Lists:GetWide( ), 80 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
			
			draw.SimpleText( name, "catherine_normal25", 90, 15, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( steamID, "catherine_normal15", 90, 35, Color( 90, 90, 90, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( reason, "catherine_normal15", 90, 60, Color( 255, 90, 90, 255 ), TEXT_ALIGN_LEFT, 1 )
		end
		
		local avatar = vgui.Create( "AvatarImage", panel )
		avatar:SetPos( 5, 5 )
		avatar:SetSize( 70, 70 )
		avatar:SetSteamID( steamID64, 84 )
		avatar.PaintOver = function( pnl, w, h )
			surface.SetDrawColor( 50, 50, 50, 150 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
			
		local avatarButton = vgui.Create( "DButton", panel )
		avatarButton:SetPos( 5, 5 )
		avatarButton:SetSize( 70, 70 )
		avatarButton:SetDrawBackground( false )
		avatarButton:SetText( "" )
		avatarButton.DoClick = function( )
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. steamID64 )
		end
		
		self.Lists:AddItem( panel )
	end
end

vgui.Register( "catherine.vgui.globalban", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "GlobalBan_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.globalban ) and catherine.vgui.globalban or vgui.Create( "catherine.vgui.globalban", menuPnl )
end )