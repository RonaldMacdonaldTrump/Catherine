--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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
	catherine.vgui.business = self
	
	self.business = nil
	self.shoppingcart = { }
	self.shoppingcartInfo = nil
	
	self:SetMenuSize( ScrW( ) * 0.95, ScrH( ) * 0.8 )
	self:SetMenuName( "Business" )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - self.w * 0.4, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
		if ( self.business and table.Count( self.business ) == 0 ) then
			draw.SimpleText( "You can't buy anything!", "catherine_normal25", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.Cart = vgui.Create( "DPanelList", self )
	self.Cart:SetPos( self.w - self.w * 0.4 + 20, 60 )
	self.Cart:SetSize( self.w * 0.4 - 30, self.h - 110 )
	self.Cart:SetSpacing( 5 )
	self.Cart:EnableHorizontal( false )
	self.Cart:EnableVerticalScrollbar( true )
	self.Cart.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self.buyItems = vgui.Create( "catherine.vgui.button", self )
	self.buyItems:SetPos( self.w * 0.6 + 20, self.h - 40 )
	self.buyItems:SetSize( self.w * 0.4 - 30, 30 )
	self.buyItems:SetStr( "Buy Items >" )
	self.buyItems:SetStrFont( "catherine_normal25" )
	self.buyItems:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.buyItems:SetGradientColor( Color( 255, 255, 255, 150 ) )
	self.buyItems.Click = function( )
		if ( self:GetShipmentCount( ) > 0 ) then
			if ( catherine.cash.Get( self.player ) >= self.shoppingcartInfo ) then
				if ( self.player:GetPos( ):Distance( self.player:GetEyeTraceNoCursor( ).HitPos ) <= 150 ) then
					Derma_Query( "Are you sure you want to buy this item(s)?", "Buy Items", "YES", function( )
						netstream.Start( "catherine.business.BuyItems", self.shoppingcart )
					end, "No", function( ) end )
				else
					catherine.notify.Add( "You cannot drop far away!", 5 )
				end
			else
				catherine.notify.Add( "No "..catherine.config.moneyName.."!", 5 )
			end
		else
			catherine.notify.Add( "Shipment bought!", 5 )
		end
	end
	self.buyItems.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 225, 225, 255 ) )
	end
	
	self:InitializeBusiness( )
end

function PANEL:RefreshShoppingCartInfo( )
	local costs = 0
	for k, v in pairs( self.shoppingcart ) do
		local itemTable = catherine.item.FindByID( v.uniqueID )
		costs = itemTable.cost * v.count
	end
	self.shoppingcartInfo = costs
end

function PANEL:MenuPaint( w, h )
	draw.SimpleText( "Shopping Cart", "catherine_normal20", w * 0.6 + 20, 45, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	
	if ( !self.shoppingcartInfo ) then return end
	draw.SimpleText( "Total " .. catherine.cash.GetName( self.shoppingcartInfo ), "catherine_normal20", w - 10, 45, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:InitializeBusiness( )
	local tab = { }
	
	for k, v in pairs( catherine.item.GetAll( ) ) do
		if ( v.showOnBusiness and v:showOnBusiness( self.player ) == false ) then continue end
		if ( !table.HasValue( v.onBusinessFactions or { }, self.player:Team( ) ) ) then continue end
		local category = v.category
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	self.business = tab
	self:BuildBusiness( )
end

function PANEL:GetShipmentCount( )
	local count = 0
	for k, v in pairs( self.shoppingcart ) do
		count = count + v.count
	end
	return count
end

function PANEL:BuildShoppingCart( )
	self.Cart:Clear( )
	for k, v in pairs( self.shoppingcart ) do
		local costs = 0
		local itemTable = catherine.item.FindByID( v.uniqueID )
		costs = itemTable.cost * v.count
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Cart:GetWide( ), 40 )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( v.name, "catherine_normal15", 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( v.count .. "'s / " .. catherine.cash.GetName( costs ), "catherine_normal15", w - 40, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
		end
		
		local removeItem = vgui.Create( "catherine.vgui.button", panel )
		removeItem:SetPos( panel:GetWide( ) - 30, 10 )
		removeItem:SetSize( 20, 20 )
		removeItem:SetStr( "X" )
		removeItem:SetStrFont( "catherine_normal15" )
		removeItem:SetStrColor( Color( 50, 50, 50, 255 ) )
		removeItem:SetGradientColor( Color( 255, 255, 255, 150 ) )
		removeItem.Click = function( )
			self.shoppingcart[ k ].count = math.max( self.shoppingcart[ k ].count - 1, 0 )
			if ( self.shoppingcart[ k ].count == 0 ) then
				self.shoppingcart[ k ] = nil
				self.Cart:RemoveItem( panel )
			end
			costs = itemTable.cost * v.count
		end
		removeItem.PaintBackground = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 150, 150, 150 ) )
		end
		
		self.Cart:AddItem( panel )
	end
end

function PANEL:BuildBusiness( )
	if ( !self.business ) then return end
	self.Lists:Clear( )
	local delta = 0
	for k, v in pairs( self.business ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( k )
		form:SetAlpha( 0 )
		form:AlphaTo( 255, 0.1, delta )
		form.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, 20, Color( 225, 225, 225, 255 ) )
			draw.RoundedBox( 0, 0, 20, w, 1, Color( 50, 50, 50, 90 ) )
		end
		form.Header:SetFont( "catherine_normal15" )
		form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
		delta = delta + 0.05

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )	
		
		form:AddItem( lists )
		
		for k1, v1 in pairs( v ) do
			local w, h = 64, 64
			local itemTable = catherine.item.FindByID( v1.uniqueID )
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( itemTable.model )
			spawnIcon:SetToolTip( itemTable.name .. "\n" .. itemTable.desc .. "\n" .. ( itemTable.cost == 0 and "Free" or catherine.cash.GetName( itemTable.cost ) ) )
			spawnIcon.DoClick = function( )
				if ( self.shoppingcart[ itemTable.uniqueID ] ) then
					self.shoppingcart[ itemTable.uniqueID ].count = self.shoppingcart[ itemTable.uniqueID ].count + 1
				else
					self.shoppingcart[ itemTable.uniqueID ] = {
						name = itemTable.name,
						uniqueID = itemTable.uniqueID,
						count = 1
					}
				end
				self:RefreshShoppingCartInfo( )
				self:BuildShoppingCart( )
				self.buyItems:SetStr( "Buy Items > [" .. self:GetShipmentCount( ) .. "]" )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( self.player, itemTable, w, h, self.player:GetInvItemDatas( itemTable.uniqueID ) )
				end
			end
			lists:AddItem( spawnIcon )
		end
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.business", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	catherine.vgui.shipment = self
	self.shipments = nil
	self.ent = nil
	self.entCheck = CurTime( ) + 1
	self.closeing = false
	
	self.w, self.h = ScrW( ) * 0.4, ScrH( ) * 0.6

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
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

function PANEL:BuildShipment( )
	if ( !self.shipments ) then return end
	self.Lists:Clear( )
	for k, v in pairs( self.shipments ) do
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Lists:GetWide( ), 40 )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( v.name, "catherine_normal15", 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( v.count .. "'s", "catherine_normal15", w - 80, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
		end
		
		local takeItem = vgui.Create( "catherine.vgui.button", panel )
		takeItem:SetPos( panel:GetWide( ) - 70, 10 )
		takeItem:SetSize( 60, 20 )
		takeItem:SetStr( "Take" )
		takeItem:SetStrFont( "catherine_normal15" )
		takeItem:SetStrColor( Color( 50, 50, 50, 255 ) )
		takeItem:SetGradientColor( Color( 50, 50, 50, 150 ) )
		takeItem.Click = function( )
			local itemTable = catherine.item.FindByID( v.uniqueID )
			if ( !itemTable ) then
				self.Lists:RemoveItem( panel )
				return
			end
			if ( !catherine.inventory.HasSpace( itemTable.weight ) ) then
				catherine.notify.Add( "You don't have inventory space!", 5 )
				return
			end
			self.shipments[ k ].count = math.max( self.shipments[ k ].count - 1, 0 )
			if ( self.shipments[ k ].count == 0 ) then
				self.shipments[ k ] = nil
				self.Lists:RemoveItem( panel )
			end
			netstream.Start( "catherine.item.Give", v.uniqueID )
			
			if ( table.Count( self.shipments ) == 0 and IsValid( self.ent ) ) then
				netstream.Start( "catherine.business.RemoveShipment", self.ent:EntIndex( ) )
			end
		end
		takeItem.PaintBackground = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
		end
		
		self.Lists:AddItem( panel )
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
	surface.SetDrawColor( 200, 200, 200, 235 )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 25, w, h )
	
	draw.SimpleText( "Shipment", "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
end

function PANEL:InitializeShipment( ent, shipments )
	self.ent = ent
	self.shipments = shipments
	self:BuildShipment( )
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

vgui.Register( "catherine.vgui.shipment", PANEL, "DFrame" )

hook.Add( "AddMenuItem", "catherine.vgui.business", function( tab )
	tab[ "Business" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.business", menuPnl )
	end
end )
