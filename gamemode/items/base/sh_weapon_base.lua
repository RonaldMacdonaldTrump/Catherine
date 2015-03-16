Base.uniqueID = "weapon_base"
Base.name = "Weapon!"
Base.desc = "A Weapon!"
Base.category = "Weapon"
Base.cost = 0
Base.weight = 0
Base.isWeapon = true
Base.weaponClass = "weapon_smg1"
Base.itemData = {
	equiped = false
}
Base.func = { }
Base.func.equip = {
	text = "Equip",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, isMenu )
		if ( !catherine.inventory.HasSpace( pl ) and type( isMenu ) == "Entity" ) then
			catherine.util.Notify( pl, "You don't have inventory space!" )
			return
		end
		if ( type( isMenu ) == "Entity" ) then
			catherine.item.Give( pl, itemTable.uniqueID )
			isMenu:Remove( )
		end
		
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		itemData.equiped = true
		
		local wep = pl:Give( itemTable.weaponClass )
		if ( IsValid( wep ) ) then
			pl:SelectWeapon( itemTable.weaponClass )
			wep:SetClip1( 0 )
		end
		
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = itemTable.uniqueID,
			newData = itemData
		} )
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.IsEquiped( itemTable.uniqueID )
	end
}
Base.func.unequip = {
	text = "Unequip",
	canShowIsMenu = true,
	func = function( pl, itemTable, isMenu )
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		itemData.equiped = false
		
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = itemTable.uniqueID,
			newData = itemData
		} )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.IsEquiped( itemTable.uniqueID )
	end
}

if ( SERVER ) then
	catherine.item.RegisterNyanHook( "PlayerSpawnedInCharacter", "catherine.item.hooks.weapon_base.PlayerSpawnedInCharacter", function( pl )
		local inventory = catherine.inventory.Get( pl )
		for k, v in pairs( inventory ) do
			if ( catherine.inventory.IsEquiped( pl, k ) ) then
				catherine.item.RunFunction( pl, k, "equip" )
			end
		end
	end )
	
	catherine.item.RegisterNyanHook( "PlayerDeath", "catherine.item.hooks.weapon_base.PlayerDeath", function( pl )
		local inventory = catherine.inventory.Get( pl )
		for k, v in pairs( inventory ) do
			if ( catherine.inventory.IsEquiped( pl, k ) ) then
				catherine.item.RunFunction( pl, k, "unequip" )
				catherine.item.Spawn( pl, k, pl:GetPos( ) )
				catherine.item.Take( pl, k )
			end
		end
	end )

	catherine.item.RegisterNyanHook( "ItemDroped", "catherine.item.hooks.weapon_base.ItemDroped", function( pl, itemTable )
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		catherine.item.RunFunction( pl, itemTable.uniqueID, "unequip" )
	end )
end