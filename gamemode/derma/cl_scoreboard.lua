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
	catherine.vgui.scoreboard = self

	self.playerCount = 0
	self.cantLook = hook.Run( "PlayerCantLookScoreboard", self.player )
	
	self:SetMenuSize( ScrW( ) * 0.65, ScrH( ) * 0.85 )
	self:SetMenuName( LANG( "Scoreboard_UI_Title" ) )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.cantLook ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Scoreboard_UI_CanNotLook_Str" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end

	self:SortPlayerLists( )
end

function PANEL:MenuPaint( w, h )
	draw.SimpleText( GetHostName( ) .. " : " .. #player.GetAll( ) .. " / " .. game.MaxPlayers( ), "catherine_normal25", w, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )
end

function PANEL:Refresh( )
	self.playerCount = #player.GetAllByLoaded( )
	self:SortPlayerLists( )
end

function PANEL:SortPlayerLists( )
	self.playerLists = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local factionTable = catherine.faction.FindByIndex( v:Team( ) )
		if ( !factionTable ) then continue end
		local name = factionTable.name or "LOADING"
		
		self.playerLists[ name ] = self.playerLists[ name ] or { }
		self.playerLists[ name ][ #self.playerLists[ name ] + 1 ] = v
	end
	
	self:RefreshPlayerLists( )
end

function PANEL:RefreshPlayerLists( )
	if ( self.cantLook or !self.playerLists ) then return end
	self.Lists:Clear( )

	for k, v in pairs( self.playerLists ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form:SetAnimTime( 0.5 )
		form.Paint = function( pnl, w, h )
			catherine.theme.Draw( CAT_THEME_FORM, w, h )
		end
		form.Header:SetFont( "catherine_normal15" )
		form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )

		for k1, v1 in pairs( v ) do
			local know = self.player == v1 and true or self.player:IsKnow( v1 )
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( form:GetWide( ), 50 )
			panel.Paint = function( pnl, w, h )
				if ( !IsValid( v1 ) ) then
					self:Refresh( )
					return
				end

				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
				
				if ( v1:SteamID( ) == "STEAM_0:1:25704824" ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/award_star_gold_1.png" ) )
					surface.DrawTexturedRect( w - 40, h / 2 - 16 / 2, 16, 16 )
					
					draw.SimpleText( LANG( "Scoreboard_UI_Author" ), "catherine_normal15", w - 50, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
				end
				
				if ( !know ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "CAT/ui/icon_idk.png", "smooth" ) )
					surface.DrawTexturedRect( 55, 10, 30, 30 )
					
					surface.SetDrawColor( 50, 50, 50, 150 )
					surface.DrawOutlinedRect( 50, 5, 40, 40 )
				end
				
				draw.SimpleText( v1:Name( ), "catherine_normal20", 100, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				draw.SimpleText( ( know and v1:Desc( ) or LANG( "Scoreboard_UI_UnknownDesc" ) ), "catherine_normal15", 100, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
			end
			
			local avatar = vgui.Create( "AvatarImage", panel )
			avatar:SetPos( 5, 5 )
			avatar:SetSize( 40, 40 )
			avatar:SetPlayer( v1, 64 )
			avatar.PaintOver = function( pnl, w, h )
				surface.SetDrawColor( 50, 50, 50, 150 )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			
			local avatarButton = vgui.Create( "DButton", panel )
			avatarButton:SetPos( 5, 5 )
			avatarButton:SetSize( 40, 40 )
			avatarButton:SetText( "" )
			avatarButton:SetDrawBackground( false )
			avatarButton:SetToolTip( LANG( "Scoreboard_UI_PlayerDetailStr", v1:SteamName( ), v1:SteamID( ), v1:Ping( ) ) )
			avatarButton.DoClick = function( )
				hook.Run( "ScoreboardPlayerOption", self.player, v1 )
			end
			
			local spawnIcon = vgui.Create( "SpawnIcon", panel )
			spawnIcon:SetPos( 50, 5 )
			spawnIcon:SetSize( 40, 40 )
			spawnIcon:SetModel( v1:GetModel( ) )
			spawnIcon:SetToolTip( false )
			spawnIcon.PaintOver = function( pnl, w, h )
				surface.SetDrawColor( 50, 50, 50, 150 )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			
			if ( !know ) then
				spawnIcon:SetVisible( false )
			end
			
			form:AddItem( panel )
		end
		
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.scoreboard", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Scoreboard_UI_Title" )
end, function( menuPnl, itemPnl )
	return vgui.Create( "catherine.vgui.scoreboard", menuPnl )
end )