Item.name = "Wallet"
Item.desc = catherine.configs.cashName .. " in a small stack."
Item.category = "Wallet"
Item.model = catherine.configs.cashModel
Item.cost = 0
Item.weight = 0.5
Item.itemData = {
	amount = 0
}
Item.func = { }
Item.func.take = {
	text = "Take " .. catherine.configs.cashName,
	icon = "icon16/money_add.png",
	canShowIsWorld = true,
	func = function( pl, itemTable, ent )
		if ( !IsValid( ent ) ) then
			catherine.util.Notify( pl, "This isn't a valid entity!" )
			return
		end
		local itemData = ent:GetItemData( )
		catherine.cash.Give( pl, itemData.amount )
		ent:Remove( )
	end,
	canLook = function( )
		return true
	end
}
Item.func.drop = {
	text = "Drop " .. catherine.configs.cashName,
	icon = "icon16/money_delete.png",
	canShowIsMenu = true,
	func = function( pl, itemTable, isMenu )
		local eyeTr = pl:GetEyeTrace( )
		if ( pl:GetPos( ):Distance( eyeTr.HitPos ) > 100 ) then
			catherine.util.Notify( pl, "You can't do that!" )
			return
		end
		catherine.util.UniqueStringReceiver( pl, "Cash_UniqueDropMoney", "What amount for drop money?", "", catherine.cash.Get( pl ), function( _, val )
			val = tonumber( val )
			if ( !val ) then return end
			if ( catherine.cash.Get( pl ) < val or val <= 0 ) then
				catherine.util.Notify( pl, "You can't do that!" )
				return
			end
			catherine.cash.Take( pl, val )
			catherine.item.Spawn( itemTable.uniqueID, eyeTr.HitPos, nil, { amount = val } )
		end )
	end,
	canLook = function( pl )
		return catherine.cash.Get( pl ) > 0
	end
}

if ( SERVER ) then
	catherine.item.RegisterNyanHook( "PlayerSpawnedInCharacter", "catherine.item.hooks.wallet.PlayerSpawnedInCharacter", function( pl )
		if ( catherine.inventory.HasItem( pl, "wallet" ) ) then return end
		catherine.item.Give( pl, "wallet" )
	end )
else
	function Item:GetDesc( pl, itemTable, itemData, isInv )
		return ( isInv and "You have " .. catherine.cash.GetName( catherine.cash.Get( pl ) ) .. "!" or catherine.cash.GetName( itemData.amount ) )
	end
end