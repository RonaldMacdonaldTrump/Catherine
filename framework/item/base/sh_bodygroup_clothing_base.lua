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

local BASE = catherine.item.New( "BODYGROUP_CLOTHING", nil, true )
BASE.name = "Bodygroup Clothing Base"
BASE.desc = "A Bodygroup Cloth."
BASE.category = "^Item_Category_BodygroupClothing"
BASE.cost = 0
BASE.weight = 0
BASE.itemData = {
	wearing = false
}
BASE.isBodygroupCloth = true
BASE.useDynamicItemData = false
BASE.bodyGroup = 0
BASE.bodyGroupSubModelIndex = 0
BASE.func = { }
BASE.func.wear = {
	text = "^Item_FuncStr01_BodygroupClothing",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		local bodygroups = catherine.character.GetCharVar( pl, "bodygroups", { } )
		local bodygroupID = itemTable.bodyGroup

		if ( bodygroupID < pl:GetNumBodyGroups( ) ) then
			if ( type( ent ) == "Entity" ) then
				catherine.item.Give( pl, itemTable.uniqueID )
				ent:Remove( )
			end

			if ( !bodygroups[ bodygroupID ] and pl:GetBodygroup( bodygroupID ) == 0 ) then
				bodygroups[ bodygroupID ] = itemTable.bodyGroupSubModelIndex
				
				pl:SetBodygroup( bodygroupID, itemTable.bodyGroupSubModelIndex )
				
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", true )
				catherine.character.SetCharVar( pl, "bodygroups", bodygroups )
			elseif ( bodygroups[ bodygroupID ] and pl:GetBodygroup( bodygroupID ) == 0 ) then
				pl:SetBodygroup( bodygroupID, itemTable.bodyGroupSubModelIndex )
				
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", true )
			else
				catherine.util.NotifyLang( pl, "Item_Func01Notify02_BodygroupClothing" )
				return
			end
		else
			catherine.util.NotifyLang( pl, "Item_Func01Notify01_BodygroupClothing" )
			return
		end
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) and itemTable:CanWear( pl )
	end
}
BASE.func.takeoff = {
	text = "^Item_FuncStr02_BodygroupClothing",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		local bodygroups = catherine.character.GetCharVar( pl, "bodygroups", { } )
		local bodygroupID = itemTable.bodyGroup
		
		if ( bodygroupID < pl:GetNumBodyGroups( ) ) then
			if ( bodygroups[ bodygroupID ] and pl:GetBodygroup( bodygroupID ) == itemTable.bodyGroupSubModelIndex ) then
				bodygroups[ bodygroupID ] = nil
				
				pl:SetBodygroup( bodygroupID, 0 )
				
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", false )
				catherine.character.SetCharVar( pl, "bodygroups", bodygroups )
			elseif ( bodygroups[ bodygroupID ] and pl:GetBodygroup( bodygroupID ) == 0 ) then
				bodygroups[ bodygroupID ] = nil
				
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", false )
				catherine.character.SetCharVar( pl, "bodygroups", bodygroups )
			else
				catherine.util.NotifyLang( pl, "Item_Func02Notify02_BodygroupClothing" )
				return
			end
		else
			catherine.util.NotifyLang( pl, "Item_Func02Notify01_BodygroupClothing" )
			return
		end
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) == true and itemTable:CanTakeOff( pl )
	end
}

function BASE:CanWear( pl )
	local bodygroups = catherine.character.GetCharVar( pl, "bodygroups", { } )
	
	if ( self.bodyGroup < pl:GetNumBodyGroups( ) ) then
		if ( !bodygroups[ self.bodyGroup ] and pl:GetBodygroup( self.bodyGroup ) == 0 ) then
			return true
		end
	end
end

function BASE:CanTakeOff( pl )
	local bodygroups = catherine.character.GetCharVar( pl, "bodygroups", { } )
	
	if ( self.bodyGroup < pl:GetNumBodyGroups( ) ) then
		if ( bodygroups[ self.bodyGroup ] and pl:GetBodygroup( self.bodyGroup ) == self.bodyGroupSubModelIndex ) then
			return true
		end
	end
end

if ( SERVER ) then
	hook.Add( "PlayerCharacterTodayFirstLoaded", "catherine.item.hooks.bodygroup_clothing_base.PlayerCharacterTodayFirstLoaded", function( pl )
		timer.Simple( 1, function( )
			for k, v in pairs( catherine.inventory.Get( pl ) ) do
				local itemTable = catherine.item.FindByID( k )
				if ( !itemTable.isBodygroupCloth or !catherine.inventory.GetItemData( pl, k, "wearing" ) ) then continue end
				
				catherine.item.Work( pl, k, "wear" )
			end
		end )
	end )

	hook.Add( "OnItemDrop", "catherine.item.hooks.bodygroup_clothing_base.OnItemDrop", function( pl, itemTable )
		if ( itemTable.isBodygroupCloth and catherine.inventory.GetItemData( pl, itemTable.uniqueID, "wearing" ) ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemStorageMove", "catherine.item.hooks.bodygroup_clothing_base.OnItemStorageMove", function( pl, itemTable )
		if ( itemTable.isBodygroupCloth and catherine.inventory.GetItemData( pl, itemTable.uniqueID, "wearing" ) ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemVendorSold", "catherine.item.hooks.bodygroup_clothing_base.OnItemVendorSold", function( pl, itemTable )
		if ( itemTable.isBodygroupCloth and catherine.inventory.GetItemData( pl, itemTable.uniqueID, "wearing" ) ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemForceTake", "catherine.item.hooks.bodygroup_clothing_base.OnItemForceTake", function( pl, itemTable )
		if ( itemTable.isBodygroupCloth and catherine.inventory.GetItemData( pl, itemTable.uniqueID, "wearing" ) ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
else
	function BASE:DrawInformation( pl, itemTable, w, h, itemData )
		if ( itemData.wearing ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "icon16/accept.png" ) )
			surface.DrawTexturedRect( 5, 5, 16, 16 )
		end
	end
end

catherine.item.Register( BASE )