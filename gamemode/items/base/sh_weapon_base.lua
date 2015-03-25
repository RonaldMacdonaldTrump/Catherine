Base.uniqueID = "weapon_base"
Base.name = "Weapon Base"
Base.desc = "A Weapon."
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
Base.func.unequip = {
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
	catherine.item.RegisterNyanHook( "PlayerSpawnedInCharacter", "catherine.item.hooks.weapon_base.PlayerSpawnedInCharacter", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			catherine.item.Work( pl, k, "equip" )
		end
	end )
	
	catherine.item.RegisterNyanHook( "PlayerDeath", "catherine.item.hooks.weapon_base.PlayerDeath", function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			if ( !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			catherine.item.Work( pl, k, "unequip" )
			catherine.item.Spawn( k, pl:GetPos( ) )
			catherine.item.Take( pl, k )
		end
	end )

	catherine.item.RegisterNyanHook( "ItemDroped", "catherine.item.hooks.weapon_base.ItemDroped", function( pl, itemTable )
		if ( !itemTable.isWeapon ) then return end
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
	end )
end