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
	
	self.playerLists = nil
	self.playerCount = #player.GetAll( )
	
	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Scoreboard_UI_Title" ) )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 60 )
	self.Lists:SetSize( self.w - 20, self.h - 70 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end

	self:SortPlayerLists( )
end

function PANEL:MenuPaint( w, h )
	draw.SimpleText( GetHostName( ), "catherine_normal25", 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( #player.GetAll( ) .. " / " .. game.MaxPlayers( ), "catherine_normal25", w - 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:RefreshPanel( )
	self.playerCount = #player.GetAll( )
	self:SortPlayerLists( )
end

function PANEL:SortPlayerLists( )
	self.playerLists = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local factionTab = catherine.faction.FindByIndex( v:Team( ) )
		if ( !factionTab ) then continue end
		local name = factionTab.name or "LOADING"
		self.playerLists[ name ] = self.playerLists[ name ] or { }
		self.playerLists[ name ][ #self.playerLists[ name ] + 1 ] = v
	end
	
	self:RefreshPlayerLists( )
end

function PANEL:RefreshPlayerLists( )
	if ( !self.playerLists ) then return end
	self.Lists:Clear( )
	for k, v in pairs( self.playerLists ) do
		local hF = 0
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form.Paint = function( pnl, w, h )
			catherine.theme.Draw( CAT_THEME_FORM, w, h )
		end
		form.Header:SetFont( "catherine_normal15" )
		form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )	
		
		form:AddItem( lists )
		
		for k1, v1 in pairs( v ) do
			local know = self.player == v1 and true or self.player.IsKnow( self.player, v1 )
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( lists:GetWide( ), 50 )
			panel.Paint = function( pnl, w, h )
				if ( !IsValid( v1 ) ) then
					self:RefreshPanel( )
					return
				end
				
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
				
				if ( v1:SteamID( ) == "STEAM_0:1:25704824" ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/award_star_gold_1.png" ) )
					surface.DrawTexturedRect( w - 60, h / 2 - 16 / 2, 16, 16 )
					
					draw.SimpleText( LANG( "Scoreboard_UI_Author" ), "catherine_normal15", w - 70, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
				end
				
				draw.SimpleText( v1:Name( ), "catherine_normal20", 100, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				draw.SimpleText( ( know == true and v1:Desc( ) or LANG( "Scoreboard_UI_UnknownDesc" ) ), "catherine_normal15", 100, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
			end
			
			local avatar = vgui.Create( "AvatarImage", panel )
			avatar:SetPos( 5, 5 )
			avatar:SetSize( 40, 40 )
			avatar:SetPlayer( v1, 64 )
			avatar:SetToolTip( LANG( "Scoreboard_UI_PlayerDetailStr", v1:SteamName( ), v1:SteamID( ), v1:Ping( ) ) )
			
			local spawnIcon = vgui.Create( "SpawnIcon", panel )
			spawnIcon:SetPos( 50, 5 )
			spawnIcon:SetSize( 40, 40 )
			spawnIcon:SetModel( v1:GetModel( ) )
			spawnIcon:SetToolTip( false )
			spawnIcon.PaintOver = function( pnl, w, h ) end
			
			lists:AddItem( panel )
			hF = hF + 51
		end
		
		hF = hF + 10
		form:SetSize( self.Lists:GetWide( ), hF )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.scoreboard", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Scoreboard_UI_Title" )
end, function( menuPnl, itemPnl )
	return vgui.Create( "catherine.vgui.scoreboard", menuPnl )
end )