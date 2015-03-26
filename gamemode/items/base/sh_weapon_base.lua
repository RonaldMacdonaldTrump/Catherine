local BASE = catherine.item.New( "WEAPON", nil, true )
BASE.name = "Weapon Base"
BASE.desc = "A Weapon."
BASE.category = "Weapon"
BASE.cost = 0
BASE.weight = 0
BASE.isWeapon = true
BASE.weaponClass = "weapon_smg1"
BASE.itemData = {
	equiped = false
}
BASE.func = { }
BASE.func.equip = {
	text = "Equip",
	icon = "icon16/ruby_get.png",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( !catherine.inventory.HasSpace( pl ) and type( ent ) == "Entity" ) then
			catherine.util.Notify( pl, "You don't have inventory space!" )
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
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", true )
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}
BASE.func.unequip = {
	text = "Unequip",
	icon = "icon16/ruby_put.png",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", false )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}

if ( SERVER ) then
	catherine.hooks.Register( "PlayerSpawnedInCharacter", "catherine.item.hooks.weapon_base.PlayerSpawnedInCharacter", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			catherine.item.Work( pl, k, "equip" )
		end
	end )

	catherine.hooks.Register( "PlayerDeath", "catherine.item.hooks.weapon_base.PlayerDeath", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			catherine.item.Work( pl, k, "unequip" )
			catherine.item.Spawn( k, pl:GetPos( ) )
			catherine.item.Take( pl, k )
		end
	end )

	catherine.hooks.Register( "ItemDroped", "catherine.item.hooks.weapon_base.ItemDroped", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
	
	catherine.hooks.Register( "ItemStorageMoved", "catherine.item.hooks.weapon_base.ItemStorageMoved", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
end

catherine.item.Register( BASE )