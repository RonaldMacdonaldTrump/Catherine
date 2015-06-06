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
	
	self.vendorData = { inv = nil }
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.6, ScrH( ) * 0.8
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	self.currMenu = nil
	self.count = 0
	self.idFunc = {
		function( )
			self.currMenu = 1
			
			self:Remove_Setting( )
			
			self.sellPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.buyPanel:SetVisible( true )
			
			self:Refresh_List( 1 )
		end,
		function( )
			self.currMenu = 2
			
			self:Remove_Setting( )
			
			self.sellPanel:SetVisible( true )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( false )
			
			self:Refresh_List( 2 )
		end,
		function( )
			self.currMenu = 3
			
			self:Build_Setting( )
			
			self.sellPanel:SetVisible( false )
			self.buyPanel:SetVisible( false )
			self.manageItemPanel:SetVisible( false )
			self.settingPanel:SetVisible( true )
		end,
		function( )
			self.currMenu = 4
			
			self:Remove_Setting( )
			
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
		self:SetPos( ScrW( ), self.y )
		self:MoveTo( ScrW( ) / 2 - self.w / 2, self.y, 0.2, 0 )
	end
	
	self.buy = vgui.Create( "catherine.vgui.button", self )
	self.buy:SetPos( 10, 35 )
	self.buy:SetSize( self.w * 0.2, 25 )
	self.buy:SetStr( LANG( "Vendor_UI_BuyFromVendorStr" ) )
	self.buy:SetStrFont( "catherine_normal15" )
	self.buy:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.buy:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.buy.Click = function( )
		self:ChangeMode( 1 )
	end
	
	self.sell = vgui.Create( "catherine.vgui.button", self )
	self.sell:SetPos( self.w * 0.2 + 30, 35 )
	self.sell:SetSize( self.w * 0.2, 25 )
	self.sell:SetStr( LANG( "Vendor_UI_SellToVendorStr" ) )
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
		self.setting:SetStr( LANG( "Vendor_UI_SettingStr" ) )
		self.setting:SetStrFont( "catherine_normal15" )
		self.setting:SetStrColor( Color( 50, 50, 50, 255 ) )
		self.setting:SetGradientColor( Color( 50, 50, 50, 255 ) )
		self.setting.Click = function( )
			self:ChangeMode( 3 )
		end
		
		self.manageItem = vgui.Create( "catherine.vgui.button", self )
		self.manageItem:SetPos( self.w * 0.6 + 40, 35 )
		self.manageItem:SetSize( self.w * 0.2, 25 )
		self.manageItem:SetStr( LANG( "Vendor_UI_ItemStr" ) )
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
		
		if ( !pnl.buyStr ) then
			pnl.buyStr = LANG( "Vendor_UI_CantBuyStr" )
		end
		
		if ( self.count == 0 ) then
			draw.SimpleText( ":(", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( pnl.buyStr, "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
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
		
		if ( !pnl.sellStr ) then
			pnl.sellStr = LANG( "Vendor_UI_CantSellStr" )
		end
		
		if ( self.count == 0 ) then
			draw.SimpleText( ":(", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( pnl.sellStr, "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
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
	self.close:SetStrFont( "catherine_normal35" )
	self.close:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.close:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.close.Click = function( )
		if ( self.closing ) then return end
		
		self:Close( )
		netstream.Start( "catherine.plugin.vendor.VendorClose" )
	end
end

function PANEL:Remove_Setting( )
	if ( IsValid( self.settingPanel.panel ) ) then
		self.settingPanel.panel:Remove( )
		self.settingPanel.panel = nil
	end
end

function PANEL:Build_Setting( )
	if ( self.currMenu != 3 ) then return end

	self.settingPanel.panel = vgui.Create( "DPanel", self.settingPanel )
	self.settingPanel.panel:SetPos( 0, 0 )
	self.settingPanel.panel:SetSize( self.settingPanel:GetWide( ), self.settingPanel:GetTall( ) )
	
	local parentPanel = self.settingPanel.panel
	local w, h = self.settingPanel.panel:GetWide( ), self.settingPanel.panel:GetTall( )
	
	self.vendorNewData = { }
	
	parentPanel.vendorName = ""
	parentPanel.vendorNameLen = 0
	
	parentPanel.vendorDesc = ""
	parentPanel.vendorDescLen = 0
	
	parentPanel.vendorNameLabel = vgui.Create( "DLabel", parentPanel )
	parentPanel.vendorNameLabel:SetPos( 10, 10 )
	parentPanel.vendorNameLabel:SetColor( Color( 50, 50, 50, 255 ) )
	parentPanel.vendorNameLabel:SetFont( "catherine_normal15" )
	parentPanel.vendorNameLabel:SetText( LANG( "Vendor_UI_VendorNameStr" ) )
	parentPanel.vendorNameLabel:SizeToContents( )
	
	parentPanel.vendorNameEnt = vgui.Create( "DTextEntry", parentPanel )
	parentPanel.vendorNameEnt:SetPos( 10, 30 )
	parentPanel.vendorNameEnt:SetSize( w - 20, 25 )
	parentPanel.vendorNameEnt:SetFont( "catherine_normal15" )
	parentPanel.vendorNameEnt:SetText( self.vendorData.name )
	parentPanel.vendorNameEnt:SetAllowNonAsciiCharacters( true )
	parentPanel.vendorNameEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	parentPanel.vendorNameEnt.OnTextChanged = function( pnl )
		parentPanel.vendorName = pnl:GetText( )
		parentPanel.vendorNameLen = parentPanel.vendorName:utf8len( )
		
		self.vendorNewData.name = parentPanel.vendorName
	end
	parentPanel.vendorNameEnt.OnEnter = function( pnl )
		netstream.Start( "catherine.plugin.vendor.VendorWork", {
			self.ent,
			CAT_VENDOR_ACTION_SETTING_CHANGE,
			self.vendorNewData
		} )
	end
	
	parentPanel.vendorDescLabel = vgui.Create( "DLabel", parentPanel )
	parentPanel.vendorDescLabel:SetPos( 10, 60 )
	parentPanel.vendorDescLabel:SetColor( Color( 50, 50, 50, 255 ) )
	parentPanel.vendorDescLabel:SetFont( "catherine_normal15" )
	parentPanel.vendorDescLabel:SetText( LANG( "Vendor_UI_VendorDescriptionStr" ) )
	parentPanel.vendorDescLabel:SizeToContents( )
	
	parentPanel.vendorDescEnt = vgui.Create( "DTextEntry", parentPanel )
	parentPanel.vendorDescEnt:SetPos( 10, 80 )
	parentPanel.vendorDescEnt:SetSize( w - 20, 25 )
	parentPanel.vendorDescEnt:SetFont( "catherine_normal15" )
	parentPanel.vendorDescEnt:SetText( self.vendorData.desc )
	parentPanel.vendorDescEnt:SetAllowNonAsciiCharacters( true )
	parentPanel.vendorDescEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	parentPanel.vendorDescEnt.OnTextChanged = function( pnl )
		parentPanel.vendorDesc = pnl:GetText( )
		parentPanel.vendorDescLen = parentPanel.vendorDesc:utf8len( )
		
		self.vendorNewData.desc = parentPanel.vendorDesc
	end
	parentPanel.vendorDescEnt.OnEnter = function( pnl )
		netstream.Start( "catherine.plugin.vendor.VendorWork", {
			self.ent,
			CAT_VENDOR_ACTION_SETTING_CHANGE,
			self.vendorNewData
		} )
	end
	
	parentPanel.vendorModelLabel = vgui.Create( "DLabel", parentPanel )
	parentPanel.vendorModelLabel:SetPos( 10, 110 )
	parentPanel.vendorModelLabel:SetColor( Color( 50, 50, 50, 255 ) )
	parentPanel.vendorModelLabel:SetFont( "catherine_normal15" )
	parentPanel.vendorModelLabel:SetText( LANG( "Vendor_UI_VendorModelStr" ) )
	parentPanel.vendorModelLabel:SizeToContents( )
	
	parentPanel.vendorModelEnt = vgui.Create( "DTextEntry", parentPanel )
	parentPanel.vendorModelEnt:SetPos( 10, 130 )
	parentPanel.vendorModelEnt:SetSize( w - 20, 25 )
	parentPanel.vendorModelEnt:SetFont( "catherine_normal15" )
	parentPanel.vendorModelEnt:SetText( self.vendorData.model )
	parentPanel.vendorModelEnt:SetAllowNonAsciiCharacters( true )
	parentPanel.vendorModelEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	parentPanel.vendorModelEnt.OnTextChanged = function( pnl )
		self.vendorNewData.model = pnl:GetText( )
	end
	parentPanel.vendorModelEnt.OnEnter = function( pnl )
		netstream.Start( "catherine.plugin.vendor.VendorWork", {
			self.ent,
			CAT_VENDOR_ACTION_SETTING_CHANGE,
			self.vendorNewData
		} )
	end
	
	parentPanel.vendorAccFacLabel = vgui.Create( "DLabel", parentPanel )
	parentPanel.vendorAccFacLabel:SetPos( 10, 170 )
	parentPanel.vendorAccFacLabel:SetColor( Color( 50, 50, 50, 255 ) )
	parentPanel.vendorAccFacLabel:SetFont( "catherine_normal15" )
	parentPanel.vendorAccFacLabel:SetText( LANG( "Vendor_UI_VendorAllowFactionStr" ) )
	parentPanel.vendorAccFacLabel:SizeToContents( )
	
	parentPanel.factionLists = vgui.Create( "DPanelList", parentPanel )
	parentPanel.factionLists:SetPos( 10, 190 )
	parentPanel.factionLists:SetSize( w - 30, 120 )
	parentPanel.factionLists:SetSpacing( 0 )
	parentPanel.factionLists:EnableHorizontal( false )
	parentPanel.factionLists:EnableVerticalScrollbar( true )	
	parentPanel.factionLists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 50, 50, 50, 255 ) )
	end

	self:Refresh_SettingList( 1 )
	self:Refresh_SettingList( 2 )
	
	self.settingPanel.panel.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
end

function PANEL:Refresh_SettingList( id )
	local parentPanel = self.settingPanel.panel
	local w, h = self.settingPanel.panel:GetWide( ), self.settingPanel.panel:GetTall( )
	
	if ( id == 1 ) then
		parentPanel.factionLists:Clear( )
		
		local factionData = self.vendorData.factions
		local notyetPermission = false

		if ( table.Count( factionData ) == 0 ) then
			notyetPermission = true
		end
		
		for k, v in pairs( catherine.faction.GetAll( ) ) do
			local has = table.HasValue( factionData, v.uniqueID )
			local name = catherine.util.StuffLanguage( v.name )
			local allowed = LANG( "Vendor_UI_VendorAllowFaction_AllowedStr" )
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( parentPanel.factionLists:GetWide( ), 25 )
			panel.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
				draw.SimpleText( name, "catherine_normal20", 5, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
				
				if ( notyetPermission or has ) then
					surface.SetFont( "catherine_normal15" )
					local tw, th = surface.GetTextSize( allowed )
					
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( w - 30 - tw, h / 2 - 16 / 2, 16, 16 )
					
					draw.SimpleText( allowed, "catherine_normal15", w - 10, h / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
				end
			end
			
			local button = vgui.Create( "DButton", panel )
			button:SetSize( panel:GetWide( ), panel:GetTall( ) )
			button:SetDrawBackground( false )
			button:SetText( "" )
			button.DoClick = function( )
				local menu = DermaMenu( )

				menu:AddOption( LANG( "Vendor_UI_VendorAllowFaction_AllowOptionStr" ), function( )
					for v2, v2 in pairs( factionData ) do
						if ( v.uniqueID == v2 ) then
							return
						end
					end
					
					factionData[ #factionData + 1 ] = v.uniqueID
					
					netstream.Start( "catherine.plugin.vendor.VendorWork", {
						self.ent,
						CAT_VENDOR_ACTION_SETTING_CHANGE,
						{ factions = factionData }
					} )
					
					self:Refresh_SettingList( 1 )
				end )
				
				menu:AddOption( LANG( "Vendor_UI_VendorAllowFaction_DenyOptionStr" ), function( )
					local changed = false
					
					for k2, v2 in pairs( factionData ) do
						if ( v.uniqueID == v2 ) then
							table.remove( factionData, k2 )
							changed = true
						end
					end
					
					if ( changed ) then
						netstream.Start( "catherine.plugin.vendor.VendorWork", {
							self.ent,
							CAT_VENDOR_ACTION_SETTING_CHANGE,
							{ factions = factionData }
						} )
						
						self:Refresh_SettingList( 1 )
					end
				end )
				
				menu:Open( )
			end
			
			parentPanel.factionLists:AddItem( panel )
		end
	end
end

function PANEL:Refresh_List( id )
	if ( id == 1 ) then
		local buyalbeItems = self:GetBuyableItems( )
		self.count = table.Count( buyalbeItems )
		
		self.buyPanel.Lists:Clear( )
		
		for k, v in SortedPairs( buyalbeItems ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.buyPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in SortedPairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					local cost = newData.cost or itemTable.cost
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.name ), "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( catherine.util.StuffLanguage( itemTable.desc ), "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					
					draw.SimpleText( cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetName( cost ), "catherine_normal20", w - 10, 15, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
					
					local stock = newData.stock
					
					draw.SimpleText( LANG( "Vendor_UI_StockStr", stock or 0 ), "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
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
				spawnIcon:SetModel( model, itemTable.skin or 0 )
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
		
		for k, v in SortedPairs( sellableItems ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.sellPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in SortedPairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
				local name = catherine.util.StuffLanguage( itemTable.name )
				local desc = catherine.util.StuffLanguage( itemTable.desc )
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					local cost = math.Round( ( newData.cost or itemTable.cost ) / PLUGIN.VENDOR_SOLD_DISCOUNTPER )
					
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( name, "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( desc, "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					
					draw.SimpleText( cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetName( cost ), "catherine_normal20", w - 10, 15, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
					
					local stock = newData.stock
					
					draw.SimpleText( LANG( "Vendor_UI_StockStr", stock or 0 ), "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
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
				spawnIcon:SetModel( model, itemTable.skin or 0 )
				spawnIcon:SetToolTip( false )
				spawnIcon:SetDisabled( true )
				spawnIcon.PaintOver = function( ) end

				form:AddItem( panel )
			end
			
			self.sellPanel.Lists:AddItem( form )
		end
	elseif ( id == 4 ) then
		self.manageItemPanel.Lists:Clear( )
		
		for k, v in SortedPairs( self:GetItemTables( ) ) do
			local form = vgui.Create( "DForm" )
			form:SetSize( self.manageItemPanel.Lists:GetWide( ), 64 )
			form:SetName( catherine.util.StuffLanguage( k ) )
			form.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_FORM, w, h )
			end
			form.Header:SetFont( "catherine_normal15" )
			form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
			
			for k1, v1 in SortedPairs( v ) do
				local itemTable = catherine.item.FindByID( v1.uniqueID )
				if ( !itemTable ) then continue end
				local newData = self.vendorData.inv[ v1.uniqueID ] or { }
				local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
				local name = catherine.util.StuffLanguage( itemTable.name )
				local desc = catherine.util.StuffLanguage( itemTable.desc )
				
				local panel = vgui.Create( "DPanel" )
				panel:SetSize( form:GetWide( ), 50 )
				panel.Paint = function( pnl, w, h )
					local cost = newData.cost or itemTable.cost
					
					draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
					draw.SimpleText( name, "catherine_normal20", 60, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( desc, "catherine_normal15", 60, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
					draw.SimpleText( cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetName( cost ), "catherine_normal15", w - 10, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
					local mode = newData.type
					
					if ( mode ) then
						if ( mode == 1 ) then
							draw.SimpleText( LANG( "Vendor_UI_VendorItemNoneTypeStr" ), "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
						elseif ( mode == 2 ) then
							draw.SimpleText( LANG( "Vendor_UI_VendorItemBuyOnlyTypeStr" ), "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
						elseif ( mode == 3 ) then
							draw.SimpleText( LANG( "Vendor_UI_VendorItemSellOnlyTypeStr" ), "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
						elseif ( mode == 4 ) then
							draw.SimpleText( LANG( "Vendor_UI_VendorItemBothTypeStr" ), "catherine_normal15", w * 0.7, 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
						end
					end
					
					local stock = newData.stock
					
					draw.SimpleText( LANG( "Vendor_UI_StockStr", stock or 0 ), "catherine_normal15", w - 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )
					
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
				spawnIcon:SetModel( model, itemTable.skin or 0 )
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

	local x, y = self:GetPos( )
	local newData = data or {
		uniqueID = itemTable.uniqueID,
		stock = 0,
		cost = itemTable.cost,
		type = 1
	}
	local title = LANG( "Vendor_UI_ItemSettingStr" )
	local name = catherine.util.StuffLanguage( itemTable.name )
	local costTitle = LANG( "Vendor_UI_ItemSetting_CostTitleStr" )
	local stockTitle = LANG( "Vendor_UI_ItemSetting_StockTitleStr" )
	
	self.itemInformationPanel = vgui.Create( "DFrame" )
	self.itemInformationPanel:SetTitle( "" )
	self.itemInformationPanel:ShowCloseButton( false )
	self.itemInformationPanel:SetSize( ScrW( ) * 0.17, ScrH( ) * 0.5 )
	self.itemInformationPanel:SetPos( x - self.itemInformationPanel:GetWide( ), ScrH( ) / 2 - self.itemInformationPanel:GetTall( ) / 2 )
	self.itemInformationPanel.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
		
		draw.SimpleText( title, "catherine_normal20", 0, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		draw.SimpleText( name, "catherine_normal15", 10, 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		
		draw.SimpleText( costTitle, "catherine_normal15", 10, 60, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		draw.SimpleText( stockTitle, "catherine_normal15", 10, 130, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
	self.itemInformationPanel:MakePopup( )
	self.itemInformationPanel:SetDraggable( false )
	
	local pnlW, pnlH = self.itemInformationPanel:GetWide( ), self.itemInformationPanel:GetTall( )
	
	self.itemInformationPanel.save = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.save:SetPos( pnlW - 100, pnlH - 30 )
	self.itemInformationPanel.save:SetSize( 90, 25 )
	self.itemInformationPanel.save:SetStr( LANG( "Vendor_UI_ItemSetting_RegisterStr" ) )
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
	self.itemInformationPanel.dis:SetStr( LANG( "Vendor_UI_ItemSetting_UNRegisterStr" ) )
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
	self.itemInformationPanel.typeChange:SetStr( "" )
	self.itemInformationPanel.typeChange:SetStrFont( "catherine_normal15" )
	self.itemInformationPanel.typeChange:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.typeChange:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.itemInformationPanel.typeChange.PaintOverAll = function( pnl )
		local type = newData.type
		
		if ( type == 1 ) then
			pnl:SetStr( LANG( "Vendor_UI_ItemSettingNoneTypeStr" ) )
		elseif ( type == 2 ) then
			pnl:SetStr( LANG( "Vendor_UI_ItemSettingBuyOnlyTypeStr" ) )
		elseif ( type == 3 ) then
			pnl:SetStr( LANG( "Vendor_UI_ItemSettingSellOnlyTypeStr" ) )
		elseif ( type == 4 ) then
			pnl:SetStr( LANG( "Vendor_UI_ItemSettingBothTypeStr" ) )
		end
	end
	self.itemInformationPanel.typeChange.Click = function( )
		local menu = DermaMenu( )
		
		menu:AddOption( LANG( "Vendor_UI_ItemSettingBuyOnlyTypeStr" ), function( )
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
		
		menu:AddOption( LANG( "Vendor_UI_ItemSettingSellOnlyTypeStr" ), function( )
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
		
		menu:AddOption( LANG( "Vendor_UI_ItemSettingBothTypeStr" ), function( )
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

	self.itemInformationPanel.cost = vgui.Create( "DTextEntry", self.itemInformationPanel )
	self.itemInformationPanel.cost:SetPos( 10, 80 )
	self.itemInformationPanel.cost:SetSize( pnlW - 20, 30 )
	self.itemInformationPanel.cost:SetText( newData.cost )
	self.itemInformationPanel.cost:SetFont( "catherine_normal15" )
	self.itemInformationPanel.cost:SetAllowNonAsciiCharacters( false )
	self.itemInformationPanel.cost:SetEditable( true )
	self.itemInformationPanel.cost.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.itemInformationPanel.cost.OnTextChanged = function( pnl )
		local newCost = pnl:GetText( )
		
		newCost = tonumber( newCost )
		
		if ( !newCost or newCost < 0 ) then
			newCost = 0
		end
		
		if ( newCost > 999999999 ) then
			newCost = 999999999
		end

		newData.cost = math.Round( newCost )
		pnl:SetText( newCost )
		pnl:SetCaretPos( #tostring( newCost ) )
	end
	
	self.itemInformationPanel.stock = vgui.Create( "DTextEntry", self.itemInformationPanel )
	self.itemInformationPanel.stock:SetPos( 10, 150 )
	self.itemInformationPanel.stock:SetSize( pnlW - 20, 30 )
	self.itemInformationPanel.stock:SetText( newData.stock )
	self.itemInformationPanel.stock:SetFont( "catherine_normal15" )
	self.itemInformationPanel.stock:SetAllowNonAsciiCharacters( false )
	self.itemInformationPanel.stock:SetEditable( true )
	self.itemInformationPanel.stock.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.itemInformationPanel.stock.OnTextChanged = function( pnl )
		local newStock = pnl:GetText( )
		
		newStock = tonumber( newStock )
		
		if ( !newStock or newStock < 0 ) then
			newStock = 0
		end
		
		if ( newStock > 999999999 ) then
			newStock = 999999999
		end

		newData.stock = math.Round( newStock )
		pnl:SetText( newStock )
		pnl:SetCaretPos( #tostring( newStock ) )
	end
	
	self.itemInformationPanel.close = vgui.Create( "catherine.vgui.button", self.itemInformationPanel )
	self.itemInformationPanel.close:SetPos( self.itemInformationPanel:GetWide( ) - 30, 0 )
	self.itemInformationPanel.close:SetSize( 30, 25 )
	self.itemInformationPanel.close:SetStr( "X" )
	self.itemInformationPanel.close:SetStrFont( "catherine_normal30" )
	self.itemInformationPanel.close:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.itemInformationPanel.close:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.itemInformationPanel.close.Click = function( )
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	
	if ( IsValid( self.ent ) ) then
		local name = self.ent:GetNetVar( "name" )
		
		if ( name ) then
			draw.SimpleText( name, "catherine_normal20", 0, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		end
	end
end

function PANEL:InitializeVendor( ent )
	self.ent = ent
	self.vendorData = PLUGIN:GetVendorDatas( ent )
	self.vendorData.inv = ent:GetNetVar( "inv", { } )
end

function PANEL:Think( )
	if ( ( self.entCheck or 0 ) <= CurTime( ) ) then
		if ( !IsValid( self.ent ) and !self.closing ) then
			self:Close( )
			
			return
		end
		
		self.entCheck = CurTime( ) + 0.5
	end
end

function PANEL:Close( )
	if ( IsValid( self.itemInformationPanel ) ) then
		self.itemInformationPanel:Remove( )
		self.itemInformationPanel = nil
	end
	
	if ( PLUGIN.VENDOR_NOANI ) then
		self.closing = true
		
		self:Remove( )
		self = nil
	else
		self.closing = true
		
		self:MoveTo( ScrW( ), self.y, 0.2, 0, nil, function( )
			self:Remove( )
			self = nil
		end )
	end
end

vgui.Register( "catherine.vgui.vendor", PANEL, "DFrame" )