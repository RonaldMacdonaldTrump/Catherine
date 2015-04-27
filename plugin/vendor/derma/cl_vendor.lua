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

local PLUGIN = PLUGIN
local PANEL = { }

function PANEL:Init( )
	catherine.vgui.vendor = self

	self.ent = nil
	self.entCheck = CurTime( ) + 1
	self.closeing = false
	self.vendorData = { inv = nil }
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.6, ScrH( ) * 0.8
	self.currMenu = nil
	self.count = 0
	self.id = nil
	self.idFunc = {
		function( )
			self.currMenu = 1
			self.sellPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.buyPanel:SetVisible( true )
			self:Refresh_List( 1 )
		end,
		function( )
			self.currMenu = 2
			self.sellPanel:SetVisible( true )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
			
			self:Refresh_List( 2 )
		end,
		function( )
			self.currMenu = 3
			self.sellPanel:SetVisible( false )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( true )
		end,
		function( )
			self.currMenu = 4
			self.sellPanel:SetVisible( false )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( true )
			self.settingPanel:SetVisible( false )
			self:Refresh_List( 4 )
		end
	}
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	if ( !PLUGIN.VENDOR_NOANI ) then
		self:SetAlpha( 0 )
		self:AlphaTo( 255, 0.2, 0 )
	end
	
	self.buy = vgui.Create( "catherine.vgui.button", self )
	self.buy:SetPos( 10, 35 )
	self.buy:SetSize( self.w * 0.2, 25 )
	self.buy:SetStr( "Buy from Vendor" )
	self.buy:SetStrFont( "catherine_normal15" )
	self.buy:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.buy:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.buy.Click = function( )
		self:ChangeMode( 1 )
	end
	
	self.sell = vgui.Create( "catherine.vgui.button", self )
	self.sell:SetPos( self.w * 0.2 + 30, 35 )
	self.sell:SetSize( self.w * 0.2, 25 )
	self.sell:SetStr( "Sell to Vendor" )
	self.sell:SetStrFont( "catherine_normal15" )
	self.sell:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.sell:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.sell.Click = function( )
		self:ChangeMode( 2 )
	end
	
	if ( self.player:IsAdmin( ) ) then
		self.setting = vgui.Create( "catherine.vgui.button", self )
		self.setting:SetPos( self.w * 0.4 + 40, 35 )
		self.setting:SetSize( self.w * 0.2, 25 )
		self.setting:SetStr( "Setting" )
		self.setting:SetStrFont( "catherine_normal15" )
		self.setting:SetStrColor( Color( 50, 50, 50, 255 ) )
		self.setting:SetGradientColor( Color( 50, 50, 50, 255 ) )
		self.setting.Click = function( )
			self:ChangeMode( 3 )
		end
		
		self.manageItem = vgui.Create( "catherine.vgui.button", self )
		self.manageItem:SetPos( self.w * 0.6 + 40, 35 )
		self.manageItem:SetSize( self.w * 0.2, 25 )
		self.manageItem:SetStr( "Item" )
		self.manageItem:SetStrFont( "catherine_normal15" )
		self.manageItem:SetStrColor( Color( 50, 50, 50, 255 ) )
		self.manageItem:SetGradientColor( Color( 50, 50, 50, 255 ) )
		self.manageItem.Click = function( )
			self:ChangeMode( 4 )
		end
	end
	
	self.buyPanel = vgui.Create( "DPanel", self )
	self.buyPanel:SetPos( 10, 65 )
	self.buyPanel:SetSize( self.w - 20, self.h - 75 )
	self.buyPanel:SetVisible( false )
	
	self.buyPanel.Lists = vgui.Create( "DPanelList", self.buyPanel )
	self.buyPanel.Lists:SetPos( 0, 0 )
	self.buyPanel.Lists:SetSize( self.buyPanel:GetWide( ), self.buyPanel:GetTall( ) )
	self.buyPanel.Lists:SetSpacing( 5 )
	self.buyPanel.Lists:EnableHorizontal( false )
	self.buyPanel.Lists:EnableVerticalScrollbar( true )	
	self.buyPanel.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		if ( self.count == 0 ) then
			draw.SimpleText( "Sorry! :(", "catherine_normal30", w / 2, h / 2 - 30, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( "You can not buy anything!", "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.sellPanel = vgui.Create( "DPanel", self )
	self.sellPanel:SetPos( 10, 65 )
	self.sellPanel:SetSize( self.w - 20, self.h - 75 )
	self.sellPanel:SetVisible( false )
	
	self.sellPanel.Lists = vgui.Create( "DPanelList", self.sellPanel )
	self.sellPanel.Lists:SetPos( 0, 0 )
	self.sellPanel.Lists:SetSize( self.sellPanel:GetWide( ), self.sellPanel:GetTall( ) )
	self.sellPanel.Lists:SetSpacing( 5 )
	self.sellPanel.Lists:EnableHorizontal( false )
	self.sellPanel.Lists:EnableVerticalScrollbar( true )	
	self.sellPanel.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		if ( self.count == 0 ) then
			draw.SimpleText( "Sorry! :(", "catherine_normal30", w / 2, h / 2 - 30, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( "You can not sell anything!", "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.settingPanel = vgui.Create( "DPanel", self )
	self.settingPanel:SetPos( 10, 65 )
	self.settingPanel:SetSize( self.w - 20, self.h - 75 )
	self.settingPanel:SetVisible( false )

	self.manageItemPanel = vgui.Create( "DPanel", self )
	self.manageItemPanel:SetPos( 10, 65 )
	self.manageItemPanel:SetSize( self.w - 20, self.h - 75 )
	self.manageItemPanel:SetVisible( false )
	
	self.manageItemPanel.Lists = vgui.Create( "DPanelList", self.manageItemPanel )
	self.manageItemPanel.Lists:SetPos( 0, 0 )
	self.manageItemPanel.Lists:SetSize( self.manageItemPanel:GetWide( ), self.manageItemPanel:GetTall( ) )
	self.manageItemPanel.Lists:SetSpacing( 5 )
	self.manageItemPanel.Lists:EnableHorizontal( false )
	self.manageItemPanel.Lists:EnableVerticalScrollbar( true )	
	self.manageItemPanel.Lists.Paint = function( pnl, w, h )
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
		netstream.Start( "catherine.plugin.vendor.VendorClose" )
	end
end

function PANEL:Refresh_List( id )
	if ( id == 1 ) then
		local buyalbeItems = self:GetBuyableItems( )
		self.count = table.Count( buyalbeItems )
		self.buyPanel.Lists:Clear( )
		
		for k, v in pairs( buyalbeItems ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.buyPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in pairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					local cost = newData.cost or itemTable.cost
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.name ), "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.desc ), "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					
					draw.SimpleText( cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetName( cost ), "catherine_normal20", w - 10, 15, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
					
					local stock = newData.stock
					draw.SimpleText( ( stock or "0" ) .. "'s Stock", "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
					if ( !stock or stock == 0 ) then
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 50, 50, 255 ) )
					else
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 255, 50, 255 ) )
					end
				end
				
				local button = vgui.Create( "DButton", panel )
				button:SetSize( panel:GetWide( ), panel:GetTall( ) )
				button:Center( )
				button:SetText( "" )
				button:SetDrawBackground( false )
				button.DoClick = function( )
					if ( !newData.stock ) then
						Derma_Message( "No stock!", "Sorry!", "OK" )
						return
					end
					netstream.Start( "catherine.plugin.vendor.VendorWork", {
						self.ent,
						CAT_VENDOR_ACTION_SELL,
						{
							uniqueID = v1.uniqueID
						}
					} )
				end
				
				local spawnIcon = vgui.Create( "SpawnIcon", panel )
				spawnIcon:SetSize( 40, 40 )
				spawnIcon:SetPos( 5, 5 )
				spawnIcon:SetModel( itemTable.model )
				spawnIcon:SetToolTip( false )
				spawnIcon:SetDisabled( true )
				spawnIcon.PaintOver = function( ) end
				
				form:AddItem( panel )
			end
			
			self.buyPanel.Lists:AddItem( form )
		end
	elseif ( id == 2 ) then
		local sellableItems = self:GetSellableItems( )
		self.count = table.Count( sellableItems )
		self.sellPanel.Lists:Clear( )
		
		for k, v in pairs( sellableItems ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.sellPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in pairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					local cost = math.Round( ( newData.cost or itemTable.cost ) / PLUGIN.VENDOR_SOLD_DISCOUNTPER )
					
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.name ), "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.desc ), "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					
					draw.SimpleText( cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetName( cost ), "catherine_normal20", w - 10, 15, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
					
					local stock = newData.stock
					draw.SimpleText( ( stock or "0" ) .. "'s Stock", "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
					if ( !stock or stock == 0 ) then
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 50, 50, 255 ) )
					else
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 255, 50, 255 ) )
					end
				end
				
				local button = vgui.Create( "DButton", panel )
				button:SetSize( panel:GetWide( ), panel:GetTall( ) )
				button:Center( )
				button:SetText( "" )
				button:SetDrawBackground( false )
				button.DoClick = function( )
					if ( !newData.stock ) then
						Derma_Message( "No stock!", "Sorry!", "OK" )
						return
					end
					netstream.Start( "catherine.plugin.vendor.VendorWork", {
						self.ent,
						CAT_VENDOR_ACTION_BUY,
						{
							uniqueID = v1.uniqueID
						}
					} )
				end
				
				local spawnIcon = vgui.Create( "SpawnIcon", panel )
				spawnIcon:SetSize( 40, 40 )
				spawnIcon:SetPos( 5, 5 )
				spawnIcon:SetModel( itemTable.model )
				spawnIcon:SetToolTip( false )
				spawnIcon:SetDisabled( true )
				spawnIcon.PaintOver = function( ) end
				
				form:AddItem( panel )
			end
			
			self.sellPanel.Lists:AddItem( form )
		end
	elseif ( id == 4 ) then
		self.manageItemPanel.Lists:Clear( )
		
		for k, v in pairs( self:GetItemTables( ) ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.manageItemPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in pairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.name ), "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.desc ), "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( ( newData.cost or itemTable.cost ) .. " Cost", "catherine_normal15", w - 10, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
					local mode = newData.type
					if ( !mode ) then
					
					elseif ( mode == 1 ) then
						draw.SimpleText( "None", "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					elseif ( mode == 2 ) then
						draw.SimpleText( "Only Buy", "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					elseif ( mode == 3 ) then
						draw.SimpleText( "Only Sell", "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					elseif ( mode == 4 ) then
						draw.SimpleText( "Buy and Sell", "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					end
					
					local stock = newData.stock
					draw.SimpleText( ( stock or "0" ) .. "'s Stock", "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
					if ( !stock ) then
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 50, 50, 255 ) )
					elseif ( stock == 0 ) then
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 255, 255, 255 ) )
					else
						draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 255, 50, 255 ) )
					end
				end
				
				local button = vgui.Create( "DButton", panel )
				button:SetSize( panel:GetWide( ), panel:GetTall( ) )
				button:Center( )
				button:SetText( "" )
				button:SetDrawBackground( false )
				button.DoClick = function( )
					self:ItemInformationPanel( itemTable, self.vendorData.inv[ v1.uniqueID ] )
				end
				
				local spawnIcon = vgui.Create( "SpawnIcon", panel )
				spawnIcon:SetSize( 40, 40 )
				spawnIcon:SetPos( 5, 5 )
				spawnIcon:SetModel( itemTable.model )
				spawnIcon:SetToolTip( false )
				spawnIcon:SetDisabled( true )
				spawnIcon.PaintOver = function( ) end
				
				form:AddItem( panel )
			end
			
			self.manageItemPanel.Lists:AddItem( form )
		end
	end
end

function PANEL:ChangeMode( id )
	self.id = id
	self.idFunc[ id ]( )
end

function PANEL:GetItemTables( )
	local tab = { }
	
	for k, v in pairs( catherine.item.GetAll( ) ) do
		local category = v.category
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	return tab
end

function PANEL:GetSellableItems( )
	local tab = { }

	for k, v in pairs( catherine.item.GetAll( ) ) do
		if ( !catherine.inventory.HasItem( k ) ) then continue end
		local data = self.vendorData.inv[ k ] or { }
		if ( !data.type or table.HasValue( { 1, 2 }, data.type ) ) then continue end
		local category = v.category
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	return tab
end

function PANEL:GetBuyableItems( )
	local tab = { }

	for k, v in pairs( catherine.item.GetAll( ) ) do
		local data = self.vendorData.inv[ k ] or { }
		if ( !data.type or table.HasValue( { 1, 3 }, data.type ) ) then continue end
		local category = v.category
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	return tab
end

function PANEL:ItemInformationPanel( itemTable, data )
	if ( IsValid( self.itemInformationPanel ) ) then
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end

	local x, y = self.GetPos( self )
	local newData = data or { uniqueID = itemTable.uniqueID, stock = 0, cost = itemTable.cost, type = 1 }
	
	self.itemInformationPanel = vgui.Create( "DPanel" )
	self.itemInformationPanel:SetSize( ScrW( ) * 0.15, ScrH( ) * 0.5 )
	self.itemInformationPanel:SetPos( x - self.itemInformationPanel:GetWide( ), ScrH( ) / 2 - self.itemInformationPanel:GetTall( ) / 2 )
	self.itemInformationPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
		surface.SetDrawColor( 200, 200, 200, 235 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 25, w, h )
		
		draw.SimpleText( "Item Setting", "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		
		draw.SimpleText( catherine.util.StuffLanguage( itemTable.name ), "catherine_normal15", 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
	
	local pnlW, pnlH = self.itemInformationPanel:GetWide( ), self.itemInformationPanel:GetTall( )
	
	self.itemInformationPanel.save = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.save:SetPos( pnlW - 100, pnlH - 30 )
	self.itemInformationPanel.save:SetSize( 90, 25 )
	self.itemInformationPanel.save:SetStr( "Register" )
	self.itemInformationPanel.save:SetStrFont( "catherine_normal15" )
	self.itemInformationPanel.save:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.save:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.save.Click = function( )
		netstream.Start( "catherine.plugin.vendor.VendorWork", {
			self.ent,
			CAT_VENDOR_ACTION_ITEM_CHANGE,
			{
				uniqueID = newData.uniqueID,
				stock = newData.stock,
				cost = newData.cost,
				type = newData.type
			}
		} )
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
	
	self.itemInformationPanel.dis = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.dis:SetPos( 10, pnlH - 30 )
	self.itemInformationPanel.dis:SetSize( 90, 25 )
	self.itemInformationPanel.dis:SetStr( "UNRegister" )
	self.itemInformationPanel.dis:SetStrFont( "catherine_normal15" )
	self.itemInformationPanel.dis:SetStrColor( Color( 255, 50, 50, 255 ) )
	self.itemInformationPanel.dis:SetGradientColor( Color( 255, 50, 50, 255 ) )
	self.itemInformationPanel.dis.Click = function( )
		netstream.Start( "catherine.plugin.vendor.VendorWork", {
			self.ent,
			CAT_VENDOR_ACTION_ITEM_UNCHANGE,
			newData.uniqueID
		} )
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
	
	self.itemInformationPanel.typeChange = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.typeChange:SetPos( 10, pnlH - 60 )
	self.itemInformationPanel.typeChange:SetSize( pnlW - 20, 25 )
	self.itemInformationPanel.typeChange:SetStr( "Mode : None" )
	self.itemInformationPanel.typeChange:SetStrFont( "catherine_normal15" )
	self.itemInformationPanel.typeChange:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.typeChange:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.typeChange.PaintOverAll = function( pnl )
		if ( newData.type == 1 ) then
			pnl:SetStr( "Mode : None" )
		elseif ( newData.type == 2 ) then
			pnl:SetStr( "Mode : Buy" )
		elseif ( newData.type == 3 ) then
			pnl:SetStr( "Mode : Sell" )
		elseif ( newData.type == 4 ) then
			pnl:SetStr( "Mode : Buy and Sell" )
		end
	end
	self.itemInformationPanel.typeChange.Click = function( )
		local menu = DermaMenu( )
		menu:AddOption( "Only Buy", function( )
			netstream.Start( "catherine.plugin.vendor.VendorWork", {
				self.ent,
				CAT_VENDOR_ACTION_ITEM_CHANGE,
				{
					uniqueID = newData.uniqueID,
					stock = newData.stock,
					cost = newData.cost,
					type = 2
				}
			} )
			self.itemInformationPanel:Remove( )
			self.itemInformationPanel = nil
		end )
		
		menu:AddOption( "Only Sell", function( )
			netstream.Start( "catherine.plugin.vendor.VendorWork", {
				self.ent,
				CAT_VENDOR_ACTION_ITEM_CHANGE,
				{
					uniqueID = newData.uniqueID,
					stock = newData.stock,
					cost = newData.cost,
					type = 3
				}
			} )
			self.itemInformationPanel:Remove( )
			self.itemInformationPanel = nil
		end )
		
		menu:AddOption( "Buy and Sell", function( )
			netstream.Start( "catherine.plugin.vendor.VendorWork", {
				self.ent,
				CAT_VENDOR_ACTION_ITEM_CHANGE,
				{
					uniqueID = newData.uniqueID,
					stock = newData.stock,
					cost = newData.cost,
					type = 4
				}
			} )
			self.itemInformationPanel:Remove( )
			self.itemInformationPanel = nil
		end )
		
		menu:Open( )
	end
	
	self.itemInformationPanel.cost = vgui.Create( "DNumSlider", self.itemInformationPanel )
	self.itemInformationPanel.cost:SetPos( 10, 120 )
	self.itemInformationPanel.cost:SetSize( pnlW - 20, 25 )
	self.itemInformationPanel.cost:SetMin( 0 )
	self.itemInformationPanel.cost:SetMax( 9000 )
	self.itemInformationPanel.cost:SetDecimals( 0 )
	self.itemInformationPanel.cost:SetValue( newData.cost )
	self.itemInformationPanel.cost:SetText( "Cost" )
	self.itemInformationPanel.cost.Label:SetFont( "catherine_normal15" )
	self.itemInformationPanel.cost.Label:SetTextColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.cost.OnValueChanged = function( pnl, val )
		newData.cost = math.Round( val )
	end
	
	self.itemInformationPanel.stock = vgui.Create( "DNumSlider", self.itemInformationPanel )
	self.itemInformationPanel.stock:SetPos( 10, 150 )
	self.itemInformationPanel.stock:SetSize( pnlW - 20, 25 )
	self.itemInformationPanel.stock:SetMin( 0 )
	self.itemInformationPanel.stock:SetMax( 9000 )
	self.itemInformationPanel.stock:SetDecimals( 0 )
	self.itemInformationPanel.stock:SetValue( newData.stock )
	self.itemInformationPanel.stock:SetText( "Stock" )
	self.itemInformationPanel.stock.Label:SetFont( "catherine_normal15" )
	self.itemInformationPanel.stock.Label:SetTextColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.stock.OnValueChanged = function( pnl, val )
		newData.stock = math.Round( val )
	end
	
	self.itemInformationPanel.close = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.close:SetPos( self.itemInformationPanel:GetWide( ) - 30, 0 )
	self.itemInformationPanel.close:SetSize( 30, 25 )
	self.itemInformationPanel.close:SetStr( "X" )
	self.itemInformationPanel.close:SetStrFont( "catherine_normal30" )
	self.itemInformationPanel.close:SetStrColor( Color( 255, 150, 150, 255 ) )
	self.itemInformationPanel.close:SetGradientColor( Color( 255, 150, 150, 255 ) )
	self.itemInformationPanel.close.Click = function( )
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	
	if ( !IsValid( self.ent ) ) then return end
	local name = self.ent.GetNetVar( ent, "name" )
	
	if ( name ) then
		draw.SimpleText( name, "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
end

function PANEL:InitializeVendor( ent )
	self.ent = ent
	self.vendorData.inv = ent.GetNetVar( ent, "inv", { } )
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
	if ( IsValid( self.itemInformationPanel ) ) then
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
	if ( !PLUGIN.VENDOR_NOANI ) then
		self.closeing = true
		self:AlphaTo( 0, 0.2, 0, function( )
			self:Remove( )
			self = nil
		end )
	else
		self.closeing = true
		self:Remove( )
		self = nil
	end
end

vgui.Register( "catherine.vgui.vendor", PANEL, "DFrame" )