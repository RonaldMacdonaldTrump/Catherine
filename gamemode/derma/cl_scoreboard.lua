local PANEL = { }

function PANEL:Init( )
	catherine.vgui.scoreboard = self
	
	self.playerLists = nil
	self.playerCount = #player.GetAll( )
	
	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( "Player List" )
	
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

function PANEL:MenuPaint( w, h )
	draw.SimpleText( GetHostName( ), "catherine_hostname", 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( #player.GetAll( ) .. " / " .. game.MaxPlayers( ), "catherine_normal25", w - 10, 40, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
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
			local know = catherine.recognize.IsKnowTarget( self.player, v1 )
			
			if ( self.player == v1 ) then know = true end
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( dpanelList:GetWide( ), 50 )
			panel.Paint = function( pnl, w, h )
				if ( !IsValid( v1 ) ) then
					self:RefreshPanel( )
					return
				end
				
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
				
				draw.SimpleText( v1:Name( ), "catherine_normal20", 50, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				draw.SimpleText( ( know == true and v1:Desc( ) or "You don't know this guy." ), "catherine_normal15", 50, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
			end
			
			local spawnIcon = vgui.Create( "SpawnIcon", panel )
			spawnIcon:SetPos( 5, 5 )
			spawnIcon:SetSize( 40, 40 )
			spawnIcon:SetModel( v1:GetModel( ) )
			spawnIcon:SetToolTip( "This player name is " .. v1:SteamName( ) .. "\nThis player Steam ID is " .. v1:SteamID( ) .. "\nThis player Ping is " .. v1:Ping( ) )
			dpanelList:AddItem( panel )
			hF = hF + 51
		end
		
		hF = hF + 10
		form:SetSize( self.Lists:GetWide( ), hF )
		dpanelList:SetSize( form:GetWide( ), form:GetTall( ) )
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.scoreboard", PANEL, "catherine.vgui.menuBase" )

hook.Add( "AddMenuItem", "catherine.vgui.scoreboard", function( tab )
	tab[ "Player List" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.scoreboard", menuPnl )
	end
end )