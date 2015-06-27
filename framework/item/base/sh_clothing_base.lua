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
BASE.category = "^Item_Category_Clothing"
BASE.cost = 0
BASE.weight = 0
BASE.itemData = {
	wearing = false
}
BASE.isCloth = true
BASE.useDynamicItemData = false
BASE.func = { }
BASE.func.wear = {
	text = "^Item_FuncStr01_Clothing",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( catherine.character.GetCharVar( pl, "clothWearing" ) ) then
			return
		end
		
		local originalModel = catherine.character.GetCharVar( pl, "originalModel" )
		
		if ( !originalModel ) then
			catherine.character.SetCharVar( pl, "originalModel", pl:GetModel( ) )
		end
		
		local replacement = itemTable.replacement
		local newModel = itemTable.model or ""
		local playerModel = pl:GetModel( ):lower( )
		
		if ( newModel:find( "female" ) or catherine.animation.Get( newModel ) == "citizen_female" and itemTable.femaleModel ) then
			newModel = itemTable.femaleModel
		end

		if ( replacement and #replacement == 2 ) then
			newModel = playerModel:gsub( replacement[ 1 ], replacement[ 2 ] )
		end
		
		if ( type( ent ) == "Entity" ) then
			catherine.item.Give( pl, itemTable.uniqueID )
			ent:Remove( )
		end

		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 100 )
		pl:SetModel( newModel )
		pl:SetupHands( )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", true )
		catherine.character.SetCharVar( pl, "clothWearing", true )
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) and !catherine.character.GetCharVar( pl, "clothWearing" )
	end
}
BASE.func.takeoff = {
	text = "^Item_FuncStr02_Clothing",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		local originalModel = catherine.character.GetCharVar( pl, "originalModel" )
		
		if ( !originalModel ) then
			return
		end
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 100 )
		pl:SetModel( originalModel )
		pl:SetupHands( )
		
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "wearing", false )
		catherine.character.SetCharVar( pl, "clothWearing", nil )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.GetItemData( itemTable.uniqueID, "wearing" ) == true and true or false
	end
}

function BASE:GetDropModel( )
	return "models/props_c17/suitCase_passenger_physics.mdl"
end

if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "catherine.item.hooks.clothing_base.PlayerSpawnedInCharacter", function( pl )
		timer.Simple( 1, function( )
			for k, v in pairs( catherine.inventory.Get( pl ) ) do
				local itemTable = catherine.item.FindByID( k )
				if ( !itemTable.isCloth or !catherine.inventory.GetItemData( pl, k, "wearing" ) ) then continue end
				
				catherine.item.Work( pl, k, "wear" )
			end
		end )
	end )

	hook.Add( "OnItemDrop", "catherine.item.hooks.clothing_base.OnItemDrop", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemStorageMove", "catherine.item.hooks.clothing_base.OnItemStorageMove", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemVendorSold", "catherine.item.hooks.clothing_base.OnItemVendorSold", function( pl, itemTable )
		if ( itemTable.isCloth ) then
			catherine.item.Work( pl, itemTable.uniqueID, "takeoff" )
		end
	end )
	
	hook.Add( "OnItemForceTake", "catherine.item.hooks.clothing_base.OnItemForceTake", function( pl, itemTable )
		if ( itemTable.isCloth ) then
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