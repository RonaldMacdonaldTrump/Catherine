local BASE = catherine.item.New( "CLOTHING", nil, true )
BASE.name = "Clothing Base"
BASE.desc = "A Cloth."
BASE.category = "Clothing"
BASE.cost = 0
BASE.weight = 0
BASE.itemData = {
	wearing = false
}
BASE.func = { }
BASE.func.wear = {
	text = "Wear",
	canShowIsWorld = true,
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
BASE.func.takeoff = {
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

catherine.item.Register( BASE )