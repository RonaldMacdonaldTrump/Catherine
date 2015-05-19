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
		
		if ( type( ent ) == "Entity" ) then
			catherine.item.Give( pl, itemTable.uniqueID )
			ent:Remove( )
		end
		
		local wep = pl:Give( itemTable.weaponClass )
		
		if ( IsValid( wep ) ) then
			pl:SelectWeapon( itemTable.weaponClass )
			wep:SetClip1( 0 )
		end

		catherine.attachment.Refresh( pl )
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
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
		
		catherine.attachment.Refresh( pl )
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", false )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}

if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "catherine.item.hooks.weapon_base.PlayerSpawnedInCharacter", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			catherine.item.Work( pl, k, "equip" )
		end
	end )

	hook.Add( "PlayerDeath", "catherine.item.hooks.weapon_base.PlayerDeath", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			catherine.item.Work( pl, k, "unequip" )
			catherine.item.Spawn( k, pl.GetPos( pl ) )
			catherine.item.Take( pl, k )
		end
	end )

	hook.Add( "OnItemDrop", "catherine.item.hooks.weapon_base.OnItemDrop", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	hook.Add( "OnItemStorageMove", "catherine.item.hooks.weapon_base.OnItemStorageMove", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	hook.Add( "OnItemVendorSold", "catherine.item.hooks.weapon_base.OnItemVendorSold", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
end

catherine.item.Register( BASE )