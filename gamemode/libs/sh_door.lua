local META = FindMetaTable( "Player" )

if ( SERVER ) then

local ent = ply:GetEyeTrace(70).Entity

function META:BuyDoor( )

	if self:GetCash( ) => nexus.configs.doorCost or ent:IsDoor( ) or ent:GetOwner( ) == nil then
		self:ChatPrint( "You has been bought the door!" )
		ent:SetOwner( self:GetCharacterID( ) )
		self:TakeCash( nexus.configs.doorCost )
	elseif self:GetCahs( ) =< nexus.configs.doorCost then
		self:ChatPrint( "You need" ..  ( nexus.configs.doorCost  - self:GetCash ) .. nexus.configs.cashName .. "(s) more!" )
	end

end

function META:SellDoor( )

	if ent:IsDoor( ) or ent:GetOwner( ) == self:GetCharacterID( ) then
		self:ChatPrint( "You has been sold the door!" )
		self:GiveCash( nexus.configs.doorSellCost )
		ent:SetOwner( nil )
	else
		self:ChatPrint( "You don't have a permission!" )
	end
end

function META:SetDoorTitle( args )

	if ent:IsDoor( ) or ent:GetOwner( ) == self:GetCharacterID( ) then
		ent:SetNWInt( "title", args  )
	end

end

concommand.Add( "DoorSetTitle", function( cmd, args ) 
	ent:SetDoorTitle( tonumber(args[1]) )
end

end