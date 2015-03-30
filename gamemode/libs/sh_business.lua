catherine.business = catherine.business or { }

if ( SERVER ) then
	function catherine.business.BuyItems( pl, shipLists )
		if ( !IsValid( pl ) or !shipLists ) then return end
		
		local cost = 0
		for k, v in pairs( shipLists ) do
			local itemTable = catherine.item.FindByID( v.uniqueID )
			if ( !itemTable ) then continue end
			cost = cost + ( itemTable.cost * v.count )
		end
		
		if ( catherine.cash.Get( pl ) < cost ) then
			print("You don't have cash!")
			return
		end
		
		catherine.cash.Take( pl, cost )
		--[[
		local ent = ents.Create( "cat_shipment" )
		ent:SetPos( Vector( pos.x, pos.y, pos.z + 10 ) )
		ent:SetAngles( Angle( ) )
		ent:Spawn( )
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:InitializeShipment( pl, shipLists )
		
		local physObject = ent:GetPhysicsObject( )
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
		--]]
	end
	
	netstream.Hook( "catherine.business.BuyItems", function( pl, data )
		catherine.business.BuyItems( pl, data )
	end
else
	netstream.Hook( "catherine.business.EntityUseMenu", function( data )
		local ent = Entity( data )
		
		if ( IsValid( catherine.vgui.shipment ) ) then
			catherine.vgui.shipment:Remove( )
			catherine.vgui.shipment = nil
		end
	end
end