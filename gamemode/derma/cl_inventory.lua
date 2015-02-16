local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.7
	self.x = ScrW( ) / 2 - self.w / 2
	self.y = ScrH( ) / 2 - self.h / 2
	self.inv = nil
	self.invWeightAni = 0
	
	self.menuName = "INVENTORY"
	
	self.invWeight = LocalPlayer( ):GetInvWeight( )
	self.invMaxWeight = LocalPlayer( ):GetInvMaxWeight( )
	
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
		
		self.invWeightAni = Lerp( 0.03, self.invWeightAni, math.min( ( self.invWeight / self.invMaxWeight ), 1 ) * w - 20 )
		
		draw.RoundedBox( 0, 10, 40, w - 20, 30, Color( 100, 100, 100, 255 ) )
		draw.RoundedBox( 0, 10, 40, self.invWeightAni, 30, Color( 150, 150, 150, 255 ) )
		
		draw.SimpleText( self.invWeight .. " kg / " .. self.invMaxWeight .. " kg", "catherine_font01_20", w / 2, 40 + 30 / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		
		draw.RoundedBox( 0, 0, 0, surface.GetTextSize( self.menuName ) + 25, 25, Color( 255, 255, 255, 235 ) )
		
		draw.SimpleText( self.menuName, "catherine_font01_25", 5, 0, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
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
	self.Lists:SetPos( 10, 80 )
	self.Lists:SetSize( self.w - 20, self.h - 90 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self:InitInventory( )
end

function PANEL:InitInventory( )
	local inv = LocalPlayer( ):GetInv( )
	if ( !inv ) then return end
	local categoryTab = { }
	for k, v in pairs( inv ) do
		local itemTab = catherine.item.FindByID( k )
		categoryTab[ itemTab.category ] = categoryTab[ itemTab.category ] or { }
		categoryTab[ itemTab.category ][ v.uniqueID ] = v
	end
	
	self.inv = categoryTab
	
	self.invWeight = LocalPlayer( ):GetInvWeight( )
	self.invMaxWeight = LocalPlayer( ):GetInvMaxWeight( )

	self:RefreshInventory( )
	
	catherine.vgui.inventory = self
end

function PANEL:RefreshInventory( )
	if ( !self.inv ) then return end
	self.Lists:Clear( )
	local has = { }
	for k, v in pairs( self.inv ) do
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
			local itemTab = catherine.item.FindByID( v1.uniqueID )
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( 64, 64 )
			spawnIcon:SetModel( itemTab.model )
			spawnIcon:SetToolTip( "Name : " .. itemTab.name .. "\nDesc : " .. itemTab.desc .. "\nCost : " .. itemTab.cost )
			spawnIcon.DoClick = function( )
				catherine.item.OpenMenu( v1.uniqueID )
			end
			spawnIcon.DoRightClick = function( )
				for k1, v1 in pairs( itemTab.func ) do
					for k2, v2 in pairs( v1 ) do
						if ( k2 == "ismenuRightclickFunc" and v2 == true ) then
							netstream.Start( "catherine.item.RunFunction_Menu", { k1, v1.uniqueID } )
							return
						end
					end
				end
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				surface.SetDrawColor( Color( 50, 50, 50, 255 ) )
				draw.NoTexture( )
				surface.DrawLine( 0, 5, 5, 0 )
				
				draw.RoundedBox( 0, 0, 5, 1, 10, Color( 50, 50, 50, 255 ) )
				draw.RoundedBox( 0, 5, 0, 10, 1, Color( 50, 50, 50, 255 ) )
				
				surface.SetDrawColor( Color( 50, 50, 50, 255 ) )
				draw.NoTexture( )
				surface.DrawLine( w, h - 6, w - 6, h )
				
				draw.RoundedBox( 0, w - 1, h - 15, 1, 10, Color( 50, 50, 50, 255 ) )
				draw.RoundedBox( 0, w - 15, h - 1, 10, 1, Color( 50, 50, 50, 255 ) )

				if ( LocalPlayer( ):IsEquiped( v1.uniqueID ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				
				draw.SimpleText( v1.count, "catherine_font01_15", 5, h - 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
			end
			
			dpanelList:AddItem( spawnIcon )
		end
		self.Lists:AddItem( form )
	end
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	catherine.vgui.inventory = nil
end

vgui.Register( "catherine.vgui.inventory", PANEL, "DFrame" )