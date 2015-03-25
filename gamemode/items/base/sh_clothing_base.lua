/*
Base.uniqueID = "clothing_base"
Base.name = "Clothing"
Base.desc = "A Cloth."
Base.category = "Clothing"
Base.modelmale = "models/humans/group01/male_01.mdl"
Base.modelfemale = "models/humans/group01/female_01.mdl"
Base.cost = 0
Base.weight = 0
Base.itemData = {
	wearing = false
}
Base.func = { }
Base.func.wear = {
	text = "Wear",
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
	end,
	canLook = function( pl, itemTable )
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		if ( itemData.wearing ) then
			return itemData.wearing
		end
		return true
	end
}
Base.func.takeoff = {
	text = "Take off",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )

	end,
	canLook = function( pl, itemTable )
		local itemData = catherine.inventory.GetItemData( pl, itemTable.uniqueID )
		if ( itemData.wearing ) then
			return itemData.wearing
		end
		return true
	end
}
*/