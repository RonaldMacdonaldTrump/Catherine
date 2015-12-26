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

catherine.business = catherine.business or { }

if ( SERVER ) then
	function catherine.business.BuyItems( pl, shipLists )
		if ( !IsValid( pl ) or !shipLists ) then return end
		local cost = 0
		
		for k, v in pairs( shipLists ) do
			local itemTable = catherine.item.FindByID( k )
			
			if ( !itemTable ) then
				table.remove( shipLists, k )
				continue
			end
			
			if ( itemTable.ShowOnBusiness and itemTable:ShowOnBusiness( pl ) == false ) then
				table.remove( shipLists, k )
				continue
			end
			
			if ( ( !itemTable.ShowOnBusiness or itemTable:ShowOnBusiness( pl ) == false ) and !table.HasValue( itemTable.onBusinessFactions or { }, pl:Team( ) ) ) then
				table.remove( shipLists, k )
				continue
			end
			
			cost = cost + ( itemTable.cost * v )
		end
		
		if ( table.Count( shipLists ) <= 0 ) then
			// Need to add Notify code
			return
		end
		
		if ( !catherine.cash.Has( pl, cost ) ) then
			catherine.util.NotifyLang( pl, "Cash_Notify_HasNot", catherine.cash.GetOnlySingular( ) )
			return
		end
		
		local ent = ents.Create( "cat_shipment" )
		ent:SetPos( catherine.util.GetItemDropPos( pl ) )
		ent:SetAngles( Angle( ) )
		ent:Spawn( )
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:InitializeShipment( pl, shipLists )
		
		local physObject = ent:GetPhysicsObject( )
		
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
		
		catherine.cash.Take( pl, cost )
		netstream.Start( pl, "catherine.business.Result", true )
	end
	
	netstream.Hook( "catherine.business.BuyItems", function( pl, data )
		catherine.business.BuyItems( pl, data )
	end )
	
	netstream.Hook( "catherine.business.RemoveShipment", function( pl, data )
		data = Entity( data )
		
		if ( IsValid( data ) ) then
			data:Remove( )
		end
	end )
else
	netstream.Hook( "catherine.business.Result", function( data )
		if ( data == true and IsValid( catherine.vgui.business ) ) then
			catherine.vgui.business:Close( )
		end
	end )
	
	netstream.Hook( "catherine.business.EntityUseMenu", function( data )
		local ent = Entity( data )
		
		if ( IsValid( catherine.vgui.shipment ) ) then
			catherine.vgui.shipment:Remove( )
			catherine.vgui.shipment = nil
		end
		
		catherine.vgui.shipment = vgui.Create( "catherine.vgui.shipment" )
		catherine.vgui.shipment:InitializeShipment( ent, ent:GetShipLists( ) )
	end )
end