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
	catherine.vgui.inventory = self

	self:SetMenuSize( ScrW( ) * 0.7, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Inventory_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 110, 35 )
	self.Lists:SetSize( self.w - 120, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	
	self.weight = vgui.Create( "catherine.vgui.weight", self )
	self.weight:SetPos( 10, self.h - 100 )
	self.weight:SetSize( 90, 90 )
	self.weight:SetCircleSize( 40 )

	self:BuildInventory( )
end

function PANEL:OnMenuRecovered( )
	self:BuildInventory( )
end

function PANEL:GetInventory( )
	local inventory = { }
	
	for k, v in pairs( catherine.inventory.Get( ) ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		
		inventory[ category ] = inventory[ category ] or { }
		inventory[ category ][ k ] = v
	end

	self.weight:SetWeight( catherine.inventory.GetWeights( ) )
	
	return inventory
end

function PANEL:BuildInventory( )
	local pl = self.player
	
	self.Lists:Clear( )

	for k, v in SortedPairs( self:GetInventory( ) ) do
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
		
		for k1, v1 in SortedPairsByMemberValue( v, "uniqueID" ) do
			local w, h = 64, 64
			local itemTable = catherine.item.FindByID( v1.uniqueID )
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( pl, itemTable, pl:GetInvItemDatas( k1 ), true ) or nil
			local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
			local noDrawItemCount = hook.Run( "NoDrawItemCount", pl, k1 )
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, itemTable.skin or 0 )
			spawnIcon:SetToolTip( catherine.item.GetBasicDesc( itemTable ) .. ( itemDesc and "\n" .. itemDesc or "" ) )
			spawnIcon.DoClick = function( )
				catherine.item.OpenMenuUse( k1 )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
			
				if ( catherine.inventory.IsEquipped( k1 ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( pl, itemTable, w, h, pl:GetInvItemDatas( k1 ) )
				end
				
				if ( !noDrawItemCount and v1.itemCount > 1 ) then
					local count = v1.itemCount
					
					surface.SetFont( "catherine_normal20" )
					local tw, th = surface.GetTextSize( count )
					
					draw.RoundedBox( 0, 5 - tw / 2, h - 20, tw * 2, 20, Color( 50, 50, 50, 200 ) )
					draw.SimpleText( count, "catherine_normal20", 5, h - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.inventory", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Inventory_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.inventory ) and catherine.vgui.inventory or vgui.Create( "catherine.vgui.inventory", menuPnl )
end )