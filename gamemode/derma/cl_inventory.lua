local PANEL = { }

function PANEL:Init( )
	catherine.vgui.inventory = self
	
	self.inv = nil
	self.invWeightAni = 0
	self.invWeight = 0
	self.invMaxWeight = 0
	
	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( "Bag" )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 65 )
	self.Lists:SetSize( self.w - 20, self.h - 75 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end

	self:InitializeInv( )
end

function PANEL:MenuPaint( w, h )
	self.invWeightAni = Lerp( 0.03, self.invWeightAni, math.min( ( self.invWeight / self.invMaxWeight ), 1 ) * w - 20 )

	draw.RoundedBox( 0, 10, 35, w - 20, 20, Color( 100, 100, 100, 255 ) )
	draw.RoundedBox( 0, 10, 35, self.invWeightAni, 20, Color( 150, 150, 150, 255 ) )

	draw.SimpleText( self.invWeight .. " kg / " .. self.invMaxWeight .. " kg", "catherine_normal15", w / 2, 35 + 20 / 2, Color( 255, 255, 255, 255 ), 1, 1 )
end

function PANEL:InitializeInv( )
	local inv = self.player:GetInv( )
	if ( !inv ) then return end
	local tab = { }
	
	for k, v in pairs( inv ) do
		local itemTab = catherine.item.FindByID( k )
		local category = itemTab.category or "Other"
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	self.inv = tab
	self.invWeight = self.player:GetInvWeight( )
	self.invMaxWeight = self.player:GetInvMaxWeight( )

	self:Refresh( )
end

function PANEL:Refresh( )
	if ( !self.inv ) then return end
	self.Lists:Clear( )
	for k, v in pairs( self.inv ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( k )
		form.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, 20, Color( 150, 150, 150, 255 ) )
		end

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )	
		
		form:AddItem( lists )
		
		for k1, v1 in pairs( v ) do
			local itemTab = catherine.item.FindByID( v1.uniqueID )
			local itemData = self.player:GetInvItemDatas( v1.uniqueID )
			local itemDesc = itemTab.GetDesc and itemTab:GetDesc( self.player, itemTab, itemData ) or ""
			local paintFunc = function( )
				if ( !itemTab.DrawOverAll ) then return end
				itemTab:DrawOverAll( self.player, 64, 64, data )
			end
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( 64, 64 )
			spawnIcon:SetModel( itemTab.model )
			spawnIcon:SetToolTip( "Name : " .. itemTab.name .. "\nDescription : " .. itemTab.desc .. "\nCost : " .. itemTab.cost .. "\n" .. itemDesc  )
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

				if ( self.player:IsEquiped( v1.uniqueID ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				draw.SimpleText( v1.count, "catherine_normal15", 5, h - 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				paintFunc( )
			end
			lists:AddItem( spawnIcon )
		end
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.inventory", PANEL, "catherine.vgui.menuBase" )


hook.Add( "AddMenuItem", "catherine.vgui.inventory", function( tab )
	tab[ "Bag" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.inventory", menuPnl )
	end
end )