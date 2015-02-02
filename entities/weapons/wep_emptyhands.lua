AddCSLuaFile( )

SWEP.Base = "wep_base"
SWEP.HoldType = "normal"
SWEP.PrintName = "Empty Hands"
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""

function SWEP:Deploy( )
	local ply = self.Owner
	if ( CLIENT ) or !IsValid( ply ) then return true end
	
	ply:DrawWorldModel( false )
	
	return true
end

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end


function SWEP:CanPrimaryAttack( )
	return false
end


function SWEP:CanSecondaryAttack( )
	return false
end

