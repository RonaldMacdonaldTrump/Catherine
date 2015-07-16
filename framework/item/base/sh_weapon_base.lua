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

local BASE = catherine.item.New( "WEAPON", nil, true )
BASE.name = "Weapon Base"
BASE.desc = "A Weapon."
BASE.category = "^Item_Category_Weapon"
BASE.cost = 0
BASE.weight = 0
BASE.isWeapon = true
BASE.weaponClass = "weapon_smg1"
BASE.itemData = {
	equiped = false
}
BASE.weaponType = "primary"
BASE.attachmentLimit = {
	primary = 1,
	secondary = 1,
	melee = 1
}
BASE.func = { }
BASE.func.equip = {
	text = "^Item_FuncStr01_Weapon",
	icon = "icon16/ruby_get.png",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) and type( ent ) == "Entity" ) then
			catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
			return
		end
		
		local playerWeaponType = catherine.character.GetCharVar( pl, "equippingWeaponTypes", { } )
		local itemWeaponType = itemTable.weaponType

		if (
			playerWeaponType[ itemWeaponType ] and
			( !itemTable.attachmentLimit[ itemWeaponType ] or
			playerWeaponType[ itemWeaponType ] >= itemTable.attachmentLimit[ itemWeaponType ] )
		) then
			catherine.util.NotifyLang( pl, "Item_Notify01_Weapon" )
			return
		end
		
		if ( type( ent ) == "Entity" ) then
			catherine.item.Give( pl, itemTable.uniqueID )
			ent:Remove( )
		end

		local wep = pl:Give( itemTable.weaponClass )
		
		if ( IsValid( wep ) ) then
			pl:SelectWeapon( itemTable.weaponClass )
			wep:SetClip1( 0 )
		end

		if ( playerWeaponType[ itemWeaponType ] ) then
			playerWeaponType[ itemWeaponType ] = playerWeaponType[ itemWeaponType ] + 1
		else
			playerWeaponType[ itemWeaponType ] = 1
		end

		catherine.attachment.Refresh( pl )
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", playerWeaponType )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", true )
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}
BASE.func.unequip = {
	text = "^Item_FuncStr02_Weapon",
	icon = "icon16/ruby_put.png",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		local playerWeaponType = catherine.character.GetCharVar( pl, "equippingWeaponTypes", { } )
		local itemWeaponType = itemTable.weaponType

		if ( playerWeaponType[ itemWeaponType ] ) then
			playerWeaponType[ itemWeaponType ] = playerWeaponType[ itemWeaponType ] - 1
			
			if ( playerWeaponType[ itemWeaponType ] <= 0 ) then
				playerWeaponType[ itemWeaponType ] = nil
			end
		end
		
		catherine.attachment.Refresh( pl )
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", playerWeaponType )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", false )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}

if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "catherine.item.hooks.weapon_base.PlayerSpawnedInCharacter", function( pl )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", { } )
		
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable.isWeapon or !catherine.inventory.IsEquipped( pl, k ) ) then continue end

			catherine.item.Work( pl, k, "equip" )
		end
		
		timer.Simple( 0.8, function( )
			if ( catherine.configs.giveHand and pl:HasWeapon( "cat_fist" ) ) then
				pl:SelectWeapon( "cat_fist" )
			end
		end )
	end )
	
	hook.Add( "CharacterLoadingStart", "catherine.item.hooks.weapon_base.CharacterLoadingStart", function( pl )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", { } )
	end )

	hook.Add( "PlayerDeath", "catherine.item.hooks.weapon_base.PlayerDeath", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			catherine.item.Work( pl, k, "unequip" )
			catherine.item.Spawn( k, pl:GetPos( ) )
			catherine.item.Take( pl, k )
		end
	end )

	hook.Add( "OnItemDrop", "catherine.item.hooks.weapon_base.OnItemDrop", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end

		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	hook.Add( "OnItemStorageMove", "catherine.item.hooks.weapon_base.OnItemStorageMove", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end

		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	hook.Add( "OnItemVendorSold", "catherine.item.hooks.weapon_base.OnItemVendorSold", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	hook.Add( "OnItemForceTake", "catherine.item.hooks.weapon_base.OnItemForceTake", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
else
	function BASE:DoRightClick( pl, itemData )
		local uniqueID = self.uniqueID
		
		if ( catherine.inventory.IsEquipped( uniqueID ) ) then
			catherine.item.Work( uniqueID, "unequip", true )
		else
			catherine.item.Work( uniqueID, "equip", true )
		end
	end
end

catherine.item.Register( BASE )