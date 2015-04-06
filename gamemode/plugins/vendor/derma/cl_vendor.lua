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
	catherine.vgui.vendor = self

	self.ent = nil
	self.entCheck = CurTime( ) + 1
	self.closeing = false
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.6, ScrH( ) * 0.8
	self.id = nil
	self.idFunc = {
		function( )
			self.sellPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.buyPanel:SetVisible( true )
			
		end,
		function( )
			self.sellPanel:SetVisible( true )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
		end,
		function( )
			self.sellPanel:SetVisible( false )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( true )
		end,
		function( )
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
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
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
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
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
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 0, 235, 255 ) )
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
	//	draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 0, 235, 255 ) )
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

function PANEL:ItemInformationPanel( itemTable, data )
	if ( IsValid( self.itemInformationPanel ) ) then
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
	
	local x, y = self:GetPos( )
	local newData = data or { uniqueID = itemTable.uniqueID, stock = 0, cost = itemTable.cost, type = 3 }
	
	self.itemInformationPanel = vgui.Create( "DPanel" )
	self.itemInformationPanel:SetSize( ScrW( ) * 0.15, ScrH( ) * 0.5 )
	self.itemInformationPanel:SetPos( x - self.itemInformationPanel:GetWide( ), ScrH( ) / 2 - self.itemInformationPanel:GetTall( ) / 2 )
	self.itemInformationPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 225, 225, 255 ) )
		draw.SimpleText( itemTable.name, "catherine_normal20", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
	
	local pnlW, pnlH = self.itemInformationPanel:GetWide( ), self.itemInformationPanel:GetTall( )
	
	self.itemInformationPanel.save = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.save:SetPos( pnlW - 60, pnlH - 30 )
	self.itemInformationPanel.save:SetSize( 50, 25 )
	self.itemInformationPanel.save:SetStr( "Save" )
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
	
	self.itemInformationPanel.cost = vgui.Create( "DNumSlider", self.itemInformationPanel )
	self.itemInformationPanel.cost:SetPos( 10, 90 )
	self.itemInformationPanel.cost:SetSize( pnlW - 20, 25 )
	self.itemInformationPanel.cost:SetMin( 0 )
	self.itemInformationPanel.cost:SetMax( 1000 )
	self.itemInformationPanel.cost:SetDecimals( 0 )
	self.itemInformationPanel.cost:SetValue( newData.cost )
	self.itemInformationPanel.cost:SetText( "Cost" )
	self.itemInformationPanel.cost.OnValueChanged = function( pnl, val )
		newData.cost = val
	end
	
	self.itemInformationPanel.stock = vgui.Create( "DNumSlider", self.itemInformationPanel )
	self.itemInformationPanel.stock:SetPos( 10, 50 )
	self.itemInformationPanel.stock:SetSize( pnlW - 20, 25 )
	self.itemInformationPanel.stock:SetMin( 0 )
	self.itemInformationPanel.stock:SetMax( 1000 )
	self.itemInformationPanel.stock:SetDecimals( 0 )
	self.itemInformationPanel.stock:SetValue( newData.stock )
	self.itemInformationPanel.stock:SetText( "Stock" )
	self.itemInformationPanel.stock.OnValueChanged = function( pnl, val )
		newData.stock = val
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

function PANEL:Refresh_List( id )
	if ( id == 4 ) then
		self.manageItemPanel.Lists:Clear( )
		for k, v in pairs( self:GetItemTables( ) ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.manageItemPanel.Lists:GetWide( ), 64 )
			form:SetName( k )
			form.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, 20, Color( 225, 225, 225, 255 ) )
				draw.RoundedBox( 0, 0, 20, w, 1, Color( 50, 50, 50, 90 ) )
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
				local w, h = 64, 64
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				
				local spawnIcon = vgui.Create( "SpawnIcon" )
				spawnIcon:SetSize( w, h )
				spawnIcon:SetModel( itemTable.model )
				spawnIcon:SetToolTip( itemTable.name .. "\n" .. itemTable.desc .. "\n" .. ( itemTable.cost == 0 and "Free" or catherine.cash.GetName( itemTable.cost ) ) )
				spawnIcon.DoClick = function( )
					self:ItemInformationPanel( itemTable )
				end
				spawnIcon.PaintOver = function( pnl, w, h )
					if ( itemTable.DrawInformation ) then
						itemTable:DrawInformation( self.player, itemTable, w, h, self.player:GetInvItemDatas( itemTable.uniqueID ) )
					end
				end
				lists:AddItem( spawnIcon )
			end
			
			self.manageItemPanel.Lists:AddItem( form )
		end
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
	surface.SetDrawColor( 200, 200, 200, 235 )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 25, w, h )
	
	if ( IsValid( self.ent ) and self.ent:GetNetVar( "name" ) ) then
		draw.SimpleText( self.ent:GetNetVar( "name" ), "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
end

function PANEL:SetEntity( ent )
	self.ent = ent
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
	self.closeing = true
	self:AlphaTo( 0, 0.2, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.vendor", PANEL, "DFrame" )