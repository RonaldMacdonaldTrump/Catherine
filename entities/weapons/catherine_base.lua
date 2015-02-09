AddCSLuaFile( )

SWEP.Base = "weapon_base"
SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy( )
	return true
end

function SWEP:Holster( )
	return true
end

function SWEP:PrimaryAttack( )
end

function SWEP:SecondaryAttack( )
end

function SWEP:Reload( )
end