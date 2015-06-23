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

local BASE = catherine.item.New( "ACCESSORY", nil, true )
BASE.name = "Accessory Base"
BASE.desc = "A Accessory."
BASE.category = "^Item_Category_Accessory"
BASE.cost = 0
BASE.weight = 1
BASE.itemData = {
	wearing = false
}
BASE.isAccessory = true
BASE.bone = "ValveBiped.Bip01_Head1"
BASE.offsetVector = Vector( 0, 3, 3 )
BASE.offsetAngles = Angle( 270, 270, 0 )
BASE.useDynamicItemData = false
BASE.func = { }
BASE.func.wear = {
	text = "^Item_FuncStr01_Accessory",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( type( ent ) == "Entity" ) then
			catherine.item.Give( pl, itemTable.uniqueID )
			ent:Remove( )
		end
		
		local result, langKey, par = catherine.accessory.Work( pl, CAT_ACCESSORY_ACTION_WEAR, {
			itemTable = itemTable
		} )
		
		if ( result ) then
			catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", true )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) and catherine.accessory.CanWork( pl, CAT_ACCESSORY_ACTION_WEAR, {
			itemTable = itemTable
		} )
	end
}
BASE.func.takeoff = {
	text = "^Item_FuncStr02_Accessory",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		local result, langKey, par = catherine.accessory.Work( pl, CAT_ACCESSORY_ACTION_TAKEOFF, {
			itemTable = itemTable
		} )
		
		if ( result ) then
			catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", false )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) and catherine.accessory.CanWork( pl, CAT_ACCESSORY_ACTION_TAKEOFF, {
			itemTable = itemTable
		} )
	end
}

if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "catherine.item.hooks.accessory_base.PlayerSpawnedInCharacter", function( pl )
		timer.Simple( 1, function( )
			for k, v in pairs( catherine.inventory.Get( pl ) ) do
				local itemTable = catherine.item.FindByID( k )
				if ( !itemTable.isAccessory or !catherine.inventory.GetItemData( pl, k, "wearing" ) ) then continue end
				
				catherine.item.Work( pl, k, "wear" )
			end
		end )
	end )

	hook.Add( "OnItemDrop", "catherine.item.hooks.accessory_base.OnItemDrop", function( pl, itemTable )
		if ( itemTable.isAccessory ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemStorageMove", "catherine.item.hooks.accessory_base.OnItemStorageMove", function( pl, itemTable )
		if ( itemTable.isAccessory ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemVendorSold", "catherine.item.hooks.accessory_base.OnItemVendorSold", function( pl, itemTable )
		if ( itemTable.isAccessory ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemForceTake", "catherine.item.hooks.accessory_base.OnItemForceTake", function( pl, itemTable )
		if ( itemTable.isAccessory ) then
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