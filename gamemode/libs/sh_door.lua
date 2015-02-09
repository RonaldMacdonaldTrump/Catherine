local META = FindMetaTable( "Player" )
local META2 = FindMetaTable( "Entity" )

function META2:IsDoor( )
	if !IsValid( self ) then return false end
	local class = self:GetClass( )
	if ( class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_dynamic" ) then
		return true
	end
	return false
end

if ( SERVER ) then
	function META:BuyDoor( )
		local ent = self:GetEyeTrace( 70 ).Entity
		if ( self:GetCash( ) >= catherine.configs.doorCost or ent:IsDoor( ) or ent:GetOwner( ) == nil ) then
			self:ChatPrint( "You has been bought the door!" )
			ent:SetOwner( self:GetCharacterID( ) )
			self:TakeCash( catherine.configs.doorCost )
		elseif ( self:GetCash( ) <= catherine.configs.doorCost ) then
			self:ChatPrint( "You need" .. ( catherine.configs.doorCost - self:GetCash( ) ) .. catherine.configs.cashName .. "(s) more!" )
		end
	end

	function META:SellDoor( )
		local ent = self:GetEyeTrace( 70 ).Entity
		if ( ent:IsDoor( ) or ent:GetOwner( ) == self:GetCharacterID( ) ) then
			self:ChatPrint( "You has been sold the door!" )
			self:GiveCash( catherine.configs.doorSellCost )
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