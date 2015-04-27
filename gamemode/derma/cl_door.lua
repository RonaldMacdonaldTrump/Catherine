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
	catherine.vgui.door = self
	
	self.ent = nil
	self.entCheck = CurTime( ) + 1
	self.closeing = false
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.7, ScrH( ) * 0.6

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
	self.playerLists = vgui.Create( "DPanelList", self )
	self.playerLists:SetPos( self.w / 2, 35 )
	self.playerLists:SetSize( self.w / 2 - 10, self.h - 85 )
	self.playerLists:SetSpacing( 5 )
	self.playerLists:EnableHorizontal( false )
	self.playerLists:EnableVerticalScrollbar( true )	
	self.playerLists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	
	self.close = vgui.Create( "catherine.vgui.button", self )
	self.close:SetPos( self.w - 30, 0 )
	self.close:SetSize( 30, 25 )
	self.close:SetStr( "X" )
	self.close:SetStrFont( "catherine_normal30" )
	self.close:SetStrColor( Color( 255, 150, 150, 255 ) )
	self.close:SetGradientColor( Color( 255, 150, 150, 255 ) )
	self.close.Click = function( )
		if ( self.closeing ) then return end
		self:Close( )
	end
end

function PANEL:BuildPlayerList( )
	self.playerLists:Clear( )
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local isMaster = catherine.door.IsDoorOwner( v, self.ent, CAT_DOOR_FLAG_MASTER )
		local isAll = catherine.door.IsDoorOwner( v, self.ent, CAT_DOOR_FLAG_ALL )
		local isBasic = catherine.door.IsDoorOwner( v, self.ent, CAT_DOOR_FLAG_BASIC )

		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.playerLists:GetWide( ), 30 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
			draw.SimpleText( v:Name( ), "catherine_normal20", 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			
			if ( isMaster ) then
				draw.SimpleText( "MASTER", "catherine_normal20", w - 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			elseif ( isAll ) then
				draw.SimpleText( "ALL", "catherine_normal20", w - 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			elseif ( isBasic ) then
				draw.SimpleText( "BASIC", "catherine_normal20", w - 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			else
				draw.SimpleText( "NO PERMISSION", "catherine_normal20", w - 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			end
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ), panel:GetTall( ) )
		button:SetDrawBackground( false )
		button:SetText( "" )
		button.DoClick = function( )
			local menu = DermaMenu( )
			
			menu:AddOption( "All permission.", function( )
			
			end )
			
			menu:AddOption( "Basic permission.", function( )
			
			end )
			
			menu:AddOption( "Remove permission.", function( )
			
			end )
			
			menu:Open( )
		end
		
		self.playerLists:AddItem( panel )
	end
end

function PANEL:InitializeDoor( ent )
	self.ent = ent
	
	self:BuildPlayerList( )
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	
	if ( !IsValid( self.ent ) ) then return end
	local title = self.ent.GetNetVar( ent, "title" )
	
	if ( title ) then
		draw.SimpleText( title, "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
end

function PANEL:Think( )
	if ( self.entCheck <= CurTime( ) ) then
		if ( !IsValid( self.ent ) and !self.closeing ) then
			self:Close( )
			return
		end
		self.entCheck = CurTime( ) + 0.01
	end
end

function PANEL:Close( )
	self.closeing = true
	self:AlphaTo( 0, 0.2, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.door", PANEL, "DFrame" )