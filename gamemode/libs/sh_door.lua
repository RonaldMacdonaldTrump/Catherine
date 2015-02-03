local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function META:BuyDoor( )
		local ent = self:GetEyeTrace( 70 ).Entity
		if ( self:GetCash( ) >= nexus.configs.doorCost or ent:IsDoor( ) or ent:GetOwner( ) == nil ) then
			self:ChatPrint( "You has been bought the door!" )
			ent:SetOwner( self:GetCharacterID( ) )
			self:TakeCash( nexus.configs.doorCost )
		elseif ( self:GetCash( ) <= nexus.configs.doorCost ) then
			self:ChatPrint( "You need" .. ( nexus.configs.doorCost - self:GetCash( ) ) .. nexus.configs.cashName .. "(s) more!" )
		end
	end

	function META:SellDoor( )
		local ent = self:GetEyeTrace( 70 ).Entity
		if ( ent:IsDoor( ) or ent:GetOwner( ) == self:GetCharacterID( ) ) then
			self:ChatPrint( "You has been sold the door!" )
			self:GiveCash( nexus.configs.doorSellCost )
			ent:SetOwner( nil )
		else
			self:ChatPrint( "You don't have a permission!" )
		end
	end

	function META:SetDoorTitle( args )
		local ent = self:GetEyeTrace( 70 ).Entity
		if ( ent:IsDoor( ) or ent:GetOwner( ) == self:GetCharacterID( ) ) then
			ent:SetNetworkValue( "Title", args )
		end
	end

	concommand.Add( "DoorSetTitle", function( cmd, args ) 
		ent:SetDoorTitle( tostring( args[ 1 ] ) )
	end )
end