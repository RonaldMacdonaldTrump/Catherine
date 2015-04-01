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