
Base.uniqueID = "weapon_base"
Base.name = "Weapon!"
Base.desc = "A Weapon!"
Base.category = "WEAPON!"
Base.cost = 0
Base.weight = 0
Base.weaponClass = "weapon_smg1"
Base.itemData = {
	equiped = false
}
Base.func = { }
Base.func.equip = {
	text = "Equip this",
	viewIsEntity = true,
	viewIsMenu = true,
	func = function( pl, tab, data )
		
		pl:Give( tab.weaponClass )
		pl:SelectWeapon( tab.weaponClass )
		
		local newData = table.Copy( data )
		newData.equiped = true
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, key = 1, newData = newData } )
		print("Weapon equiped!")
	end
}

Base.func.unequip = {
	text = "Unequip this",
	viewIsMenu = true,
	func = function( pl, tab, data )
		if ( pl:HasWeapon( tab.weaponClass ) ) then
			pl:StripWeapon( tab.weaponClass )
		end
		local newData = table.Copy( data )
		newData.equiped = false
		
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, key = 1, newData = newData } )
		print("Weapon unequiped!")
	end
}