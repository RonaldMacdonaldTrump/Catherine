Base.uniqueID = "weapon_base"
Base.name = "Weapon!"
Base.desc = "A Weapon!"
Base.category = "Weapon"
Base.cost = 0
Base.weight = 0
Base.weaponClass = "weapon_smg1"
Base.itemData = {
	equiped = false,
	clipOne = 0,
	clipTwo = 0
}

--[[
Base.func = { }
Base.func.equip = {
	text = "Equip this weapon",
	viewIsEntity = true,
	viewIsMenu = true,
	ismenuRightclickFunc = true,
	func = function( pl, tab, data )
		if ( !pl:HasItem( tab.uniqueID ) ) then
			catherine.item.GiveToCharacter( pl, tab.uniqueID )
		end
		local weapon = pl:Give( tab.weaponClass )
		local newData = data or { }
		newData.equiped = true
		if ( IsValid( weapon ) ) then
			pl:SelectWeapon( tab.weaponClass )
			//weapon:SetClip1( newData.clipOne or 0 )
			//weapon:SetClip2( newData.clipTwo or 0 )
		end
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, itemData = newData } )
	end,
	showFunc = function( pl, tab, key )
		if ( pl:IsEquiped( tab.uniqueID ) ) then
			return false
		end
		return true
	end
}
Base.func.unequip = {
	text = "Unequip this weapon",
	viewIsMenu = true,
	func = function( pl, tab, key )
		if ( pl:HasWeapon( tab.weaponClass ) ) then
			pl:StripWeapon( tab.weaponClass )
		end
		local newData = { }
		newData.equiped = false
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, itemData = newData } )
	end,
	showFunc = function( pl, tab, key )
		if ( pl:IsEquiped( tab.uniqueID ) ) then
			return true
		end
		return false
	end
}
Base.func.drop = {
	text = "Drop this weapon",
	viewIsMenu = true,
	func = function( pl, tab, key )
		local eyeTrace = pl:GetEyeTrace( )
		if ( pl:GetPos( ):Distance( eyeTrace.HitPos ) > 100 ) then
			catherine.util.Notify( pl, "You can't drop this item far away!" )
			return
		end
		if ( pl:HasWeapon( tab.weaponClass ) ) then
			pl:StripWeapon( tab.weaponClass )
		end
		local newData = { }
		newData.equiped = false
		catherine.item.Spawn( tab, eyeTrace.HitPos )
		catherine.inventory.Update( pl, "remove", tab.uniqueID )
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, itemData = newData } )
	end,
	viewCre = function( tab, ent, key )
		return !tab.cantDrop
	end


if ( SERVER ) then
	hook.Add( "PlayerSpawn", "weapon_base_PlayerSpawn", function( pl )
		if ( !pl:IsCharacterLoaded( ) ) then return end
		local inv = catherine.inventory.GetInv( pl ) or { }
		for k, v in pairs( inv ) do
			for k1, v1 in pairs( v ) do
				local equiped = catherine.inventory.Equiped( pl, k )
				local itemTab = catherine.item.FindByID( k )
				if ( equiped ) then
					catherine.item.RunFunction( pl, "equip", itemTab )
				end
			end
		end
	end )
	
	hook.Add( "CharacterLoaded", "weapon_base_CharacterLoaded", function( pl )
		if ( !pl:IsCharacterLoaded( ) ) then return end
		local inv = catherine.inventory.GetInv( pl ) or { }
		for k, v in pairs( inv ) do
			for k1, v1 in pairs( v ) do
				local equiped = catherine.inventory.Equiped( pl, k )
				local itemTab = catherine.item.FindByID( k )
				if ( equiped ) then
					catherine.item.RunFunction( pl, "equip", itemTab )
				end
			end
		end
	end )
end

}--]]