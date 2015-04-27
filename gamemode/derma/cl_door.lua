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
	self.mode = 0
	
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
	self.playerLists:SetSize( self.w / 2 - 10, self.h - 45 )
	self.playerLists:SetSpacing( 5 )
	self.playerLists:EnableHorizontal( false )
	self.playerLists:EnableVerticalScrollbar( true )	
	self.playerLists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.mode != CAT_DOOR_FLAG_OWNER ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Door_Notify_NoOwner" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.doorDescEnt = vgui.Create( "DTextEntry", self )
	self.doorDescEnt:SetPos( 10, 55 )
	self.doorDescEnt:SetSize( self.w / 2 - 20, 30 )
	self.doorDescEnt:SetFont( "catherine_normal15" )
	self.doorDescEnt:SetText( "" )
	self.doorDescEnt:SetAllowNonAsciiCharacters( true )
	self.doorDescEnt.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.doorDescEnt.OnEnter = function( pnl )
		if ( self.mode == CAT_DOOR_FLAG_BASIC ) then
			catherine.notify.Add( LANG( "Door_Notify_NoOwner" ) )
			return
		end
		
		netstream.Start( "catherine.door.Work", {
			self.ent,
			CAT_DOOR_CHANGE_DESC,
			pnl:GetText( )
		} )
	end
	
	self.sellDoor = vgui.Create( "catherine.vgui.button", self )
	self.sellDoor:SetPos( 10, self.h - 40 )
	self.sellDoor:SetSize( self.w / 2 - 20, 30 )
	self.sellDoor:SetStr( LANG( "Door_UI_DoorSellStr" ) )
	self.sellDoor:SetStrFont( "catherine_normal20" )
	self.sellDoor:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.sellDoor:SetGradientColor( Color( 255, 255, 255, 150 ) )
	self.sellDoor.Click = function( )
		if ( self.mode != CAT_DOOR_FLAG_OWNER ) then
			catherine.notify.Add( LANG( "Door_Notify_NoOwner" ) )
			return
		end
		
		catherine.command.Run( "doorsell" )
		self:Close( )
	end
	self.sellDoor.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 225, 225, 255 ) )
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
	if ( self.mode != CAT_DOOR_FLAG_OWNER ) then return end
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local has, flag = catherine.door.IsHasDoorPermission( v, self.ent )

		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.playerLists:GetWide( ), 60 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
			draw.SimpleText( v:Name( ), "catherine_normal20", 70, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )

			if ( flag == CAT_DOOR_FLAG_OWNER ) then
				draw.SimpleText( LANG( "Door_UI_OwnerStr" ), "catherine_normal25", w - 20, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			elseif ( flag == CAT_DOOR_FLAG_ALL ) then
				draw.SimpleText( LANG( "Door_UI_AllStr" ), "catherine_normal25", w - 20, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			elseif ( flag == CAT_DOOR_FLAG_BASIC ) then
				draw.SimpleText( LANG( "Door_UI_BasicStr" ), "catherine_normal25", w - 20, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			end
		end
		
		local spawnIcon = vgui.Create( "SpawnIcon", panel )
		spawnIcon:SetPos( 5, 5 )
		spawnIcon:SetSize( 50, 50 )
		spawnIcon:SetModel( v.GetModel( v ) )
		spawnIcon:SetToolTip( false )
		spawnIcon:SetDisabled( true )
		spawnIcon.PaintOver = function( ) end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ), panel:GetTall( ) )
		button:SetDrawBackground( false )
		button:SetText( "" )
		button.DoClick = function( )
			local menu = DermaMenu( )
			
			menu:AddOption( LANG( "Door_UI_AllPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.ent,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v.SteamID( v ),
						CAT_DOOR_FLAG_ALL
					}
				} )
			end )
			
			menu:AddOption( LANG( "Door_UI_BasicPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.ent,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v.SteamID( v ),
						CAT_DOOR_FLAG_BASIC
					}
				} )
			end )
			
			menu:AddOption( LANG( "Door_UI_RemPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.ent,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v.SteamID( v ),
						0
					}
				} )
			end )
			
			menu:Open( )
		end
		
		self.playerLists:AddItem( panel )
	end
end

function PANEL:InitializeDoor( ent, flag )
	self.ent = ent
	self.doorDescEnt:SetText( self.ent.GetNetVar( self.ent, "customDesc", "" ) )
	
	self.mode = flag

	if ( flag == CAT_DOOR_FLAG_ALL or flag == CAT_DOOR_FLAG_BASIC ) then
		self.sellDoor:SetVisible( false )
	end
	
	if ( flag == CAT_DOOR_FLAG_BASIC ) then
		self.doorDescEnt:SetVisible( false )
	end
	
	self:BuildPlayerList( )
end

function PANEL:Refresh( )
	self.doorDescEnt:SetText( self.ent.GetNetVar( self.ent, "customDesc", "" ) )
	self:BuildPlayerList( )
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	
	if ( !IsValid( self.ent ) ) then return end

	draw.SimpleText( self.ent.GetNetVar( self.ent, "title", LANG( "Door_UI_Default" ) ), "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	
	if ( self.mode == CAT_DOOR_FLAG_BASIC ) then return end
	
	draw.SimpleText( LANG( "Door_UI_DoorDescStr" ), "catherine_normal15", 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
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