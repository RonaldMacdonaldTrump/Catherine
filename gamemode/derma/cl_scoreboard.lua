local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.85
	self.x = ScrW( ) / 2 - self.w / 2
	self.y = ScrH( ) / 2 - self.h / 2

	self.menuName = "SCOREBOARD"
	self.playerLists = nil
	self.playerCount = #player.GetAll( )
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
		surface.SetDrawColor( 200, 200, 200, 235 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 25, w, h )

		draw.RoundedBox( 0, 0, 0, surface.GetTextSize( self.menuName ) + 30, 25, Color( 255, 255, 255, 235 ) )
		
		draw.SimpleText( self.menuName, "catherine_font01_25", 5, 0, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		
		draw.SimpleText( GetHostName( ), "catherine_font01_25", 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		draw.SimpleText( #player.GetAll( ) .. " / " .. game.MaxPlayers( ), "catherine_font01_25", w - 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
		
		surface.SetDrawColor( 50, 50, 50, 235 )
		surface.SetMaterial( Material( "gui/gradient" ) )
		surface.DrawTexturedRect( 10, 55, w - 20, 1 )
	end

	self.CloseMenu = vgui.Create( "catherine.vgui.button", self )
	self.CloseMenu:SetSize( 30, 25 )
	self.CloseMenu:SetPos( self.w - 30, 0 )
	self.CloseMenu:SetOutlineColor( Color( 255, 0, 0, 255 ) )
	self.CloseMenu:SetStr( "X" )
	self.CloseMenu.Click = function( )
		self:Close( )
	end
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 65 )
	self.Lists:SetSize( self.w - 20, self.h - 75 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self:SortPlayerLists( )
end

function PANEL:RefreshPanel( )
	self.playerCount = #player.GetAll( )
	self:SortPlayerLists( )
end

function PANEL:SortPlayerLists( )
	self.playerLists = { }
	
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		local factionTab = catherine.faction.FindByIndex( v:Team( ) )
		if ( !factionTab ) then continue end
		self.playerLists[ factionTab.name ] = self.playerLists[ factionTab.name ] or { }
		self.playerLists[ factionTab.name ][ #self.playerLists[ factionTab.name ] + 1 ] = v
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
		form:SetName( k )
		form.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, 20, Color( 150, 150, 150, 255 ) )
		end

		local dpanelList = vgui.Create( "DPanelList", form )
		dpanelList:SetSize( form:GetWide( ), form:GetTall( ) )
		dpanelList:SetSpacing( 3 )
		dpanelList:EnableHorizontal( true )
		dpanelList:EnableVerticalScrollbar( false )	
		
		form:AddItem( dpanelList )
		
		for k1, v1 in pairs( v ) do
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( dpanelList:GetWide( ), 50 )
			panel.Paint = function( pnl, w, h )
				if ( !IsValid( v1 ) ) then
					self:RefreshPanel( )
					return
				end
				
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
				
				draw.SimpleText( v1:Name( ), "catherine_font01_20", 50, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				draw.SimpleText( v1:Desc( ), "catherine_font01_15", 50, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				
				draw.SimpleText( v1:Ping( ), "catherine_font01_25", w - 30, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			end
			
			local spawnIcon = vgui.Create( "SpawnIcon", panel )
			spawnIcon:SetPos( 5, 5 )
			spawnIcon:SetSize( 40, 40 )
			spawnIcon:SetModel( v1:GetModel( ) )
			
			dpanelList:AddItem( panel )
			
			hF = hF + 50
		end
		
		hF = hF + 10
		form:SetSize( self.Lists:GetWide( ), hF )
		dpanelList:SetSize( form:GetWide( ), form:GetTall( ) )
		self.Lists:AddItem( form )
	end
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	catherine.vgui.scoreboard = nil
end

vgui.Register( "catherine.vgui.scoreboard", PANEL, "DFrame" )