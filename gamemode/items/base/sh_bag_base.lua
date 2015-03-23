Base.uniqueID = "bag_base"
Base.name = "Bag Base"
Base.desc = "A Bag."
Base.category = "Storage"
Base.cost = 0
Base.weight = 0
Base.weightPlus = 10
Base.isBag = true
Base.func = { }
Base.func.drop = {
	text = "Drop",
	canShowIsMenu = true,
	canLook = function( pl, itemTable )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( pl )
		return invWeight < ( invMaxWeight - itemTable.weightPlus )
	end
}