local BASE = catherine.item.New( "BAG", nil, true )
BASE.name = "Bag Base"
BASE.desc = "A Bag."
BASE.category = "Storage"
BASE.cost = 0
BASE.weight = 0
BASE.weightPlus = 10
BASE.isBag = true
BASE.func = { }
BASE.func.drop = {
	text = "Drop",
	canShowIsMenu = true,
	canLook = function( pl, itemTable )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( pl )
		return invWeight < ( invMaxWeight - itemTable.weightPlus )
	end
}

catherine.item.Register( BASE )