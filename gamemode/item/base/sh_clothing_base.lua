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

local BASE = catherine.item.New( "CLOTHING", nil, true )
BASE.name = "Clothing Base"
BASE.desc = "A Cloth."
BASE.category = "Clothing"
BASE.cost = 0
BASE.weight = 0
BASE.itemData = {
	wearing = false
}
BASE.isCloth = true
//BASE.replacement
//BASE.femaleModel
BASE.func = { }
BASE.func.wear = {
	text = "Wear",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( catherine.character.GetCharVar( pl, "clothWearing" ) ) then
			return
		end
		
		local originalModel = catherine.character.GetCharVar( pl, "originalModel" )
		
		if ( !originalModel ) then
			return
		end
		
		local replacement = itemTable.replacement
		local newModel = itemTable.model
		local playerModel = pl:GetModel( ):lower( )
		
		if ( newModel:find( "female" ) or catherine.animation.Get( newModel ) == "citizen_female" and itemTable.femaleModel ) then
			newModel = itemTable.femaleModel
		end

		if ( replacement and #replacement == 2 ) then
			newModel = playerModel:gsub( replacement[ 1 ], replacement[ 2 ] )
		end
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		pl:SetModel( newModel )
		pl:SetupHands( )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", true )
		catherine.character.SetCharVar( pl, "clothWearing", true )
	end,
	canLook = function( pl, itemTable )
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		
		return !itemData.wearing
	end
}
BASE.func.takeoff = {
	text = "Take off",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		local originalModel = catherine.character.GetCharVar( pl, "originalModel" )
		
		if ( !originalModel ) then
			return
		end
		
		local replacement = itemTable.replacement
		
		if ( replacement and #replacement == 2 ) then
			originalModel = pl:GetModel( ):lower( ):gsub( replacement[ 2 ], replacement[ 1 ] )
		end
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		pl:SetModel( originalModel )
		pl:SetupHands( )
		
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", false )
		catherine.character.SetCharVar( pl, "clothWearing", nil )
	end,
	canLook = function( pl, itemTable )
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )

		return itemData.wearing
	end
}

if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "catherine.item.hooks.clothing_base.PlayerSpawnedInCharacter", function( pl )
		timer.Simple( 1, function( )
			for k, v in pairs( catherine.inventory.Get( pl ) ) do
				local itemTable = catherine.item.FindByID( k )
				if ( !itemTable.isCloth or !catherine.inventory.GetItemData( pl, k ).wearing ) then continue end
				
				catherine.item.Work( pl, k, "wear" )
			end
		end )
	end )

	hook.Add( "ItemDroped", "catherine.item.hooks.clothing_base.ItemDroped", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "ItemStorageMove", "catherine.item.hooks.clothing_base.ItemStorageMoved", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "ItemVendorSolded", "catherine.item.hooks.weapon_base.ItemVendorSolded", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
end

catherine.item.Register( BASE )