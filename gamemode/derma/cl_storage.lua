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
	catherine.vgui.storage = self

	self.entCheck = CurTime( ) + 1

	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ) * 0.7, ScrH( ) * 0.6
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2

	self:SetSize( self.w, self.h )
	self:SetPos( ScrW( ), self.y )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	self:MoveTo( ScrW( ) / 2 - self.w / 2, self.y, 0.2, 0 )
	
	self.storageLists = vgui.Create( "DPanelList", self )
	self.storageLists:SetPos( 10, 35 )
	self.storageLists:SetSize( self.w / 2 - 20, self.h - 85 )
	self.storageLists:SetSpacing( 5 )
	self.storageLists:EnableHorizontal( false )
	self.storageLists:EnableVerticalScrollbar( true )	
	self.storageLists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.storageInventory and table.Count( self.storageInventory ) == 0 ) then
			draw.SimpleText( LANG( "Storage_UI_StorageNoHaveItem" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.playerLists = vgui.Create( "DPanelList", self )
	self.playerLists:SetPos( self.w / 2, 35 )
	self.playerLists:SetSize( self.w / 2 - 10, self.h - 85 )
	self.playerLists:SetSpacing( 5 )
	self.playerLists:EnableHorizontal( false )
	self.playerLists:EnableVerticalScrollbar( true )	
	self.playerLists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.playerInventory and table.Count( self.playerInventory ) == 0 ) then
			draw.SimpleText( LANG( "Storage_UI_PlayerNoHaveItem" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.playerWeight = vgui.Create( "catherine.vgui.weight", self )
	self.playerWeight:SetPos( self.w - 50, self.h - 45 )
	self.playerWeight:SetSize( 40, 40 )
	self.playerWeight:SetCircleSize( 15 )
	self.playerWeight:SetShowText( false )
	
	self.storageWeight = vgui.Create( "catherine.vgui.weight", self )
	self.storageWeight:SetPos( 10, self.h - 45 )
	self.storageWeight:SetSize( 40, 40 )
	self.storageWeight:SetCircleSize( 15 )
	self.storageWeight:SetShowText( false )
	
	self.close = vgui.Create( "catherine.vgui.button", self )
	self.close:SetPos( self.w - 30, 0 )
	self.close:SetSize( 30, 25 )
	self.close:SetStr( "X" )
	self.close:SetStrFont( "catherine_normal30" )
	self.close:SetStrColor( Color( 255, 150, 150, 255 ) )
	self.close:SetGradientColor( Color( 255, 150, 150, 255 ) )
	self.close.Click = function( )
		self:Close( )
	end
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	
	if ( IsValid( self.ent ) ) then
		local name = self.ent:GetNetVar( "name" )
		
		if ( name ) then
			draw.SimpleText( name, "catherine_normal25", 10, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		end
		
		draw.SimpleText( LANG( "Storage_UI_YourInv" ), "catherine_normal25", w / 2, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	end
end

function PANEL:InitializeStorage( ent )
	self.ent = ent
	
	local storageInventory = { }
	local playerInventory = { }
	
	for k, v in pairs( catherine.storage.GetInv( ent ) ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		
		storageInventory[ category ] = storageInventory[ category ] or { }
		storageInventory[ category ][ v.uniqueID ] = v
	end

	for k, v in pairs( catherine.inventory.Get( ) ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		
		playerInventory[ category ] = playerInventory[ category ] or { }
		playerInventory[ category ][ v.uniqueID ] = v
	end
	
	self.playerInventory = playerInventory
	self.storageInventory = storageInventory
	
	self.storageWeight:SetWeight( catherine.storage.GetWeights( self.ent ) )
	self.playerWeight:SetWeight( catherine.inventory.GetWeights( ) )

	self:BuildStorage( )
end

function PANEL:Think( )
	if ( ( self.entCheck or 0 ) <= CurTime( ) ) then
		if ( !IsValid( self.ent ) and !self.closeing ) then
			self:Close( )
			return
		end
		
		self.entCheck = CurTime( ) + 1
	end
end

function PANEL:BuildStorage( )
	self.storageLists:Clear( )
	self.playerLists:Clear( )
	local delta = 0
	
	for k, v in pairs( self.storageInventory or { } ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.storageLists:GetWide( ), 54 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form:SetAlpha( 0 )
		form:AlphaTo( 255, 0.1, delta )
		form.Paint = function( pnl, w, h )
			catherine.theme.Draw( CAT_THEME_FORM, w, h )
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
			local w, h = 54, 54
			local itemTable = catherine.item.FindByID( v1.uniqueID )
			if ( !itemTable ) then continue end
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( self.player, itemTable, self.player:GetInvItemDatas( itemTable.uniqueID ), false ) or nil
			local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, itemTable.skin or 0 )
			spawnIcon:SetToolTip( catherine.item.GetBasicDesc( itemTable ) .. ( itemDesc and "\n" .. itemDesc or "" ) )
			spawnIcon.DoClick = function( )
				netstream.Start( "catherine.storage.Work", {
					self.ent:EntIndex( ),
					CAT_STORAGE_ACTION_REMOVE,
					v1.uniqueID
				} )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( catherine.inventory.IsEquipped( v1.uniqueID ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( self.player, itemTable, w, h, self.player:GetInvItemDatas( itemTable.uniqueID ) )
				end
				
				if ( v1.itemCount > 1 ) then
					draw.SimpleText( v1.itemCount, "catherine_normal20", 5, h - 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.storageLists:AddItem( form )
	end
	
	delta = 0
	
	for k, v in pairs( self.playerInventory or { } ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.playerLists:GetWide( ), 54 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form:SetAlpha( 0 )
		form:AlphaTo( 255, 0.1, delta )
		form.Paint = function( pnl, w, h )
			catherine.theme.Draw( CAT_THEME_FORM, w, h )
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
			local w, h = 54, 54
			local itemTable = catherine.item.FindByID( v1.uniqueID )
			if ( !itemTable ) then continue end
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( self.player, itemTable, self.player:GetInvItemDatas( itemTable.uniqueID ), true ) or nil
			local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, itemTable.skin or 0 )
			spawnIcon:SetToolTip( catherine.item.GetBasicDesc( itemTable ) .. ( itemDesc and "\n" .. itemDesc or "" ) )
			spawnIcon.DoClick = function( )
				netstream.Start( "catherine.storage.Work", {
					self.ent:EntIndex( ),
					CAT_STORAGE_ACTION_ADD,
					{
						uniqueID = v1.uniqueID,
						itemData = self.player:GetInvItemDatas( itemTable.uniqueID )
					}
				} )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( catherine.inventory.IsEquipped( v1.uniqueID ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( self.player, itemTable, w, h, self.player:GetInvItemDatas( itemTable.uniqueID ) )
				end
				
				if ( v1.itemCount > 1 ) then
					draw.SimpleText( v1.itemCount, "catherine_normal20", 5, h - 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.playerLists:AddItem( form )
	end
end

function PANEL:Close( )
	if ( self.closeing ) then return end
	
	self.closeing = true
	self:MoveTo( ScrW( ), self.y, 0.2, 0, nil, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.storage", PANEL, "DFrame" )